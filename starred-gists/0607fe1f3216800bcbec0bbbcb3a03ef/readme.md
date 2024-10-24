WSL Installer for IOOPM
=======================

**Note: these scripts were written for WSL1 / Ubuntu 18.04, today 
it's easier to download Ubuntu from the Store and follow the linux
instructions on the course-web!**

***Best of luck with the course! (and make sure to have fun!)***

These scripts automatically install most of what 
is needed for the course IOOPM @ Uppsala University.

Remember that this is not an *officially* supported
environment - only the Linux terminals at the university
are. Thus, *always* check your code before turning in
an assignment on the terminals, git is super handy
for that, *and* is also a learning goal! Also good if
you experience any problems.

## Installing

***Step 0***

Update Windows to the latest version preferably build 1709 and 
later, see *FAQ* for builds tested. You can find the build number
in `About your PC`. Make sure your internet connection is *stable*, 
so it is probably a bad idea to do this during a lab! If something goes 
wrong, check the *FAQ*.

Also, if something is unclear you can refer to this [YouTube video](https://youtu.be/VNnrRFf1hB8).

### Step 3
Download `install.ps1` by right-clicking [this link](https://gist.githubusercontent.com/novium/fa877a4b2cd8013dfde2d8739a80bdcb/raw/bee6395a1d30028fa3976ed9b345b301378dcb2c/install.ps1)
and selecting "save as" *or* by clicking "Raw" in the right
corner of the file and saving the file to disk.

*Remember, it is good practice skimming thru any
script you download from the internet! Including
this one.*

### Step 4
Close and save all running applications since your 
computer **will reboot** during the installation.
Then use `cd` in Powershell (as an admin) to navigate to the 
directory where you saved the file and run 
`. .\install.ps1` (you don't need to download 
`resume.ps1` since it is downloaded from here
by the script).

**Important** During the installation after the restart 
it will say that Ubuntu is installing, after that it will
ask you to provide a username and a password. These are 
the ones used inside bash when using commands such as `sudo`.

### Step 5
**After entering your username and password type the command `exit` 
in the powershell window, it will ask for the password once more after
that and then continue installing!** Be sure to get a cup of coffee
since after typing your secure password 3 times you're probably in 
a dire need (and installing all the packages can take a while)!

You're done when you see the prompt `PS C:\Windows\system32>`, phew!
Now you can use Linux by opening up Powershell and using the command `bash`
or by running the Windows app `Ubuntu`.

From bash you have access to the entire Windows filesystem!

## FAQ

*1. Error `...\install.ps1 cannot be loaded`*

You need to update your security policy, to do that
open a Powershell window as an administrator and type
this command `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned`.
This option allows scripts to be run. You can change 
it back to `AllSigned` when you're done.

I recommend installing Chocolatey as a package manager
for Windows, then you can leave the policy as RemoteSigned :)

*2. Error appx package can't be sideloaded.*

Go to Settings, Update & Security, For Developers, and
press "Sideload apps" to allow apps to be sideloaded.

*3. Minimum Windows Version*

Definitely requires Windows 10. Tested with build 1803 
(*April 2018 Update*) and 1709 (*Fall Creators Update*).

*4. Temporary files*

As long as the installation finishes all the temporary
files should be deleted, otherwise they should be deleted
by Windows automatically during the next disk cleanup. If you want
to make sure - check that the directory `%temp%\ioopm` doesn't exist.

*5. `adduser: Please enter a username matching...`*

Ubuntu needs a lowercase username (think just letters an numbers) 
due to certain constraints. Try again with a lowercase username!

*6. Uninstalling* 

If you  want to uninstall you just need to uninstall
the `Ubuntu` app on Windows.

*7. AFL*

This program is a bit special, if it doesn't work, use the terminals 
or move the code and app to the *Linux* homefolder!

*8. Restarted but nothing happened*

First, wait a bit! It seems like it can take a few minutes before
some computers continue the script!

Try opening Powershell as an administrator and type `cd $env:TEMP\ioopm`,
from there, run the command `. .\resume.ps1` and continue from step 5 in 
the instruction. If this directory doesn't exist the installation probably
finished, try running `bash` again in a command prompt.

**Anything else? Catch Alexander at a lab!**