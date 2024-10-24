## Setup WSL for development environment in powershell

```powershell
# Enabled WSL
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

wsl --status # Determine if you are on version 2
wsl --set-default-version 2 # If not already.
wsl --install --distribution ubuntu
```

## Inside WSL CLI

```bash

echo "Disable path sharing between windows"
sudo touch /etc/wsl.conf
echo """

[interop]
appendWindowsPath = false

[network]
generateResolvConf = true # was false but found workaround

""" | sudo tee -a /etc/wsl.conf

# sudo rm /etc/resolv.conf
# sudo touch /etc/resolv.conf
# sudo chattr -f +i /etc/resolv.conf

# TODO: Update first two nameserver entries to your company dns servers.
# TODO: Update 3rd name server
#echo """
#nameserver 192.168.1.1  # Your Corporate DNS Servers
#nameserver 192.168.1.50 # Your Corporate DNS Servers
#nameserver 8.8.4.4 # Your home dns or googles dns servers
#""" | sudo tee /etc/resolv.conf

# Follow instructions for wsl-vpnkit https://github.com/sakai135/wsl-vpnkit

# Reboot WSL After this is done
# Run in Powershell Window:
wsl --shutdown

echo "Setup Bash"
echo """
test -f ~/.profile && . ~/.profile
test -f ~/.bashrc && . ~/.bashrc
""" | tee -a ~/.bash_profile

sudo install -m 0755 -d /etc/apt/keyrings

echo "Updating to Git repo"
sudo add-apt-repository ppa:git-core/ppa
sudo apt update; sudo apt install git -y

echo "Installing dotnet"

wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt-get update; \
  sudo apt-get install -y apt-transport-https && \
  sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-6.0

echo ""
echo "Installing JQ"
sudo apt-get install jq -y

echo ""
echo "Installing pwsh"
sudo apt-get update
sudo apt-get install -y wget apt-transport-https software-properties-common
sudo apt-get update
sudo apt-get install -y powershell
pwsh -v

echo ""
echo "Installing Go"
sudo apt install -y golang
echo 'export PATH=$(go env GOPATH)/bin:$PATH' | tee -a ~/.profile
echo 'export GOPATH=$(go env GOPATH)/bin' | tee -a ~/.profile


echo ""
echo "Installing GVM - Go Lang Version Manager"
sudo apt-get install -y bison
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
# echo "Add this line to ~/.bash_profile"
# echo """
# export GVM_ROOT=/opt/gvm
# . $GVM_ROOT/scripts/gvm-default
# [[ -s “$GVM_ROOT/scripts/gvm” ]] && source “$GVM_ROOT/scripts/gvm”
# """ | tee -a ~/.profile

source ~/.bash_profile
sudo chown root:$USER -R /opt/gvm
sudo chmod g+rwx -R /opt/gvm
gvm install go1.19.3
gvm use go1.19.3

# tfenv deprecated.
# echo ""
# echo "Installing TF ENV"
# git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
# echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bash_profile
# echo 'export PATH="$HOME/.tfenv/bin:$PATH"' | tee -a ~/.profile
# sudo ln -s ~/.tfenv/bin/* /usr/local/bin
# sudo apt install -y unzip

echo ""
echo "Installing T ENV TFENV replacement"
echo "Repository with instructions: https://github.com/tofuutils/tenv"
choco install tenv

echo ""
echo "Installing Nodejs LTS"
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
node -v

echo ""
echo "Installing Nodejs Version manager"
export NVS_HOME="$HOME/.nvs"
git clone https://github.com/jasongin/nvs "$NVS_HOME"
. "$NVS_HOME/nvs.sh" install
echo 'export NVS_HOME="$HOME/.nvs"' | tee -a ~/.profile

echo ""
echo "Installing Azure CLI"
sudo apt-get update
sudo apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-get update
sudo apt-get install -y azure-cli
az version

echo ""
echo "Installing kubectl"
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
kubectl version

echo ""
echo "Installing Hashicorp Vault and packer"
curl https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install -y vault packer
vault --version

echo ""
echo "Installing sqlcmd"
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo apt-get update
export ACCEPT_EULA=Y 
sudo apt-get install -y mssql-tools unixodbc-dev
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' | tee -a ~/.profile
source ~/.bash_profile

# Install influxdb cli
echo ""
echo "Installing influxdb cli"
echo "deb https://repos.influxdata.com/ubuntu focal stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
sudo curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y influxdb2-cli

echo ""
echo "Installing k6"
echo "Setup GPG for root"
sudo gpg --gen-key
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install -y k6

echo ""
echo "Installing xk6"
go install go.k6.io/xk6/cmd/xk6@latest

echo ""
echo "Adding VSCode windows path to ~/.profile"
echo """

export PATH=\"/mnt/c/Program Files/Microsoft VS Code/bin:\$PATH\"

""" | tee -a ~/.profile

echo ""
echo "Adding bash Alias"
echo """

alias tf='terraform'
alias kb='kubectl'

""" | tee -a ~/.profile

echo "Setting up SSH agent"
mkdir ~/.ssh
chmod  0700 ~/.ssh
echo '''

env=~/.ssh/agent.env

agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ; }

agent_load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add ~/.ssh/id_ed25519
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add ~/.ssh/id_ed25519
fi

unset env

''' | tee -a ~/.profile

echo "Add Git Update Fork script"
cat <<EOF | tee -a ~/.gitconfig
[user]
	name = <Your Name Here>
	email = <Your Github user email here>
[alias]
  # Get the default branch for origin. This comes from StackOverflow
  # https://stackoverflow.com/a/44750379 This makes it so while we transition
  # away from using the "master" terminology the aliases work. The added
  # benefit is that it should work for any default branch name, so if people
  # use main, dev, develop, trunk, etc. the aliases should still function as
  # expected.
  #
  # Also, this alias is here because you can do nested aliases in git now! I
  # didn't realize that it was enabled in 2.20, so thanks again StackOverflow
  # https://stackoverflow.com/a/52863852
  def = !git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'

  # Rebase the current branch off the default branch (see def above). You can
  # also choose to pass in a branch name if you are trying to rebase from a
  # different branch.
  #
  brebase = !sh -c 'def=$(git def) && git checkout \${1:-\$def} && git fetch origin && git merge origin/\${1:-\$def} --ff-only && git checkout @{-1} && git rebase \${1:-\$def}' -

  # Pull the latest from upstream and push it to my fork at origin
  updef = !def=$(git def) && git checkout \$def && git fetch upstream && git merge upstream/\$def --ff-only && git push origin HEAD

  # Prune branches and delete any that are already merged into the default
  # branch borrowed from here:
  # https://stackoverflow.com/questions/6127328/how-can-i-delete-all-git-branches-which-have-been-merged
  pbranch = !sh -c 'def=$(git def) && git checkout \$def && git pull && git checkout - && git branch --merged | egrep -v "\\\\(^\\\\\\\\*\\\\|main\\\\)" | xargs git branch -d'
  
  undocommit = !git reset --soft HEAD~1

  squash = !git reset --soft main

EOF

echo "Restart Ubuntu WSL by running command in windows powershell"
echo "wsl --shutdown"
```

## Cisco AnyConnect VPN Bug

Cisco AnyConnect VPN client will block all WSL2 shells network connection.  It is a known bug.  To get around this, you must have a poswershell script change the interface priority to 1 for WSL and 6000 for the Cisco AnyConnect adapter.  This needs to run every time you connect to the VPN.  Thus requiring a scheduled task.  

Pre-Requisites:
You must have powershell 7 installed.

Attached are two files that will set this up.
* `UpdateAnyConnectInterfaceMetric.ps1` - Powershell Script
* `Update Anyconnect Adapter Interface Metric for WSL2.xml` - Scheduled Task

1. Copy powershell file `UpdateAnyConnectInterfaceMetric.ps1` to local box.  Preferrebly in C:\Scripts. Don't put it in your user folder
2. Open task scheduler
3. Import task
4. Update user account to your account.
5. Click Action Tab and edit `Start a program` action
6. Updated file path to the powershell script you downloaded earlier
7. Click OK 

You now will have network conectivity on and off vpn.

