# Backup/archive a repo
1. Clone the repo
  ```
  git clone --mirror https://github.com/vuejs/vue
  ```
2. `cd` into the cloned repo
3. Create a bundle file in the parent directory
  ```
  git bundle create ../vuejs_vue.bundle --all
  ```
4. That bundle file is now a full archive of the repo, including all of its branches and tags

# Restore a repo from a bundle file
Here we will restore the repo from the bundle and create a new remote origin that will contain all brnaches and tags
1. Clone the repo from the bundle
  ```
  git clone vuejs_vue.bundle
  ```
2. Get all the branches locally to be pushed up to your origin later (from: https://gist.github.com/grimzy/a1d3aae40412634df29cf86bb74a6f72)
  ```
  git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
  git fetch --all
  git pull --all
  ```
3. Create a new repo on your git server and update the origin of the local repo
  ```
  git remote set-url origin git@github.com/xtream1101/test-backup.git
  ```
4. Push all branches and tags to the new remote origin
  ```
  git push --all
  git push --tags
  ```