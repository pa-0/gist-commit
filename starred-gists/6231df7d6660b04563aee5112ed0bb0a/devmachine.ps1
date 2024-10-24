#####################
# PREREQUISITES
#####################

Write-Host @'
 =============================
< Windows Subsystem for Linux >
< (Ubuntu >= 18.04) installer >
 =============================
   \
    \
        .--.
       |o_o |
       |:_/ |
      //   \ \
     (|     | )
    /'\_   _/`\
    \___)=(___/
'@

if ([Environment]::OSVersion.Version.Major -ne 10) {
  Write-Error 'Upgrade to Windows 10 before running this script'
  Exit
}

if (!(Get-Command 'boxstarter' -ErrorAction SilentlyContinue)) {
  Write-Error @'
You need Boxstarter to run this script; install with:
. { iwr -useb http://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force; refreshenv
'@
  Exit
}

# Allow running PowerShell scripts
Update-ExecutionPolicy Unrestricted

# Show more info for files in Explorer
Set-WindowsExplorerOptions -EnableShowProtectedOSFiles  -EnableShowFileExtensions -EnableShowFullPathInTitleBar -EnableShowHiddenFilesFoldersDrives
# Small taskbar
Set-TaskbarOptions -Size Small -Combine Always
#taskbar where window is open for multi-monitor
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 2

# Enable developer mode on the system
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowDevelopmentWithoutDevLicense -Value 1

# Windows Update
Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -AcceptEula

if ((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId -lt 1803) {
  Write-Error 'You need to run Windows Update and install Feature Updates to at least version 1803'
  Exit
}

# Windows Subsystems/Features
choco install Microsoft-Hyper-V-All -source WindowsFeatures -y
choco install Microsoft-Windows-Subsystem-Linux -source WindowsFeatures -y

# Install Ubuntu 18.04 on WSL
cinst wsl-ubuntu-1804

#####################
# SOFTWARE
#####################

# 7Zip
cinst 7zip

# Some browsers
cinst googlechrome
cinst firefox


#Java
# cinst jdk11

# Dev Tools
cinst git.install
cinst postman
cinst fiddler
cinst microsoft-windows-terminal
cinst pycharm
cinst docker-desktop
cinst docker-kitematic

# Messaging
cinst slack

# Tools
cinst screentogif
cinst sysinternals
