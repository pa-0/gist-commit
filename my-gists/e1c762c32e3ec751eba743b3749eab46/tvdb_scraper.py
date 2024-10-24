import argparse
import asyncio
import re
from functools import reduce
from itertools import chain
from operator import attrgetter
from typing import Dict, NamedTuple

import aiohttp
import bs4
import pyclip
import requests
import tqdm
import tqdm.asyncio


def sanitize_filename(filename: str) -> str:
    subs: dict[str, str] = {
        r'\?': '',  # remove question marks
        r':': ' -',  # replace colons
        r'[´`"‘’]': "'",  # replace wrong apostrophes
        r'[‒–—―]': "-",  # replace dashes (figure dash, en dash, em dash, horizontal bar)
        r'…': '...',  # replace ellipsis
    }

    return reduce(lambda acc, pattern_repl: re.sub(*pattern_repl, acc), subs.items(), filename)


class EpisodeLink(NamedTuple):
    season: int
    number_in_season: int
    episode_url: str


class Episode(NamedTuple):
    show: str
    season: int
    number_in_season: int
    titles: Dict[str, str]


def parse_range_list(ranges: str) -> [int]:
    """Parses a list of comma-separated ranges. E.g. 1,2,5-7
    https://gist.github.com/kgaughan/2491663#gistcomment-2683607"""

    def parse_range(range_str: str) -> range:
        if len(range_str) == 0:
            return []
        limits = range_str.split("-")
        if len(limits) > 2:
            raise ValueError(f"Invalid range: {range_str}")
        return range(int(limits[0]), int(limits[-1]) + 1)

    return sorted(set(chain.from_iterable(map(parse_range, ranges.split(",")))))


def parse_show_breadcrumbs(bc_tag: bs4.Tag) -> {str: str}:
    breadcrumbs_pattern = re.compile(r"/\s*(?P<title>.+?)\s*/\s*(?P<order>\w+ Order)\s*/")
    return breadcrumbs_pattern.search(bc_tag.text).groupdict()


def parse_episode_breadcrumbs(bc_tag: bs4.Tag) -> {str: str}:
    breadcrumbs_pattern = re.compile(
        r"/\s*(?P<title>.+?)\s*/\s*(?P<order>\w+ Order)\s*/\s*Season (?P<season>\d+)\s*/\s*Episode (?P<episode>\d+)")
    crumbs = breadcrumbs_pattern.search(bc_tag.text).groupdict()
    return crumbs


def parse_episode_header(episode_header: bs4.Tag) -> EpisodeLink:
    try:
        episode_id = re.search(r"S(?P<season>\d+)E(?P<episode>\d+)", episode_header.parent.text).groupdict()
    except AttributeError as e:
        episode_id = re.search(r"SPECIAL (?P<season>\d+)x(?P<episode>\d+)", episode_header.parent.text).groupdict()
    episode_link = f"https://thetvdb.com{episode_header.get('href')}"

    return EpisodeLink(season=int(episode_id['season']), number_in_season=int(episode_id['episode']),
                       episode_url=episode_link)


async def parse_episode(session: aiohttp.ClientSession, episode_url: str) -> Episode:
    async with session.get(episode_url) as resp:
        episode_html = await resp.text()

    episode_soup = bs4.BeautifulSoup(episode_html, features="html.parser")

    # Home / Series / {title} / {order} / Season 1 / Episode 1
    crumbs = parse_episode_breadcrumbs(episode_soup.select_one('.crumbs'))

    episode_languages = \
        {tag['data-language']: tag['data-title'].strip() for tag in episode_soup(class_='change_translation_text')}

    return Episode(crumbs['title'], int(crumbs['season']), int(crumbs['episode']), episode_languages)


async def scrape_episodes(episode_links):

    async with aiohttp.ClientSession() as session:

        tasks = []
        for episode_link in episode_links:
            tasks.append(asyncio.ensure_future(parse_episode(session, episode_link.episode_url)))

        episodes = [await episode_parsed for episode_parsed in tqdm.asyncio.tqdm.as_completed(tasks)]
    return episodes


def episode_to_string(
        episode: Episode,
        language: str = 'deu',
        original_language: str = 'eng') -> str:
    if language in episode.titles and original_language in episode.titles:
        return f"{episode.show} - {episode.season}x{episode.number_in_season:02d} {episode.titles[language]} ({episode.titles[original_language]})"
    else:
        episode_title = episode.titles.get(language, episode.titles.get(original_language, ""))
        return f"{episode.show} - {episode.season}x{episode.number_in_season:02d} {episode_title}"


def episode_to_filename(
        episode: Episode,
        language: str = 'deu',
        original_language: str = 'eng',
        file_extension: str = 'mkv') -> str:
    return sanitize_filename(episode_to_string(episode, language, original_language) + '.' + file_extension.lstrip('.'))


def url_join(left: str, right: str) -> str:
    return left.rstrip('/') + '/' + right.lstrip('/')


async def main(argv=None):
    parser = argparse.ArgumentParser(argv)
    parser.add_argument("show_url", help="TheTVDB-URL of tv-show (e.g. https://thetvdb.com/series/ted-lasso)")
    parser.add_argument("-c", "--to-clipboard", help="Copies the result to the clipboard.", action='store_true')
    parser.add_argument('-e', '--file-extension', help="File-extension used for generated filenames.", default='mkv')
    parser.add_argument('-s', '--seasons', help="Range of seasons to parse")

    args = parser.parse_args()

    # Setup

    all_episodes_url = url_join(args.show_url, "/allseasons/official")

    # Acquiring links
    html = requests.get(all_episodes_url).text
    soup = bs4.BeautifulSoup(html, features="html.parser")

    episode_headers = soup(href=re.compile("/episodes/"), string=lambda s: s is not None)
    episode_links = [parse_episode_header(episode_header) for episode_header in episode_headers]

    if args.seasons:
        season_to_parse = parse_range_list(args.seasons)
        filter_ = lambda link: link.season in season_to_parse
        num_seasons_to_parse = "selected"
    else:
        filter_ = lambda link: True
        num_seasons_to_parse = len(soup('h3'))

    episode_links = list(filter(filter_, episode_links))

    # Scraping episodes
    # "Home / Series / {title} / {order} /"
    show_title = parse_show_breadcrumbs(soup.find(class_='crumbs'))['title']

    number_of_episodes = len(episode_links)

    print(f'Found {number_of_episodes} episodes in {num_seasons_to_parse} seasons for "{show_title}".')
    if input(f"Continue scraping {number_of_episodes} episodes? ('n' to abort.)").lower() == 'n':
        print("Abort scraping...")
        exit()

    episodes = await scrape_episodes(episode_links)

    episodes.sort(key=attrgetter('season', 'number_in_season'))

    episode_filenames = [episode_to_filename(episode, file_extension=args.file_extension) for episode in episodes]
    # Output
    for episode_filename in episode_filenames:
        print(episode_filename)

    if args.to_clipboard:
        print("Copying filenames to clipboard.", end=' ')
        pyclip.copy('\n'.join(episode_filenames))
        print("Done.")


if __name__ == '__main__':
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())
    asyncio.run(main())
