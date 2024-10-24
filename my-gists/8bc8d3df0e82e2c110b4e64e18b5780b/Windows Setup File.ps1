# --------------------------------------------------
# -- Windows/System settings
# --------------------------------------------------
    # Settings:
        # System:
            # Notifications & actions:
                # Show me the Windows welcome experience...: Uncheck
                # Suggest ways I can finish setting up my device...: Uncheck
                # Get tips, tricks, and suggestions...: Uncheck
            # Multitasking:
                # Timeline:
                    # Show suggestions in your timeline: Off
        # Ease of Access:
            # Keyboard:
                # Use Sticky Keys: Off/Uncheck shortcut
                # Use Toggle Keys: Off/Uncheck shortcut
                # Use Filter Keys: Off/Uncheck shortcut
                # Print Screen Shortcut: Off
        # Personalization:
            # Background
                # Background: Solid color - grey
            # Colors:
                # Choose your color: Dark
            # Lock screen:
                # Background: Picture
                # Get fun facts: Off
                # Remove all app mappings
            # Start:
                # Show recently added apps: Off
                # Show suggestions occasionaly in Start: Off
                # Show recently opened items...: Off
                # Choose which folders appear on Start: File Explorer, Settings, Downloads
            # Taskbar:
                # Notification area:
                    # Select which icons appear on the taskbar: Show all (On)
                # Multiple displays:
                    # Show taskbar buttons on: Taskbar where window is open
        # Privacy:
            # General:
                # Change privacy options: Disable All
            # Activity History:
                # Story my activity history on this device: Disable all
        # Update & Security:
            # For developers:
                # File Explorer: Apply
                # Remote Desktop: Apply
                # PowerShell: Apply
    # Power Standby/Monitor Settings
        powercfg /X /monitor-timeout-ac 10
        powercfg /X /standby-timeout-ac 0
        powercfg /H off
        # Power Schemes - Pick one
            powercfg /S e9a42b02-d5df-448d-aa00-03f14749eb61 # Ultimate Performance; # Preferred for high end desktop; # Not supported on all versions of Win10;
            powercfg /S 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c # High Performance; # Preferred for desktop;
            powercfg /S 381b4222-f694-41f0-9685-ff5bb260df2e # Balanced;
            powercfg /S a1841308-3541-4fab-bc81-f71556f20b4a # Power Saver; # Preferred for laptop;
    # Disable UAC
        # Not doing this anymore
        # sp -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name ConsentPromptBehaviorAdmin -Value 0
    # Remove Shortcuts from "This PC" (Documents, 3D Objects, Videos, etc)
        $shortcutList = 'B4BFCC3A-DB2C-424C-B029-7FE99A87C641','A8CDFF1C-4878-43be-B5FD-F8091C1C60D0','d3162b92-9365-467a-956b-92703aca08af','374DE290-123F-4565-9164-39C4925E467B','088e3905-0323-4b02-9826-5d99428e115f','1CF1260C-4DD0-4ebb-811F-33C572699FDE','3dfdf296-dbec-4fb4-81d1-6a3438bcf4de','3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA','24ad3ad4-a569-4530-98e1-ab02f9417aa8','A0953C92-50DC-43bf-BE83-3742FED03C9C','f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a','0DB7E03F-FC29-4DC6-9020-FF41B59E513A'
        $shortcutList | % {
            rm -Path ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\${_}") -ErrorAction SilentlyContinue
            rm -Path ("HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\${_}") -ErrorAction SilentlyContinue
        }
	# Disable Bing search in Start menu
		ni -Path HKCU:\SOFTWARE\Policies\Microsoft\Windows -Name Explorer -Force
		sp -Path HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer -Name DisableSearchBoxSuggestions -Value 0x1 -Type DWord -Force
	# Show seconds in the task bar clock
		sp -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowSecondsInSystemClock -Value 0x1 -Type DWord -Force
	# Start menu open delay
		sp -Path 'HKCU:\Control Panel\Desktop' -Name MenuShowDelay -Value 100
    
    ## Hardware specific ##
    # Disable Surface Adaptive Contrast
    #   sp -path 'HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0001' -Name FeatureTestControl -Value 0x00009250
