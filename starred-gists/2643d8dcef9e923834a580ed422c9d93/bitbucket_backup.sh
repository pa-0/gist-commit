#!/bin/bash

team=${1};
repos_list_file=${2};

while read repo; do
  if [[ ! -d "$repo" ]]; then
    echo $repo clone...
    git clone git@bitbucket.org:${team}/${repo}.git;
    TIMEOUT=$((5 + RANDOM % 10));
    echo cloning next repo starts after $TIMEOUT seconds;
    sleep $TIMEOUT;
  else
    cd $repo;
    git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
    git pull --all
    cd ../;  
  fi
done < ${repos_list_file}
