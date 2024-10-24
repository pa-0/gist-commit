#!/bin/bash

##
# Ubuntu WSL Ansible installation and setup script
##

# Configuration variables
TIMEZONE=""
WINDOWS_USER=""
LINUX_USER=""
CUSTOM_CA_PATH=""
GIT_REPO_URL=""

if [ -z "$TIMEZONE" ]; then
  read -p "Enter your local timezone: " TIMEZONE
fi
if [ -z "$WINDOWS_USER" ]; then
  read -p "Enter your Windows username: " WINDOWS_USER
fi
if [ -z "$LINUX_USER" ]; then
  read -p "Enter your Linux username: " LINUX_USER
fi

# APT Update and Upgrade
sudo apt update && sudo apt upgrade -y

# Set timezone
sudo apt install -yq tzdata && \
    sudo ln -fs /usr/share/zoneinfo/$TIMEZONE /etc/localtime && \
    sudo dpkg-reconfigure -f noninteractive tzdata

# Enable systemd
if [ ! -f /etc/wsl.conf ]; then
  sudo tee -a /etc/wsl.conf <<EOF
[boot]
systemd=true
[user]
default=$USER
EOF
fi

# Install custom CA certificates
if [ -z "$CUSTOM_CA_PATH" ]; then
  read -p "Enter WSL path to custom Root CA certificates: " CUSTOM_CA_PATH
fi
if [ -z "$CUSTOM_CA_PATH" ]; then
  echo "No custom CA certificates provided. Skipping..."
else
  sudo mkdir /usr/local/share/ca-certificates/extra
  sudo cp $CUSTOM_CA_PATH/* /usr/local/share/ca-certificates/extra/
  if [ -f /usr/local/share/ca-certificates/extra/zscaler_root_ca.cer ]; then
    sudo openssl x509 -inform DER -in /usr/local/share/ca-certificates/extra/zscaler_root_ca.cer -out /usr/local/share/ca-certificates/extra/zscaler_root_ca.crt
  fi
  sudo update-ca-certificates
fi

# Install base tools and Python 3 (required by Ansible)
sudo apt install -y curl wget netcat nano git mc whois bash-completion hstr libffi-dev libssl-dev python3-pip python3-venv sshpass
if ! grep -q 'export PATH=$PATH:~/.local/bin' ~/.bashrc; then
  echo "" >> ~/.bashrc
  echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
fi
python3 -m pip install --upgrade pip

# Install Ansible and it's dependencies
sudo apt install -y ansible
python3 -m pip install ansible-lint

# Copy SSH key from host and set permissions
mkdir ~/.ssh
rm ~/.ssh/id_rsa
cp /mnt/c/Users/$WINDOWS_USER/.ssh/id_rsa ~/.ssh/id_rsa
rm ~/.ssh/id_rsa.pub
cp /mnt/c/Users/$WINDOWS_USER/.ssh/id_rsa.pub ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/id_rsa && chmod 600 ~/.ssh/id_rsa.pub

# bash profile config
if ! grep -q "export LC_ALL='C.UTF-8'" ~/.bashrc; then
  hstr --show-configuration >> ~/.bashrc
  tee -a ~/.bashrc <<EOF
export LC_ALL='C.UTF-8'
export EDITOR=nano
EOF
fi

# Create ansible config file
rm ~/.ansible.cfg
tee -a ~/.ansible.cfg <<EOF
[defaults]
inventory=inventory
privatekeyfile=~/.ssh/id_rsa
remote_user=$LINUX_USER
roles_path=~/ansible/roles
filter_plugins=~/ansible/filter_plugins

[privilege_escalation]
become=True
EOF

# Copy git configuration from host
rm ~/.gitconfig
cp /mnt/c/Users/$WINDOWS_USER/.gitconfig ~/.gitconfig
git config --global http.sslBackend gnutls

# Add GitHub & Azure DevOps SSH keys
if ! grep -q "github.com" ~/.ssh/known_hosts; then
  ssh-keyscan -H github.com >> ~/.ssh/known_hosts
fi
if ! grep -q "ssh.dev.azure.com" ~/.ssh/known_hosts; then
  ssh-keyscan -H ssh.dev.azure.com >> ~/.ssh/known_hosts
fi

# Clone ansible repository
## You first need to set your SSH key in Azure DevOps
git clone $GIT_REPO_URL ~/ansible

### Install custom tools

# Install Oh-My-Posh
rm oh-my-posh-setup.sh
wget https://gist.githubusercontent.com/adeotek/b3b9997773172f5bbd0b4ff75bb2c5b2/raw/oh-my-posh-setup.sh
chmod +x oh-my-posh-setup.sh
./oh-my-posh-setup.sh

# Install Node.js
sudo curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt install -y nodejs
sudo npm install -g --upgrade npm

# Install Neovim
sudo apt install -y build-essential
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
rm nvim-linux64.tar.gz
if ! grep -q 'export PATH="$PATH:/opt/nvim-linux64/bin"' ~/.bashrc; then
  echo "" >> ~/.bashrc
  echo 'export PATH="$PATH:/opt/nvim-linux64/bin"' >> ~/.bashrc
  echo 'alias vim="nvim"' >> ~/.bashrc
fi
sudo npm install -g neovim
sudo npm install -g tree-sitter-cli
mkdir ~/.config
git clone https://github.com/adeotek/neovim-adeotek.git ~/.config/nvim
