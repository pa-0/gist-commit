param(
    [string]$Method,
    [bool]$IsChangeDNS,
    [string]$NetworkName,
    [string]$InstallPath,
    [bool]$ActivateWindows,
    [string]$OldUserName,
    [string]$NewComputerName,
    [bool]$UseLocalInstaller
)

# Use the values from $PSBoundParameters to update global variables
foreach ($param in $PSBoundParameters.Keys) {
    $value = $PSBoundParameters[$param]
    if ($null -ne $value) {
        Write-Host "Global:$param ---> $value" -ForegroundColor Green
        Set-Variable -Name "Global:$param" -Value $value -Scope Global
    }
}

# Set the default encoding to UTF8
[Console]::InputEncoding = [Text.Encoding]::UTF8
[Console]::OutputEncoding = [Text.Encoding]::UTF8

# Set the warning preference to SilentlyContinue
$WarningPreference = "SilentlyContinue"

# Global variables with default values
# Method to execute
$Global:Method = "InitializeComputer"
# Change DNS or not
$Global:IsChangeDNS = $true
# Network name
$Global:NetworkName = "Ethernet0"
# Install path
$Global:InstallPath = (Join-Path -Path $PSScriptRoot -ChildPath "tools")
if ((Test-Path -Path "d:\tools") -or (New-Item -ItemType Directory -Path "d:\tools" -ErrorAction SilentlyContinue)) {
    # Scenario 1 and 2: The d:\tools folder exists or can be created
    $Global:InstallPath = "d:\tools"
}

# Activate Windows
$Global:ActivateWindows = $true
# Old user name
$Global:OldUserName = "hjf"
# New computer name
$Global:NewComputerName = "hjf-pc"
# Use local installer
$Global:UseLocalInstaller = $false

# Constants
$LogsDirectory = Join-Path -Path $PSScriptRoot -ChildPath "logs"
$InstallersDirectory = Join-Path -Path $PSScriptRoot -ChildPath "installers"

# Define the array of Windows features to be installed
$WindowsFeatures = @(
    "IIS-WebServerRole",
    "TelnetClient",
    "Microsoft-Hyper-V",
    "Microsoft-Windows-Subsystem-Linux",
    "VirtualMachinePlatform"
)

# Define the programs to unpin from the taskbar
$ProgramsToUnpin = @(
    'Microsoft Edge',
    'Microsoft Store'
)

# Define the programs to pin to the taskbar and their default installation paths
$ProgramsToPin = @{
    'Windows Terminal' = Join-Path -Path $env:ProgramFiles -ChildPath 'Windows Terminal\wt.exe'
    'IIS Manager'      = Join-Path -Path $env:SystemRoot -ChildPath 'System32\inetsrv\inetmgr.exe'
    'Google Chrome'    = Join-Path -Path $env:ProgramFiles -ChildPath 'Google\Chrome\Application\chrome.exe'
}

# Define the array of apps to be installed using winget, by their IDs
class WingetTool {
    [Parameter(Mandatory = $true)]
    [string] $AppId

    [Parameter(Mandatory = $true)]
    [string] $AppName

    [Parameter(Mandatory = $true)]
    [bool] $Install

    [Parameter(Mandatory = $false)]
    [string] $Parameter
}

$Installers = [WingetTool[]]@(
    [WingetTool] @{
        AppId   = "7zip.7zip"
        AppName = "7zip"
        Install = $true
    },
    [WingetTool] @{
        AppId   = "Notepad++.Notepad++"
        AppName = "Notepad++"
        Install = $true
    },
    [WingetTool] @{
        AppId   = "Google.Chrome"
        AppName = "Chrome"
        Install = $true
    },
    [WingetTool] @{
        AppId   = "Git.Git"
        AppName = "Git"
        Install = $true
    },
    [WingetTool] @{
        AppId   = "TortoiseGit.TortoiseGit"
        AppName = "TortoiseGit"
        Install = $true
    },
    [WingetTool] @{
        AppId   = "Microsoft.VisualStudioCode"
        AppName = "Microsoft VS Code"
        Install = $true
    },
    [WingetTool] @{
        AppId   = "Microsoft.VisualStudio.2022.Enterprise"
        AppName = "Microsoft Visual Studio"
        Install = $false
    }
)

