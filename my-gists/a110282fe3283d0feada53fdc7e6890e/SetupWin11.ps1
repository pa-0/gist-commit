# =============
# Run terminal as admin, then run 'powershell.exe -ExecutionPolicy Unrestricted' 
# to start powershell session in unrestricted mode 
# https://learn.microsoft.com/th-th/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.4

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# get all input parameter
$computerName = Read-Host 'Change Computer Name from [' $env:COMPUTERNAME '] to (blank to skip) ' 
$monitorTimeout = Read-Host 'Set monitor timeout to __ second (blank to skip) ' 
$enableDevMode = Read-Host 'Enable Windows 11 dev mode (Y / N or blank to skip) ' 
$enableRemote = Read-Host 'Enable Remote Desktop (Y / N or blank to skip) ' 
$gitEmail = Read-Host 'Set Git user email (blank to skip) '
$gitName = Read-Host 'Set Git user name (blank to skip) '

# === Variable ==================================================
# TODO: make it a check list for user to select
$Apps = @(
    # Basic
    "googlechrome",
    "firefox",
    "7zip.install",
    "microsoft-teams-new-bootstrapper",
    "irfanview", # image viewer
    "googledrive",
    "cutepdf", # pdf editor
    "foxitreader", # pdf reader
    "line", # lacking messenger app but popular
    "zoom",
    
    # Utils
    "obsidian", # notebook
    "notepadplusplus.install", # better notepad
    "keepassxc", # password manager
    "vlc", # video player
    "mpc-hc-clsid2", # video player
    "powertoys", # windows tools
    "obs-studio", # streaming
    "rustdesk", # remote desktop
    "calibre", # ebook management
    # "folder_size",  # disk space inspect
    "treesizefree", # disk space inspect
    "cpu-z", # hw info
    "handbrake.install", # video encoder
    "qbittorrent", # torrent
    "tor-browser", # hidden web
    "advanced-ip-scanner", # network scanner
    "ffmpeg", # video tool
    "gimp", # image editor
    "inkscape", # vector image editor
    "filezilla", # ftp, sftp
    "upscayl", # image upscale

    # Dev
    # "python",  
    "putty",
    "git",
    "vscode",
    "sysinternals",
    "postman", # http test
    "httpie", # http test
    "beyondcompare",
    "github-desktop",
    "nodejs-lts",
    "docker-desktop",
    "figma",
    "sourcetree",
    #"virtualbox",
    "powershell-core",
    "oh-my-posh")

$uwpRubbishApps = @(
    "Microsoft.Microsoft3DViewer"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "*549981C3F5F10*"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.PowerAutomateDesktop"
    "Microsoft.BingWeather"
    "Microsoft.BingNews"
    "king.com.CandyCrushSaga"
    "Microsoft.Messaging"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "4DF9E0F8.Netflix"
    "Microsoft.GetHelp"
    # "Microsoft.People"
    "Microsoft.YourPhone"
    "MicrosoftTeams"
    "Microsoft.Getstarted"
    # "Microsoft.Microsoft3DViewer"
    "Microsoft.WindowsMaps"
    "Microsoft.MixedReality.Portal"
    "Microsoft.SkypeApp")



# === Gathering Fact ============================================

Write-Host "OS Info:" -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Get-CimInstance Win32_OperatingSystem | Format-List Name, Version, InstallDate, OSArchitecture
(Get-ItemProperty HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0\).ProcessorNameString
Write-Host ""

# -----------------------------------------------------------------------------

Write-Host "Set New Computer name:" -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Write-Host "Current computer name: " $env:COMPUTERNAME
if ((-not ([string]::IsNullOrEmpty($computerName))) -and ($computerName -ne $env:COMPUTERNAME)) {
    Write-Host "Renaming this computer to: " $computerName  -ForegroundColor Yellow
    Rename-Computer -NewName $computerName
}
else {
    Write-Host "Skip Rename : same name or blank input"
}
Write-Host ""