# --------------------------------------------------
#
# --------------------------------------------------
    # Remove Extra Appx Packages
        Get-AppxPackage |
            ? {!$_.NonRemovable} |
            ? Name -NotMatch 'CanonicalGroupLimited.Ubuntu(\d\d\.\d\d)?onWindows' |
            ? Name -NotMatch '^Microsoft\.([A-Z0-9]+Extension[s]?|NET\.Native\..*|UI\.Xaml\..*|VCLibs\..*)$' |
            ? Name -NotMatch '^Microsoft\.(MicrosoftOfficeHub|DesktopAppInstaller|ScreenSketch|StorePurchaseApp|WindowsCalculator)$' |
            ? Name -NotMatch '^Microsoft\.(windowscommunicationsapps|WindowsNotepad|WindowsStore|WindowsTerminal|YourPhone|549981C3F5F10)$' |
            ? Name -NotMatch '^(AppUp.IntelGraphicsExperience)$' |
            ? Name -NotLike 'Microsoft.Services.Store.Engagement' |
            ? Name -NotLike 'Microsoft.Windows.Photos' |
            ? Name -NotLike 'Microsoft.MicrosoftEdge.Stable' |
            ? Name -NotLike 'Microsoft.Winget.Source' |
            select Name | sort -Property Name
            # % { $_ | Remove-AppxPackage -Verbose }
# --------------------------------------------------
#
# --------------------------------------------------
# Setup Powershell and Choco
# --------------------------------------------------
    # Powershell Core
        iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI -AddExplorerContextMenu -EnablePSRemoting -Quiet"
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        # Set-ExecutionPolicy -ExecutionPolicy RemoteSigned #Also gets set by Windows "For Developers" settings
        # Or use chocolatey if that was done first: cinst powershell-core
    # Chocolatey
        if (!(Test-Path $PROFILE)) { ni -Path $PROFILE -ItemType File -Force }
        Set-ExecutionPolicy RemoteSigned -Force
        # Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force # not sure if needed
        iex "& { $(irm https://chocolatey.org/install.ps1) }"
        # Set-ExecutionPolicy -ExecutionPolicy (Get-ExecutionPolicy -Scope LocalMachine) -Scope Process -Force #Restores policy back to default
        # Chocolatey settings
            choco feature enable -n allowGlobalConfirmation
            choco feature enable -n useRememberedArgumentsForUpgrades
    # Chocolatey core extension
        cinst chocolatey-core.extension
    # Chocolatey (unofficial) cleanup service
        cinst choco-cleaner
# --------------------------------------------------
#
# --------------------------------------------------
# -- Minimum
# --------------------------------------------------
    # 7-Zip
#        cinst 7zip
    # Google Chrome
#        cinst googlechrome; choco pin add -n googlechrome
    # Notepad++
#        cinst notepadplusplus --x86
    # OpenSSH Client and Server
        # Refer to notes in Evernote
        # https://github.com/chadbaldwin/notes/blob/master/Technical%20Setup%20Scripts/SSH%20Server%20and%20Client%20for%20Windows.md
# --------------------------------------------------
#
# --------------------------------------------------
# -- Choco Installers
# --------------------------------------------------
    # Acrobat Reader
#        cinst adobereader --params "/NoUpdates"
    # CCleaner
#        cinst ccleaner
    # Core Temp
#        cinst coretemp
    # CPU-Z
#        cinst cpu-z
    # CrystalDiskMark
#        cinst crystaldiskmark
    # CrystalDiskInfo
#        cinst crystaldiskinfo
    # Everything - search indexing tool
#        cinst everything
#        cinst es # cli tool
    # ExpressVPN
#        cinst expressvpn
    # Firefox
#        cinst firefox -params "/NoTaskbarShortcut /NoDesktopShortcut"
    # Telerik Fiddler
#        cinst fiddler
    # FileZilla FTP Client
#        cinst filezilla
    # Fork
#        cinst git-fork; choco pin add -n git-fork
    # Greenshot
#        cinst greenshot
    # IrfanView
#        cinst irfanview
    # Java Runtime
#        cinst javaruntime
        # or
#        cinst jre8 # this one appears to be more popular
    # LINQPad
#        cinst linqpad
    # MakeMKV
        # Must also install Java JRE
#        cinst makemkv
    # Microsoft Azure Storage Explorer
#        choco install microsoftazurestorageexplorer
    # MSBuild Structured Log Viewer
#        cinst msbuild-structured-log-viewer
    # NodeJS
#        cinst nodejs
    # OBS Studio
