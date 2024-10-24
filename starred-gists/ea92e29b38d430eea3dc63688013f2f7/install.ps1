# Elevate to Adminstrator
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# Add "This PC" desktop icon
$thisPCIconRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
$thisPCRegValname = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
$item = Get-ItemProperty -Path $thisPCIconRegPath -Name $thisPCRegValname -ErrorAction SilentlyContinue

if ($item) {
Set-ItemProperty  -Path $thisPCIconRegPath -name $thisPCRegValname -Value 0  
}
else {
New-ItemProperty -Path $thisPCIconRegPath -Name $thisPCRegValname -Value 0 -PropertyType DWORD  | Out-Null  
}

# Remove Edge icon
$edgeLink = $env:USERPROFILE + "\Desktop\Microsoft Edge.lnk"
Remove-Item $edgeLink

# Enable Remote Desktop
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\" -Name "fDenyTSConnections" -Value 0
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\" -Name "UserAuthentication" -Value 1
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Delete preinstalled UWP Apps
$uwpRubbishApps = @(
	"Microsoft.BingFinance"
	"Microsoft.3DBuilder"
	"Microsoft.BingNews"
	"Microsoft.BingSports"
	"Microsoft.BingWeather"
	"Microsoft.CommsPhone"
	"Microsoft.Getstarted"
	"Microsoft.WindowsMaps"
	"*MarchofEmpires*"
	"Microsoft.GetHelp"
	"Microsoft.Messaging"
	"*Minecraft*"
	"Microsoft.MicrosoftOfficeHub"
	"Microsoft.OneConnect"
	"Microsoft.WindowsPhone"
	"Microsoft.WindowsSoundRecorder"
	"*Solitaire*"
	"Microsoft.MicrosoftStickyNotes"
	"Microsoft.Office.Sway"
	"Microsoft.XboxApp"
	"Microsoft.XboxIdentityProvider"
	"Microsoft.ZuneMusic"
	"Microsoft.ZuneVideo"
	"Microsoft.NetworkSpeedTest"
	"Microsoft.FreshPaint"
	"Microsoft.Print3D"
	"*Autodesk*"
	"*BubbleWitch*"
    "king.com*"
    "G5*"
	"*Dell*"
	"*Facebook*"
	"*Keeper*"
	"*Netflix*"
	"*Twitter*"
	"*Plex*"
	"*.Duolingo-LearnLanguagesforFree"
	"*.EclipseManager"
	"ActiproSoftwareLLC.562882FEEB491" # Code Writer
	"*.AdobePhotoshopExpress"
 )

foreach ($uwp in $uwpRubbishApps) {
    Get-AppxPackage -Name $uwp | Remove-AppxPackage
    Get-AppXProvisionedPackage -Online | Where DisplayName -like $appName | Remove-AppxProvisionedPackage -Online
}

#--- Enable developer mode on the system ---
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowDevelopmentWithoutDevLicense -Value 1

#--- Windows Features ---
# Show hidden files, Show protected OS files, Show file extensions
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions

#--- File Explorer Settings ---
# will expand explorer to the actual folder you're in
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Value 1
#adds things back in your left pane like recycle bin
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Value 1
#opens PC to This PC, not quick access
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Value 1
#taskbar where window is open for multi-monitor
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 2

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Windows features
Enable-WindowsOptionalFeature Microsoft-Hyper-V-All
Enable-WindowsOptionalFeature VirtualMachinePlatform
Enable-WindowsOptionalFeature Microsoft-Windows-Subsystem-Linux
Enable-WindowsOptionalFeature Containers

# WSL
Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile ~/Ubuntu.appx -UseBasicParsing
Add-AppxPackage -Path ~/Ubuntu.appx
RefreshEnv
Ubuntu1804 install --root
Ubuntu1804 run apt update
Ubuntu1804 run apt upgrade -y

# Turn off hibernation
powercfg.exe /hibernate off

# Server products
choco install sql-server-2017 --confirm
choco install ssms --confirm

# Development tools (Visual Studio)
choco install visualstudio2019community --confirm
choco install visualstudio2019-workload-manageddesktop --confirm
choco install visualstudio2019-workload-netweb --confirm
choco install visualstudio2019-workload-netcoretools --confirm

# Development tools (Visual Studio Code)
choco install vscode --confirm
code --install-extension ms-vscode.azure-account
code --install-extension ms-azure-devops.azure-pipelines
code --install-extension ms-vsts.team
code --install-extension ms-dotnettools.csharp
code --install-extension cake-build.cake-vscode
code --install-extension msjsdiag.debugger-for-chrome
code --install-extension ms-azuretools.vscode-docker
code --install-extension mikestead.dotenv
code --install-extension pgourlain.erlang
code --install-extension eamodio.gitlens
code --install-extension ms-vscode.go
code --install-extension dbankier.vscode-instant-markdown
code --install-extension zainchen.json
code --install-extension eriklynd.json-tools
code --install-extension ms-vscode.powershell
code --install-extension ms-python.python
code --install-extension ms-vscode-remote.remote-wsl
code --install-extension ms-mssql.mssql
code --install-extension mauve.terraform
code --install-extension dotjoshjohnson.xml
code --install-extension ms-vscode-remote.vscode-remote-extensionpack

choco install resharper --confirm
choco install azure-data-studio --confirm

# Utilities
choco install slack --confirm
choco install dropbox --confirm
choco install 7zip --confirm
choco install adobereader --confirm
choco install awscli --confirm
choco install beyondcompare --confirm
choco install curl --confirm
choco install docker-desktop --confirm
choco install fiddler --confirm
choco install git --confirm
choco install google-backup-and-sync --confirm
choco install googlechrome --confirm
choco install office365business --confirm
choco install microsoft-teams --confirm
choco install microsoft-windows-terminal --confirm
choco install msbuild-structured-log-viewer --confirm
choco install lastpass --confirm
choco install notepadplusplus --confirm
choco install openconnect-gui --confirm
choco install spacesniffer --confirm
choco install postman --confirm
choco install powershell-core --confirm
choco install powerbi --confirm

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula