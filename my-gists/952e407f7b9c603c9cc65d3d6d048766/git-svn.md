# Migrate Archive Google Code SVN to Git

## Requirements
- git
- git-svn

## Setup¹
~~~
$ sudo apt-get install git
$ sudo add-apt-repository ppa:git-core/ppa
$ sudo apt-get update
$ sudo apt-get install git-svn
~~~
¹ Ubuntu 14.04

## How To
1. Download svn dump from Google archive.
2. Create a local svn repo by load the svn dump.
3. Start svn daemon.
4. Create `authors.txt` to map all svn users to git users.
5. Create a bare git repo.
6. git svn clone.
7. Add git remote then push.
8. Done.

```
$ wget https://storage.googleapis.com/google-code-archive-source/v2/code.google.com/your-google-code-project/repo.svndump.gz
$ gunzip repo.svndump.gz
$ svnadmin create /tmp/repo1
$ svnadmin load /tmp/repo1/ < repo.svndump
$ svnadmin --foreground -d
```

Start a new terminal Window
```
$ git svn --stdlayout -A authors.txt clone svn://localhost/tmp/repo1/
$ cd repo1
$ git remote add origin https://repo.git
$ git push --set-upstream origin master
```

## authors.txt
Must map all svn users to git users.
```
user1 = user1 <user1@email.com>
user2 = user2 <user2@email.com>
(no author) = user3 <user3@email.com>
```

## Credits
- https://dominikdorn.com/2016/05/how-to-recover-a-google-code-svn-project-and-migrate-to-github/
- https://docs.gitlab.com/ee/workflow/importing/migrating_from_svn.html
- https://www.guyrutenberg.com/2011/11/09/author-no-author-not-defined-in-authors-file/