# -----------------------------------------------------------------------------

Write-Host "Disable Sleep on AC Power..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
if ($monitorTimeout) {
    Write-Host "monitor-timeout-ac " $monitorTimeout
    Powercfg /Change monitor-timeout-ac $monitorTimeout
}
Write-Host "standby-timeout-ac 0"
Powercfg /Change standby-timeout-ac 0


Write-Host ""
# -----------------------------------------------------------------------------

Write-Host "Set other windows  setting ..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

# Write-Host "Time format"
# $culture = Get-Culture
# $culture.DateTimeFormat.ShortDatePattern = 'yyyy-mm-dd'
# Set-Culture $culture

Write-Host "Set not to hide file extention"
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -PropertyType DWORD -Force



Write-Host ""

# -----------------------------------------------------------------------------

Write-Host "Add 'This PC' Desktop Icon..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
$thisPCIconRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
$thisPCRegValname = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
$item = Get-ItemProperty -Path $thisPCIconRegPath -Name $thisPCRegValname -ErrorAction SilentlyContinue
if ($item) {
    Set-ItemProperty  -Path $thisPCIconRegPath -name $thisPCRegValname -Value 0
}
else {
    New-ItemProperty -Path $thisPCIconRegPath -Name $thisPCRegValname -Value 0 -PropertyType DWORD | Out-Null
}
Write-Host ""

# -----------------------------------------------------------------------------

# To list all appx packages:
# Get-AppxPackage | Format-Table -Property Name,Version,PackageFullName
Write-Host "Removing Unwanted preinstall Universal Windows Platform (UWP)..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

function Remove-UWP {
    param (
        [string]$name
    )

    Write-Host "Removing UWP $name..." -ForegroundColor Yellow
    Get-AppxPackage $name | Remove-AppxPackage
    Get-AppxPackage $name | Remove-AppxPackage -AllUsers
}

foreach ($uwp in $uwpRubbishApps) {
    # Write-Host "Removing ... " $uwp
    Remove-UWP $uwp
}

Write-Host ""

# -----------------------------------------------------------------------------

# === REMOVE: This is not working in latest window update ===
# Write-Host "Starting UWP apps to upgrade..." -ForegroundColor Green
# Write-Host "------------------------------------" -ForegroundColor Green
# $namespaceName = "root\cimv2\mdm\dmmap"
# $className = "MDM_EnterpriseModernAppManagement_AppManagement01"
# $wmiObj = Get-WmiObject -Namespace $namespaceName -Class $className
# Write-Host "Get-WmiObject -Namespace " $namespaceName "-Class" $className
# Write-Host $wmiObj ".UpdateScanMethod()"
# $result = $wmiObj.UpdateScanMethod()
# Write-Host "Result: " $result

# Write-Host ""

# -----------------------------------------------------------------------------

Write-Host "Enable Windows 11 Developer Mode..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
if ($enableDevMode -eq "Y") {
    reg add "HKEY_LOCAL_MACHNE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"
}
else {
    Write-Host "Skip"
}

Write-Host ""

# -----------------------------------------------------------------------------

Write-Host "Enable Remote Desktop..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
if ($enableRemote -eq "Y") {
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\" -Name "fDenyTSConnections" -Value 0
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\" -Name "UserAuthentication" -Value 1
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
}
else {
    Write-Host "Skip"
}

Write-Host ""

# -----------------------------------------------------------------------------

Write-Host "Install Chocolately ..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

