#
# Windows 10 post install script - Part 2
#
# Created by PM 2019-01-21
#
# Run the following command:
# PS> Set-ExecutionPolicy Bypass -Scope Process -Force; iex .\post_instal_part2.ps1
#-----------------------------------------------------------------------------------------------------------------------

#
# Self-elevate the script if required
#
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    Write-Warning "This script needs to be run As Admin - Starting new elevated powershell process";
    $CommandLine = $MyInvocation.MyCommand.Path
    $directory = split-path $CommandLine
    Start-Process -wait -FilePath PowerShell.exe -Verb Runas -ArgumentList "-noexit -command `"Set-ExecutionPolicy Bypass -Scope Process -Force; cd $directory ; &'$CommandLine'"
    break
}

#
# Halt execution on eny  error
#
$ErrorActionPreference = "Stop"

#
# Install Chocolatey
#
function Install-Chocolatey {
    if (-not $env:ChocolateyInstall -or -not (Test-Path "$env:ChocolateyInstall\bin\choco.exe")) {
        write-host "Installing Chocolatey..."
        set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        write-host "Chocolatey installation complete."
    }
}

#
# Update Classic Shell Start Menu settings
#
function Update-ClassicStartMenuSettings {
    param([switch]$useSettingsFile)

    if (-not (Test-Path "$env:ProgramFiles\Classic Shell\ClassicStartMenu.exe")) {
        write-warning 'It looks like Classic shell is not installed. Please run:  cinst -y classic-shell -installArgs ADDLOCAL=ClassicStartMenu'
        break
    }

    write-host "Installing new layout for Classic Shell start menu..."  -NoNewline

    if ($useSettingsFile) {
        if (test-path .\startmenu.xml) {
            Start-Process -FilePath "$env:ProgramFiles\Classic Shell\ClassicStartMenu.exe" -ArgumentList ("-xml " + (get-item .\startmenu.xml).FullName) -wait
        }
        else { Write-Warning "Could not find Classic Shell settings startmenu.xml"}
    }
    else {
        '<?xml version="1.0"?>
            <Settings component="StartMenu" version="4.3.1">
                <MenuStyle value="Classic1"/>
                <HideProgramsMetro value="1"/>
                <PinnedPrograms value="PinnedItems"/>
                <RecentPrograms value="None"/>
                <RecentProgsTop value="1"/>
                <EnableJumplists value="1"/>
                <StartScreenShortcut value="0"/>
                <SearchBox value="Normal"/>
                <SearchPrograms value="1"/>
                <SearchMetroApps value="0"/>
                <SearchFiles value="0"/>
                <SearchContents value="0"/>
                <SearchInternet value="0"/>
                <SkinC1 value="Metro"/>
                <SkinVariationC1 value=""/>
                <SkinOptionsC1>
                    <Line>CAPTION=0</Line>
                    <Line>USER_IMAGE=0</Line>
                    <Line>USER_NAME=0</Line>
                    <Line>CENTER_NAME=0</Line>
                    <Line>SMALL_ICONS=1</Line>
                    <Line>LARGE_FONT=0</Line>
                    <Line>ICON_FRAMES=1</Line>
                    <Line>OPAQUE=0</Line>
                </SkinOptionsC1>
                <SkipMetro value="1"/>
            </Settings>' | out-file $env:temp\startmenu.xml
        Start-Process -FilePath "$env:ProgramFiles\Classic Shell\ClassicStartMenu.exe" -ArgumentList "-xml $env:temp\startmenu.xml" -wait
        Remove-Item $env:temp\startmenu.xml
    }

    write-host Done
}

#
# Install extensions and settings for Visual Studio Code
#
function Install-VisualStudioCodeextensions {
    param([switch]$useSettingsFile)

    if (-not ($env:path -like "*Microsoft VS Code*" ) -or -not (Test-Path "$env:programfiles\Microsoft VS Code\code.exe")) {
        write-warning 'It looks like Microsoft VS Code is not installed. Please run: cinst -y visualstudiocode'
        break
    }
    write-host "Installing extensions for Visual Studio Code..."
    code --install-extension gerane.theme-zenburn
    code --install-extension ms-vscode.powershell
    code --install-extension donjayamanne.githistory
    code --install-extension hookyqr.beautify
    code --install-extension rintoj.blank-line-organizer

    write-host "Updating settings for Visual Studio Code..."
    if ($useSettingsFile) {
        if (test-path .\vscode_settings.json) {
            get-content .\vscode_settings.json | out-file $env:APPDATA\Code\User\settings.json -force -Encoding UTF8
        }
        else { Write-Warning "Could not find VS Code settings file settings.json"}
    }
    else {
        '{
            "editor.mouseWheelZoom": true,
            "editor.minimap.enabled": false,
            "workbench.colorTheme": "Zenburn",
            "editor.formatOnPaste": true,
            "editor.formatOnSave": true,
            "files.autoGuessEncoding": true,
            "files.trimTrailingWhitespace": true,
            "files.insertFinalNewline": true,
            "files.trimFinalNewlines": true,
            "blankLine.keepOneEmptyLine": true,
            "blankLine.triggerOnSave": true,
            "blankLine.languageIds": [
                "powershell",
                "java"
            ],
            "files.autoSave": "off",
            "editor.renderIndentGuides": true
        }' | out-file $env:APPDATA\Code\User\settings.json -force -Encoding UTF8
    }
    Write-host "Visual Studio Code extensions and settings done."
}

#
# Base application packages
#
function Install-BaseApps {
    cinst -y git.install
    cinst -y googlechrome
    cinst -y visualstudiocode
    cinst -y classic-shell -installArgs ADDLOCAL=ClassicStartMenu
    cinst -y cmder
    cinst -y winrar
    cinst -y 7zip

    Install-VisualStudioCodeextensions -useSettingsFile
    Update-ClassicStartMenuSettings -useSettingsFile

}

#
# Install dev application packages
#
function Install-DevApps {
    cinst -y linqpad
    cinst -y intellijidea-community
    cinst -y visualstudio2017community
    cinst -y sql-server-management-studio
    cinst -y resharper-platform
    cinst -y postman
    cinst -y poshgit
    cinst -y dotpeek
}

function install-awscli {
    cinst -y awscli
    cinst -y aws.powershell
    cinst -y awstools.powershell
}

#
# Install tool application packages
#
function install-Tools {
    cinst -y spotify
    cinst -y windirstat
    cinst -y filezilla
    cinst -y teracopy
    cinst -y wireshark
    cinst -y sysinternals
    cinst -y adobereader
    cinst -y virtualbox
    cinst -y ccleaner
    cinst -y slack
    cinst -y rufus
    cinst -y vlc
    cinst -y chocolateygui
    cinst -y k-litecodecpackfull
    cinst -y winmerge
    cinst -y mremoteng
}

Install-Chocolatey

Install-BaseApps

#install-awscli

#Install-DevApps
#install-Tools

#EOF
