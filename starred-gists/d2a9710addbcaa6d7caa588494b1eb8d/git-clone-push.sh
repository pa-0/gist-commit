#!/bin/bash

echo "Initializing cloning for segun-adeleye/$1"

git clone git@github.com:segun-adeleye/$1.git

echo "segun-adeleye/$1 cloned"

echo
echo "Initializing creation of segunadeleye/$1 on github"
echo "Running 'curl -u 'segunadeleye' https://api.github.com/user/repos -d \"{\"name\":\"$1\"}\"'"

curl -u 'segunadeleye' https://api.github.com/user/repos -d "{\"name\":\"$1\"}"
echo "segunadeleye/$1 created"

echo "Move into created directory --> $1"
cd $1

echo "List the contents of the directory"
ls -l

echo
echo "Changing origin to segunadeleye/$1"
git remote set-url origin git@github.com:segunadeleye/$1.git

echo
echo "Confirming origin update"
git remote -v

echo
echo "View remote branches"
git branch -r

# Read remote branches into an array
branches=( $(git branch -r) )

# Print all items in the array
echo
echo "${branches[@]}"

# origin/HEAD and -> are unwanted items so we have to remove them from the array
HEAD=( origin/HEAD )
ARROW=( "->" )

# Print number of items in the array
echo
echo "Number of items in the array --> ${#branches[@]}"

# Remove unwanted items. Could be implemented at a loop
branches=( ${branches[@]/$HEAD} )
branches=( ${branches[@]/$ARROW} )

echo
echo "New Array sans unwanted items --> ${branches[@]}"
echo "Number of items in the array --> ${#branches[@]}"

# Remove duplicate items from the array
echo
echo 'Removing duplicated branches'
branches=( $(printf "%s\n" "${branches[@]}" | sort -u | tr '\n' ' ') )

echo
echo 'Initializing branch upload to github'
for br in ${branches[@]}
do
  # Skip origin/ in remote branch name
  echo ${br[@]:7}

  # Checkout into the branch and push to github
  git checkout ${br[@]:7} && git push origin
done

echo "All ${#branches[@]} branches pushed"

echo
echo 'Deleting cloned repo'

if [ $1 == '.' ]; then
  echo "ERROR! I wouldn't advise you to run this command 'rm -rf $1'"
else
  cd ..
  rm -rf $1
  echo "$1 deleted!"
fi

echo 'Done'