#!/usr/bin/env python3
"""Clone all repos owned by an organization or user using the GitHub CLI (gh).

usage: gh-clone-all.py [-h] [--pattern PATTERN] owner [-- <gitflags>...]
"""
import argparse
import json
import re
import subprocess
from concurrent.futures import ThreadPoolExecutor

def clone_all(owner=None, pattern=None, gitflags=[]):
    """Clone all repos owned by owner, or your account if no owner is given.

    If pattern is given, clone only repos matching pattern.
    gitflags contains additional arguments to pass to `git clone`.
    """
    with ThreadPoolExecutor() as executor:
        for repo in repo_list(owner, pattern):
            executor.submit(gh, 'repo', 'clone', repo, '--', *gitflags)

def repo_list(owner=None, pattern=None, limit=1000):
    """Return a list of repos names owned by owner, matching pattern.
    """
    args = ['repo', 'list', '--limit', str(limit)]
    if owner:
        args.append(owner)
    output = gh(*args, json_names=['name', 'nameWithOwner'])
    return [item['nameWithOwner'] for item in json.loads(output) if not pattern or re.match(pattern, item['name'])]

def gh(*cmd, json_names=None):
    """Run the specified gh command.

    json_names, if provided, specifies that the output should be parsed as json with the given json field names.
    """
    try:
        if json_names:
            prefix = ['gh', '--json', ','.join(json_names)]
            return subprocess.check_output(prefix + list(cmd), encoding='utf-8')
        else:
            return subprocess.run(['gh'] + list(cmd), check=True)
    except FileNotFoundError:
        raise SystemExit('gh not found, install from: https://cli.github.com/')

parser = argparse.ArgumentParser()
parser.add_argument('owner')
parser.add_argument('gitflags', nargs='*', help='Pass additional `git clone` flags by listing them after "--"')
parser.add_argument('--pattern', help="Clone only repos matching the PATTERN regular expression")

def main(args):
    args = parser.parse_args(args)
    clone_all(args.owner, args.pattern, args.gitflags)

if __name__ == '__main__':
    import sys
    try:
        main(sys.argv[1:])
    except subprocess.CalledProcessError as error:
        sys.exit(error.returncode)