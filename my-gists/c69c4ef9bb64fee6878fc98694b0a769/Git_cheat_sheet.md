# Git Cheat Sheet

<https://gist.github.com/timdetering/9fe9d3ece2e1b2232589821fd7f33318>

A collection of common Git tips and tasks.

## Commits

### Removing an entire commit

I call this operation *"cherry-pit"* since it is the inverse of a _"cherry-pick"_. First identify the SHA of the commit you wish to remove. You can do this using `gitk --date-order` or using `git log --graph --decorate --oneline`. You are looking for the 40 character SHA-1 hash ID (or the 7 character abbreviation). If you know the `^` or `~` shortcuts you may use those.

    git rebase -p --onto SHA^ SHA

Where `SHA` is the SHA-1 hash of the commit to remove. 

### Remove a file or directory from history ###

Replace `FILE_LIST` with the files or directories that you are removing.  This will rewrite local history.

    git filter-branch --tag-name-filter cat --index-filter 'git rm -r --cached --ignore-unmatch FILE_LIST' --prune-empty -f -- --all

## Submodules ##
### Cloning a repro with submodules ###
If you pass `--recursive` to the git clone command, it will automatically initialize and update each submodule in the repository.

    git clone --recursive https://github.com/chaconinc/MainProject

### Add a submodule

    git submodule add https://github.com/chaconinc/DbConnector

### List submodules ###
    git submodule status

### Initialize (update) ###
    git submodule update --init

### Remove a submodule ###
Newer  Git versions have the `deinit` command:

    git submodule deinit <path>

Pass `--all` without the path to unregister all submodules in the working tree.

#### Old way ####
1. Delete the relevant section from the _.gitmodules_ file
1. Stage the _.gitmodules_ changes `git add .gitmodules`
1. Delete the relevant section from _.git/config_
1. Run `git rm --cached path_to_submodule` (no trailing slash)
1. Run `rm -rf .git/modules/path_to_submodule`

### Move/Rename a submodule ###
Since git 1.8.5, `git mv old/submod new/submod` works as expected and does all the plumbing for you.


## CVS (Concurrent Versions System) ##
CVS (Concurrent Versions System) is an old-school source control program.

### Import from CVS ###
**NOT WORKING**

To import a CVS repository run:

    git cvsimport -C target-repo -r cvs -k -vA authors-file.txt -d $CVSROOT module

or

    git cvsimport -C target-repo -r cvs -k -o master -v -d :pserver:anonymous@reponame.cvs.sourceforge.net:/cvsroot/path ModuleName

Where:

 - `target-repo` is the directory to keep my local copy of the repository.
 - `cvs` is the name to use for referencing the remote repository. For example, `cvs/master`, `cvs/HEAD`, etc.
 - `authors-file.txt` is the file that contains the matches between CVS account and Name+email, each line contains `userid=User Name <useremail@hostname>`
 - `$CVSROOT` is the CVS repository server. If importing anonymously from a SourceForge <https://sourceforge.net> project repository, then use: `:pserver:anonymous@project_name.cvs.sourceforge.net:/cvsroot/project_name`
 - `module` is the module inside of the repository to clone. If the repository has only one module, then likely will be the same as `project_name`.

#### Issues: ####
`Could not start cvsps: No such file or directory`

#### Example: ####
    git cvsimport -C d20sharp.git-cvs -r cvs -k -v -d :pserver:anonymous@d20sharp.cvs.sourceforge.net:/cvsroot/d20sharp d20sharp

## SVN (Apache Subversion) ##

### Import ###
    git svn clone https://myproject.svn.codeplex.com MyProject.git-svn -s

`-s` = If your SVN repo follows standard naming convention where main source is in “trunk”, branches are created in “branches”.

I personally prefer to add the `.git-svn` extension to local repository directories to indicate the folder is a SVN mirror.


#### Issues: ####
Ran into this `git svn clone` issue:

    > git svn clone https://quantitysystem.svn.codeplex.com/svn
    ...
    > r31852 = 136be6269406386f72328af19ff177686d426252 (refs/remotes/git-svn)
              M   QuantitySystemSolution/QuantitySystem.Runtime/RuntimeTypes/QsMatrixOperations.cs
              M   QuantitySystemSolution/QuantitySystem.Runtime/RuntimeTypes/QsMatrix.cs
              M   QuantitySystemSolution/QuantitySystem.Runtime/Runtime/QsVar.cs
      QuantitySystemSolution/QuantitySystem.Runtime/Runtime/QsNamespace.cs was not found in commit 136be6269406386f72328af19ff177686d426252 (r31852)

To workaround the issue without spending too much time, I re-cloned the repository from the trouble commit forward:

    > git svn clone -r31853:HEAD https://quantitysystem.svn.codeplex.com/svn QuantitySystem.git-svn

Or

    > git svn clone -r 1:11 --stdlayout https://wtorrent-project.googlecode.com/svn/ wtorrent.git-svn
    ...  
    > cd wtorrent.git-svn
    > git svn fetch -r 15:HEAD

## References ##
 * On undoing, fixing, or removing commits in git <https://sethrobertson.github.io/GitFixUm/fixup.html>
 * Submodules - Git <https://git-scm.com/book/en/v2/Git-Tools-Submodules>
 * List submodules in a git repository - Stack Overflow <http://stackoverflow.com/questions/12641469/list-submodules-in-a-git-repository>
* How to git-svn clone the last n revisions from a Subversion repository? - Stack Overflow <http://stackoverflow.com/questions/747075/how-to-git-svn-clone-the-last-n-revisions-from-a-subversion-repository>
 * Removing and purging files from git history <http://blog.ostermiller.org/git-remove-from-history>
 * <http://stackoverflow.com/questions/4604486/how-do-i-move-an-existing-git-submodule-within-a-git-repository>
 * git-cvsimport Documentation - Git <https://git-scm.com/docs/git-cvsimport>
 * How to import and keep updated a CVS repository in Git? - Stack Overflow <(http://stackoverflow.com/questions/11362676/how-to-import-and-keep-updated-a-cvs-repository-in-git>
 * cvs2git - Tigris.org <http://cvs2svn.tigris.org/cvs2git.html>

