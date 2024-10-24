#!/usr/bin/env sh

# usage git-branch-rename.sh <oldName> <newName>

# make code up to date
git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
git fetch --all
git pull --all


oldName=$1;
newName=$2;

git checkout "$oldName";
git pull origin "$oldName";

git branch -m "$newName";

git push origin -u "$newName";
git push origin --delete "$oldName";

echo "renamed branch $oldName to $newName";
