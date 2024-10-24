#!/usr/bin/env python3
"""hg-bb-to-github - Transfer from BitBucket Mercurial to GitHub.
Populate authors file with any author mappings you'd like to clean up at the
time. The file should contain lines like:
"Michael Lenzen <mlenzen@corp.com>"="Michael Lenzen <m.lenzen@gmail.com>"
"Michael Lenzen m.lenzen@gmail.com"="Michael Lenzen <m.lenzen@gmail.com>"
"""
from pathlib import Path
import subprocess
from typing import List, Union

import click

GITIG = '.gitignore'
HGIG = '.hgignore'
HG_FAST_EXPORT = Path.home() / '.local' / 'src' / 'fast-export' / 'hg-fast-export.sh'
PathLike = Union[Path, str]


class Error(Exception): ...


def echo(s: str, color='bright_blue'):
    click.secho('\n' + s, fg=color)


def run(*args, check=True, **kwargs):
    echo(' '.join(str(arg) for arg in args[0]))
    return subprocess.run(*args, check=check, **kwargs)


def _validate_dst(path) -> bool:
    """Validate destination path."""
    """Validate destination path, return if is is "fresh"."""
    if not path.exists():
        path.mkdir(parents=True)
        return True
    if not path.is_dir():
        raise Error('Destination path already exists and is not a directory')
    if not any(path.iterdir()):
        # It is an empty dir
        return True
    if not (path / '.git').exists():
        raise Error('Destination path already exists and does not contain a git repo.')
    return False


def move_repo(
        name: str,
        bitbucket_user: str,
        github_user: str,
        code_dir: Path,
        authors: Path,
        ):
    """Move a repository from BitBucket to GitHub."""
    gh_url = f'git@github.com:{github_user}/{name}.git'
    src_path = code_dir / 'bitbucket-hg-archive' / name
    dst_path = code_dir / name
    dst_fresh = _validate_dst(dst_path)

    # src_path.mkdir(exist_ok=True, parents=True)
    try:
        bb_url = f'ssh://hg@bitbucket.org/{bitbucket_user}/{name}'
        run(('hg', 'clone', bb_url, src_path))
    except subprocess.CalledProcessError:
        # A git repo, not hg
        bb_url = f'git@bitbucket.org:{bitbucket_user}/{name}.git'
        _move_git_repo(dst_path, bb_url, gh_url, dst_fresh)
    else:
        _move_hg_repo(dst_path, src_path, authors, gh_url)
    run(('git', 'push', '--set-upstream', 'origin', 'master'), cwd=dst_path)
    echo('All Done!', color='green')


def _move_git_repo(dst_path: Path, src_url: str, dst_url: str, dst_fresh: bool):
    if dst_fresh:
        run(('git', 'clone', src_url, dst_path))
    else:
        run(('git', 'pull'), cwd=dst_path)
    run(('git', 'remote', 'set-url', 'origin', dst_url), cwd=dst_path)


def _move_hg_repo(dst_path: Path, src_path: Path, authors: Path, dst_url: str):
    run(('git', 'init'), cwd=dst_path)
    export_args = [HG_FAST_EXPORT, '-r', src_path]
    if authors.exists():
        export_args.extend(['-A', authors])
    run(export_args, cwd=dst_path)
    run(('git', 'checkout', 'HEAD'), cwd=dst_path)
    if Path(dst_path / HGIG).exists():
        run(('git', 'mv', HGIG, GITIG), cwd=dst_path)
        run(('git', 'commit', '-m', f'mv {HGIG} {GITIG}'), cwd=dst_path)
    run(('git', 'remote', 'add', 'origin', dst_url), cwd=dst_path)


@click.command(help=__doc__)
@click.argument('repo', nargs=-1)
@click.option('--bitbucket-user', default='lenzm')
@click.option('--github-user', default='mlenzen')
@click.option(
        '--code-dir',
        type=click.Path(file_okay=False),
        default='~/code',
        )
@click.option(
        '--authors',
        type=click.Path(dir_okay=False),
        default='~/code/authors',
        )
def main(
        repo: List[str],
        bitbucket_user: str,
        github_user: str,
        code_dir: PathLike,
        authors: PathLike,
        ):
    # Code in this function should must be just about manipulating the input
    # and calling move_repo with all business logic residing there. If it isn't
    # specific to dealing with input from the CLI it doesn't belong here.
    code_dir = Path(code_dir).expanduser()
    code_dir.mkdir(exist_ok=True, parents=True)
    authors = Path(authors).expanduser()
    for repo_name in repo:
        move_repo(
            repo_name,
            bitbucket_user=bitbucket_user,
            github_user=github_user,
            code_dir=code_dir,
            authors=authors,
            )


if __name__ == '__main__':
    main()