#        cisnt obs-studio
    # OpenVPN Client
        # This choco package doesn't update very frequently, so may need to download and install manually - links for website and github repo
        # https://openvpn.net/community-downloads/
        # https://github.com/OpenVPN/openvpn-gui/releases
#        cinst openvpn
    # Postman
#        cinst postman; choco pin add -n postman
    # Microsoft PowerToys
#        cinst powertoys; choco pin add -n powertoys
    # Oh-My-Posh
#        cinst oh-my-posh
    # Putty
#        cinst putty.install # using .install package since the standard package depends on .portable
    # qBittorrent
#        cinst qbittorrent
    # ScreenToGif
#        cinst screentogif
    # SQL Server Management Studio
        # Link to release page: https://aka.ms/ssms
        # Link to download: https://aka.ms/ssmsfullsetup
#        cinst sql-server-management-studio
    # Sysinternals Suite
#        cinst sysinternals --params "/InstallDir:C:\Program Files\Sysinternals"
    # Teamviewer
#        cinst teamviewer
    # TortoiseGit
#        cinst tortoisegit
    # Typora Markdown editor
#        cinst typora
    # VLC Media Player
#        cinst vlc
    # Visual Studio Code
        # Link to download page: https://code.visualstudio.com/docs/?dv=win
#        cinst vscode --params "/NoDesktopIcon"; choco pin add -n vscode
    # Windows Terminal
        # Must install through windows app store: https://github.com/microsoft/terminal
#        cinst microsoft-windows-terminal
    # WinMerge
#        cisnt winmerge
    # WinSCP 
#        cinst winscp
    # Wireguard
#        cinst wireguard
    # Wireshark
#        cinst wireshark
# --------------------------------------------------
# Command line tools
# --------------------------------------------------
    # AWS CLI (v2)
#        msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
        # cinst awscli
    # Azure Bicep
#        cinst bicep
    # Azure CLI
        # https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
#        cinst azure-cli
#        az bicep install
#        az extension add --name azure-devops
    # EchoArgs - powershell helper to view how arguments are being parsed by the console
#        cinst echoargs
    # ExifTool
#        cinst exiftool
    # FFMPEG
#        cinst ffmpeg
    # Fuzzy Finder
#        cinst fzf
    # Git
#        cinst git --params "/NoShellIntegration /WindowsTerminal"
    # GitHub CLI
#        cinst gh
    # Graphviz -- needed for Terraform visualizer and VS Code Graphviz preview
#        cinst graphviz
    # Nuget
#        cinst nuget.commandline
    # Ripgrep
#        cinst ripgrep
    # SqlPackage
#        cinst sqlpackage
    # Terraform
#        cinst terraform
    # Yarn
#        cinst yarn
    # YouTube-dl
#        cinst youtube-dl
# --------------------------------------------------
#
# --------------------------------------------------
# Other
# --------------------------------------------------
    # Clipdiary - Apply license
        # Link to download page: http://clipdiary.com/
    # Docker Desktop
        # BIOS
            # Hardware assisted virtualization (VT-X & VT-D)
            # Data Execution Protection
        # Install Dependencies
            # Containers
#                Enable-WindowsOptionalFeature -Online -FeatureName Containers -All -NoRestart
            # Hyper-V
                # Turns out this may not be necessary at all for running linux docker containers. Leaving disabled until finding otherwise.
                # Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
        # Link to download page: https://download.docker.com/win/stable/Docker%20Desktop%20Installer.exe
    # Malware Bytes Anti-Malware
    # Microsoft Office 365
    # OneDrive
        # Set up new O:\ partition
        # Configure drive with BitLocker, use password from LastPass
    # SQL Redgate Tools
        # SQL Prompt
        # SQL Search
    # Visual Studio 2019
        # Link to download page: https://visualstudio.microsoft.com/thank-you-downloading-visual-studio/?sku=Community&rel=16
        # Packages
            # ASP.NET and web development
            # Python development
            # Node.js development
            # Data storage and processing
            # Data science and analytical applications
            # .NET Core cross-platform development
        # ? SQL Server Data Tools - not sure if needs to be installed separately, can be done upon initial install
    # Visual Studio Build Tools
        # Link to download page: https://aka.ms/buildtools
    # Windows Subsystem Linux
        # Per documentation, future releases can be installed using: wsl --install
