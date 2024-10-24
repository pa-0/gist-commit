# Migrate Archived Google Code SVN to GitHub Git (in 2023)

This document was forked from <https://gist.github.com/yancyn/3f870ca6da4d4a5af5618fbd3ce4dd13>.

## Requirements

- wget
- git
- git-svn

## Setup

```bash
# Ubuntu 23.04
sudo apt install -y wget git git-svn
```

## authors.txt

Must map all svn users to git users.

```gitconfig
# Syntax: "svn author name" = "github username" <github mail address>
# TIPS: You can see the list of commits by each svn authors.
# https://code.google.com/archive/p/foo-project/source/default/commits
user1 = user1 <user1@email.com>
user2 = user2 <user2@email.com>
(no author) = user3 <user3@email.com>
```

## How To

```bash
SVN_PJ_NAME='foo-project'
GIT_PJ_NAME='foo-project-archive'
YOUR_GH_URL='https://github.com/torvalds'

# Download svn dump from Google archive.
wget "https://storage.googleapis.com/google-code-archive-source/v2/code.google.com/${SVN_PJ_NAME}/repo.svndump.gz"
gunzip repo.svndump.gz

# Create a local svn repo by load the svn dump.
svnadmin create "$SVN_PJ_NAME" && svnadmin load $_ < repo.svndump

# Start svn daemon.
svnserve --foreground -d -r . &

# Create a bare git repo.
git svn clone -s -A authors.txt "svn://localhost/${SVN_PJ_NAME}" "$GIT_PJ_NAME"

# Add existing remote git repo then push.
pushd "$GIT_PJ_NAME"
git remote add "${YOUR_GH_URL}/${GIT_PJ_NAME}"
git push -u origin master
popd

# Kill daemon.
kill %1

# Remove SVN and dump file.
rm -rf "$SVN_PJ_NAME" repo.svndump
```

## Credits

- https://dominikdorn.com/2016/05/how-to-recover-a-google-code-svn-project-and-migrate-to-github/
- https://docs.gitlab.com/ee/workflow/importing/migrating_from_svn.html
- https://www.guyrutenberg.com/2011/11/09/author-no-author-not-defined-in-authors-file/