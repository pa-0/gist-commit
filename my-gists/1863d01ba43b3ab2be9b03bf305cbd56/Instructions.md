# How to use `github-fork-sync.sh`

GitHub does not provide a quick and fast way to automatically sync the branches of a fork with the upstream repository.

Until now... With GitHub actions!

If you don’t care about the HOW, then here are the... 

## Quick Steps:

### 1. Download the `github-fork-sync.sh` script from this Gist

### 2. Make it executable:

```bash
chmod a+x github-fork-sync.sh
```
### 3. Run it: 

```bash
./github-fork-sync.sh
```

You will see the help dialog:

```bash
❯  ./github-fork-sync.sh
github-fork-sync.sh <fork> <upstream> <branch-to-sync>
Example: github-sync.sh mathieucarbou/terracotta-platform Terracotta-OSS/terracotta-platform master
```
![image](https://gist.github.com/assets/134162878/9e9f4aee-4889-4d90-850c-7bb989e3b96e)

The script takes 3 parameters:

1. Your fork
2. The upstream repository
3. The branch to sync

- The script will install a Gihub Action in your repository that will be run each hour by default.
- The update takes about 20 seconds to run.
- You will also be able to manually trigger an update.
- This action will be pushed into a branch called "`actions`". This branch will be automatically created.

> ## ⚠️IMPORTANT:⚠️ 
> ## Follow the script output!

The script pauses at one point and asks you to go in your GiHub fork to change the default branch name. **This is sadly required because GitHub has currently a bug preventing to discover the pushed GitHub actions not in a default branch.**

Once the steps are done, you will be able to go in your fork and trigger an automatic update by clicking on the **`Run workflow`** button.
![image](https://gist.github.com/assets/134162878/0d0b5402-3b09-4a15-8b5f-4d6525da5cd7)
The GitHub action tab will show you the scheduled executions:
![image](https://gist.github.com/assets/134162878/38fbf838-8bae-4aa8-8456-80dfc72dc65e)
And you can even edit the action script to support the update of several branches in a fork. Example here.
![image](https://gist.github.com/assets/134162878/11d72746-ba18-4ddd-9f64-0f880fc1f007)
You can take a look at the integration in the original gist author's forks [**here**](https://github.com/mathieucarbou?tab=repositories&q=&type=fork&language=&sort=).

## Notes

- In the script, you can replace `uses: mathieucarbou/Fork-Sync-With-Upstream-action@fork-sync` with your own fork of: [aormsby/Fork-Sync-With-Upstream-action](https://github.com/aormsby/Fork-Sync-With-Upstream-action "GitHub Repo hosting the action this script employs").

- By pointing the script to your own personal fork of this repo, you can control any updates that are applied from the `upstream` (original parent) repository. Moreover, you can create a branch in your fork to use with the script, and still continue to sync the master branch of your fork with the upstream (https://github.com/aormsby/Fork-Sync-With-Upstream-action). This way any changes to the master branch in your fork caused by syncing with the upstream will not affect the branch your script uses. You can manually move code over from master to the branch used in the script as needed. This is a more secure approach.