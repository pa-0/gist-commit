#!/usr/bin/env python
# Copyright 2021-2024 by Peter Cock, The James Hutton Institute.
# All rights reserved.
# This file is released under the "MIT License Agreement".
"""Python script to keep GitHub mirrors in sync with upstream.

Mirror mirror on the wall, who's the newest of them all?

Usage:

    $ ls token.txt
    $ python ./on_the_wall.py username1 [username2 ...]

This will identify those of the user (or organisation) repos
which are forks, and then clone the upstream repository in
the default named sub-folder and add your fork as a remote.
i.e. origin = upstream it was forked from, username = fork.

It will report those repos where the default branch is out
of date, and then if you have provided authentication, push
an update.

Latest version is here:
https://gist.github.com/peterjc/899a6d24badd47d6305ddc5e299fd4bd
"""
# TODO - Proper command line API?
#
# TODO - What if a repo name appears more than once?
# Should we store the keys under username specific folders?
# (like this does for the repositories)

import os
import sys

import git  # gitpython

from github import Github  # pygithub
from github.GithubException import BadCredentialsException
from github.GithubException import UnknownObjectException

key_dir = "keys/"
cache_dir = "cache/"
make_key = 'ssh-keygen -q -t rsa -b 4096 -C "%s" -f %s_key -N ""'

if len(sys.argv) > 1:
    owners = sys.argv[1:]
else:
    sys.exit("ERROR: Supply one or more GitHub user or organisation names")

with open("token.txt") as handle:
    token = handle.read().strip()

if not os.path.isdir(cache_dir):
    os.mkdir(cache_dir)


def update_mirror(repo, parent, branch):
    deployment_key = os.path.join(key_dir, name + "_key")
    if not os.path.isfile(deployment_key):
        sys.stdout.write(" - Creating new SSH deploy key\n")
        cmd = make_key % (name, os.path.join(key_dir, name))
        if os.system(cmd) or not os.path.isfile(deployment_key):
            sys.exit(f"ERROR - Building new key failed:\n{cmd}")
            return
    ssh_cmd = f"ssh -i {os.path.abspath(deployment_key)}"
    # sys.stderr.write(f"DEBUG: Seting ssh cmd to: {ssh_cmd}\n")

    try:
        keys = list(repo.get_keys())
    except UnknownObjectException:
        sys.exit(
            "ERROR - token does not have key access."
            " Try admin:public_key, public_repo, read:org, repo:status"
        )
    have_key = False
    deploy_key_pub = open(deployment_key + ".pub").read().strip()
    for key in keys:
        if deploy_key_pub.startswith(key.key):
            if key.read_only:
                sys.stderr.write("ERROR - This deploy key is read only\n")
                return
            sys.stdout.write(" - Verified deploy key\n")
            have_key = True
            break
    if not have_key:
        sys.stdout.write(" - Giving deploy key write access\n")
        kind, pub, title = deploy_key_pub.split(None, 2)
        repo.create_key(title, kind + " " + pub, read_only=False)

    # print(parent.clone_url)
    if not os.path.isdir(os.path.join(directory, ".git")):
        sys.stdout.write(" - Cloning repository\n")
        # cmd = f"git clone '{parent.clone_url}' '{directory}'"
        # sys.stdout.write(f" - {cmd}\n")
        git_repo = git.Repo.clone_from(parent.clone_url, directory)
    else:
        sys.stdout.write(" - Opening repository\n")
        git_repo = git.Repo(os.path.join(directory, ".git"))

    origin = git_repo.remote("origin")
    if origin.url != parent.clone_url:
        sys.exit(f"ERROR {directory} origin URL {origin.url} != {parent.clone_url}")

    try:
        mirror = git_repo.remote("mirror")
    except ValueError:
        sys.stdout.write(" - Defining mirror repository\n")
        # This wrapper API Does not appear to split pull/push URL
        # mirror = git_repo.create_remote(
        #    "mirror",
        #    pull_url=repo.git_url,
        #    push_url=f"git@github.com:{owner}/{name}.git",
        # )
        # Not repo.git_url nor repo.clone_url
        mirror = git_repo.create_remote(
            "mirror", url=f"git@github.com:{owner}/{name}.git"
        )

    sys.stdout.write(" - Fetching latest origin & mirror\n")
    # What would be different about using .update() here?
    origin.fetch()
    with git_repo.git.custom_environment(GIT_SSH_COMMAND=ssh_cmd):
        mirror.fetch()

    sys.stdout.write(f" - Updating local {branch}\n")
    # git_repo.git.checkout(branch)
    # Fancier version when default branches have changed
    # git checkout --track=direct -B brapi-V2.0 origin/brapi-V2.0
    git_repo.git.checkout(f"origin/{branch}", track="direct", B=branch, force=True)
    git_repo.git.rebase(f"origin/{branch}")  # Redundant with above checkout?

    sys.stdout.write(f" - Updating mirror {branch}\n")
    with git_repo.git.custom_environment(GIT_SSH_COMMAND=ssh_cmd):
        git_repo.git.push(mirror, branch)


# using an access token
try:
    g = Github(token)
except BadCredentialsException:
    sys.exit("Bad token")

for repo in g.get_user().get_repos():
    # To ensure local uniqueness, want fork's name, not parent's name!
    name = repo.name
    owner = repo.owner.login
    if owner not in owners:
        continue
    sys.stdout.write(f"{owner}/{name}\n")
    if not os.path.isdir(os.path.join(cache_dir, owner)):
        os.mkdir(os.path.join(cache_dir, owner))
    directory = os.path.join(cache_dir, owner, name)
    parent = repo.parent
    if not parent:
        sys.stdout.write(f" - Skipping {name}, not a forked repository\n")
        continue
    if repo.archived:
        sys.stdout.write(" - Skipping as archived\n")
        continue
    if parent.archived:
        sys.stdout.write(f"WARNING: Should archive mirror of {owner}/{name}\n")
    if repo.has_wiki:
        sys.stderr.write(f"WARNING: {owner}/{name} has wiki\n")
    if repo.has_projects:
        sys.stderr.write(f"WARNING: {owner}/{name} has projects\n")
    if repo.default_branch != parent.default_branch:
        sys.stderr.write(
            f"WARNING: Change of default branch, we have {name}/{repo.default_branch} "
            f" vs {owner}/{parent.default_branch}\n"
        )
        # TODO: if repo.default_branch in parent.branches():  <-- how?
        sys.stdout.write(f" - Updating former default branch {repo.default_branch}\n")
        update_mirror(repo, parent, repo.default_branch)  # update the old default branch

        sys.stdout.write(f" - Updating new default branch {parent.default_branch}\n")
        update_mirror(repo, parent, parent.default_branch)  # get/update the new default branch
        sys.stdout.write(f" - WARNING: Changing default branch to {parent.default_branch}\n")
        repo.edit(default_branch=parent.default_branch)  # new branch now exists, can become our default
    else:
        update_mirror(repo, parent, repo.default_branch)
