##################################################
### Install Ubuntu 20.04 WSL2
##################################################
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

# rmdir -Recurse $temp_dir
$temp_dir = "C:\Temp"
# mkdir $temp_dir

# Distro name
$distro = "Ubuntu"
$install_loc = "$temp_dir\Ubuntu-WSL"

function DownloadWslDistro {
    $uri = "https://aka.ms/wslubuntu2004"
    $name = "Ubuntu.zip"
    $fullFilePath = "$temp_dir\$name"
    Invoke-WebRequest -Uri $uri -OutFile $fullFilePath


    # Expand the archive
    Expand-Archive $fullFilePath $temp_dir

    Rename-Item "$temp_dir\Ubuntu_2004.2021.825.0_x64.appx" "$temp_dir\Ubuntu_2004.zip"

    Expand-Archive "$temp_dir\Ubuntu_2004.zip" $install_loc

    # Remove archive after expansion
    Remove-Item -Path $fullFilePath
    Remove-Item -Path "$temp_dir\Ubuntu_2004.zip"
}

function InstallWsl2Distro {
    # Try to get the image to install at WSL 2
    wsl --set-default-version 2

    # Execute the image install
    Write-Host "Installing Ubuntu 20.04"
    ls $install_loc
    & "$install_loc\ubuntu.exe" install --root
    
    Write-Host "Installed Ubuntu 20.04"
    
    # Ensure the image is upgraded to WSL 2
    Write-Host "Setting wsl version to 2"
    wsl --set-version $distro 2

    # set default distro
    Write-Host "Setting default wsl distro"
    wsl --set-default $distro
}

function InstallWindowsDocker {
    ### Add custom configuration
    Write-Host "Starting windows docker installation"
    # install windows docker binaries, register as service
    Write-Host "Installing windows docker binaries, registering as service"
    curl.exe -o docker.zip -LO https://download.docker.com/win/static/stable/x86_64/docker-20.10.9.zip
    Expand-Archive docker.zip -DestinationPath C:\
    [Environment]::SetEnvironmentVariable("Path", "$($env:path);C:\docker", [System.EnvironmentVariableTarget]::Machine)
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    dockerd --register-service
    Start-Service docker
    Write-Host "Finished windows docker installation"
}

function InstallLinuxDocker {
    # 
    # Install docker daemon, client, containerd in wsl
    Write-Host "Starting linux docker installation"

    Write-Output '
apt-get update -yqq
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /tmp/docker.gpg
gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg -i /tmp/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -yqq
apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
' | Out-File C:\Temp\LinuxInstallDocker.sh

    ((Get-Content C:\Temp\LinuxInstallDocker.sh) -join "`n") + "`n" | Set-Content -NoNewline C:\Temp\LinuxInstallDocker.sh

    Write-Host "Finished writing LinuxInstallDocker.sh"
    try {
        wsl -d $distro -e sh /mnt/c/Temp/LinuxInstallDocker.sh
        if (-not $?) { Write-Host  "failed sh"; throw "failed sh" }
        Write-Host "Finished sh /mnt/c/Temp/LinuxInstallDocker.sh"
    }
    catch {
        Write-Host  "failed LinuxInstallDocker"
        Start-Sleep -Seconds 2
        Write-Host $_
        throw "LinuxInstallDocker failed"
    }

    Write-Host "Finished linux docker installation"
}

function SetupDockerInit {
    Write-Host "Setting up docker init"
    # set hosts so dockerd is reachable from windows host
    Write-Output '{ "hosts" : ["tcp://127.0.0.1:2375"] }' | Out-File c:\Temp\daemon.json
    wsl -d $distro -e mkdir /etc/docker
    if (-not $?) { Write-Host  "failed mkdir /etc/docker"; throw "failed mkdir /etc/docker" }

    wsl -d $distro -e cat /mnt/c/Temp/daemon.json > /etc/docker/daemon.json
    if (-not $?) { Write-Host  "failed cat /mnt/c/Temp/daemon.json > /etc/docker/daemon.json"; throw "failed cat /mnt/c/Temp/daemon.json > /etc/docker/daemon.json" }

    wsl -d $distro -e dos2unix /etc/docker/daemon.json
    if (-not $?) { Write-Host  "failed dos2unix /etc/docker/daemon.json"; throw "failed dos2unix /etc/docker/daemon.json" }

    wsl -d $distro -e service docker start
    if (-not $?) { Write-Host  "failed service docker start"; throw "failed service docker start" }
    wsl -d $distro -e update-rc.d docker enable
    if (-not $?) { Write-Host  "failed update-rc.d docker enable"; throw "failed update-rc.d docker enable" }
    Write-Host "Finished setting up docker init"
}

function CreateLinuxDockerContext {
    # create docker context for windows command to access linux docker daemon
    Write-Host "Creating linux docker context"
    docker context create linux --docker host=tcp://127.0.0.1:2375
    Write-Host "Finished creating linux docker context"
}


function DownloadWindowsDockerCompose {
    # download docker-compose on windows
    Write-Host "Downloading docker-compose on windows"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    mkdir "$Env:ProgramFiles\Docker"
    $env:Path += ";$Env:ProgramFiles\Docker"
    Invoke-WebRequest "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Windows-x86_64.exe" -UseBasicParsing -OutFile $Env:ProgramFiles\Docker\docker-compose.exe
    Write-Host "Finished downloading docker-compose on windows"
}
### End custom configuration

function ExportWsl2 {
    # reboot
    Write-Host "WSL2 reboot"
    wsl -d $distro -e reboot

    # Now that's it's built, export the file system
    Write-Host "WSL2 export"
    wsl --export $distro "c:\Ubuntu-fs.tar"

    # Now we delete the distro
    # Write-Host "WSL2 unregister"
    # wsl --unregister $distro

    # And re-import it from a new location
    # $location = "C:\"
    # $location = "${location}\Ubuntu-WSL"
    # wsl --import $distro $location "c:\Ubuntu-fs.tar"
}

function DisableWindowsUpdates { 
    $Updates = (New-Object -ComObject "Microsoft.Update.AutoUpdate").Settings

    if ($Updates.ReadOnly -eq $True) { Write-Error "Cannot update Windows Update settings due to GPO restrictions." }

    else {
        $Updates.NotificationLevel = 1 #Disabled
        $Updates.Save()
        $Updates.Refresh()
        Write-Output "Automatic Windows Updates disabled."
    }
}

# start main script
Write-Host "Running Ubuntu-20.04 WSL2 Installation"

$RunningAsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (!$RunningAsAdmin) {
    Write-Error "Not running as admin"
    exit 1
}

try {
    DisableWindowsUpdates
    DownloadWslDistro
    InstallWsl2Distro
    InstallWindowsDocker
    InstallLinuxDocker
    SetupDockerInit
    CreateLinuxDockerContext
    DownloadWindowsDockerCompose
    ExportWsl2
    Write-Host "Completed Ubuntu-20.04 WSL2 Installation"
    exit 0
}
catch {
    Write-Host "An error occurred:"
    Write-Host $_
    exit 1
}

exit 10