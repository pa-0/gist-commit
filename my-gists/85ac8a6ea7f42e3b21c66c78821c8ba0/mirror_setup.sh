#!/bin/bash
set -euo pipefail

# See https://blastedbio.blogspot.co.uk/2016/05/sync-github-mirror-with-cron.html and
# https://gist.github.com/peterjc/eccac1942a9709993040425d33680352 for mirroring script
#
# Usage:
#
# 1. Fork upstream repo under HuttonICS, disable wiki, projects, issues etc. Protect master branch.
# 2. Run:
#
#     ./mirror_setup.sh repo-name https://github.com/upstream-owner/repo-name.git
#
# 3. Copy and paste repo-name_key.pub into GitHub fork settings as deploy key with write permissions
# 4. Add crontab entry
#
#
#The script does this:
#
# 1. ssh-keygen -t rsa -b 4096 -C "repo-name key" -f repo-name_key -N ""
# 2. Clone upstream repo using HTTPS, cd repo-name
# 3. git remote add mirror *HuttonForkUsingGit*
# 4. git fetch mirror

name="$1"
upstream="$2"

if [ ! -f "${name}_key" ]; then
    echo "Generating ${name} SSH key"
    ssh-keygen -t rsa -b 4096 -C "huttonics/${name} deployment (Peter's iMac)" -f ${name}_key -N ""
fi

if [ ! -d "${name}/.git" ]; then
    echo "Cloning upstream ${name} repository ${upstream}"
    git clone "$upstream" "$name"
    cd $name
    git remote add mirror git@github.com:HuttonICS/${name}.git
    cd ..
fi

echo "======================================================="
echo
echo "For the GitHub deployment key:"
echo
cat ${name}_key.pub
echo
echo "Paste this into https://github.com/HuttonICS/${name}/settings/keys"
echo
echo "======================================================="
echo
echo "For the cron tab:"
echo "~/cron/mirror_git ~/cron/${name} ~/cron/${name}_key ~/cron/${name}.log"
