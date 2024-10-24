#!/bin/bash

GH_USER=${1-$USER}
REPOS=`curl -s https://api.github.com/users/$GH_USER/starred |grep full_name | cut -f 4 -d\" |xargs`

for REPO in $REPOS; do
   VERSION=`curl -s https://api.github.com/repos/$REPO/releases |grep tag_name |grep -v rc | head -1 |cut -f4 -d\"`
   echo "$REPO : $VERSION"
done