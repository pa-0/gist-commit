#!/bin/bash

##
# WSL Debian Angular dev environment setup
##

# Configuration variables
WINDOWS_USER=""
CUSTOM_CA_PATH=""
ARTIFACTORY_DOMAIN=""
ARTIFACTORY_REPO=""
GIT_REPO_URL=""
ANGULAR_APP_DIR=""
ANGULAR_APP_PATH=""

if [ -z "$WINDOWS_USER" ]; then
  read -p "Enter your Windows username: " WINDOWS_USER
fi

# APT update && upgrade
sudo apt update && sudo apt upgrade -y

# Install base tools
sudo apt install -y nano curl wget mc whois netcat-traditional jq fd-find ripgrep git bash-completion hstr

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
alias ll='ls -lAF'
EOF
fi

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

# Install Node.js
sudo curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt install -y nodejs
sudo npm install -g --upgrade npm
sudo npm install -g @angular/cli
sudo npm install -g nx@18.2.2

# Install .NET SDK and Tools
wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt update && sudo apt upgrade -y
sudo apt install -y dotnet-sdk-8.0
dotnet tool install -g Adeotek.DevOpsTools

# Create Artifactory NPM login script
rm ~/npm-login.sh
tee -a ~/npm-login.sh <<EOF
#!/bin/bash

read -p "Enter Artifactory username: " ARTIFACTORY_USER
read -p "Enter Artifactory key/token: " ARTIFACTORY_KEY

echo "//$ARTIFACTORY_DOMAIN/artifactory/api/$ARTIFACTORY_REPO/:\$(curl -u "\$ARTIFACTORY_USER":"\$ARTIFACTORY_KEY" https://$ARTIFACTORY_DOMAIN/artifactory/api/npm/auth/ | grep _auth | sed -r 's/\s+//g')" > ~/.npmrc
EOF
chmod +x ~/npm-login.sh

# Clone SwapOne UI repository
git clone $GIT_REPO_URL ~/$ANGULAR_APP_DIR
cd ~/$ANGULAR_APP_DIR/$ANGULAR_APP_PATH
npm install
npm install @nx/nx-linux-x64-gnu --save-dev

### Install custom tools

# Install ad configure Oh My Posh
rm oh-my-posh-setup.sh
wget https://gist.githubusercontent.com/adeotek/b3b9997773172f5bbd0b4ff75bb2c5b2/raw/oh-my-posh-setup.sh
chmod +x oh-my-posh-setup.sh
./oh-my-posh-setup.sh

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
