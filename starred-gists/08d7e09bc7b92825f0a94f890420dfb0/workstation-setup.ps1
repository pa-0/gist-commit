# Install packages with Scoop

if (!(Get-Command scoop -ErrorAction SilentlyContinue)) {
  Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
  Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression
}
Set-Alias -Name scoop -Value scoop.cmd

function Install-Package-If-Missing([String]$packageName) {
  if (scoop list | Select-String -Pattern "^\s+\b$packageName\b" -Quiet) {
    Write-Output "Package $packageName already installed"
    return
  }

  Write-Output "Installing package $packageName"
  scoop install $packageName
}

Install-Package-If-Missing git

scoop bucket add extras
scoop bucket add java
scoop bucket add nonportable

Install-Package-If-Missing sudo

Install-Package-If-Missing 7zip
Install-Package-If-Missing autohotkey
Install-Package-If-Missing curl
Install-Package-If-Missing dotnet-sdk
Install-Package-If-Missing fiddler
Install-Package-If-Missing firefox
Install-Package-If-Missing googlechrome
Install-Package-If-Missing jetbrains-toolbox
Install-Package-If-Missing kitty
Install-Package-If-Missing libreoffice-fresh
Install-Package-If-Missing microsoft-edge-beta-np
Install-Package-If-Missing nodejs
Install-Package-If-Missing notepadplusplus
Install-Package-If-Missing nssm
Install-Package-If-Missing openjdk
Install-Package-If-Missing powertoys
Install-Package-If-Missing processhacker
Install-Package-If-Missing putty
Install-Package-If-Missing slack
Install-Package-If-Missing vagrant
Install-Package-If-Missing vim
Install-Package-If-Missing virtualbox-np
Install-Package-If-Missing vlc
Install-Package-If-Missing vscode
Install-Package-If-Missing wget
Install-Package-If-Missing windows-terminal
Install-Package-If-Missing winscp
Install-Package-If-Missing wireshark
Install-Package-If-Missing wiztree

# PowerShell settings
if (!(Test-Path -Path C:\Users\Bruno\Documents\WindowsPowerShell\Microsoft.Powershell_profile.ps1)) {
  $powershellProfile = @'
Import-Module PSReadline
Set-PSReadlineOption -EditMode Emacs
'@
  New-Item -ItemType Directory -Force -Path C:\Users\Bruno\Documents\WindowsPowershell
  Write-Output $powershellProfile > C:\Users\Bruno\Documents\WindowsPowerShell\Microsoft.Powershell_profile.ps1
}

# Admin Commands
$adminCommands = @'
# Set Caps Lock to Ctrl
$Remap = New-Object -TypeName byte[] -ArgumentList 20
$Remap[8] = 0x02
$Remap[12] = 0x1d
$Remap[14] = 0x3a
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout' -Name 'Scancode Map' -Value $Remap -Force

# Show Hidden Files and Extensions in Explorer
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value '0' -Type DWORD -Force
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Hidden' -Value '1' -Type DWORD -Force

# Enable Hyper-V if available
$hyperv = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
if ($hyperv -ne $null -And $hyperv.State -ne "Enabled") {
  Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName Microsoft-Hyper-V -All -ErrorAction Continue
}

# Enable Virtual Machine Platform if Available
$vmPlatform = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
if ($vmPlatform -ne $null -And $vmPlatform.State -ne "Enabled") {
  Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName VirtualMachinePlatform -All -ErrorAction Continue
}

# Enable WSL
$wsl = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
if ($wsl.State -ne "Enabled") {
  Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName Microsoft-Windows-Subsystem-Linux
}

Write-Output "To complete the setup, after rebooting run: 'wsl --set-default-version 2'"
'@

$tempFile = New-TemporaryFile
$adminCommandsFile = $tempFile.FullName + ".ps1"
$adminCommandsOutFile = $adminCommandsFile + ".out"

Rename-Item -Path $tempFile.FullName -NewName $adminCommandsFile
Set-Content -Path $adminCommandsFile -Value $adminCommands

Write-Output "Running commands that require administrative privileges"
Start-Process -FilePath powershell -Verb RunAs -Wait -WindowStyle Hidden -ArgumentList "-Command &`"${adminCommandsFile}`" *> $adminCommandsOutFile"
Get-Content $adminCommandsOutFile