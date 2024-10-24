## Install WSL2 (GNU/Winnux)
Do you want a way to bring the potential of Linux into Windows? Then try WSL (Windows Subsystem for Linux). 

This guide will cover the installation process + Arch Linux installation so that you can say "I use Arch btw" without actually using Arch btw. 

## Enable WSL features

Open `powershell` (Admin), and run these commands:
```
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```
Or, you could go to start menu > search for "Turn Windows features on or ff", and scroll down to find "Windows Subsystem for Linux".

You probably need to restart your PC afterwards, so restart your PC. 

## Install WSL

Run these commands in Administrator `powershell`:

```
wsl --install
wsl --set-default-version 2
```
You need the WSL2 kernel too:

Get this: https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi
And double click on the installer file.

You may need to restart your computer too. It's best to restart your computer now.

## Install Arch Linux (longer one)

Alright, now let's get to the fun part so that you can say "I use Arch BTW" and flex `neofetch` and `cmatrix` to your friends. 

First, you need to get `scoop`, which is a PowerShell package manager for Windows. First, launch Internet Explorer then open PowerShell **without admin**.

```
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

Invoke-WebRequest get.scoop.sh | Invoke-Expression
```
Then, run these commands to add the `extras` repository:

```
scoop install git
scoop bucket add extras
```

Now, use scoop to install `Arch.exe`

```
scoop install archwsl
```

**To install globally, run this command instead in PowerShell (admin):**
```
sudo scoop install archwsl
```

Finished, you've installed Arch Linux. Now, run `Arch.exe` in PowerShell to complete the next steps.

## ArchWSL setup (important !)

*It's important that you follow **all** of these steps in order*

**Pro tip:** When using `nano`, use your arrow keys to navigate. Press `Ctrl+S` to save and `Ctrl+X` to exit. You can also use `Ctrl+W` to find your country. 

**Pro tip #2:** If launching Arch on Windows terminal, go to drop down arrow > settings > Arch, and put this in "Command Line": `C:\Users\<WINDOWSUSERNAME>\scoop\shims\arch.exe`. This only works when you install it with `scoop`. 

Now, edit the `/etc/pacman.d/mirrorlist` file:

```
nano /etc/pacman.d/mirrorlist
```

Uncomment the lines (by removing the `#` in front of them) under your country's name. Again, use your arrow keys to scroll down to find your country or somewhere near your country. I'd recommend only uncommenting one country, and not all of the servers in a country.


Then, run this to update the system:

```
pacman -Syu
```
**Don't leave yet! Let's create a user.**
## Setting up a default user

This time, open the start menu and find "Arch Linux".

Add a sudoers group:
```
groupadd sudo
```
Then, run this command to install `vi`:
```
pacman -S vi
```
Now, run `sudo visudo` and uncomment these lines only:
```
%wheel ALL=(ALL:ALL) ALL

%sudo  ALL=(ALL:ALL) ALL
```
In this case, you need to press `i` to insert. Press `esc` and type `:wq` to save and exit.

Create a user:

```
useradd -m -G wheel,sudo -s /bin/bash <username>
```

Create a password for that user:
```
passwd <username>
```

Then open PowerShell on another window and run:

```
Arch.exe config --default-user <username>
```

## Linking the /home/USERNAME folder to your C:/Users/USERNAME folder

Copy the files first (use `sudo su`):

```
cp -r /home/USERNAME/.* /mnt/c/Users/WINDOWSUSERNAME
```
Then, remove the folder:

```
rm -r /home/USERNAME
```
Now, link the folder:
```
ln -s /mnt/c/Users/WINDOWSUSERNAME /home/USERNAME
```
Finished! Now, let's install an AUR helper

## AUR helper

Run this command to get `git` and `openssh`:

```
sudo pacman -S git openssh
```
Then, install the `base-devel` group:
```
sudo pacman -S --needed base-devel
```
Now, run these commands to get `yay`:
```
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si
```

## Goodies

Programming languages:
```
sudo pacman -S ruby nodejs python go crystal php jre-openjdk-headless dotnet-sdk
```

Task viewer (`bashtop`)

```
sudo pacman -S bashtop
```
`neofetch` for system info:
```
sudo pacman -S neofetch
```

`cmatrix` to fake hack:

```
sudo pacman -S cmatrix
```