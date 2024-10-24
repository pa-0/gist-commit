# Windows 10/11 Post Install

## Introduction
This document serves as a step-by-step guide for setting up a fresh Windows installation with the necessary tools and configurations. The guide is personalized for individual use.

## Table of Contents
- [Debloat](#debloat)
- [Winget](#winget)
- [Traffic Monitor](#traffic-monitor)
- [Peazip](#zip)
- [Free Download Manager](#fdm)
- [Fonts](#fonts)
- [WSL](#wsl)
- [VS Code](#vs-code)
- [Windows Terminal](#windows-term)
- [Python](#python)
- [Git](#git)
- [Miscellaneous](#misc)


## Debloat <a name="debloat"></a>
Debloat it with [Sophia Script](https://github.com/farag2/Sophia-Script-for-Windows). Follow instruction there & edit the script.

Open `Powershell Admin`, cd into the `Sophia Directory` and prepare ExecutionPolicy.
```powershell
# Neede before running Sophia Script
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
```

Run the script & start debloating
```powershell
# Debloating start
.\Sophia.ps1
```


## Winget <a name="winget"></a>
Windows Package Manager (Winget) simplifies the installation of various software packages through the command line.

### Install/Reinstall Winget:
The default preinstalled version may have issues, so it's recommended to reinstall it. Download the latest Winget from [Github-releases](https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle).

### Upgrade all installed packages:
```powershell
winget upgrade --all
```

## TrafficMonitor <a name="traffic-monitor"></a>
```powershell
# Specify the repository and file name
$repo = 'zhongyang219/TrafficMonitor'
$fileName = 'TrafficMonitor_{version}_x64_Lite.zip'
$installPath = 'C:\Program Files\Traffic Monitor'

# Get the latest release information using GitHub API
$latestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases/latest"
$version = $latestRelease.tag_name

# Create the download link by replacing the placeholder with the version
$downloadLink = "https://github.com/$repo/releases/download/$version/$fileName" -replace '{version}', $version

# Create the directory if it doesn't exist
New-Item -ItemType Directory -Path $installPath -Force

# Specify the local path to save the downloaded file
$localPath = Join-Path -Path $installPath -ChildPath "TrafficMonitor_${version}_x64_Lite.zip"

# Download the file using Invoke-WebRequest
Invoke-WebRequest -Uri $downloadLink -OutFile $localPath -ErrorAction Stop
Write-Output "Downloaded file saved to: $localPath"

# Extract the contents of the zip file
Expand-Archive -Path $localPath -DestinationPath $installPath -Force
Write-Output "Extracted contents to: $installPath"

# Move all files from source to destination
$sourcePath = Join-Path -Path $installPath -ChildPath "TrafficMonitor"
Get-ChildItem -Path $sourcePath | Move-Item -Destination $installPath -Force
Write-Host "Files moved successfully."

# Remove the downloaded zip file & TrafficMonitor
Remove-Item -Path $sourcePath -Force
Remove-Item -Path $localPath -Force
Write-Output "Deleted downloaded zip file: $localPath"

# Start the TrafficMonitor
Start-Process -FilePath (Join-Path -Path $installPath -ChildPath 'TrafficMonitor.exe')
Write-Host "Executable started successfully."
```

### Configuration:
Right-click on the Toolbar TrafficMonitor
- Enable `Show Taskbar Window`
- Disable `Show Main Window`
- Go to `Options`:
  - Select `Taskbar Window Settings` tab
    - Click `Choose Font`
      - `Verdana`, Size `10`.
      - Enable `Automatically set background....`
      - Enable `Auto adapt to Windows dark/light themes`
  - Select `General` tab.
    - Click `Reset autorun`
    - Click `Apply` at the bottom right


## Peazip <a name="zip"></a>
```powershell
winget install Giorgiotani.Peazip --location "C:\Program Files\PeaZip"
```


## Free Download Manager <a name="fdm"></a>
```powershell
winget install SoftDeluxe.FreeDownloadManager --location "C:\Program Files\Free Download Manager"
```


## Fonts <a name="fonts"></a>
For now `SpaceMonoNerdFont` is my favorite Nerd Font

 - Download the [SpaceMono](https://github.com/ryanoasis/nerd-fonts/releases/latest/download/SpaceMono.zip) ZIP.
 - Extract the downloaded ZIP file.
 - Install by select all & install as System:


## WSL <a name="wsl"></a>
### Installation
```powershell
# Enable features, Install WSL2 and Ubuntu
wsl --install -n
# Opt for the cutting-edge experience
wsl --update --pre-release
```

### Cleanup:
Above script enables `Virtual Machine Platform` feature which is needed for WSL2 but it also enables `Windows Subsystem for Linux` in Optional features, which is needed for WSL1 but not for WSL2. Disable it.

```powershell
Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```
Probably needs a restart.
Setup WSL user & password by launching `Ubuntu` from start menu.

### Setup
Few linux specific configurations
```
# Update package information and install Nala package manager
sudo apt update
sudo apt install nala
# Fetch the latest package information
sudo nala fetch
# Upgrade installed packages
sudo nala upgrade -y
```

#### Add nala alis to ~/.bashrc
Open the ~/.bashrc by this command

```bash
# Open the bash configuration file for editing
nano ~/.bashrc
```
And add this line where all aliases

```bash
# Create an alias for 'apt' to use Nala package manager
alias apt='nala'
```


## VS Code <a name="vs-code"></a>
```powershell
winget install Microsoft.VisualStudioCode --scope machine --location "C:\Program Files\VS Code"
```

#### Add to path:
```powershell
$existingPath = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)
$newPath = "C:\Program Files\VS Code\bin"
if (-not ($existingPath -like "*$newPath*")) {
    [System.Environment]::SetEnvironmentVariable('Path', "$existingPath;$newPath", [System.EnvironmentVariableTarget]::Machine)
    Write-Host "Added $newPath to the system PATH."
} else {
    Write-Host "$newPath is already in the system PATH."
}
```


## Windows Terminal <a name="windows-term"></a>
Open the `settings.json` file of Windows Terminal
```powershell
code $env:USERPROFILE\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

### Configuration
#### Window size & position
Search for defaultProfile in the file. It will look like this:
```json
"copyFormatting": "none",
"copyOnSelect": false,
"defaultProfile": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
"newTabMenu": []
```

Make the following changes:
```json
"centerOnLaunch": true, // Added
"copyFormatting": "none",
"copyOnSelect": false,
"defaultProfile": "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}",
"initialCols": 110, // Added
"initialRows": 26, // Added
"newTabMenu": []
```

#### Font & UI
Search for `defaults` in the file. It will look like this:
```json
"defaults": {},
```

Make the following changes:
```json
"defaults": {
    "colorScheme": "One Half Dark",
    "cursorShape": "emptyBox",
    "elevate": true,
    "font": {
        "face": "SpaceMono Nerd Font"
    },
    "intenseTextStyle": "all",
    "opacity": 85,
    "useAcrylic": true
}
```

#### Hide profiles
Set `"hidden": true` for the following three profiles:
- Command Prompt
- Windows.Terminal.Wsl
- Windows.Terminal.Azure

#### Acrylic in Tab
In the last section of the file, after `"themes": [],` add:
```json
"useAcrylicInTabRow": true
```

So after the channge it will be like
```json
"themes": [],
"useAcrylicInTabRow": true //Added
```

Ensure to save the settings.json file after making these changes. Restart Windows Terminal to apply the updated configurations.


## Python <a name="python"></a>
```powershell
winget install python3 --location "C:\Program Files\Python3"
```


## Git <a name="git"></a>
Version Control System

### Install MinGit:
```powershell
winget install Git.MinGit --location "C:\Program Files\Git"
```

The above command installs an outdated version, so use the following PowerShell script to download and extract the latest Git release:

### Update to Latest MinGit:
```powershell
# Specify the repository and file name
$repo = 'git-for-windows/git'
$fileName = 'MinGit-{version}-busybox-64-bit.zip'

# Get the latest release information using GitHub API
$latestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases/latest"

# Extract the version number from the latest release
$version = $latestRelease.tag_name -replace 'v', ''

# Extract everything before .windows from the version
$version = $version -replace '\.windows.*', ''

# Create the download link by replacing the placeholder with the version
$downloadLink = "https://github.com/$repo/releases/download/$($latestRelease.tag_name)/$fileName" -replace '{version}', $version

# Specify the local path to save the downloaded file
$localPath = "C:\Program Files\Git\MinGit-$version.zip"

# Download the file using Invoke-WebRequest
Invoke-WebRequest -Uri $downloadLink -OutFile $localPath -ErrorAction Stop
Write-Output "Downloaded file saved to: $localPath"

# Remove all files and folders inside $extractedFolder except ".db" files and the downloaded zip
Get-ChildItem -Path $extractedFolder | Where-Object { ($_.Extension -ne ".db") -and ($_.Extension -ne ".zip")} | Remove-Item -Recurse -Force
Write-Output "Deleted all files and folders except '.db' files and downloaded zip from: $extractedFolder"

# Specify the destination folder to extract the contents
$extractedFolder = "C:\Program Files\Git"

# Extract the contents of the zip file
Expand-Archive -Path $localPath -DestinationPath $extractedFolder -Force
Write-Output "Extracted contents to: $extractedFolder"

# Remove the downloaded zip file
Remove-Item -Path $localPath -Force
Write-Output "Deleted downloaded zip file: $localPath"
```

### Fix Circular Include Issue in Git Configuration</a>
If you encounter the error "fatal: exceeded maximum include depth (10) while including C:/Program Files/Git/etc/gitconfig," it might be due to circular includes in the Git configuration file.

Use the following PowerShell script to remove any lines that include "C:/Program Files/Git/etc/gitconfig" from the Git configuration file.

```powershell
# Specify the path to the Git configuration file
$gitConfigPath = "C:\Program Files\Git\etc\gitconfig"

# Read the content of the file
$configContent = Get-Content -Path $gitConfigPath

# Remove lines with circular includes
$configContent = $configContent | Where-Object { $_ -notlike '*C:/Program Files/Git/etc/gitconfig*' }

# Write the modified content back to the file
Set-Content -Path $gitConfigPath -Value $configContent

Write-Output "Circular includes removed from: $gitConfigPath"
```

### Add to path:
```powershell
$existingPath = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)
$newPath = "C:\Program Files\Git\mingw64\bin"
if (-not ($existingPath -like "*$newPath*")) {
    [System.Environment]::SetEnvironmentVariable('Path', "$existingPath;$newPath", [System.EnvironmentVariableTarget]::Machine)
    Write-Host "Added $newPath to the system PATH."
} else {
    Write-Host "$newPath is already in the system PATH."
}
```

### Configuration:
```bash
git config --global user.name "git_username"
git config --global user.email "user@git.com"
```


## Miscellaneous <a name="misc"></a>

### Windows & Office Activation
```powershell
irm https://massgrave.dev/get | iex
```