#        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
#        Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
        # Ubuntu - Install from windows app store
        # Enable wsl ver 2
            # Changes individual distros: wsl --set-version <Distro> 2
            # Sets default for new distros: wsl --set-default-version 2
            # Verify: wsl -l -v
            # https://aka.ms/wsl2kernel
    # Windows Sandbox
#        Enable-WindowsOptionalFeature -Online -FeatureName Containers-DisposableClientVM -All -NoRestart
    # Windows Telnet Client
#        Enable-WindowsOptionalFeature -Online -FeatureName TelnetClient -All -NoRestart
    # Windows MSMQ Server
#        Enable-WindowsOptionalFeature -Online -FeatureName MSMQ-Server -All -NoRestart
# --------------------------------------------------
#
# --------------------------------------------------
# VS Code Extensions
# --------------------------------------------------
    # C# Plugin
#        code --install-extension ms-dotnettools.csharp
    # "Debugger for Chrome"
#        code --install-extension msjsdiag.debugger-for-chrome
    # "Docker"
#        code --install-extension ms-azuretools.vscode-docker
    # "SQL Server"
#        code --install-extension ms-mssql.mssql
    # "PowerShell"
#        code --install-extension ms-vscode.powershell
    # "Python"
#        code --install-extension ms-python.python
    # "Remote - WSL"
#        code --install-extension ms-vscode-remote.remote-wsl
    # ".NET Interactive Notebooks"
#        code --install-extension ms-dotnettools.dotnet-interactive-vscode
    # "Graphviz (dot) language support"
#        code --install-extension joaompinto.vscode-graphviz
# --------------------------------------------------
#
# --------------------------------------------------
# Powershell Modules
# --------------------------------------------------
    # Azure
        # https://docs.microsoft.com/en-us/powershell/azure/install-az-ps
#        Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
    # NuGet
#        Install-PackageProvider NuGet -Force
    # CredentialManager
#        Install-Module CredentialManager -Force
    # DBA Tools
#        Install-Module dbatools -Force
        # cinst dbatools
    # DotNet Installer
        # https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-install-script
#        irm 'https://dot.net/v1/dotnet-install.ps1' | Out-File ~\dotnet-install.ps1
    # Get-Parameter
        # https://www.powershellgallery.com/packages/Get-Parameter/2.9
#        Install-Script Get-Parameter
    # PoshGit
#        Install-Module posh-git -AllowPrerelease -Force
    # PowershellGet
#        Install-Module PowerShellGet -Force
    # AWS Tools
        # This module is fairly large, use the new packaged version instead if possible
#        Install-Module AWSPowerShell.NetCore -Force
    # ZLocation
