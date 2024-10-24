#!/bin/bash

# This script will attempt to rename your fork's master branch to main.
#
# The script needs to run at the root directory of where you have your forks
# It assumes a flat folder structure i.e. all your forks are in
# the same directory. The script also assumes you already have a
# local clone of your fork. If you do not, it will not update it.
# Also important, make sure you do not have any uncommited changes as the
# git commands will fail.
#
# It assumes your remotes are setup as following:
# origin  git@github.com:<username>/edgex-global-pipelines.git (fetch)
# origin  git@github.com:<username>/edgex-global-pipelines.git (push)
# upstream        git@github.com:edgexfoundry/edgex-global-pipelines.git (fetch)
# upstream        git@github.com:edgexfoundry/edgex-global-pipelines.git (push)

# NOTE: After a successful change to the main branch, it will delete
# both the remote and local master branch copies. You can remove that
# portion of the script below if you do not want this behavior

# You will also need to export a GitHub Personal Access Token(PAT) to authenticate
# the GitHub requests. The PAT should only need the "repo" scope to function properly
# You can see your token info here: https://github.com/settings/tokens

owner=${1:-ernestojeda} # you can replace this with your username or pass it in as an argument to the script
base_dir=$(pwd)

if [ "$GITHUB_TOKEN" == "" ]; then
    echo "GitHub token env var GITHUB_TOKEN is not set. Exiting..."
    exit 1
fi

edgex_repos=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/search/repositories?q=user:edgexfoundry+archived:false&per_page=200"  | jq -r '.items[].clone_url')

for clone_url in $edgex_repos; do
    repo=$(basename "$clone_url" | sed 's/.git//g')
    echo "Checking if fork exists: https://github.com/$owner/$repo"
    code=$(curl -s -o /dev/null -w "%{http_code}" "https://github.com/$owner/$repo")

    # check if not response code is 200
    if [ "$code" -eq 200 ]; then
        # make sure we have a main branch
        if [ -d "$base_dir/$repo" ]; then
            cd "$base_dir/$repo"
            git fetch upstream
            git branch -a | grep "upstream/main"

            if [ $? -eq 0 ]; then
                echo -e "\033[0;32mWe have a main branch...Checking to see if switch is needed.\033[0m"
                
                current_default=$(git remote show origin | awk '/HEAD branch/ {print $NF}')
                if [ "$current_default" == "main" ]; then
                    echo -e "\033[0;32mCurrent default branch is already main. Nothing to do.\033[0m"
                else
                    git fetch origin
                    echo -e "\033[0;32mUpdating default branch setting to 'main' for $owner/$repo\033[0m"
                    git checkout main && git push origin main

                    change_code=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" -H "Content-Type: application/json" --request PATCH --data '{"default_branch": "main" }' "https://api.github.com/repos/${owner}/${repo}")
                    
                    if [ "$change_code" -eq 200 ]; then
                        git remote set-head origin -a
                        # --- remove the following 2 lines if you want to keep master around
                        echo -e "033[0;32Removing local and remote copy of master branch\033[0m"
                        git push origin --delete master && git branch -D master
                    fi
                fi
            else
                echo -e "\033[0;31mNo main branch exists for $repo...Skipping\033[0m"
            fi
        else
            echo -e "\033[0;31mNo local copy of $repo exists...Skipping\033[0m"
        fi
    else
        echo -e "\033[0;31mYou do not have a fork of edgexfoundry/$repo...Skipping.\033[0m"
    fi
    echo "---"
done