#!/bin/bash

# Does NOT apply to submodules; to include submodules when fetching commits:
# find . -name .git -type d | xargs -n1 -P4 -I% git --git-dir=% --work-tree=%/.. fetch --all --recurse-submodules
# OR
# Where some repos require manual password input:
# find . -name .git -type d | xargs -n1 -I% git --git-dir=% --work-tree=%/.. fetch --all --recurse-submodules

# Enclose current directory in double quotes where the path contains special characters
# store the current dir
CUR_DIR=$(pwd)

# Let the person running the script know what's going on.
echo "\n\033[1mPulling in latest changes for all repositories...\033[0m\n"

# Find all git repositories and update it to the master latest revision
for i in $(find . -name ".git" | cut -c 3-); do
    echo "";
    echo "\033[33m"+$i+"\033[0m";

    # We have to go to the .git parent directory to call the pull command
    cd "$i";
    cd ..;

    # finally pull
    git pull origin master;

    # lets get back to the CUR_DIR
    cd $CUR_DIR
done

echo "\n\033[32mComplete!\033[0m\n"
