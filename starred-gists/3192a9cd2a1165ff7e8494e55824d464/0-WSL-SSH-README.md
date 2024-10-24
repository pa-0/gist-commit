## Install linux subsystem Ubuntu 18.04
See [Microsoft's WSL install guide for windows 10](https://docs.microsoft.com/en-us/windows/wsl/install-win10) for details.

Work-in-progress - command line only install:
* Open Powershell as Administrator and run:  
  `Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux`
* Open Windows App Store
  * Search for "Ubuntu" and install **Ubuntu 18.04**
  
(work in progress - command line install steps):
* Download linux system system: 
  `Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile Ubuntu1804.zip -UseBasicParsing`
  * Install it

## Setup open-ssh server
* Install openssh-server (found I needed to remove the original package first)  
  ```
  apt remove openssh-server
  apt update
  apt install openssh-server
  ```
* Modify default port used by editing `/etc/ssh/sshd_config `  
  ``
  Port 2218 # change from 22
  AllowUsers dayne # add this line with your usename
  ``
* Start service  
  `sudo /etc/init.d/ssh start`
* Add 2218 to windows firewall (see below)
* Then try to ssh in:  ssh username@windowsbox.lan -p 2218
  
## Windows Firewall settings:

* Windows Defender Firewall -> Advanced Settings 
* Windows Defender Firewall with Advanced Security 
  * inbound rules -> Actions Tab -> New Rule
  * Port -> TCP, Specificed local ports: 2218 ->
  *  Allow the connection,
  *  Checked: Domain, Private
  *  Name: ubuntu1806ssh
  
### set ssh server to autolaunch on boot

See [harleyday's original gist](https://gist.github.com/harleyday/76a103a1a0ca97c6f33706e4a8cc3307) for details.

* Set Ubuntu-18.04 as default
  * Open Windows PowerShell  
  ```
  wslconfig /l   # list your linux subsystems
  wslconfig /setdefault Ubuntu-18.04 # set default
  bash.exe       # launch default WLS
  lsb_release -a # verify you've got Ubuntu 18.04.1
  ```
* Enable passwordless sudo to start openssh:
  * `visudo` and add the following at the end of the file:  
  ```
  %sudo ALL=NOPASSWD: /etc/init.d/ssh
  ```
* Put `win-start-linux.vbs` in Startup folder (available below) - this calls boot-linux.bat on login.
  * Open start menu: type `run` to Run Command
  * Then type `shell:startup` to open up your Startup folder
* Put `boot-linux.bat` in your Windows Documents directory (available below) - this call the boot.sh from within the WSL
* Put `boot.sh` in your WSL root (as `/boot.sh`) (available below) - this starts the openssh server
  * Note: this needs passwordless sudo to work
  