
# Git Mirror with submodules

While creating a git mirror is as simple as `git clone --mirror`, unfortunately this git command does not support git submodules (difficult) or lfs (easier). These scripts help in creating a mirror of a project with submodule and/or git lfs.

General user case:

1. You have a git repo with submodule on a git server
2. `git_mirror https://github.com/visionsystemsinc/vsi_common.git master`, recursively create mirrors of all submodule currently in the master branch.
3. Transfer `vsi_common_prep/transfer_{date}.tgz` to your destination
4. Write an `info.env` file:

    ```bash
    repos[.]=https://my_repo.com/foobar/vsi_common.git
    repos[docker/recipes]=https://my_repo.com/foobar/recipes.git
    ```

5. `push_to_mirror ./info.env ./transfer_extracted_dir/`
6. Now to clone from your new mirror: `clone_from_mirror ./info.env ./my_project_dir/`

## git_mirror

Downloads a mirror of a git repo and all of its submodules. The normal `git clone --mirror` command does not support submodules at all. This will at least clone all the submodules available in the specified branch (`master` by default).

```
git_mirror {git repo or prep dir on subsequent calls} [git branch]
```

The script creates a directory: `{repo_name}_prep`. That directory will contain all of the repositories plus a single `transfer_{date}.tgz` file containing all the repositories, lfs objects, etc... Only this `tgz` file needs to be transferred to your destination.

Subsequent calls to `git_mirror` will use the existing `{repo_name}_prep` directory as cache, updating faster than the last fist time.

Subsequent calls also create a second `tgz` file, `transfer_{date1}_transfer_{date2}.tgz`. These are incremental files. Instead of having to bring in an entire transfer, only the incremental files are needed, plus the original full archive.

All three of these examples result in identical repos:

```
tar zxf transfer_2020_03_02_14_24_12.tgz

###

tar zxf transfer_2020_03_02_14_16_09.tgz
tar --incremental zxf transfer_2020_03_02_14_24_12_transfer_2020_03_02_14_16_09.tgz

###

tar zxf transfer_2020_03_02_14_07_59.tgz
tar --incremental transfer_2020_03_02_14_16_09_transfer_2020_03_02_14_07_59.tgz
tar --incremental transfer_2020_03_02_14_24_12_transfer_2020_03_02_14_16_09.tgz
```

## push_to_mirror

Push the contents of the prep dir from [git_mirror](#git_mirror) to your own mirrors.

Usage:

```
push_to_mirror {file setting repos array} {extracted prep dir}
```

Since the urls for your mirrors will different from the original repo urls, you need to create an environment file to specify the repo URLs. The main repo is referred to as `.` while the rest of the repos are referred to by the relative path with respect to the main repo (e.g. `external/vsi_common`). These need to be stored in an associative array called `repos`. For example:

```bash
repos[.]=https://my_repo.com/foobar/vsi_common.git
repos[docker/recipes]=https://my_repo.com/foobar/recipes.git
```

In this example, the main repo's mirror url is `https://my_repo.com/foobar/vsi_common.git`, and the submodule stored at `./docker/recipes` has the url `https://my_repo.com/foobar/recipes.git`. This file will also be used for [clone_from_mirror](#clone_from_mirror).

## clone_from_mirror

Since the `.gitmodules` file will point to different urls than your mirrors, and changing the `.gitmodules` file will change the repo, which we don't want to do, we need to use a third script to make the initial clone of from the mirror.

Usage:

```
clone_from_mirror {file setting repos array} [clone path, . by default]
```

The main repo needs to be cloned, submodules inited, then submodule urls updated before fetching the submodules, and this has to be done one layer of submodules at a time. This can be very tedious, so this script will do all of this for you.

## Limitations

- It will not pull all submodules from every version, only from a specific branch/sha/tag you specify (master by default). This is because trying to pull all submodules from the past could be very lengthy, and is very likely to include urls that do not exist anymore.
    - If you know you need submodules from multiple branches, you can always run `git_mirror` multiple times, deleting the `transfer_{date}.tgz` file each time (except the last)

- Does not support git older than 1.8. Neither does Atlassian.

- Uses `bash`, tested on alpine, debian, centos, and fedora. So should be fairly universal.

- Handles all valid characters for submodule paths, including spaces, tabs, and newlines, however git will not handle newlines nor paths that start or end with white space

- Handles all valid character for submodule names, including spaces, and tabs

- Support git lfs, but if you need extra configuration options to use particular lfs store or other git or lfs options, then set the environment variable `GIT` to call your own git script. For example `git2`:

```bash
#!/usr/bin/env bash
git -c lfs.customtransfer.lfs-folder.path=/tmp/lfs-folderstore-linux-amd64/lfs-folderstore"'" -c lfs.customtransfer.lfs-folder.args=/tmp/lfs/objects"'" -c lfs.standalonetransferagent=lfs-folder ${@+"${@}"}
```

## Bugs

- Does not support sub-projects. Anyone need that? Didn't think so...

- Does not de-duplicate a submodule that may be used multiple times by other submodules