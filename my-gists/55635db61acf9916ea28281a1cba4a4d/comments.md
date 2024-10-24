# Comments to original Gist
_for poserity_

###`git-pull-all`
```sh
#!/usr/bin/env bash

git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
git fetch --all
git pull --all
```
#### @florian-die commented on Mar 7, 2018

According to the doc on pull, the `--all` option only affects the fetch part of the `pull` command.
So isn't it kind of useless to do a `fetch --all` before a `pull --all` ?
Also I have doubts that git pull --all does indeed pull all remote branch and not just the current one.
What do you think ?

#### @refactormyself commented on Mar 21, 2018

I think and I just witness that it is not useless.
I have some branch on my remote not tracked locally, git pull --all will not help me with that.
Doing `git fetch --all` first let me see this clearly, I can see that pull misses some branches.
So I do  `git checkout --track origin/%branchname%`

I will stick to this; I won't sacrifice joy and happiness for keystrokes.

#### @Timmmm commented on Aug 22, 2018

`--all` just means to fetch from all remotes.

#### @gwierink commented on Dec 15, 2018

After cloning a repo and wanting to fetch all branches, git complains (rightfully so) that it does not think it makes sense to create 'HEAD' manually. When I threw out master, all was well:
```sh
git branch -r | grep -v '\->' | grep -v 'master' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
```

#### @rhujisawa commented on Apr 16, 2019

```sh
GIT_SSH_COMMAND='ssh -i ~/.ssh/ key' git branch -r | grep -v '\->' | grep -v 'master' | while read remote; do git branch --track "${remote#origin/}" "$remote"; done
```
#### @Rocking80 commented on Jun 11, 2019

when I executed `git branch -r | grep -v '\->'`, I got lots of previous branches which not used yet. why?

#### @ankurash commented on Sep 26, 2019

`pull --all and fetch --all` do not pull all branches, just all the remotes. Have tested it multiple times now.
I haven't found a solution and I'm desperately looking for a real solution.
Meanwhile, have been using the following workaround (again, this is not a solution).

```sh
for remote in `git branch -r | grep -v '\->'`; do (git branch --track ${remote#origin/} $remote; git checkout ${remote#origin/}; git pull ); done; git checkout master; git pull --all
```
This tracks and pulls all branches but has a ridiculous overhead of changing the repo contents when checking out in every branch.

#### @ElfSundae commented on Nov 27, 2019

If there are existing branch names, e.g. master, then `set -e` option will cause this command fails and some branches may not be checkout.
This issue can be fixed by appending `|| true for git branch --track` command:

```sh
git branch -r | grep -v '\->' | while read remote; do git branch --track "${remote#origin/}" "$remote" || true; done 2>/dev/null
```

#### @ElfSundae commented on Dec 16, 2019

You're welcome. I use below now:

```sh
remote=origin ; for brname in `git branch -r | grep $remote | grep -v master | grep -v HEAD | awk '{gsub(/^[^\/]+\//,"",$1); print $1}'`; do git branch --track $brname $remote/$brname || true; done 2>/dev/null
```
From https://gist.github.com/ElfSundae/92a5868f418ec3187dfff90fe6b20387

#### @will-tam commented on Apr 13, 2020

Hello and thanks everyone for this tips

#### @maskym commented on Jul 21, 2020

Thank you so much ElfSundae, I've looked for this answer so much, only to find fetch --all ...

#### @HoffiMuc commented on Nov 24, 2020

```sh
current=$(git branch --show-current) ; for brname in $(git branch -r | grep origin | grep -v master | grep -v HEAD | awk '{gsub(/^[^\/]+//,"",$1); print $1}'); do echo git checkout $brname ; git checkout $brname ; echo git pull ; git pull ; done ; echo git checkout $current ;git checkout $current
```
#### @andreasslc commented on Apr 24, 2021

```sh
for abranch in $(git branch -a | grep -v HEAD | grep remotes | sed "s/remotes\/origin\///g"); do git checkout $abranch ; done
```
This statement will checkout all branches when executed in local repo location. I use it frequently.

#### @m3asmi commented on Mar 14, 2022
I use this:
git branch -r | grep -v '\->' | sed -e 's/^origin\///' | while read remote; do echo "parsing branch $remote"; branch=${remote/origin\//}; git checkout "$branch"; git reset --hard $remote ; git pull; echo "$remote done";done 

#### @Wandalen commented on Jun 1, 2022

According to the doc on pull, the `--all` option only affects the `fetch` part of the `pull` command.
So isn't it kind of useless to do a `fetch --all` before a `pull --all` ?
Also I have doubts that `git pull --all` does indeed pull all remote branch and not just the current one.
What do you think ?

Confirmed. That is useless. Any working alternative?

#### @jcwren commented on Jun 29, 2022

```sh
git branch -r | grep -v '->' | tr -d 'origin/' | while read remote; do echo "parsing branch $remote"; git checkout "$remote"; git reset --hard $remote ; git pull; echo "$remote done";done
```
Your tr command is incorrect, as it deletes characters in the list. You want sed.

```sh
$ echo "origin/docubranch" | tr -d 'origin/'
emtesdcubach
$ echo "origin/docubranch" | sed -e 's/^origin\///'
docubranch
```

#### @m3asmi commented on Jul 13, 2022

@jcwren thanks, I fixed it

#### @hughesjs commented on Dec 8, 2023

Going to come in with a controversial new option:

```sh
git branch --remote | cut -c 10- | xargs -d\\n -n1 git switch -f
```
Just make sure you've committed or stashed all of your changes. This does assume that your remote is called origin, if it's not, change the number of digits getting slashed by cut.

#### @andry81 commented on Dec 30, 2023

Mine own approach to pull and sync:

https://github.com/andry81/gitcmd (implementation, not interactive usage)
```sh
git_pull_remote*.sh
git_sync_remotes.sh
```

https://github.com/andry81/gituserbin (wrappers, interactive usage)
```sh
pull-remote*.*
sync-remotes.*
```

Git checkout all remote branches
git-checkout-all-branches.sh
```sh
#!/bin/bash
remote=origin ; for brname in `git branch -r | grep $remote | grep -v /master | grep -v /HEAD | awk '{gsub(/^[^\/]+\//,"",$1); print $1}'`; do git branch --track $brname $remote/$brname || true; done 2>/dev/null
```
**Refs:**
https://gist.github.com/grimzy/a1d3aae40412634df29cf86bb74a6f72
https://gist.github.com/grimzy/a1d3aae40412634df29cf86bb74a6f72#gistcomment-3094412
https://stackoverflow.com/a/6300386/521946

#### @kublermdk commented on Apr 6, 2021

This is exactly what I wanted. Thank you.

I've added that to my bash aliases file as a function.

```sh
function gitCheckoutAllBranches {
        remote=origin;
        for brname in `git branch -r | grep $remote | grep -v /master | grep -v /HEAD | awk '{gsub(/^[^\/]+\//,"",$1); print $1}'`;
                do git branch --track $brname $remote/$brname || true;
        done
}
```