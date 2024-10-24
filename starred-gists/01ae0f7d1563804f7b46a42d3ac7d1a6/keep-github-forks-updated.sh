#!/bin/bash

# Quick script to sync all my forks on GitHub up-to-date with the parent repo
# Assumes I never commit to the main branch, which I try to avoid.
# Runs on cron, so only outputs with errors.

USER=$(gh api '/user' | jq -r .login)
REPOS=$(gh api "users/$USER/repos?type=owner&per_page=100" | jq -r '.[] | select( ( .fork == true ) and ( .disabled == false ) and ( .archived == false )  ) | .full_name + " " +.default_branch' )

while IFS= read -r line; do
        parts=($line)

        result=$( gh api --method POST -H 'X-GitHub-Api-Version: 2022-11-28' "repos/${parts[0]}/merge-upstream" -f branch="${parts[1]}" | jq -r '.message' )
        if [[ ${result} != *"is not behind the upstream"* && ${result} != *"Successfully"* ]]; then
                echo -n "${parts[0]} "
                echo "$result"
        fi
done <<< "$REPOS"