#        Install-Module ZLocation -Scope CurrentUser
# --------------------------------------------------
#
# --------------------------------------------------
# Custom scripts to apply settings by linking them to OneDrive
# --------------------------------------------------
    $AppSettingsDir = "${env:OneDrive}\Documents\AppSettingsBackup"
    # CCleaner
        gi "${env:ProgramFiles}\CCleaner\ccleaner.ini" -ErrorAction Ignore | rm
        ni -ItemType SymbolicLink -Path "${env:ProgramFiles}\CCleaner\ccleaner.ini" -Target "${AppSettingsDir}\CCleaner\ccleaner.ini"
    # Clipdiary
        gi "${env:APPDATA}\Clipdiary" -ErrorAction Ignore | rm
        ni -ItemType SymbolicLink -Path "${env:APPDATA}\Clipdiary" -Target "${AppSettingsDir}\Clipdiary"
    # Fork
        gi "${env:LOCALAPPDATA}\Fork\settings.json" -ErrorAction Ignore | rm
        ni -ItemType SymbolicLink -Path "${env:LOCALAPPDATA}\Fork\settings.json" -Target "$AppSettingsDir\Fork\settings.json"
    # Git Config
        gi "${env:USERPROFILE}\.gitconfig" -ErrorAction Ignore | rm
        ni -ItemType SymbolicLink -Path "${env:USERPROFILE}\.gitconfig" -Target "${AppSettingsDir}\Git\.gitconfig"
    # IrfanView
        "[Others]`r`nINI_Folder=${AppSettingsDir}\IrfanView" | Out-File -Encoding utf8 -FilePath "${env:ProgramFiles}\IrfanView\i_view64.ini"
    # Notepad++
        # Apply Settings
            gi "${env:APPDATA}\Notepad++" -ErrorAction Ignore | rm
            ni -ItemType SymbolicLink -Path "${env:APPDATA}\Notepad++" -Target "${AppSettingsDir}\Notepad++"
        # Plugins
            # TextFX
                ni -ItemType SymbolicLink -Path "${env:ProgramFiles(x86)}\Notepad++\plugins\NppTextFX" -Target "${AppSettingsDir}\Notepad++\plugins\Binary\NppTextFX"
            # XML Tools
                ni -ItemType SymbolicLink -Path "${env:ProgramFiles(x86)}\Notepad++\plugins\XMLTools" -Target "${AppSettingsDir}\Notepad++\plugins\Binary\XMLTools"
    # SQL Server Management Studio
        # Dark Theme
            $file = gi "${env:ProgramFiles(x86)}\Microsoft SQL Server Management Studio 18\Common7\IDE\ssms.pkgundef"
            (gc $file) -Replace '(.*{1ded0138-47ce-435e-84ef-9ec1f439b749})', '//$1' | Out-File $file
        # Query execution settings
            $ssmsUserSettingsFile = "${env:APPDATA}\Microsoft\SQL Server Management Studio\18.0\UserSettings.xml"
            $newXml = "<Element><Key><int>-1</int></Key><Value><string>EXEC [master].dbo.sp_whoisactive @show_own_spid = 0, @get_outer_command = 1, @get_plans = 1, @format_output = 2, @get_locks = 1;</string></Value></Element>
                       <Element><Key><int>3</int></Key><Value><string /></Value></Element>
                       <Element><Key><int>4</int></Key><Value><string /></Value></Element>
                       <Element><Key><int>5</int></Key><Value><string>USE </string></Value></Element>
                       <Element><Key><int>6</int></Key><Value><string>SELECT FORMAT(COUNT(*),'N0') FROM </string></Value></Element>
                       <Element><Key><int>7</int></Key><Value><string>SELECT TOP(100) * FROM </string></Value></Element>
                       <Element><Key><int>8</int></Key><Value><string>SELECT * FROM </string></Value></Element>
                       <Element><Key><int>9</int></Key><Value><string>SELECT </string></Value></Element>
                       <Element><Key><int>0</int></Key><Value><string /></Value></Element>"
            # Open file
            [xml]$xmlDoc = gc $ssmsUserSettingsFile; $QESettings=$xmlDoc.SqlStudio.SSMS.QueryExecution
            # Set Settings
            ($QESettings.SelectSingleNode("QueryShortcuts")).InnerXml=$newXml
            # $QESettings.ExecutionSettings.SetTransactionIsolationLevel="READ UNCOMMITTED" # commenting out for now, may be skewing performance tuning since SSMS is not running in same isolation level as code that is deployed
            $QESettings.ExecutionSettings.SetDeadlockPriorityLow="true"
            $QESettings.ExecutionResults.RetainCRLFOnCopyOrSave="true"
            # Save file, then re-open and save to pretty-print
            $xmlDoc.Save($ssmsUserSettingsFile); [xml]$xmlDoc = gc $ssmsUserSettingsFile; $xmlDoc.Save($ssmsUserSettingsFile)
    # SQL Prompt
        $SQLPromptDir="${AppSettingsDir}\RedGate\SQL Prompt"; $SQLPromptRegKey = 'HKCU:\Software\Red Gate\SQL Prompt 10'
        sp -Path $SQLPromptRegKey -Name 'Formatting Styles Folder'    -Value "${SQLPromptDir}\StylesV2"
        sp -Path $SQLPromptRegKey -Name 'Snippets Folder'             -Value "${SQLPromptDir}\Snippets"
        sp -Path $SQLPromptRegKey -Name 'Options Folder'              -Value "${SQLPromptDir}\Options"
        sp -Path $SQLPromptRegKey -Name 'Code Analysis Settings Path' -Value "${SQLPromptDir}\CodeAnalysisSettings.casettings"
# --------------------------------------------------
# Extras
# --------------------------------------------------
    # Git
        # Remove Context Menus
            New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ErrorAction Ignore
            gci HKCR:\Directory\shell\git_* | rm -Verbose
            gci HKCR:\LibraryFolder\background\shell\git_* | rm -Verbose
            gci HKLM:\SOFTWARE\Classes\Directory\background\shell\git_* | rm -Verbose
# --------------------------------------------------
#
# --------------------------------------------------