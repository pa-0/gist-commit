# `Git history prune`

If you don’t need to maintain a full history, you can use the following set of commands to remove the history entirely from your Git repository. With the repository cloned into a path on your workstation, use the `--orphan` option, which returns it to the init state with only one commit. Deleting the `.git` folder may cause problems in your `git` repository. 

**If you want to delete all your commit history but keep the code in its current state***, it is very safe to do it as in the following:

```git
git checkout --orphan freshBranch
git add -A
git commit -m 'purge'
git branch -D main
git branch -m main
git push -f origin main
git gc --aggressive --prune=all
git push -f origin main
```
