import requests
from bs4 import BeautifulSoup
from argparse import ArgumentParser
import subprocess as sp
import tempfile
import os
from multiprocessing.pool import ThreadPool
import json
import logging
import re
import string
import time


class Progress:
    def __init__(self, total):
        self.done = 0
        self.failed = 0
        self.total = total

    def __repr__(self):
        return f'Tasks: {self.done: 5d} done, {self.failed: 5d} failed of {self.total: 5d}'


special_characters = (
    set(string.printable) -
    set(string.ascii_letters) -
    set(string.digits) -
    set('-_')
)

header = '''<!DOCTYPE html>
<html lang="de">
<head>
  <meta charset="utf-8">
  <title>{title}</title>
  <meta name="author" content="{author}">
  <meta name="date" content="{year}">
  <meta name="publisher" content="{publisher}">
  <meta name="volume" content="{volume}">
</head>
<body>
'''

footer = '''
</body>
</html>
'''
metadata_xml = '''
<?xml version="1.0" enconding="UTF-8"?>
<dc:title>{title}</dc:title>
<dc:creator>{author}</dc:creator>
<dc:date>{year}</dc:date>
<dc:publisher>{publisher}</dc:publisher>
<dc:language>de-DE</dc:language>
<dc:source>{url}</dc:source>
<dc:type>{type}</dc:type>
'''

metadata_keys = ['author', 'year', 'title', 'publisher', 'translator', 'type', 'volume']

parser = ArgumentParser()
subparsers = parser.add_subparsers(dest='command')
subparsers.required = True

parser_all = subparsers.add_parser('all')
parser_all.add_argument('outputpath')

parser_author = subparsers.add_parser('author')
parser_author.add_argument('url')
parser_author.add_argument('outputpath')

parser_title = subparsers.add_parser('title')
parser_title.add_argument('url')
parser_title.add_argument('outputpath')


baseurl = 'http://gutenberg.spiegel.de'


def parse_metadata(soup):
    metadata_div = soup.find('div', {'id': 'metadata'})
    rows = metadata_div.find_all('tr')
    metadata = {}
    for row in rows:
        key, value = map(lambda c: c.text.strip(), row.find_all('td'))
        metadata[key] = value
    for key in metadata_keys:
        if key not in metadata:
            metadata[key] = ''
    return metadata


def parse_chapters(soup):
    navbar = soup.find('ul', {'class': 'gbnav'}).find('ul')
    chapters = [l.find('a')['href'] for l in navbar.find_all('li')]
    return chapters


def download_image(outdir, base, url):
    os.makedirs(os.path.join(outdir, os.path.dirname(url)), exist_ok=True)
    r = requests.get(base + url)
    with open(os.path.join(outdir, url), 'wb') as f:
        f.write(r.content)
    

def download_images(outdir, soup):
    base = soup.find('base')['href']

    images = [
        img['src'] for img in
        soup.find('div', {'id': 'gutenb'}).find_all('img')
    ]

    for image in images:
        try:
            download_image(outdir, base, image)
        except Exception as e:
            print(f'Could not save img {base}/{url}')


def sanitize_filename(filename):
    filename, ext = os.path.splitext(filename)
    filename = filename.lower()
    for special_char in special_characters:
        filename = filename.replace(special_char, '_')
    return re.sub('_(_)+', '_', filename) + ext


def convert_to_epub(url, outputpath):
    soup = to_soup(url)

    metadata = parse_metadata(soup)
    chapter_urls = parse_chapters(soup)

    if os.path.isdir(outputpath):
        outputpath = os.path.join(
            outputpath,
            sanitize_filename(metadata['title'] + '.epub')
        )

    if os.path.isfile(outputpath):
        print(f'Already converted {url}')
        return

    with tempfile.TemporaryDirectory() as tmpdir:

        with open(os.path.join(tmpdir, 'metadata.xml'), 'wb') as f:
            f.write(
                metadata_xml.format(url=url, **metadata).encode('utf-8')
            )

        with open(os.path.join(tmpdir, 'content.html'), 'wb') as html:
            html.write(header.format(**metadata).encode('utf-8'))
            for chapter_url in chapter_urls:
                soup = to_soup(baseurl + chapter_url)
                text = soup.find('div', {'id': 'gutenb'}).encode('utf-8')
                html.write(text)

                download_images(tmpdir, soup)

            html.write(footer.encode('utf-8'))

        p = sp.run(
            [
                'pandoc',
                '-o', outputpath,
                '--epub-metadata={}'.format('metadata.xml'),
                'content.html',
            ],
            stdout=sp.PIPE, stderr=sp.PIPE,
            encoding='utf-8',
            cwd=tmpdir,
        )
        if p.returncode != 0:
            print(f'Could not convert {url} to epub because of pandoc error')

        if p.stderr:
            print(p.stderr)


