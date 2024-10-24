# C/C++ development environment setup script for Windows + WSL
# Author: sgdc3

$defaultApps = @(
	"Microsoft.BingFinance"
	"Microsoft.3DBuilder"
	"Microsoft.BingFinance"
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
);

# Disable UAC
Write-Host "Disabling UAC..."
Disable-UAC

# Enable developer mode
Write-Host "Enabling developer mode..."
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowDevelopmentWithoutDevLicense -Value 1

Write-Host "Tweaking explorer settings..."
# Show hidden files and extensions
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowFileExtensions
# Expand explorer to the actual folder
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Value 1
# Show all elements in the file explorer left pane
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Value 1
# Open PC to This PC
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Value 1
# Taskbar where window is open for multi-monitor
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 2

Write-Host "Removing default apps..."
foreach ($app in $defaultApps) {
	Write-Host "Trying to remove $app"
	Get-AppxPackage $app -AllUsers | Remove-AppxPackage
	Get-AppXProvisionedPackage -Online | Where DisplayNam -like $app | Remove-AppxProvisionedPackage -Online
}

Write-Host "Installing software..."
choco install -y vscode
#choco install -y git --package-parameters="'/GitAndUnixToolsOnPath /WindowsTerminal'"
#choco install -y 7zip.install

Write-Host "Installing WSL..."
#choco install -y Microsoft-Windows-Subsystem-Linux --source="'windowsfeatures'"
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile ~/Ubuntu.appx -UseBasicParsing
Add-AppxPackage -Path ~/Ubuntu.appx

Write-Host "Refreshing environment..."
RefreshEnv

Write-Host "Installing Ubuntu into WLS..."
Ubuntu1804 install --root
Ubuntu1804 run apt update
Ubuntu1804 run apt upgrade -y

Write-Host "Installing tools inside the WSL distro..."
Ubuntu1804 run apt install build-essential -y

Write-Host "Installing VSCode extensions..."
code --install-extension ms-vscode.cpptools

Write-Host "Done! Enabling UAC..."
Enable-UAC

Write-Host "Done!"
