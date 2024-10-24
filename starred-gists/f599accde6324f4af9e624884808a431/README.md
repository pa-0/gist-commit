WSL is mounted on the c drive and the system32 path, a system folder which does not permit users to have full access, because of this, it is important to install applications from your default users home path `~`, this is where this user has full access permissions and will ensure that all the applications and interactions will complete withouth any access permission errors.

as mentioned above you should not need to modify permissions manually except in rare cases but if you do, the following snippets might help you.

before starting, if you struggle to undrestand certain commands or snippets you can use the following [service](https://explainshell.com/).

in order to debug any permission related issues the first step should be to start a bash window that will echo all commads that are executed:
```
bash --login -x
```

you can then view all permissions on all files and directories in the current path by:
```
ls -l
```
to view permissions on a specific file:
```
ls -l | grep 'filename'
```
overall description of the different fields:

![alt text](https://user-images.githubusercontent.com/7329422/89122008-5647c500-d4b3-11ea-82cc-731a4ca36894.png)

use the following command to see what groups you belong to:
```
id
```
use the following command to see your user name:
```
whoami
```

to change permissions you have two opetions, chmod and chown, In simple terms chown is used to change the ownership of a file while chmod is for changing the file mode bits.

- [chown defines who owns the file](https://ss64.com/bash/chown.html).
- [chmod defines who can do what](https://ss64.com/bash/chmod.html)

[have a look at this picture to help you decide](https://gist.github.com/farhad-taran/92d44f52d61f66d0b0fa11146db86986#gistcomment-3401043)

to elevate a user to `root`:
```
sudo usermod -a -G root ftaran
```
to login and run commands as sudo:
```
sudo -i 
sudo -s
```
give ownership of all directories that have brew as a prefix to the current user:
```
sudo chown -R $(whoami) $(brew --prefix)/*
```



