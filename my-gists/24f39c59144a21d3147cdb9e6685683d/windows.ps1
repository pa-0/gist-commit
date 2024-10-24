# Run in PS with elevated privileges
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install -y googlechrome
choco install -y git
choco install -y vscode
choco install -y docker-engine
Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux", "VirtualMachinePlatform" -NoRestart
Invoke-WebRequest -Uri https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -OutFile wsl_update_x64.msi -UseBasicParsing
Start-Process msiexec.exe -Wait -ArgumentList "/I $((Get-Location).Path)\wsl_update_x64.msi /quiet"
# Reboot the machine before you continue

choco install -y vscode-powershell
code --install-extension eamodio.gitlens
code --install-extension ms-azure-devops.azure-pipelines
code --install-extension HashiCorp.terraform
code --install-extension redhat.vscode-xml
code --install-extension bierner.markdown-mermaid
code --install-extension ms-vscode-remote.remote-containers
code --install-extension ms-azuretools.vscode-docker
code --install-extension GitHub.codespaces

# Run in a console with a normal user account
wsl --set-default-version 2
wsl --install --distribution Ubuntu
wsl --list --verbose # make sure that version is 2. otherwise run wsl --set-version Ubuntu 2

# Run in Ubuntu:
cat <<EOF | sudo tee /etc/wsl.conf
[network]
generateResolvConf = false
EOF
cat <<EOF | sudo tee /etc/resolv.conf
nameserver 8.8.8.8
EOF
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
sudo dockerd
