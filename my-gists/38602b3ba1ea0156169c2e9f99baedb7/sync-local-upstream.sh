# Assumes that the git repository has upstream and remote urls set
# Assumes that you've committed your work on your current branch

current_branch=$(git rev-parse --abbrev-ref HEAD)

git fetch upstream
git checkout master
git merge upstream/master

git push # origin

git checkout $current_branch