def to_soup(url):
    r = requests.get(url)
    r.raise_for_status()
    return BeautifulSoup(r.text, 'lxml')


def get_all_urls():
    soup = to_soup(baseurl + '/autor')
    author_urls = [
        a for a in soup.find('div', {'id': 'spTeaserColumn'}).find_all('a')
    ]

    authors = [a.text for a in author_urls]
    author_urls = [a['href'] for a in author_urls]

    with ThreadPool(50) as pool:
        urls = []
        for i, res in enumerate(pool.imap(get_archived_works, author_urls), start=1):
            urls.append(res)
            print(f'Done {i} of {len(authors)} authors')

    return dict(zip(authors, urls))


def get_archived_works(url):
    if not url.startswith('http'):
        url = baseurl + url
    soup = to_soup(url)
    archived_works = soup.find('div', {'class': 'archived'})

    if archived_works is None:
        return []

    return [
        baseurl + '/' + l.find('a')['href'].replace('../', '')
        for l in archived_works.find_all('li')
        if l.find('a') and 'hide' not in l.get('class', [])
    ]


def convert_author(author, urls, outputpath, progress):
    os.makedirs(outputpath, exist_ok=True)

    for url in urls:
        try:
            convert_to_epub(url, outputpath)
            progress.done += 1
        except Exception as e:
            logging.exception(f"Could not convert url {url}")
            progress.failed += 1


def main():
    args = parser.parse_args()

    if args.command == 'all':
        args.outputpath = os.path.abspath(args.outputpath)

        if not os.path.isfile('authors.json'):
            print('Getting all works from gutenberg-de, this may take a while')
            authors = get_all_urls()
            with open('authors.json', 'w') as f:
                json.dump(authors, f)
        else:
            with open('authors.json', 'r') as f:
                authors = json.load(f)

        for author, urls in authors.items():
            if len(urls) > 0:
                if any('xmlbyid' in s for s in urls):
                    print(author)

        total = sum(map(len, authors.values()))
        print('Found {} works of {} authors'.format(
            len(authors), total
        ))

        os.makedirs(args.outputpath, exist_ok=True)
        print('Start converting to ebooks')

        progress = Progress(total)

        def convert(author, urls):
            try:
                if author:
                    outputpath = os.path.join(
                        args.outputpath,
                        author[0].lower(),
                        sanitize_filename(author)
                    )
                else:
                    outputpath = os.path.join(args.outputpath, 'unknown')
                convert_author(author, urls, outputpath, progress)
            except Exception as e:
                logging.exception(f'Could not convert {author}')
            return len(urls)

        with ThreadPool(10) as pool:
            res = pool.starmap_async(convert, authors.items())
            while not res.ready():
                print(progress, end='\r')
                time.sleep(10)
            print()

    elif args.command == 'author':
        args.outputpath = os.path.abspath(args.outputpath)

        soup = to_soup(args.url)
        author = soup.find('h2', {'class': 'name'}).text
        urls = get_archived_works(args.url)

        total = len(urls)
        print(f'Found {total} works')

        os.makedirs(args.outputpath, exist_ok=True)
        print('Start converting to ebooks')

        progress = Progress(total)

        def success(arg):
            progress.done += 1

        def error(arg):
            print(arg)
            progress.failed += 1

        with ThreadPool(10) as pool:
            res = []
            for url in urls:
                res.append(pool.apply_async(
                    convert_to_epub,
                    args=(url, args.outputpath),
                    callback=success, error_callback=error,
                ))
            while any(not r.ready() for r in res):
                print(progress, end='\r')
                time.sleep(10)
            print()

    elif args.command == 'title':
        convert_to_epub(args.url, os.path.abspath(args.outputpath))


if __name__ == "__main__":
    main()
