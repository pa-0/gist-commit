# Getting wget for Windows
For most of the Unix-like work I do on Windows, the small set of utilities provided by [Git](https://git-scm.com/downloads) for Windows suffice. But just yesterday I found myself needing [wget]() to complete a small (Windows) shell script I wanted to write.

In my search for a solution I finally took a closer look at the [Git for Windows SDK](https://github.com/git-for-windows/git/wiki/Technical-overview), and lo! found it includes a wget binary for Windows.

There are a few ways I could have gone with this. The "right" way would have been to replace my existing install with a recompiled Git for Windows. But I wasn't going to exert that kind of effort to get a single utility. What I did instead was install wget for the SDK and then copy it and its one dependency to where I had Git installed.

First install the SDK and open its shell (```msys1_shell.cmd```). Then install wget using pacman(```pacman -Sy wget```).

Next, open a Windows terminal as Admin and copy the wget executable and its supporting library to where you have Git installed:

```
PS C:\Windows\System32> copy C:\git-sdk-64\usr\bin\wget.exe "C:\Program Files\Git\usr\bin"
PS C:\Windows\System32> copy C:\git-sdk-64\usr\bin\msys-pcre2-8-0.dll "C:\Program Files\Git\usr\bin"
```
