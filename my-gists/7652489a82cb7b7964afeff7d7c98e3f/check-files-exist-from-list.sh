#!/usr/bin/env bash
#Check Files in list from file exist or doesn't exist in directory.

if [ $# -eq 0 ] || [ $# -eq 1 ]
  then
    echo "You must pass the path to file with the list and the path to directory to check files. \nsh check-file-exist-from-list.sh path/to/file path/to/directory"
    exit 1
fi

while read -r file; do
  if [ -e "$2/$file" ]; then
    echo "$file exists in $2"
  else
    echo "$file doesn't exist in $2"
  fi
done < "$1"
