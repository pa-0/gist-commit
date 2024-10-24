#!/bin/bash

if ! command -v gh >/dev/null 2>&1; then
    echo "Install gh first"
    exit 1
fi
echo "gh cli installed"

# This script 
if ! gh auth status >/dev/null 2>&1; then
    echo "You need to login: gh auth login"
    gh auth login
fi
echo "logged in via gh cli"

# commands to get a list of all repos with the default branch set to master using gh repo list
repos=`gh repo list --json nameWithOwner,defaultBranchRef --source --jq '.[] | select(.defaultBranchRef.name == "master") | .nameWithOwner'`

# loop through the repos and update the default branch to main
if ! pushd /tmp/gitdefaultbranch; then 
    mkdir /tmp/gitdefaultbranch
    pushd /tmp/gitdefaultbranch
fi

for repo in $repos
do
    echo "Updating $repo"
    folder=$(basename "$repo")

    if pushd $folder; then 
        git pull; 
    else 
        gh repo clone $repo
        pushd $folder
    fi

    ls

    git checkout master
    git pull
    git branch -m master main
    read -p "Push to origin? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
    git push -u origin main
    git checkout main

    gh repo edit $repo --default-branch main
    
    popd
done

popd
rm -rf /tmp/gitdefaultbranch
