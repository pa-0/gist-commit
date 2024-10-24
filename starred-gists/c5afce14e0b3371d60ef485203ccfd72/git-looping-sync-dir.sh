#!/bin/bash
################
# Runs every 10 seconds, change the sleep value (10 currently) according to your needs. 
# Make it executable with sudo chmod +x  yourFIleName.sh , then run it with $ ./yourfileName.sh
# cool hack: If you start a screen you can have it running in the background: 
# Run 'screen -S autopuller' first and then run the script. 
# To detach from the screen, press Ctrl + A and Ctrl + D!
# REPOSITORIES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
i=1
while [ "$i" -ne 0 ]
do
REPOSITORIES=`pwd`
IFS=$'\n'
for REPO in `ls "$REPOSITORIES/"`
do
  if [ -d "$REPOSITORIES/$REPO" ]
  then
    echo "Updating $REPOSITORIES/$REPO at `date`"
    if [ -d "$REPOSITORIES/$REPO/.git" ]
    then
      cd "$REPOSITORIES/$REPO"
      git status
      echo "Fetching"
      git fetch
      echo "Pulling"
      git pull
      cd ..
    else
      echo "Skipping because it doesn't look like it has a .git folder."
    fi
    echo "Done at `date`"
    echo
  fi
done
sleep 10
done