function InitializeComputer {
    # Ensure the logs directory exists
    Test-Path -Path $LogsDirectory -PathType Container -ErrorAction SilentlyContinue | Out-Null
    if (-not (Test-Path $LogsDirectory)) {
        New-Item -Path $LogsDirectory -ItemType Directory | Out-Null
    }

    # Ensure the installers directory exists
    Test-Path -Path $InstallersDirectory -PathType Container -ErrorAction SilentlyContinue | Out-Null
    if (-not (Test-Path $InstallersDirectory)) {
        New-Item -Path $InstallersDirectory -ItemType Directory | Out-Null
    }

    # Ensure the install path exists
    Test-Path -Path $Global:InstallPath -PathType Container -ErrorAction SilentlyContinue | Out-Null
    if (-not (Test-Path $Global:InstallPath)) {
        New-Item -Path $Global:InstallPath -ItemType Directory | Out-Null
    }

    if ($Global:IsChangeDNS) {
        Set-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter -Name $Global:NetworkName).ifIndex -ServerAddresses 114.114.114.114
    }

    # Enable NumLock after startup
    New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS | Out-Null

    # Set the monitor timeout to 0
    powercfg -change monitor-timeout-ac 0
    # Set the disk timeout to 0
    powercfg -change disk-timeout-ac 0
    # Set the standby timeout to 30
    powercfg -change hibernate-timeout-ac 30

    if ($Global:ActivateWindows) {
        # Activate Windows system
        & ([ScriptBlock]::Create((Invoke-RestMethod https://massgrave.dev/get))) /HWID
    }

    # Rename the computer name
    Rename-Computer -NewName $Global:NewComputerName -Force -ErrorAction Stop | Out-Null

    # Enable the Administrator account
    Enable-LocalUser -Name "Administrator" | Out-Null

    # Disable current user UAC prompt
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 0

    # Set automatic logon for the Administrator account
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name 'AutoAdminLogon' -Value 1 -Type DWORD
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name 'DefaultUsername' -Value "Administrator" -Type String

    # Set the policy to disable the privacy experience on OOBE (Out-of-Box Experience)
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" -Name "DisablePrivacyExperience" -Value 1
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" -Name "DisableOobeDatasourceWindows" -Value 1

    # Set the policy to disable the "Agree to cross-border data transfer" prompt（无效） 
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" -Name "DisableOobeDatasourceWindows" -Value 1
    $AdminSID = (Get-WmiObject -Class Win32_UserAccount -Filter "Name='Administrator'").SID
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy\TosAdditionalDataPeriodic\$AdminSID" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy\TosAdditionalDataPeriodic\$AdminSID" -Name "TosAdditionalDataPeriodic" -Value 1 -Type DWord

    # Disable OneDrive startup
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive")) {
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 1

    # Disable Location Tracking
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 0
    #Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 0

    # Disable Advertising ID
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type DWord -Value 0

    # Disable Error reporting待验证
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type DWord -Value 1
    Disable-ScheduledTask -TaskName "Microsoft\Windows\Windows Error Reporting\QueueReporting" | Out-Null

    # Stop and disable Diagnostics Tracking Service待验证
    Stop-Service "DiagTrack" -WarningAction SilentlyContinue
    Set-Service "DiagTrack" -StartupType Disabled

    # Enable Remote Desktop w/o Network Level Authentication待验证
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWord -Value 0
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Type DWord -Value 0

    # Disable Autoplay待验证
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 1

    # Disable Hibernation待验证
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Name "HibernteEnabled" -Type Dword -Value 0
    If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowHibernateOption" -Type Dword -Value 0

    # Enable the features that require a restart
    Enable-WindowsOptionalFeature -Online -FeatureName $WindowsFeatures -All -NoRestart | Out-Null
    # Disable the Windows Media Player
    Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart | Out-Null

    # Uninstall Xbox Game Bar
    Get-AppxPackage Microsoft.XboxGamingOverlay | Remove-AppxPackage

    # Install Chocolatey
    Invoke-WebRequest https://community.chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression
    # Enable Chocolatey global confirmation
    choco feature enable -n allowGlobalConfirmation
    # Set the number of retry attempts for installing packages
    choco config set feature.dotnetexe.retryattempts 20
    # Set the wait time between retry attempts for installing packages
    choco config set feature.dotnetexe.retrywait 10000
    # Set the retry count for package operations to 5
    choco config set retryCount 5
    # Set the timeout for network operations to 300 seconds
    choco config set timeout 300

    # Import RefreshEnv cmd
    Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1

    # Copy installers to temp
    if ($Global:UseLocalInstaller) {
        $PowershellCoreInstallerPath = "C:\Users\hjf\AppData\Local\Temp\chocolatey\powershell-core\7.4.1\"
        if (Test-Path -Path "$PSScriptRoot\installers\PowerShell-7.4.1-win-x64.msi" -ErrorAction SilentlyContinue) {
            New-Item -ItemType Directory -Path $PowershellCoreInstallerPath -Force | Out-Null
            Copy-Item -Path "$PSScriptRoot\installers\PowerShell-7.4.1-win-x64.msi" -Destination $PowershellCoreInstallerPath -Force | Out-Null
        }
        $WingetInstallerPath = "C:\ProgramData\chocolatey\lib\winget-cli\tools\"
        if (Test-Path -Path "$PSScriptRoot\installers\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -ErrorAction SilentlyContinue) {
            New-Item -ItemType Directory -Path $WingetInstallerPath -Force | Out-Null
            Copy-Item -Path "$PSScriptRoot\installers\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -Destination $WingetInstallerPath -Force | Out-Null
        }
    }

    # Install powershell-core winget
    if ($Global:UseLocalInstaller) {
        choco install powershell-core 7.4.1 winget v1.7.10661 -y --force --execution-timeout 0 --ignore-dependencies
    }
    else {
        choco install powershell-core winget -y --force --execution-timeout 0 --ignore-dependencies
    }
}

function CreateScheduledTaskAndRestart {
    param(
        [string]$Method
    )

    RefreshEnv
    # Create a scheduled task to continue the script after a reboot
    $ScriptPath = Join-Path -Path $PSScriptRoot -ChildPath "script.ps1"
    $TaskDesc = "Continues the script after the computer restarts."
    $TaskTrigger = New-ScheduledTaskTrigger -AtLogOn
    $scheduledTaskCMD = 
    if (Get-Command pwsh -ErrorAction SilentlyContinue) {
        "pwsh.exe"
    }
    else {
        "powershell.exe"
    }
    $TaskAction = New-ScheduledTaskAction -Execute $scheduledTaskCMD -Argument "-ExecutionPolicy Bypass -NoExit -File `"$ScriptPath`" -Method `"$Method`""
    $TaskSettings = New-ScheduledTaskSettingsSet
    Register-ScheduledTask -TaskName "ContinueScriptAfterReboot" -Description $TaskDesc -Trigger $TaskTrigger -Settings $TaskSettings -Action $TaskAction -User 'Administrator' -RunLevel 'Highest' -Force  | Out-Null

    # Add a pause statement for debugging
    Write-Host "Press any key to continue debugging..."
    $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    # Restart the computer and continue the script
    Restart-Computer -Force
}

function DeleteScheduledTask {
    # Unregister the scheduled task after restarting the computer
    $TaskName = "ContinueScriptAfterReboot"
    $Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($null -ne $Task) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false | Out-Null
    }
}

function ConfigureWindowsSettings {
    # Delete the standard user account and its directory
    Remove-LocalUser -Name $Global:OldUserName
    $UserHome = "C:\Users\$Global:OldUserName"
    Remove-Item -Path $UserHome -Recurse -Force

    # Copy the background image to the default wallpaper location
    # then Set the desktop background image
    $DestinationPath = "C:\Windows\Web\Wallpaper\Windows\background.jpg"
    Copy-Item -Path "$PSScriptRoot\images\background.jpg" -Destination $DestinationPath -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name 'Wallpaper' -Value $DestinationPath -Force

    # Show desktop computer icons
    If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel")) {
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' -Value 0 -Type DWORD

    # Set File Explorer to open This PC by default
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'LaunchTo' -Value 1 -Type DWORD -Force

    # Enable showing seconds in the system clock
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'ShowSecondsInSystemClock' -Value 1 -Force

    # Not hidden taskbar
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name 'EnableAutoTray' -Value 0 -Type DWORD -Force

    # Show all system tray icons
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideIcons" -Value 0 -Type DWORD -Force

    # Set the taskbar's icon grouping level to "Never combine"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarGlomLevel" -Value 2 -Type DWORD -Force

    # Show hidden files
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'Hidden' -Value 1 -Type DWORD -Force

    # Show file extensions
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name 'HideFileExt' -Value 0 -Type DWORD -Force

    # Set the taskbar to the left
    Set-Itemproperty -Path "HKCU:\SOFTWARE\MICROSOFT\WINDOWS\CURRENTVERSION\EXPLORER\ADVANCED" -Name 'TaskbarAl' -Value 0 -Type DWORD -Force

    # Remove the Task View button from the taskbar
    Set-ItemProperty -Path "HKCU:\SOFTWARE\MICROSOFT\WINDOWS\CURRENTVERSION\EXPLORER\ADVANCED" -Name 'ShowTaskViewButton' -Value 0 -Type DWORD -Force

    # Remove the Widgets button from the taskbar
    Set-ItemProperty -Path "HKCU:\SOFTWARE\MICROSOFT\WINDOWS\CURRENTVERSION\EXPLORER\ADVANCED" -Name 'TaskbarDa' -Value 0 -Type DWORD -Force

    # Remove the Copilot button from the taskbar
    Set-ItemProperty -Path "HKCU:\SOFTWARE\MICROSOFT\WINDOWS\CURRENTVERSION\EXPLORER\ADVANCED" -Name 'ShowCopilotButton' -Value 0 -Type DWORD -Force

    # Change the region to United States and the language to English
    Set-WinHomeLocation -GeoId 0xF4
    Install-Language -Language en-US
    Set-WinUserLanguageList -LanguageList en-US -Force | Out-Null
    Set-SystemPreferredUILanguage -Language en-US
    Set-Culture -CultureInfo en-US
    Set-WinUILanguageOverride -Language en-US

    # Change date and time format to yyyy/MM/dd HH:mm:ss
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sShortDate -Value "yyyy/MM/dd"
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sShortTime -Value "HH:mm:ss"
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sTimeFormat -Value "HH:mm:ss"

    # Restart explorer to apply the changes
    Stop-Process -Name explorer -Force

    # Update WSL2
    wsl --update
    # Set WSL's default version to 2
    wsl --set-default-version 2
    # Install WSL2
    #wsl --install -d Ubuntu-22.04

    # Copy installers to temp
    if ($Global:UseLocalInstaller) {
        $DockerInstallerPath = "C:\Users\Administrator\AppData\Local\Temp\chocolatey\docker-desktop\4.28.0\"
        if (Test-Path -Path "$PSScriptRoot\installers\Docker Desktop Installer.exe" -ErrorAction SilentlyContinue) {
            New-Item -ItemType Directory -Path $DockerInstallerPath -Force | Out-Null
            Copy-Item -Path "$PSScriptRoot\installers\Docker Desktop Installer.exe" -Destination $DockerInstallerPath -Force | Out-Null
        }
    }

    if ($Global:UseLocalInstaller) {
        # Install docker-desktop
        choco install docker-desktop 4.28.0 -y --force --execution-timeout 0 --ignore-dependencies
    }
    else {
        choco install docker-desktop -y --force --execution-timeout 0 --ignore-dependencies
    }
}

function InstallTools {
    # Iterate over each installer object
    foreach ($Installer in $Installers) {
        if ($Installer.Install) {
            # Build the winget install command with backticks for line continuation
            $wingetCommand = "winget install $($Installer.AppId) " +
            "--location `"$($Global:InstallPath)\$($Installer.AppName)`" " +
            "--log `"$Global:LogFilePath`" " +
            "--silent " +
            "--accept-source-agreements " +
            "--accept-package-agreements"

            # Add custom parameter if it is defined
            if ($null -ne $Installer.Parameter) {
                $wingetCommand += " --custom `"$($Installer.Parameter)`""
            }

            # Output the command for verification
            Write-Host "Executing command: $wingetCommand"

            # Execute the command
            Invoke-Expression $wingetCommand
        }
    }

    # Refresh environment variables, if Chocolatey's RefreshEnv cmdlet is defined
    RefreshEnv
}

# function PinAndUnpinIcons {
#     # Get the list of pinned programs on the taskbar
#     $RegPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband'
#     $PinnedItems = Get-ItemProperty -Path $RegPath -Name 'Favorites' -ErrorAction SilentlyContinue

#     if ($null -ne $PinnedItems) {
#         # Convert the binary data to a string array
#         $FavoritesAsString = [System.Text.Encoding]::Unicode.GetString($PinnedItems.Favorites)
#         $FavoritesArray = $FavoritesAsString -split '\0' | Where-Object { $_ } # Split by null character and remove empty entries

#         # Create a new list excluding the programs to unpin
#         $NewFavorites = $FavoritesArray | Where-Object { $_ -notin $ProgramsToUnpin }

#         # Add the paths of the programs to pin
#         $ProgramsToPin.Values.ForEach({
#             $NewFavorites += $_
#         })

#         # Convert the string array back to binary data
#         $NewFavoritesBinary = [System.Text.Encoding]::Unicode.GetBytes(($NewFavorites -join "`0") + "`0") # Join with null character and add a trailing null

#         # Update the registry with the new binary data
#         Set-ItemProperty -Path $RegPath -Name 'Favorites' -Value $NewFavoritesBinary
#     }

#     # Restart the explorer process to apply the changes
#     Stop-Process -Name explorer -Force  
# }

function PinAndUnpinIcons {
    # Get the list of pinned programs on the taskbar
    $RegPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband'
    $PinnedItems = Get-ItemProperty -Path $RegPath -Name 'Favorites' -ErrorAction SilentlyContinue
    if ($null -ne $PinnedItems) {
        $NewValue = $PinnedItems.Favorites | Where-Object { $_ -notin $PinnedItems.Favorites.Split(',') -and $_ -notin $ProgramsToUnpin }
        $NewValue += $ProgramsToPin.Values | ForEach-Object { $_.Replace(($_.Split('\')[-1]).Split('.')[0], '') }
        Set-ItemProperty -Path $RegPath -Name 'Favorites' -Value ($NewValue -join ',')
    }
    # Restart the explorer process to apply the changes
    Stop-Process -Name explorer -Force  
}

# Script entry point
function main {
    # Execute the function based on the Method global variable
    switch ($Global:Method) {
        "InitializeComputer" { 
            InitializeComputer
            CreateScheduledTaskAndRestart -Method "ConfigureWindowsSettings"
            break
        }
        "ConfigureWindowsSettings" { 
            ConfigureWindowsSettings
            DeleteScheduledTask
            CreateScheduledTaskAndRestart -Method "InstallTools"
            break
        }
        "InstallTools" { 
            InstallTools
            DeleteScheduledTask
            PinAndUnpinIcons
            break
        }
    }

    # Add a pause statement for debugging
    Write-Host "Press any key to continue debugging..."
    $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
}
main