#
# Windows 10 post install script - Part 1
#
# Created by PM 2019-01-21
#
# Run the following command:
# PS> Set-ExecutionPolicy Bypass -Scope Process -Force; iex .\post_instal_part1.ps1
#-----------------------------------------------------------------------------------------------------------------------

#
# Self-elevate the script if required
#
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    Write-Warning "This script needs to be run As Admin - Starting new elevated powershell process";
    $CommandLine = $MyInvocation.MyCommand.Path
    Start-Process -wait -FilePath PowerShell.exe -Verb Runas -ArgumentList "-noexit -command `"Set-ExecutionPolicy Bypass -Scope Process -Force; &'$CommandLine'"
    break
}

#
# Halt execution on eny  error
#
$ErrorActionPreference = "Stop"

#
# Gray Windows theme
#
function Update-WindowsTheme {
    write-host 'Setting windows theme....' -NoNewline

    # Change background to solid color
    set-ItemProperty -Path "HKCU:\Control Panel\Colors" -name Background -type String -value "74 84 89"
    set-itemproperty -path "HKCU:\Control Panel\Desktop" -name WallPaper -type String -value ""

    # sett dark theme
    set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -name AppsUseLightTheme -type dword -value 0

    #  enable colors on start, task, and title bar
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\DWM  ColorPrevalence -Type DWord -Value 1
    set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -name ColorPrevalence -type dword -value 1
    set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -name EnableTransparency -type dword -value 1
    set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -name SpecialColor -type dword -value 12235947

    # add color accent
    set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent -Name AccentPalette -Type Binary -Value ([byte[]](0x98, 0xab, 0xb6, 0x00, 0x7d, 0x8d, 0x96, 0x00, 0x63, 0x70, 0x77, 0x00, 0x4a, 0x54, 0x59, 0x00, 0x37, 0x3f, 0x42, 0x00, 0x2c, 0x32, 0x35, 0x00, 0x1f, 0x23, 0x25, 0x00, 0x00, 0xb7, 0xc3, 0x00))
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent -name StartColorMenu -Type DWord -Value 4284044362
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Accent -name AccentColorMenu -Type DWord -Value 4282531639

    # disable background image on logon screen
    set-itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -name DisableLogonBackgroundImage -Type DWord -Value 1
    write-host 'Done'
}