function CheckCommand($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

if (CheckCommand -cmdname 'choco') {
    Write-Host "Choco is already installed, skip installation."
}
else {
    Write-Host ""
    Write-Host "Installing Chocolate for Windows..." -ForegroundColor Green
    Write-Host "------------------------------------" -ForegroundColor Green
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}


Write-Host ""

# -----------------------------------------------------------------------------

Write-Host "Installing Applications..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

foreach ($app in $Apps) {
    choco install $app -y
}

# refresh terminal

Write-Host ""

# -----------------------------------------------------------------------------

Write-Host "Setup oh-my-posh ..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green


Write-Host "Create profile : " $PROFILE
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupPath = "$PROFILE.$timestamp"
if (Test-Path -Path $PROFILE) {
    Write-Host " - Backup old profile to : " $backupPath
    Copy-Item -Path $PROFILE -Destination $backupPath -Force
}
New-Item -Path $PROFILE -Type File -Force

Write-Host "Setup pwsh profile with theme"
$line = 'oh-my-posh --init --shell pwsh --config "C:\\App\\dark_minimal.omp.json" | Invoke-Expression'
Add-Content -Path $PROFILE -Value $line

Write-Host "Install NF font"
Invoke-Expression "& oh-my-posh font install hack"
Invoke-Expression "& oh-my-posh font install CascadiaCode"
Invoke-Expression "& oh-my-posh font install FiraCode"
Invoke-Expression "& oh-my-posh font install FiraCode"
Invoke-Expression "& oh-my-posh font install JetBrainsMono"
Invoke-Expression "& oh-my-posh font install Meslo"


Write-Host "Download theme https://gist.github.com/TheGU/c7596ccb3b444b969c5186da9efe37c0"
$gistRawUrl = "https://gist.githubusercontent.com/TheGU/c7596ccb3b444b969c5186da9efe37c0/raw/cca5d74ebaea96f4c67dd0af1babe5212547073e/dark_minimal.omp.json"
$localDirectory = "C:\App"
$localFilename = "dark_minimal.omp.json"

# Create the directory if it doesn't exist
if (-not (Test-Path -Path $localDirectory)) {
    New-Item -ItemType Directory -Path $localDirectory
}

# Download the file from the Gist
Invoke-WebRequest -Uri $gistRawUrl -OutFile (Join-Path -Path $localDirectory -ChildPath $localFilename)

Write-Host "Theme downloaded and saved as $localFilename"

Write-Host "Follow https://ohmyposh.dev/docs/installation/fonts to setup font for other program" -ForegroundColor DarkGreen

Write-Host ""

# -----------------------------------------------------------------------------

Write-Host "Setup Oh-My-Posh Terminal ..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

$settingsPathWildcard = Join-Path $env:LocalAppData "Packages\Microsoft.WindowsTerminal_*\LocalState\settings.json"
$settingsPath = (Get-ChildItem -Path $settingsPathWildcard)[0].FullName

Write-Host "Setting windows terminal"  -ForegroundColor Yellow
Write-Host "Setting file : $settingsPath"
$settingJson = Get-Content -Path $settingsPath | ConvertFrom-Json

Write-Host "setup default font to hack"
if (-not $settingJson.profiles.defaults) {
    $settingJson.profiles.defaults = @{}
}
$settingJson.profiles.defaults = $settingJson.profiles.defaults -as [hashtable]
if (-not $settingJson.profiles.defaults.font) {
    $settingJson.profiles.defaults.font = @{}
}
$settingJson.profiles.defaults.font = $settingJson.profiles.defaults.font -as [hashtable]
$settingJson.profiles.defaults.font.face = 'Hack Nerd Font'

Write-Host "setup default terminal to Powershell Core"
# Loop through the list of profiles
foreach ($profile in $settingJson.profiles.list) {
    # Check if the source of the profile is 'Windows.Terminal.PowershellCore'
    if ($profile.source -eq 'Windows.Terminal.PowershellCore') {
        # Replace the value of 'defaultProfile' with the 'guid' of the current profile
        $settingJson.defaultProfile = $profile.guid
    }
}

# Write the updated JSON content back to the settings.json file
$settingJson | ConvertTo-Json -Depth 100 | Set-Content -Path $settingsPath


Write-Host "Setting VSCode termianl"  -ForegroundColor Yellow
$settingsPath = "$HOME\\AppData\\Roaming\\Code\\User\\settings.json" # Specify the path to your settings.json file
if (-not (Test-Path -Path $settingsPath)) { New-Item -Path $settingsPath -ItemType File -Force }
$content = Get-Content -Path $settingsPath # Load the content of the settings.json file
if ([string]::IsNullOrWhiteSpace($content)) { $json = @{} } else { $json = $content | ConvertFrom-Json } # If the file is empty, initialize an empty JSON object

Write-Host "setup default editor font to hack"
$json | Add-Member -Type NoteProperty -Name "editor.fontFamily" -Value "'Hack Nerd Font', Consolas, 'Courier New', monospace" -Force
Write-Host "setup default terminal font to hack"
$json | Add-Member -Type NoteProperty -Name "terminal.integrated.fontFamily" -Value "'Hack Nerd Font', monospace" -Force

# Write-Host "setup default font size to 14"
# if (-not $json."editor.fontSize") {
#     $json | Add-Member -Type NoteProperty -Name "editor.fontSize" -Value 14
# } else {
#     $json."editor.fontSize" = 14
# }
$json | ConvertTo-Json | Set-Content -Path $settingsPath  # Write the updated JSON content back to the settings.json file


Write-Host ""

# -----------------------------------------------------------------------------

Write-Host "Set other windows env ..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

Write-Host "- Setup wsl Ubuntu and set default to Ubuntu" -ForegroundColor Yellow
Invoke-Expression "& wsl install -d Ubuntu"
Invoke-Expression "& wsl --setdefault Ubuntu"

Write-Host "- Removing Bluetooth icons..." -ForegroundColor Yellow
# cmd.exe /c "reg add `"HKCU\Control Panel\Bluetooth`" /v `"Notification Area Icon`" /t REG_DWORD /d 0 /f"
Write-Host "Skip"

Write-Host "Enabling Hardware-Accelerated GPU Scheduling..." -ForegroundColor Yellow
# New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\" -Name 'HwSchMode' -Value '2' -PropertyType DWORD -Force
Write-Host "Skip"

Write-Host "- Excluding repos from Windows Defender..." -ForegroundColor Yellow
# Add-MpPreference -ExclusionPath "$env:USERPROFILE\source\repos"
# Add-MpPreference -ExclusionPath "$env:USERPROFILE\.nuget"
# Add-MpPreference -ExclusionPath "$env:USERPROFILE\.vscode"
# Add-MpPreference -ExclusionPath "$env:USERPROFILE\.dotnet"
# Add-MpPreference -ExclusionPath "$env:USERPROFILE\.ssh"
# Add-MpPreference -ExclusionPath "$env:APPDATA\npm"
# Add-MpPreference -ExclusionPath "C:\Code"
Write-Host "Skip"

Write-Host "- Setting Time zone 'SE Asia Standard Time' ..." -ForegroundColor Yellow
Set-TimeZone -Id "SE Asia Standard Time"

Write-Host "- Syncing time..." -ForegroundColor Yellow
net stop w32time
net start w32time
w32tm /resync /force
w32tm /query /status

Write-Host "- Disabling the Windows Ink Workspace..." -ForegroundColor Yellow
REG ADD "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\PenWorkspace" /V PenWorkspaceButtonDesiredVisibility /T REG_DWORD /D 0 /F

# Write-Host "Time format"
# $culture = Get-Culture
# $culture.DateTimeFormat.ShortDatePattern = 'yyyy-mm-dd'
# Set-Culture $culture


Write-Host "- Applying file explorer settings..." -ForegroundColor Yellow
Write-Host "  -- Allowing show file extension"
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -PropertyType DWORD -Force
# cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f"
# Write-Host "  Allowing AutoCheckSelect"
# cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v AutoCheckSelect /t REG_DWORD /d 0 /f"
# Write-Host "  Lunch to This PC"
# cmd.exe /c "reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v LaunchTo /t REG_DWORD /d 1 /f"

Write-Host "- Enabling Thai input method..." -ForegroundColor Yellow
$LanguageList = Get-WinUserLanguageList
$LanguageList.Add("th-TH")
Set-WinUserLanguageList $LanguageList -Force

Write-Host "- Enable long file path support in Windows..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1

# Write-Host "- Enable Windows Subsystem for Linux (WSL)..." -ForegroundColor Yellow
# Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

# Write-Host "- Set home path hidden folders and files..." -ForegroundColor Yellow
# Get-ChildItem -Path $HOME -Filter .* -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object { $_.Attributes = $_.Attributes -bor [System.IO.FileAttributes]::Hidden }



Write-Host ""
# -----------------------------------------------------------------------------

Write-Host "Setting up Git for Windows..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
if ($gitEmail -ne "") {
    Write-Host "git config --global user.email $gitEmail"
    Write-Host "git config --global user.name $gitName"
    git config --global user.email $gitEmail
    git config --global user.name $gitName
} else {
    Write-Host "Skip setting up git user email and name"
}
Write-Host "git config --global core.autocrlf true"
git config --global core.autocrlf true


Write-Host ""
# -----------------------------------------------------------------------------


Write-Host "Checking Windows updates..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Install-Module -Name PSWindowsUpdate -Force
Write-Host "Installing updates... (Computer will reboot in minutes...)" -ForegroundColor Yellow
Get-WindowsUpdate -AcceptAll -Install -ForceInstall -AutoReboot

Write-Host ""
# -----------------------------------------------------------------------------


Write-Host "Set Manual ..." -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green

Write-Host "- Setup thai font by download load and add to setting"
Write-Host "Download font from https://fonts.google.com/share?selection.family=Anuphan:wght@100..700|Athiti:wght@200;300;400;500;600;700|Charmonman:wght@400;700|Chonburi|IBM+Plex+Sans+Thai+Looped:wght@100;200;300;400;500;600;700|IBM+Plex+Sans+Thai:wght@100;200;300;400;500;600;700|Itim|K2D:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800|Kanit:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900|KoHo:ital,wght@0,200;0,300;0,400;0,500;0,600;0,700;1,200;1,300;1,400;1,500;1,600;1,700|Kodchasan:ital,wght@0,200;0,300;0,400;0,500;0,600;0,700;1,200;1,300;1,400;1,500;1,600;1,700|Krub:ital,wght@0,200;0,300;0,400;0,500;0,600;0,700;1,200;1,300;1,400;1,500;1,600;1,700|Maitree:wght@200;300;400;500;600;700|Mali:ital,wght@0,200;0,300;0,400;0,500;0,600;0,700;1,200;1,300;1,400;1,500;1,600;1,700|Mitr:wght@200;300;400;500;600;700|Niramit:ital,wght@0,200;0,300;0,400;0,500;0,600;0,700;1,200;1,300;1,400;1,500;1,600;1,700|Noto+Sans+Thai+Looped:wght@100;200;300;400;500;600;700;800;900|Noto+Sans+Thai:wght@100..900|Noto+Serif+Thai:wght@100..900|Pattaya|Pridi:wght@200;300;400;500;600;700|Prompt:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900|Roboto:ital,wght@0,100;0,300;0,400;0,500;0,700;0,900;1,100;1,300;1,400;1,500;1,700;1,900|Sarabun:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800|Sriracha|Srisakdi:wght@400;700|Taviraj:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900|Thasadith:ital,wght@0,400;0,700;1,400;1,700|Trirong:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900"

Write-Host "- Setup wsl Ubuntu and set default to Ubuntu"
Invoke-Expression "& wsl install -d Ubuntu"
Invoke-Expression "& wsl --setdefault Ubuntu"


Write-Host ""
# -----------------------------------------------------------------------------


Write-Host "------------------------------------" -ForegroundColor Green
$restartConfirm = Read-Host -Prompt "Setup is done, restart is needed, press [Y] to restart computer. Or press any key to exit."
if ($restartConfirm -eq "Y") {
    Restart-Computer
}
