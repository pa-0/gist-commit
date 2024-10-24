# Merge Wiki Changes From A Forked Github Repo

This is inspired (or basically copied) from [How To Merge Github Wiki Changes From One Repository To Another](http://roman-ivanov.blogspot.com/2013/11/how-to-merge-github-wiki-changes-from.html), by Roman Ivanov, and serves to ensure that should something happen to the original article, the information remains nice and safe here.

### Terminology

**OREPO**: original repo - the repo created or maintained by the owner

**FREPO**: the forked repo that presumably has updates to its wiki, not yet on the **OREPO**

## Contributing

Should you want to contribute to the wiki of a repo you have forked, do the following:

- fork the repo
- clone only the wiki to your machine:
  `$ g clone [FREPO].wiki.git`
- make changes to your local forked wiki repo
- push your changes to GitHub

Once you are ready to let the author know you have changes, do the following:

- open an issue on **OREPO**
- provide a direct link to your wiki's git repo for ease of merging:
  i.e. [**FREPO**].wiki.git

## Merging Changes

As the owner of **OREPO**, you have now received a message that there are updates to your wiki on someone else's **FREPO**.

If wiki changes are forked from latest **OREPO** wiki, you may do the following:

```shell
$ git clone [OREPO].wiki.git
$ cd [OREPO].wiki.git

# squashing all FREPO changes
$ git pull [FREPO].wiki.git master

$ git push origin master
```

If **OREPO** wiki is ahead of where **FREPO** forked from, do the following:

```shell
$ git clone [OREPO].wiki.git
$ cd [OREPO].wiki.git
$ git fetch [FREPO] master:[FREPO-branch]
$ git checkout [FREPO-branch]

#checkout to last OREPO commit
$ git reset --hard [last-OREPO-commit-hash]

# do massive squash of all FREPO changes
$ git merge --squash HEAD@{1}
$ git commit -m "Wiki update from FREPO - [description]"
$ git checkout master

# cherry-pick newly squashed commit
$ git cherry-pick [OREPO-newly-squashed-commit]
$ git push
```