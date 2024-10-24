# Table of Contents

 - [Before we start](#before-we-start)
 - [Install WSL2 & Ubuntu](#install-wsl2--ubuntu)
 - [Install a GUI Environment](#install-a-gui-environment)
 - [Set up an X Server](#set-up-an-x-server)
   - [If you choose VcXsrv](#if-you-choose-vcxsrv)
   - [If you choose X410](#if-you-choose-x410)
 - [Further Fixes and Enhancements](#further-fixes-and-enhancements)
   - [Make Ubuntu Desktop recognize the Internet connection](#make-ubuntu-desktop-recognize-the-internet-connection)
   - [Enable audio output in WSL2](#enable-audio-output-in-wsl2)
   - [Create a unique hostname to connect to WSL2](#create-a-unique-hostname-to-connect-to-wsl2)

# Before we start

If you want to uninstall Ubuntu (either because you messed up the steps and want to restart, or you don't want WSL anymore), remember to shutdown WSL before uninstall the store app:
```powershell
wsl --shutdown
```
Then you can safely right click on Ubuntu and click "uninstall".

# Install WSL2 & Ubuntu

Taken from https://docs.microsoft.com/en-us/windows/wsl/install-win10

#### Enable the related features in Windows

Run following in powershell:
```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

#### Get the Linux kernel update package

Download and install this (may need restart):
https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi

#### Set WSL2 as the default version

Run in powershell:
```powershell
wsl --set-default-version 2
```

#### Install Ubuntu

Go to Microsoft store, search for `ubuntu` and install Ubuntu latest.

Open the newly installed app (which should open as terminal), then follow the instructions to set up linux account and password.

# Install a GUI Environment

Taken from 
 - https://www.most-useful.com/ubuntu-20-04-desktop-gui-on-wsl-2-on-surface-pro-4.html
 - https://gist.github.com/Ta180m/e1471413f62e3ed94e72001d42e77e22

#### Update the newly installed distro before everything else

Run in Ubuntu terminal:
```bash
sudo apt-get update
sudo apt-get upgrade
```

#### Use `tasksel` to easily install the packages we need

Run in Ubunti terminal:
```bash
sudo apt install tasksel
sudo tasksel
```

A menu should then appear, allowing you to choose the tasks to be installed.
Use arrow keys to navigate, press <kbd>Space</kbd> to toggle the tasks to be installed.
Choose whatever you want, but make sure to choose the desktop environment `Ubuntu Desktop`.
Press <kbd>Enter</kbd> to start the installation.

#### Enable `systemd`

Run the following in Ubuntu terminal:
```bash
git clone https://github.com/DamionGans/ubuntu-wsl2-systemd-script.git
cd ubuntu-wsl2-systemd-script/
bash ubuntu-wsl2-systemd-script.sh
```

#### Shutdown Ubuntu
Close all Ubuntu terminals, then run the following in **powershell**:
```powershell
wsl --shutdown
```

# Set up an X Server

Taken from
 - https://www.most-useful.com/ubuntu-20-04-desktop-gui-on-wsl-2-on-surface-pro-4.html
 - https://x410.dev/cookbook/wsl/using-x410-with-wsl2/

#### Set up a launch script for the desktop

Find a safe place in Windows to create a file `start_desktop.sh`.

Paste the following inside:
```bash
# Define necessary environment variables
export DISPLAY="$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }'):0.0"
export DESKTOP_SESSION="ubuntu"
export LIBGL_ALWAYS_INDIRECT=1
export GDMSESSION="ubuntu"
export XDG_SESSION_DESKTOP="ubuntu"
export XDG_CURRENT_DESKTOP="ubuntu:GNOME"
export XDG_SESSION_TYPE="x11"
export XDG_BACKEND="x11"
export XDG_SESSION_CLASS="user"
export XDG_DATA_DIRS="/usr/local/share/:/usr/share/:/var/lib/snapd/desktop"
export XDG_CONFIG_DIRS="/etc/xdg"
export XDG_RUNTIME_DIR="$HOME/xdg"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share" 
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DESKTOP_DIR="$HOME/Desktop"
export XDG_DOCUMENTS_DIR="$HOME/Documents"
export XDG_DOWNLOAD_DIR="$HOME/Downloads"
export XDG_MUSIC_DIR="$HOME/Music"
export XDG_PICTURES_DIR="$HOME/Pictures"
export XDG_PUBLICSHARE_DIR="$HOME/Public"
export XDG_TEMPLATES_DIR="$HOME/Templates"
export XDG_VIDEOS_DIR="$HOME/Videos"
# Start desktop environment
gnome-session
```

We will use this script later.

From now on you have the option to choose between two X servers: [VcXsrv](https://sourceforge.net/projects/vcxsrv/) which is free, or [X410](https://x410.dev/) which is paid but offers a better experience by targeting Windows 10 only.

If you choose VcXsrv, [continue below](#if-you-choose-vcxsrv).

If you choose X410, [skip to the related part](#if-you-choose-x410).

## If you choose VcXsrv

#### Set up VcXsrv

Download and install VcXsrv:
https://sourceforge.net/projects/vcxsrv/

**When a firewall prompt appears while you are using VcXsrv, make sure to allow connections on BOTH private and public networks.**

Double click `XLaunch` to start. In the menu that appears, choose any one of the display options **except** Multiple Windows.
Set the display number to `0` and click next.

Choose "Open session via XDMCP" and click next.

Choose "Connect to host" in this page and type in `127.0.0.1` in the text box. Leave everything else unchecked, then click next.

Check everything in this page and leave the "additional arguments" text box empty. Click next.

In this last page, click "Save Configuration" to save the config in an XLaunch file. Place the file next to the `start_desktop.sh` we created above.

Click cancel after saving. (Clicking finish would start the X server and give you an empty window.)

#### Create a shortcut script

In the same directory as the `start_desktop.sh` and the XLaunch file, create a `ubuntu.bat` with the follow content:
```batch
start "" "config.xlaunch"
ubuntu.exe run "if [ -z \"$(pidof gnome-session)\" ]; then bash /mnt/c/Utilities/Ubuntu/start_desktop.sh; pkill '(gpg|ssh)-agent'; fi;"
```
Note that you need to replace the `/mnt/c/Utilities/Ubuntu/start_desktop.sh` part with the full path to your `start_desktop.sh` script. In my case, the script is located at `C:\Utilities\Ubuntu\start_desktop.sh`, so I would write `/mnt/c/Utilities/Ubuntu/start_desktop.sh`.

#### Done!

Double click `ubuntu.bat` to launch the GUI. `ubuntu.bat` would be your shortcut to launch the GUI from now on. You don't need to repeat any of the above set up.

## If you choose X410

#### Set up X410

Download and install X410:
https://x410.dev/

**When a firewall prompt appears while you are using X410, make sure to allow connections on BOTH private and public networks.**

#### Create a shortcut script

In the same directory as the `start_desktop.sh`, create a `ubuntu.bat` with the follow content:
```batch
start /B x410.exe :0 /desktop /public
ubuntu.exe run "if [ -z \"$(pidof gnome-session)\" ]; then bash /mnt/c/Utilities/Ubuntu/start_desktop.sh; pkill '(gpg|ssh)-agent'; fi;"
taskkill.exe /IM x410.exe
```
Note that you need to replace the `/mnt/c/Utilities/Ubuntu/start_desktop.sh` part with the full path to your `start_desktop.sh` script. In my case, the script is located at `C:\Utilities\Ubuntu\start_desktop.sh`, so I would write `/mnt/c/Utilities/Ubuntu/start_desktop.sh`.

The first line of the above script contains the switch `/desktop`. This starts X410 in **Desktop** mode. You may change this to `/wm` to start X410 in **Windowed Apps** mode.

#### Done!

Double click `ubuntu.bat` to launch the GUI. `ubuntu.bat` would be your shortcut to launch the GUI from now on. You don't need to repeat any of the above set up.

# Further Fixes and Enhancements

Taken from
 - https://www.most-useful.com/ubuntu-20-04-desktop-gui-on-wsl-2-on-surface-pro-4.html#Login%20With%20VcXsrv%20in%20XDMCP%20mode
 - https://x410.dev/cookbook/wsl/enabling-sound-in-wsl-ubuntu-let-it-sing/

The following sections are optional fixes and enhancements. Proceed as you wish.

## Make Ubuntu Desktop recognize the Internet connection

You may notice a weird situation where the Ubuntu desktop claims that you are offline, but web browsers work just fine. This can be easily fixed.

Run in Ubuntu terminal:
```bash
sudo rm -rf /etc/netplan/*.yaml
sudo nano /etc/netplan/01-network-manager-all.yaml
```

In the editor that appears, copy and paste the following **exactly**:
```yaml
# Let NetworkManager manage all devices on this system
network:
  version: 2
  renderer: NetworkManager
```

When you are done, press <kbd>Ctrl</kbd>+<kbd>X</kbd>, then <kbd>Y</kbd>, then <kbd>Enter</kbd> to save and exit the editor.

Finally, run the following in Ubuntu terminal:
```bash
sudo netplan generate
sudo netplan apply
sudo service network-manager restart
```

Ubuntu should now show an active network connection.

## Enable audio output in WSL2

The current version of WSL2 does not support audio output directly, but there is a workaround by forwarding sound using PulseAudio.

Download PulseAudio for windows here:
https://www.freedesktop.org/wiki/Software/PulseAudio/Ports/Windows/Support/

Unzip and put the content in a safe folder.

Edit `etc\pulse\default.pa` (using any text editor is fine, e.g. notepad)

Line 42:

from `load-module module-waveout sink_name=output source_name=input`

to `load-module module-waveout sink_name=output source_name=input record=0`

Line 61:

from `#load-module module-native-protocol-tcp`

to `load-module module-native-protocol-tcp listen=0.0.0.0 auth-anonymous=1`

Edit `etc\pulse\daemon.conf`

Line 39:

from `; exit-idle-time = 20`

to `exit-idle-time = -1`

After configuration, double click to run `bin\pulseaudio.exe`. Allow both private and public connections in the firewall prompt.
You may ignore any warnings and errors in the output.

Close `bin\pulseaudio.exe`.

Edit `start_desktop.sh`:
```bash
# Define necessary environment variables
export DISPLAY="$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }'):0.0"
export DESKTOP_SESSION="ubuntu"
export PULSE_SERVER=tcp:$(cat /etc/resolv.conf | grep nameserver | awk '{ print $2 }')
export LIBGL_ALWAYS_INDIRECT=1
export GDMSESSION="ubuntu"
export XDG_SESSION_DESKTOP="ubuntu"
export XDG_CURRENT_DESKTOP="ubuntu:GNOME"
export XDG_SESSION_TYPE="x11"
export XDG_BACKEND="x11"
export XDG_SESSION_CLASS="user"
export XDG_DATA_DIRS="/usr/local/share/:/usr/share/:/var/lib/snapd/desktop"
export XDG_CONFIG_DIRS="/etc/xdg"
export XDG_RUNTIME_DIR="$HOME/xdg"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share" 
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DESKTOP_DIR="$HOME/Desktop"
export XDG_DOCUMENTS_DIR="$HOME/Documents"
export XDG_DOWNLOAD_DIR="$HOME/Downloads"
export XDG_MUSIC_DIR="$HOME/Music"
export XDG_PICTURES_DIR="$HOME/Pictures"
export XDG_PUBLICSHARE_DIR="$HOME/Public"
export XDG_TEMPLATES_DIR="$HOME/Templates"
export XDG_VIDEOS_DIR="$HOME/Videos"
# Start desktop environment
gnome-session
```

Edit `ubuntu.bat`:

**If you are using VcXsrv:**
```batch
start "" "config.xlaunch"
start "" /B "C:\Utilities\pulseaudio\bin\pulseaudio.exe"
ubuntu.exe run "if [ -z \"$(pidof gnome-session)\" ]; then bash /mnt/c/Utilities/Ubuntu/start_desktop.sh; pkill '(gpg|ssh)-agent'; fi;"
taskkill.exe /IM pulseaudio.exe /F
```
Remember to change the paths `/mnt/c/Utilities/Ubuntu/start_desktop.sh` and `C:\Utilities\pulseaudio\bin\pulseaudio.exe`.

**If you are using X410:**
```batch
start /B x410.exe /desktop
start "" /B "C:\Utilities\pulseaudio\bin\pulseaudio.exe"
ubuntu.exe run "if [ -z \"$(pidof gnome-session)\" ]; then bash /mnt/c/Utilities/Ubuntu/start_desktop.sh; pkill '(gpg|ssh)-agent'; fi;"
taskkill.exe /IM x410.exe
taskkill.exe /IM pulseaudio.exe /F
```
Remember to change the paths `/mnt/c/Utilities/Ubuntu/start_desktop.sh` and `C:\Utilities\pulseaudio\bin\pulseaudio.exe` and change `/desktop` to `/wm` if you want.

You should be able to hear sound coming from Ubuntu when you launch `ubuntu.bat` again.

## Create a unique hostname to connect to WSL2

Since the IP address of WSL2 changes every time, it is more convenient to set up a unique hostname pointing to the IP address if you need to connect to WSL2 from Windows. Note that in our above setup, a workaround is used to save this hostname setup, but if you need other types of connections into the WSL2, you may find this hostname useful.

Download `wsl2host.exe`:
https://github.com/shayne/go-wsl2-host/releases/latest

In your Windows terminal of choice (command prompt/powershell...), run:
```powershell
.\wsl2host.exe install
```
Type in your Windows username and password when prompted.

After the installation, check if it is already working:
Launch Ubuntu, then in **powershell** (or cmd):
```powershell
ping ubuntu.wsl
```
If the ping is successful, we are done here.

If you are loggin into Windows with a Microsoft account, and the ping is unsuccessful (request timed out or the host `ubuntu.wsl` is not found), continue with the fix below.

Press <kbd>Win</kbd>+<kbd>R</kbd>, type in `services.msc` and press <kbd>Enter</kbd>.

Locate the `WSL2 Host` service. Trying to start the service should give you an error.

Right click on the service, choose "Properties" and choose the "Log On" tab.

Choose "This account" in the tab, then click "Browse...".

In the new dialog, click "Advanced...", then "Find Now".

Choose your username from the list, then click "OK" and "OK" again to close the 2 dialogs.

You should see your username appearing in the text box next to "This account". Enter and re-enter your password in the boxes below. Use your Microsoft account password instead of Windows Hello PIN.

Click "OK" to close the properties dialog. Try to start the service now. If it works, we are done here.

If it still fails, proceed with the following fix.

(If you are NOT using Windows 10 Home, skip this step) If you are using Windows 10 Home (check in Settings > System > About), you need to enable Local Security Policy first.

Create a file called `gpedit-enabler.bat` with the content:
```batch
@echo off 
@echo "This batch file from MajorGeeks.Com will enable Group Policy Editor (Gpedit.msc) on Windows 10 Home."
@echo "If this method fails, there are other methods to try at https://tinyurl.com/majorgeeksgpedit"
pushd "%~dp0" 

dir /b %SystemRoot%\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientExtensions-Package~3*.mum >List.txt 
dir /b %SystemRoot%\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientTools-Package~3*.mum >>List.txt 

for /f %%i in ('findstr /i . List.txt 2^>nul') do dism /online /norestart /add-package:"%SystemRoot%\servicing\Packages\%%i" 
pause
```
(File content obtained from: https://www.majorgeeks.com/files/details/add_gpedit_msc_with_powershell.html)

Save and run the file. You should be able to access Local Security Policy now.

In the task bar search box, type Local Security Policy and run it as administrator.

Go to "Local Policies" > "User Rights Assignment" and double click on "Log on as a service".

Click "Add User or Group...". You should recognize the dialog box that appears. Go through the same procedure as in service properties to add your username into "Log on as a service Properties".

Once you are done, click "OK" to close the properties dialog. you can also close Local Security Policy now.

Go to Windows 10 Settings > Accounts > Sign-in options. Turn off "Require Windows Hello sign-in for Microsoft accounts".

Press <kbd>Win</kbd>+<kbd>L</kbd> to lock your computer, then choose password in sign-in options and sign in with your Microsoft account password.

Go back to Services (if you have already closed it, press <kbd>Win</kbd>+<kbd>R</kbd>, type in `services.msc` and press <kbd>Enter</kbd> to open it). Find the "WSL2 Host" service and start it. It should start without error now.

In powershell, run
```powershell
wsl --shutdown
```

Then, launch Ubuntu again. You should now be able to `ping ubuntu.wsl`. This hostname always points to the IP address of Ubuntu.