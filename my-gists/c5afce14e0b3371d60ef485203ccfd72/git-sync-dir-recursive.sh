#!/bin/bash

################
# Recursive version of script
sync_directory() {
  IFS=$'\n'

  for REPO in `ls "$1/"`
  do
    if [ -d "$1/$REPO" ]
    then
      echo "Updating $1/$REPO at `date`"
      if [ -d "$1/$REPO/.git" ]
      then
        git -C "$1/$REPO" pull
      else
        sync_directory "$1/$REPO" 
      fi
      echo "Done at `date`"
    fi
  done
}

REPOSITORIES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

sync_directory $REPOSITORIES