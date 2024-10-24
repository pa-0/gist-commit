# Open PowerShell as Administrator and run
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

# optional: switch to WSL2
https://docs.microsoft.com/en-us/windows/wsl/wsl2-install

dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
wsl --set-version ubuntu 2
wsl --set-default-version 2

# install Ubuntu from Microsoft Store
https://www.microsoft.com/en-us/p/ubuntu/9nblggh4msv6?activetab=pivot:overviewtab

# update apt packages
sudo apt-get update && sudo apt-get dist-upgrade

# install zsh
sudo apt install zsh

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# powerlevel theme
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k

# zsh-plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# rvm, ruby and colorls
# sudo apt-get install software-properties-common
# sudo apt-add-repository -y ppa:rael-gc/rvm
# sudo apt-get update
# sudo apt-get install rvm

echo insecure >> ~/.curlrc
curl -L https://get.rvm.io | bash
# restart terminal
rvm install ruby
gem install colorls

# add rvm to path
export PATH=$PATH:/opt/rvm/bin:/opt/rvm/sbin


# nvm and nodejs
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.1/install.sh | bash

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" 
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

nvm install node

# cleanup - remove unused packages
sudo apt autoremove

# seting git
git config --global user.name "Oleh Melnyk"
git config --global user.email "oleh.melnyk@gmail.com"
git config --global core.autocrlf false

# if wsl does not work with VPN
# just add IP > bitbucket.com to /etc/hosts

# using SSH keys from Windows
cd ~
mkdir .ssh
chmod 700 .ssh
cd .ssh
cp /mnt/c/Users/Oleh/.ssh/id_rsa* .
chmod 600 id_rsa
chmod 644 id_rsa.pub

# change port (if needed) and set PasswordAuthentication yes
sudo nano /etc/ssh/ssh_config

# pacthed nerd font mono for VSCode
https://github.com/haasosaurus/nerd-fonts/blob/regen-mono-font-fix/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete%20Mono%20Windows%20Compatible.ttf

# if git shows all fiels are modifed -
git config --global core.filemode false

https://github.com/microsoft/WSL/issues/2318#issuecomment-314631096
git config --global core.autocrlf input
