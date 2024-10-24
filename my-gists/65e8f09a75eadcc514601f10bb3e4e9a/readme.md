
## Installing the distro:
### Make Windows ready:
Open PowerShell as Administrator and run:
```ps
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```
Restart your computer when prompted.

### Install distro:
To install distro we use LxRunOffline which gives us the option to install the distro on any directory that we want.
Get [LxRunOffline](https://github.com/DDoSolitary/LxRunOffline) and extract it, then:

1. Download the latest long term support Ubuntu from `https://lxrunoffline.apphb.com/download/Ubuntu/bionic` or download your prefered distro from [LxRunOffline wiki](https://github.com/DDoSolitary/LxRunOffline/wiki) and copy it to LxRunOffline directory.

2. Run PowerShell in LxRunOffline.

##### Install:

Install the distro and give it a name, you will use this name to create shortcut and set this distro to default distro later:
```
$ .\LxRunOffline.exe install -n Ubuntu -f .\Distros\ubuntu-focal-core-cloudimg-amd64-root.tar.gz -d C:\WSL\Ubuntu

-n : Desired name for your distro
-f : Distro file that we downloaded earlier
-d : Desired installation directory
```

Create shortcut:

```
$ .\lxrunoffline s -n Ubuntu -f .\Ubuntu.lnk -i .\Icons\ubuntu.ico

-n : The name of the distro
-f : The location for the shortcut to be created
-i : Desired icon file to be used.
```

Set as default so `wsl` loads this distro :

```
$ .\lxrunoffline sd -n Ubuntu
```

If you want to avoid appending Windows `$PATH` (optional) :
```
$ .\lxrunoffline sf -n Ubuntu -v 5
```

You are ready, run your distro using the shortcut you created and move to the next step.

#### User Management:

Install `sudo`:

```
$ apt update
$ apt-get install sudo -y
```

Create user & configure password and give your user root access:

```
$ useradd --create-home -d /home/username username

$ passwd username
$ usermod -aG sudo username
```

Set a password for root user as well:

```
passwd root
```

Change to your user:
```
$ su - username
$ bash
$ echo $UID
```

Set your user as default user of `WSL` (in PowerShell :

```
$ .\lxrunoffline su -n Ubuntu -v 1000
```



### Install common tools:

```
$ sudo apt-get install software-properties-common

$ sudo apt-get update && sudo apt-get upgrade
```

### Install software:

Install some development tools:
```
$ sudo apt-get install git zsh curl make build-essential 
$ sudo apt-get install libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev python-openssl imagemagick libmagickwand-dev
```

###  Install [`oh-mh-zsh`](https://ohmyz.sh/) and configure `zsh`:
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
gedit ~/.zshrc
```

Set `zsh` as your default terminal:
```
chsh -s $(which zsh)
```

###  Install [`asdf`](https://github.com/asdf-vm/asdf) version manager:
```
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0
```
~/.bashrc:
```
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
```

~/.zshrc:
```
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.zshrc
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.zshrc
```
Install one of the dozens of [plugins](https://github.com/asdf-vm/asdf-plugins):
```
asdf plugin-add python https://github.com/tuvistavie/asdf-python.git  
asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git 

asdf plugin-add nodejs
# Imports Node.js release team's OpenPGP keys to main keyring: 
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring 
  

```
You can update the plugins all at once with this simple command:
`asdf plugin-update --all`

You can see what versions are available for a particular language like this:
```
asdf list all ruby  
asdf list all nodejs
asdf list all python
```
Then you can install any version you need like this:
```
asdf install ruby 2.4.2  
asdf install nodejs 8.7.0  
asdf install erlang 20.1
```
After you install a particular language version, I always set one as the system default like this:
```
asdf global ruby 2.4.2  
asdf global elixir 1.5.2
```
And in a particular project directory, I can set it to use any other version, just for that project:
```
asdf local ruby 2.3.4
```
The command above will write a `.tool-versions` file to the directory you're at when you ran it. It will contain the language and version you chose, so whenever you go back to that directory ASDF will set the correct version for the language you need. The previous `asdf global <language>` command is actually writing a `.tool-versions` file to your home directory. The local config override the home directory version.


Sometimes, if a dependency is missing and an install fails, you must manually remove it before attempting to reinstall, so you have to do:
```
asdf remove <language> <version>
```

If global installs for npm fail, that's because WSL only has `root` user. Do:
`npm install -g electron --unsafe-perm=true --allow-root --scripts-prepend-node-path`


## Optional Steps:

### Install `yarn`:
```
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

sudo apt-get update && sudo apt-get install --no-install-recommends yarn

```

Add to `~/.bashrc` and `~/.zshrc`:
`
export PATH="$(yarn global bin):$PATH"
`

### Upgrade distro:
`sudo apt-get dist-upgrade`

### Run GUI Apps:

Download and install `VcXsrv` and add this to `~/.bashrc` and `~/.zshrc` :
`export DISPLAY=:0`
Then you can run GUI apps like this:
`gedit /path/to/your/file/`

### Autoclean
```
sudo bash -c "apt-get update && apt-get -y upgrade && apt-get -y autoremove && apt-get -y clean"
```

### Install `mlocate` (Optional: to fix mlocate errors)
```
$ sudo apt-get install mlocate
$ sudo updatedb
````
then add `/mnt` to `PRUNEPATHS` in `/etc/updatedb.conf` in order to avoid indexing Windows files.

