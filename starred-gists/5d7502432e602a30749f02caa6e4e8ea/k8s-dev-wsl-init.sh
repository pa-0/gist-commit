#!/bin/bash

# Update
sudo apt update && sudo apt upgrade -y

# Install tools
sudo apt install -y git nano wget curl mc netcat software-properties-common apt-transport-https

# Enable systemd
sudo tee -a /etc/wsl.conf <<EOF
[boot]
systemd=true
EOF

# Install Python pip
sudo apt install -y python3-pip
python3 -m pip install --upgrade pip
# Install Python 3.9
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt install -y python3.9

# Install NodeJs
sudo apt install -y nodejs

# Install Go
sudo apt install -y golang-go

# Install .NET
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt update && sudo apt upgrade -y
sudo apt install -y dotnet-sdk-7.0
sudo apt install -y dotnet-sdk-6.0

# Install .NET tools


# Docker
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get install -y ca-certificates curl gnupg lsb-release
wget --no-check-certificate -O- https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/docker.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update && sudo apt upgrade -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker $USER && newgrp docker

# Install kubectl
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

# Install MiniKube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb
#curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
#sudo install minikube-linux-amd64 /usr/local/bin/minikube
tee -a ~/.bashrc <<EOF

alias mkubectl="minikube kubectl --"
EOF


### Optional

## Oh My Posh
#chmod +x oh-my-posh-setup.sh
#./oh-my-posh-setup.sh
