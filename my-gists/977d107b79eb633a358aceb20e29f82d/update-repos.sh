#!/bin/bash

# store the current dir
CUR_DIR=$(pwd)

# Let the person running the script know what's going on.
echo -e "\n\033[1mPulling in latest changes for all repositories...\033[0m\n"

# Find all git repositories and update it to the master latest revision
for i in $(find -L . -name ".git" | cut -c 3-); do
    echo "";
    echo -e "\033[33m"+$i+"\033[0m";

    # We have to go to the .git parent directory to call the pull command
    cd "$i";
    cd ..;

    # git checkout master;
    git remote prune origin;
    git fetch origin;
    git pull;

    if [ -f "yarn.lock" ]
    then
        yarn install --prefer-offline;
    fi

    if [ -f "package-lock.json" ]
    then
        npm ci --prefer-offline --no-audit;
    fi  

    # lets get back to the CUR_DIR
    cd $CUR_DIR
done

echo -e "\n\033[32mComplete!\033[0m\n"