#
# Explorer settings
#
function Update-ExplorerSettings {
    write-host 'Updating explorer settings....' -NoNewline

    If (-Not (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
        New-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Force | Out-Null
    }

    # Set task bar to never combine and show small icons
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer'
    $advancedKey = "$key\Advanced"
    $cabinetStateKey = "$key\CabinetState"

    If (-Not (Test-Path $cabinetStateKey)) {
        New-Item -Path $cabinetStateKey -Force | Out-Null
    }

    Set-ItemProperty $advancedKey TaskbarSmallIcons 1
    Set-ItemProperty $advancedKey TaskbarGlomLevel 2
    set-ItemProperty $advancedKey HideFileExt 0
    Set-ItemProperty $advancedKey NavPaneExpandToCurrentFolder 1
    Set-ItemProperty $advancedKey NavPaneShowAllFolders 1
    Set-ItemProperty $advancedKey SnapAssist 0
    Set-ItemProperty $advancedKey MMTaskbarMode 2
    Set-ItemProperty $advancedKey LaunchTo 1
    Set-ItemProperty $cabinetStateKey FullPath  1
    Set-ItemProperty $advancedKey Hidden 1
    Set-ItemProperty $advancedKey DontUsePowerShellOnWinX 0

    # Remove ribbon
    If (-Not (Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Ribbon")) {
        New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Ribbon -Force | Out-Null
    }
    set-itemproperty -path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Ribbon -name MinimizedStateTabletModeOff -value 1
    set-itemproperty -path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Ribbon -name QatItems -value -

    # Disable Quick Access: Recent Files
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowRecent -Type DWord -Value 0

    # Disable Quick Access: Frequent Folders
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowFrequent -Type DWord -Value 0

    # Disable the Lock Screen (the one before password prompt - to prevent dropping the first character)
    If (-Not (Test-Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization)) {
        New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows -Name Personalization | Out-Null
    }
    Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization -Name NoLockScreen -Type DWord -Value 1

    # Use the Windows 7-8.1 Style Volume Mixer
    If (-Not (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name MTCUVC | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC" -Name EnableMtcUvc -Type DWord -Value 0
    write-host 'Done'
}

#
# Privacy settings
#
function Update-PrivacySettings {
    write-host 'Updating privacy settings....' -NoNewline

    # Privacy: SmartScreen Filter for Store Apps: Disable
    If (-Not (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost")) {
        New-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost -Force | Out-Null
    }
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost -Name EnableWebContentEvaluation -Type DWord -Value 0
    If (-Not (Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost")) {
        New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost -Force | Out-Null
    }
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost -Name EnableWebContentEvaluation -Type DWord -Value 0

    # WiFi Sense: HotSpot Sharing: Disable
    If (-Not (Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
        New-Item -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting -Force | Out-Null
    }
    Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting -Name value -Type DWord -Value 0
    If (-Not (Test-Path "HKCU:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
        New-Item -Path HKCU:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting -Force | Out-Null
    }
    Set-ItemProperty -Path HKCU:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting -Name value -Type DWord -Value 0

    # WiFi Sense: Shared HotSpot Auto-Connect: Disable
    If (-Not (Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots")) {
        New-Item -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots -Force | Out-Null
    }
    Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots -Name value -Type DWord -Value 0
    If (-Not (Test-Path "HKCU:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots")) {
        New-Item -Path HKCU:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots -Force | Out-Null
    }
    Set-ItemProperty -Path HKCU:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots -Name value -Type DWord -Value 0

    # Disable Telemetry (requires a reboot to take effect)
    If (-Not (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection")) {
        New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection -Force | Out-Null
    }
    Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection -Name AllowTelemetry -Type DWord -Value 0
    If (-Not (Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\DataCollection")) {
        New-Item -Path HKCU:\SOFTWARE\Policies\Microsoft\Windows\DataCollection -Force | Out-Null
    }
    Set-ItemProperty -Path HKCU:\SOFTWARE\Policies\Microsoft\Windows\DataCollection -Name AllowTelemetry -Type DWord -Value 0
    Get-Service DiagTrack, Dmwappushservice | Stop-Service | Set-Service -StartupType Disabled
    write-host 'Done'
}

#
# Disable Windows Update automatic restart
# Note: This doesn't disable the need for the restart but rather tries to ensure that the restart doesn't happen in the least expected moment.
Function Disable-UpdateRestart {
    Write-host "Disabling Windows Update automatic restart...."  -NoNewline
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -Type DWord -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUPowerManagement" -Type DWord -Value 0
    write-host "Done"
}

#
# Disable Windows Defender
#
Function Disable-Defender {
    Write-Host "Disabling Windows Defender...." -NoNewline
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Type DWord -Value 1
    If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsDefender" -ErrorAction SilentlyContinue
    }
    ElseIf ([System.Environment]::OSVersion.Version.Build -ge 15063) {
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -ErrorAction SilentlyContinue
    }
    write-host 'Done'

    Write-Host "Disabling Windows Defender Cloud..." -nonew
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SpynetReporting" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SubmitSamplesC
    onsent" -Type DWord -Value 2
    write-host 'Done'
}

#
# Install Winsdows linux subsystem
#
function Install-WindowsSubsystemForLinux {
    param ([string]$dist = "debian")

    if ((Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq "Enabled") {
        Write-host "Windows feature Microsoft-Windows-Subsystem-Linux is already enabled"
    }
    else {
        Write-host "Installing windows feature Microsoft-Windows-Subsystem-Linux"
        Write-host "Restart your system after the feature is installed and rerun the script"
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    }

    if (test-path (join-path "C:\distros\" $dist)) {
        write-host (join-path "C:\distros\" $dist) " already exists. " -nonew
        read-host Press enter to overwrite installation
         Remove-Item (join-path "C:\distros\" $dist) -rec -force
    
    }

    write-host "Installing $dist ....." -NoNewline

    # hide progress bar to speed up invoke-webrequest
    $ProgressPreference = 'SilentlyContinue'

    if ($dist -like "ubuntu") {
        $env:Path += ";C:\distros\ubuntu\;"
        Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1604 -OutFile $env:temp\ubuntu.zip -UseBasicParsing
        expand-Archive $env:temp\ubuntu.zip C:\Distros\ubuntu -force
        Remove-Item $env:temp\ubuntu.zip
        write-host "Ubuntu first run - Create a user. Exit ubuntu when done."
        start-process ubuntu -Wait -nonew
        ubuntu config --default-user root
    }
    elseif ($dist -like "kali") {
        $env:Path += ";C:\distros\debian\;"
        Invoke-WebRequest -Uri https://aka.ms/wsl-kali-linux -OutFile $env:temp\kali.zip -UseBasicParsing
        Expand-Archive $env:temp\kali.zip $env:temp\kalitmp -force
        Rename-Item $env:temp\kalitmp\DistroLauncher-Appx_1.1.4.0_x64.appx DistroLauncher-Appx_1.1.4.0_x64.zip
        Expand-Archive $env:temp\kalitmp\DistroLauncher-Appx_1.1.4.0_x64.zip C:\distros\kali\ -force
        Remove-Item $env:temp\kalitmp\ -recurse
        Remove-Item $env:temp\kali.zip
        write-host "Kali first run - Create a user. Exit kali when done."
        start-process ubuntu -Wait -nonew
        kali config --default-user root

    }
    elseif ($dist -like "debian") {
        $env:Path += ";C:\distros\debian\;"
        Invoke-WebRequest -Uri https://aka.ms/wsl-debian-gnulinux -OutFile $env:temp\debian.zip -UseBasicParsing
        Expand-Archive $env:temp\debian.zip C:\Distros\debian -force
        debian install --root
        #debian.exe -c "apt-get update; apt-get install zsh -y, apt-get install git -y"
    }
    else {
        write-warning "Unknown dist $dist. Function Install-Wsl handles ubuntu, kali and debian";
    }

    wslconfig.exe /setdefault $dist

    # reset progress bar
    $ProgressPreference = 'Continue'
    write-host 'Done'
}

#
# Set User access control level to lowest possible
#
Function Disable-UAC {
    Write-host 'Lowering UAC level...' -NoNewline
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 0
    write-host 'Done'
}

#
# Disable auto play for all devices
#

Function Disable-Autoplay {
    Write-host "Disabling Autoplay...." -NoNewline
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 1
    write-host 'Done'

    Write-host "Disabling Autorun for all drives..." -NoNewline
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWord -Value 255
    write-host 'Done'
}



Function Disable-LockscreenPolicies {
    $key = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
    If (!(Test-Path $key)) {
        write-host "No personalization policies found"
    } else {
        Write-host 'Setting policies for personalization...' -NoNewline
            Set-ItemProperty -Path $key -Name NoLockScreen -Type DWord -Value 1
        Set-ItemProperty -Path $key -Name PersonalColors_Background -Type DWord -Value 4284044362
        Set-ItemProperty -Path $key -name PersonalColors_Accent -Type DWord -Value 4282531639
        Set-ItemProperty -Path $key -name LockScreenOverlaysDisabled -Type DWord -Value 1
        write-host 'Done'
    }
}
    

Function Disable-OemSystemPolicies {
    $key ="HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
 
    If (!(Test-Path $key)) {
        write-host "No System policies found"
    } else {
        Write-host 'Setting policies for System...' -NoNewline
        Set-ItemProperty -Path $key -Name DisableLogonBackgroundImage -Type DWord -Value 0
        Set-ItemProperty -Path $key -Name UseOEMBackground -Type DWord -Value 0
        Set-ItemProperty -Path $key -Name UserPolicyMode -Type DWord -Value 1
        Set-ItemProperty -Path $key -Name GroupPolicyMinTransferRate -Type DWord -Value 0
        Set-ItemProperty -Path $key -Name EnableSmartScreen -Type DWord -Value 0
         write-host 'Done'
    }
}

Function Disable-SearchPolicies {  
   $key ="HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"

    If (!(Test-Path $key)) {
        write-host "No Windows search policies found" 
    } else {
    Write-host 'Setting policies for Windows search ...' -NoNewline
        Set-ItemProperty -Path $key -Name AllowCortana -Type DWord -Value 0
        Set-ItemProperty -Path $key -Name AllowCortanaAboveLock -Type DWord -Value 0
        Set-ItemProperty -Path $key -Name AllowSearchToUseLocation -Type DWord -Value 0    
        write-host 'Done'
    }   
}

Disable-UAC
Disable-UpdateRestart
Disable-Autoplay
Update-ExplorerSettings
Update-WindowsTheme
Disable-Defender
Update-PrivacySettings
Disable-LockscreenPolicies
Disable-SearchPolicies
Disable-OemSystemPolicies

if((read-host "Install linux subsystem (y/n)") -eq "y") {
    Install-WindowsSubsystemForLinux
}

Write-host "Part 1 done!"