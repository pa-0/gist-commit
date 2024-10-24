# Description: Boxstarter Win 10 DemoLab Script
# Adapted by: https://twitter.com/sintaxasn
# Original Author: https://twitter.com/GhostInTheWire5
#
# Install boxstarter:
# 	. { iwr -useb http://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force
# NOTE the "." above is required.
#
# Run this boxstarter by calling the following from **elevated** powershell:
#   example: Install-BoxstarterPackage -PackageName https://gist.github.com/sintaxasn/ef2b4e97e27dbb55d04f0a99cd1878f4/raw/boxstarter_win10demo.ps1
# Learn more: http://boxstarter.org/Learn/WebLauncher
#
# START http://boxstarter.org/package/nr/url?http://boxstarter.org/package/nr/url?https://gist.github.com/sintaxasn/ef2b4e97e27dbb55d04f0a99cd1878f4/raw/boxstarter_win10demo.ps1

## Set up BoxStarter defaults
$Boxstarter.RebootOk = $true # Allow reboots?
$Boxstarter.NoPassword = $false # Is this a machine with no login password?
$Boxstarter.AutoLogin = $true # Save my password securely and auto-login after a reboot

$checkpointPrefix = 'BoxStarter:Checkpoint:'

Function UpdateModule {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, ValueFromPipeline)]
		[string]$module
	)
	Find-Module $module | Where-Object {
		-not ( Get-Module -FullyQualifiedName @{ ModuleName = $_.Name; ModuleVersion = $_.Version } -ListAvailable )
	} | Install-Module -SkipPublisherCheck -AllowClobber -RequiredVersion { $_.Version }
}

function Add-DefenderBypassPath {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string[]]$Path
	)
	begin {
		$Paths = @()
	}
	process {
		$Paths += $Path
	}
	end {
		$Paths | ForEach-Object {
			if (-not [string]::isnullorempty($_)) {
				Add-MpPreference -ExclusionPath $_ -Force
			}
		}
	}
}

function Get-CheckpointName {
	param
	(
		[Parameter(Mandatory = $true)]
		[string]
		$CheckpointName
	)
	return "$checkpointPrefix$CheckpointName"
}

function Set-Checkpoint {
	param
	(
		[Parameter(Mandatory = $true)]
		[string]
		$CheckpointName,

		[Parameter(Mandatory = $true)]
		[string]
		$CheckpointValue
	)

	$key = Get-CheckpointName $CheckpointName
	[Environment]::SetEnvironmentVariable($key, $CheckpointValue, "Machine") # for reboots
	[Environment]::SetEnvironmentVariable($key, $CheckpointValue, "Process") # for right now
}

function Get-Checkpoint {
	param
	(
		[Parameter(Mandatory = $true)]
		[string]
		$CheckpointName
	)

	$key = Get-CheckpointName $CheckpointName
	[Environment]::GetEnvironmentVariable($key, "Process")
}

function Clear-Checkpoints {
	$checkpointMarkers = Get-ChildItem Env: | Where-Object { $_.name -like "$checkpointPrefix*" } | Select-Object -ExpandProperty name
	foreach ($checkpointMarker in $checkpointMarkers) {
		[Environment]::SetEnvironmentVariable($checkpointMarker, '', "Machine")
		[Environment]::SetEnvironmentVariable($checkpointMarker, '', "Process")
	}
}

function Get-SystemDrive {
	return $env:SystemDrive[0]
}

function Set-BaseSettings {

	$checkpoint = 'BaseSettings'
	$done = Get-Checkpoint -CheckpointName $checkpoint

	if ($done) {
		Write-BoxstarterMessage "$checkpoint are already installed"
		return
	}

	#############################
	# Privacy / Security Settings
	#############################

	Disable-BingSearch
	Disable-GameBarTips

	# Privacy: Let apps use my advertising ID: Disable
	If (-Not (Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
		New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo | Out-Null
	}
	Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo -Name Enabled -Type DWord -Value 0

	# WiFi Sense: HotSpot Sharing: Disable
	If (-Not (Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
		New-Item -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting | Out-Null
	}
	Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting -Name value -Type DWord -Value 0

	# WiFi Sense: Shared HotSpot Auto-Connect: Disable
	Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots -Name value -Type DWord -Value 0

	# Start Menu: Disable Bing Search Results
	Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name BingSearchEnabled -Type DWord -Value 0

	# Start Menu: Disable Cortana
	New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows' -Name 'Windows Search' -ItemType Key
	New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name AllowCortana -Type DWORD -Value 0

	# Disable SMBv1
	Disable-WindowsOptionalFeature -Online -FeatureName smb1protocol

	############################
	# Developer Settings
	############################

	#--- Enable developer mode on the system ---
	Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowDevelopmentWithoutDevLicense -Value 1

	############################
	# Personal Preferences on UI
	############################

	# Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -DisableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowFullPathInTitleBar -EnableOpenFileExplorerToQuickAccess -DisableExpandToOpenFolder -EnableShowRibbon
	# Set-BoxStarterTaskbarOptions -Size Large -Dock Bottom -Combine Always 
	# Set-BoxStarterTaskbarOptions -Lock -AlwaysShowIconsOn
	# Set-StartScreenOptions -EnableShowStartOnActiveScreen

	# Change Explorer home screen back to "This PC"
	Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Type DWord -Value 1

	# These make "Quick Access" behave much closer to the old "Favorites"
	# Disable Quick Access: Recent Files
	Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowRecent -Type DWord -Value 0
	# Disable Quick Access: Frequent Folders
	Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowFrequent -Type DWord -Value 0

	# Restores things to the left pane like recycle bin
	Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Value 1
	#--- Windows Taskbar options
	# main taskbar AND taskbar where window is open for multi-monitor
	Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 1
	# Hide the search button and bar:
	Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Search -Name SearchboxTaskbarMode -Value 0
	# Hide cortana
	Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowCortanaButton -Value 0
	# Show TaskView
	Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowTaskViewButton -Value 1

	# Disable the Lock Screen (the one before password prompt - to prevent dropping the first character)
	If (-Not (Test-Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization)) {
		New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows -Name Personalization | Out-Null
	}
	Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization -Name NoLockScreen -Type DWord -Value 1

	# Lock screen (not sleep) on lid close
	Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name AwayModeEnabled -Type DWord -Value 1

	# Use the Windows 7-8.1 Style Volume Mixer
	If (-Not (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name MTCUVC | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC" -Name EnableMtcUvc -Type DWord -Value 0

	# Disable Xbox Gamebar
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name AppCaptureEnabled -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name GameDVR_Enabled -Type DWord -Value 0

	# Turn off People in Taskbar
	If (-Not (Test-Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
		New-Item -Path HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People | Out-Null
	}
	Set-ItemProperty -Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name PeopleBand -Type DWord -Value 0

	################
	# Privacy Tweaks
	################

	# Disable Telemetry
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\ProgramDataUpdater" | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Autochk\Proxy" | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" | Out-Null

	# Disable Wi-Fi Sense
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -Type Dword -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "WiFISenseAllowed" -Type Dword -Value 0

	# Disable SmartScreen Filter
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Type String -Value "Off"
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Type DWord -Value 0
	$edge = (Get-AppxPackage -AllUsers "Microsoft.MicrosoftEdge").PackageFamilyName
	If (!(Test-Path "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\PhishingFilter")) {
		New-Item -Path "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\PhishingFilter" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\PhishingFilter" -Name "EnabledV9" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\$edge\MicrosoftEdge\PhishingFilter" -Name "PreventOverride" -Type DWord -Value 0

	# Disable Bing search in Start Menu
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1

	# Disable App Suggestions
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1

	# Disable Lock Screen Spotlight
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0


	# Disable Map Updates
	Set-ItemProperty -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -Type DWord -Value 0

	# Disable Feedback
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null


	# Disable Advertising ID
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type DWord -Value 0

	# Disable Cortana
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0


	# Restrict Windows P2P downloads to local network
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 1
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization" -Name "SystemSettingsDownloadMode" -Type DWord -Value 3

	# Disable SMB1
	Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force

	# Set the current network as Private
	Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private

	# Set unknown networks to Private
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24" -Name "Category" -Type DWord -Value 1

	# Disable Home Groups
	Stop-Service "HomeGroupListener" -WarningAction SilentlyContinue
	Set-Service "HomeGroupListener" -StartupType Disabled
	Stop-Service "HomeGroupProvider" -WarningAction SilentlyContinue
	Set-Service "HomeGroupProvider" -StartupType Disabled

	# Disable Shared Experiences
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDP" -Name "RomeSdkChannelUserAuthzPolicy" -Type DWord -Value 0

	# Disable Remote Assistance
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0

	# Disable Storage Sense
	Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Recurse -ErrorAction SilentlyContinue

	# Disable Windows Indexing Service
	Stop-Service "WSearch" -WarningAction SilentlyContinue
	Set-Service "WSearch" -StartupType Disabled

	# Disable Hibernation
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Name "HibernteEnabled" -Type Dword -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowHibernateOption" -Type Dword -Value 0

	# Disable Display and Sleep mode timeouts
	powercfg /X monitor-timeout-ac 0
	powercfg /X monitor-timeout-dc 0
	powercfg /X standby-timeout-ac 0
	powercfg /X standby-timeout-dc 0

	# Disable Sticky Keys
	Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "506"

	# Show Task Manager Details
	If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Force | Out-Null
	}
	$preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
	If (!($preferences)) {
		$taskmgr = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
		While (!($preferences)) {
			Start-Sleep -m 250
			$preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
		}
		Stop-Process $taskmgr
	}
	$preferences.Preferences[28] = 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -Type Binary -Value $preferences.Preferences

	# Show File Operation details
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" -Name "EnthusiastMode" -Type DWord -Value 1

	# Hide Taskbar Search Box
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0

	# Hide Taskbar People Icon
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 0

	# Hide Recent Shortcuts
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Type DWord -Value 0

	# Set Explorer view to This PC
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1

	# Hide Music icon in This PC
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" -Recurse -ErrorAction SilentlyContinue

	# Hide Music in Explorer
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"

	# Hide Videos from This PC
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" -Recurse -ErrorAction SilentlyContinue

	# Hide Videos from Explorer
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"

	# Hide 3D Objects from This PC
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse -ErrorAction SilentlyContinue

	# Hide 3D Objects from Explorer
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
	If (!(Test-Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag")) {
		New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"

	# Adjust Visual FX to for appearance
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Type String -Value 1
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type String -Value 400
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Type Binary -Value ([byte[]](0x9E, 0x1E, 0x07, 0x80, 0x12, 0x00, 0x00, 0x00))
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type String -Value 1
	Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Type DWord -Value 3
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Type DWord -Value 1

	# Enable NumLock after Startup
	If (!(Test-Path "HKU:")) {
		New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS | Out-Null
	}
	Set-ItemProperty -Path "HKU:\.DEFAULT\Control Panel\Keyboard" -Name "InitialKeyboardIndicators" -Type DWord -Value 2147483650
	Add-Type -AssemblyName System.Windows.Forms
	If (!([System.Windows.Forms.Control]::IsKeyLocked('NumLock'))) {
		$wsh = New-Object -ComObject WScript.Shell
		$wsh.SendKeys('{NUMLOCK}')
	}

	# Disable OneDrive
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 1

	# Uninstall OneDrive
	Stop-Process -Name OneDrive -ErrorAction SilentlyContinue
	Start-Sleep -s 3
	$onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
	If (!(Test-Path $onedrive)) {
		$onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
	}
	Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
	Start-Sleep -s 3
	Stop-Process -Name explorer -ErrorAction SilentlyContinue
	Start-Sleep -s 3
	Remove-Item -Path "$env:USERPROFILE\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "$env:PROGRAMDATA\Microsoft OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "$env:SYSTEMDRIVE\OneDriveTemp" -Force -Recurse -ErrorAction SilentlyContinue
	If (!(Test-Path "HKCR:")) {
		New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
	}
	Remove-Item -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue

	# Remove Default Printers
	Remove-Printer -Name "Microsoft XPS Document Writer" -ErrorAction:SilentlyContinue
	Remove-Printer -Name "Microsoft Print to PDF" -ErrorAction:SilentlyContinue
	Remove-Printer -Name "Fax" -ErrorAction:SilentlyContinue

    Set-Checkpoint -CheckpointName $checkpoint -CheckpointValue 1

}

function Remove-SystemBloat {
	$checkpoint = 'SystemBloat'
	$done = Get-Checkpoint -CheckpointName $checkpoint

	if ($done) {
		Write-BoxstarterMessage "$checkpoint is already removed"
		return
	}

	###############################
	# Windows 10 Metro App Removals
	###############################

	Get-AppxPackage "Microsoft.3DBuilder" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingFinance" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingNews" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingSports" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingWeather" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Getstarted" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MicrosoftOfficeHub" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MicrosoftSolitaireCollection" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Office.OneNote" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.People" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.SkypeApp" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Windows.Photos" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsAlarms" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsCamera" | Remove-AppxPackage
	Get-AppxPackage "microsoft.windowscommunicationsapps" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsMaps" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsPhone" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsSoundRecorder" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.ZuneMusic" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.ZuneVideo" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.AppConnector" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.ConnectivityStore" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Office.Sway" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Messaging" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.CommsPhone" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MicrosoftStickyNotes" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.OneConnect" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsFeedbackHub" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MinecraftUWP" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MicrosoftPowerBIForWindows" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.NetworkSpeedTest" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MSPaint" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Microsoft3DViewer" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.RemoteDesktop" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Print3D" | Remove-AppxPackage
	Get-AppxPackage "9E2F88E3.Twitter" | Remove-AppxPackage
	Get-AppxPackage "king.com.CandyCrushSodaSaga" | Remove-AppxPackage
	Get-AppxPackage "4DF9E0F8.Netflix" | Remove-AppxPackage
	Get-AppxPackage "Drawboard.DrawboardPDF" | Remove-AppxPackage
	Get-AppxPackage "D52A8D61.FarmVille2CountryEscape" | Remove-AppxPackage
	Get-AppxPackage "GAMELOFTSA.Asphalt8Airborne" | Remove-AppxPackage
	Get-AppxPackage "flaregamesGmbH.RoyalRevolt2" | Remove-AppxPackage
	Get-AppxPackage "AdobeSystemsIncorporated.AdobePhotoshopExpress" | Remove-AppxPackage
	Get-AppxPackage "ActiproSoftwareLLC.562882FEEB491" | Remove-AppxPackage
	Get-AppxPackage "D5EA27B7.Duolingo-LearnLanguagesforFree" | Remove-AppxPackage
	Get-AppxPackage "Facebook.Facebook" | Remove-AppxPackage
	Get-AppxPackage "46928bounde.EclipseManager" | Remove-AppxPackage
	Get-AppxPackage "A278AB0D.MarchofEmpires" | Remove-AppxPackage
	Get-AppxPackage "KeeperSecurityInc.Keeper" | Remove-AppxPackage
	Get-AppxPackage "king.com.BubbleWitch3Saga" | Remove-AppxPackage
	Get-AppxPackage "89006A2E.AutodeskSketchBook" | Remove-AppxPackage
	Get-AppxPackage "CAF9E577.Plex" | Remove-AppxPackage
	Get-AppxPackage "A278AB0D.DisneyMagicKingdoms" | Remove-AppxPackage
	Get-AppxPackage "828B5831.HiddenCityMysteryofShadows" | Remove-AppxPackage
	Get-AppxPackage "WinZipComputing.WinZipUniversal" | Remove-AppxPackage
	Get-AppxPackage "SpotifyAB.SpotifyMusic" | Remove-AppxPackage
	Get-AppxPackage "PandoraMediaInc.29680B314EFC2" | Remove-AppxPackage
	Get-AppxPackage "2414FC7A.Viber" | Remove-AppxPackage
	Get-AppxPackage "64885BlueEdge.OneCalendar" | Remove-AppxPackage
	Get-AppxPackage "41038Axilesoft.ACGMediaPlayer" | Remove-AppxPackage

	###################################
	# Disable / Remove Xbox Features
	##################################

	Get-AppxPackage "Microsoft.XboxApp" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.XboxIdentityProvider" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.XboxSpeechToTextOverlay" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.XboxGameOverlay" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Xbox.TCUI" | Remove-AppxPackage
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0

	Set-Checkpoint -CheckpointName $checkpoint -CheckpointValue 1
}

function Install-PowerShellProfile {
	$checkpoint = 'PowerShellProfile'
	$done = Get-Checkpoint -CheckpointName $checkpoint

	if ($done) {
		Write-BoxstarterMessage "$checkpoint are already installed"
		return
	}

	# Default PowerShell profile
	$powerShellProfile = @'
## Detect if we are running powershell without a console.
$_ISCONSOLE = $TRUE
try {
	[System.Console]::Clear()
}
catch {
	$_ISCONSOLE = $FALSE
}
# Everything in this block is only relevant in a console. This keeps nonconsole based powershell sessions clean.
if ($_ISCONSOLE) {
	##  Check SHIFT state ASAP at startup so we can use that to control verbosity :)
	try {
	Add-Type -Assembly PresentationCore, WindowsBase
		if ([System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::LeftShift) -or [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::RightShift)) {
			$VerbosePreference = "Continue"
		}
	}
	catch {
		# Maybe this is a non-windows host?
	}
	## Set the profile directory variable for possible use later
	Set-Variable ProfileDir (Split-Path $MyInvocation.MyCommand.Path -Parent) -Scope Global -Option AllScope, Constant -ErrorAction SilentlyContinue
}
# Relax the code signing restriction so we can actually get work done
Import-module Microsoft.PowerShell.Security
Set-ExecutionPolicy RemoteSigned Process
'@

	Write-Output 'Creating user powershell profile...'
	$powerShellProfile | Out-File -FilePath $PROFILE -Encoding:utf8 -Force

	Set-Checkpoint -CheckpointName $checkpoint -CheckpointValue 1
}

function Install-RequiredApps {
    $checkpoint = 'RequiredApps'
    $done = Get-Checkpoint -CheckpointName $checkpoint

    if ($done) {
        Write-BoxstarterMessage "$checkpoint are already installed"
        return
    }

	#Install Chrome
	cup googlechrome --cacheLocation $tempInstallFolder
	choco pin add -n GoogleChrome

	#Install Microsoft Edge
	cup microsoft-edge --cacheLocation $tempInstallFolder
	choco pin add -n microsoft-edge

	# Install Microsoft Terminal
	cup microsoft-windows-terminal --cacheLocation $tempInstallFolder
	choco pin add -n microsoft-windows-terminal

	# Install Zip Tools
	cup 7zip --cacheLocation $tempInstallFolder
	cup bandizip --cacheLocation $tempInstallFolder

	# Install File Tools
	cup notepadplusplus --cacheLocation $tempInstallFolder
	choco pin add -n notepadplusplus

	# Install Data Transfer tools
	cup curl --cacheLocation $tempInstallFolder
	cup wget --cacheLocation $tempInstallFolder

	# Install REST tools
	# cup postman --cacheLocation $tempInstallFolder
	# cup insomnia-rest-api-client --cacheLocation $tempInstallFolder

	# install Image tools
	cup paint.net --cacheLocation $tempInstallFolder
	choco pin add -n paint.net

	# Install PowerShell Core
	cup powershell-core --cacheLocation $tempInstallFolder

	# Install Troubleshooting Tools
	cup sysinternals --cacheLocation $tempInstallFolder

	# Install git & git credential manager
	cinst git.install --package-parameters="'/GitOnlyOnPath /WindowsTerminal /NoShellIntegration /SChannel'" --cacheLocation $tempInstallFolder
	cup git-credential-manager-for-windows --cacheLocation $tempInstallFolder

	# Install posh-git
	cup poshgit --cacheLocation $tempInstallFolder

	# install Open SSH
	cup openssh --cacheLocation $tempInstallFolder

	# Registry keys for swapping out Notepad as the default text editor
	$NotepadPlus = Resolve-Path "$($env:systemdrive)\Program Files*\Notepad++\notepad++.exe"
	$RegNppPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe"
	$RegName = "Debugger"
	$RegValue = """$NotepadPlus"" -notepadStyleCmdline -z"

	# Create / Update registry key
	if (Test-Path $regNppPath) {
		New-ItemProperty -Path $regNppPath -Name $regName -Value $RegValue -PropertyType String -Force | Out-Null
	}
	else {
		New-Item -Path $regNppPath -Force | Out-Null
		New-ItemProperty -Path $regNppPath -Name $regName -Value $RegValue -PropertyType String -Force | Out-Null
	}

	# Install Source Code Pro NF Font
	Write-Host 'Install SauceCodePro font'
	$fontFileName = 'Sauce Code Pro Nerd Font Complete Mono Windows Compatible.ttf'
	$fontFaceName = 'SauceCodePro NF Regular'
	$faceName = 'SauceCodePro NF'
	$fontUrl = 'https://github.com/haasosaurus/nerd-fonts/raw/regen-mono-font-fix/patched-fonts/SourceCodePro/Regular/complete/Sauce%20Code%20Pro%20Nerd%20Font%20Complete%20Mono%20Windows%20Compatible.ttf'

	$fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
	$font = $fonts.Items() | Where-Object Name -eq $fontFaceName
	if (-not $font) {
		$fontFilePath = "$env:TEMP\$fontFileName"
		if (Test-Path $fontFilePath) { Remove-Item $fontFilePath }
		Invoke-WebRequest $fontUrl -OutFile $fontFilePath -UseBasicParsing
		$fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
		$fonts.CopyHere($fontFilePath)
		Remove-Item $fontFilePath -Force
	}

	Write-Host 'Set console defaults'
	Set-ItemProperty -Path 'HKCU:\Console' -Name 'FaceName' -Value $faceName -Type String -Force
	Set-ItemProperty -Path 'HKCU:\Console' -Name 'FontSize' -Value 0x140000 -Type DWord -Force
	Set-ItemProperty -Path 'HKCU:\Console' -Name 'ScreenBufferSize' -Value 0x270f0078 -Type DWord -Force
	Set-ItemProperty -Path 'HKCU:\Console' -Name 'WindowSize' -Value 0x240078 -Type DWord -Force
	Set-ItemProperty -Path 'HKCU:\Console' -Name 'QuickEdit' -Value 1 -Force

	refreshenv

    Set-Checkpoint -CheckpointName $checkpoint -CheckpointValue 1
}

function Install-SQLServer {
    $checkpoint = 'SQLServer'
    $done = Get-Checkpoint -CheckpointName $checkpoint

    if ($done) {
        Write-BoxstarterMessage "$checkpoint is already installed"
        return
    }

	# Install SQL Server
	cup sql-server-2019 --cacheLocation $tempInstallFolder

	# Install SQL Management Studio
	cup sql-server-management-studio --cacheLocation $tempInstallFolder
	choco pin add -n sql-server-management-studio

	# Install SQL Reporting Services
	cinst ssrs-2019 --package-parameters='"/Edition:Dev"' --cacheLocation $tempInstallFolder

    Set-Checkpoint -CheckpointName $checkpoint -CheckpointValue 1
}

function Install-VisualStudio {
	$checkpoint = 'VisualStudio'
	$done = Get-Checkpoint -CheckpointName $checkpoint

	if ($done) {
		Write-BoxstarterMessage "$checkpoint is already installed"
		return
	}

	# Install Visual Studio Dependancies
	cup chocolatey-visualstudio.extension --cacheLocation $tempInstallFolder
	cup KB3033929 --cacheLocation $tempInstallFolder
	cup KB2919355 --cacheLocation $tempInstallFolder
	cup KB2999226 --cacheLocation $tempInstallFolder
	cup dotnetfx --cacheLocation $tempInstallFolder
	cup visualstudio-installer --cacheLocation $tempInstallFolder

	if (Test-PendingReboot) {
		Write-Warning "Rebooting for VS2019 dependencies"
		Invoke-Reboot
	}

	# Install Visual Studio Community Edition
	cup visualstudio2019community --cacheLocation $tempInstallFolder
	choco pin add -n visualstudio2019community

	# Install .NET Core cross platform development workload
	cup visualstudio2019-workload-netcrossplat --cacheLocation $tempInstallFolder
	choco pin add -n visualstudio2019-workload-netcrossplat

	Set-Checkpoint -CheckpointName $checkpoint -CheckpointValue 1
}

function Install-VisualStudioCode {
	$checkpoint = 'VisualStudioCode'
	$done = Get-Checkpoint -CheckpointName $checkpoint

	if ($done) {
		Write-BoxstarterMessage "$checkpoint is already installed"
		return
	}

	# Install Visual Studio Code
	cup vscode --cacheLocation $tempInstallFolder
	choco pin add -n vscode

	# Install Visual Studio Code Extensions
	code --install-extension aaron-bond.better-comments
	code --install-extension code --install-extension adpyke.codesnap
	code --install-extension akamud.vscode-theme-onedark
	code --install-extension code --install-extension akamud.vscode-theme-onelight
	code --install-extension alefragnani.Bookmarks
	code --install-extension christian-kohler.path-intellisense
	code --install-extension CoenraadS.bracket-pair-colorizer-2
	code --install-extension DavidAnson.vscode-markdownlint
	code --install-extension davidbabel.vscode-simpler-icons
	code --install-extension donjayamanne.githistory
	code --install-extension code --install-extension dotiful.dotfiles-syntax-highlighting
	code --install-extension DotJoshJohnson.xml
	code --install-extension eamodio.gitlens
	code --install-extension esbenp.prettier-vscode
	code --install-extension foxundermoon.shell-format
	code --install-extension IBM.output-colorizer
	code --install-extension mikestead.dotenv
	code --install-extension mohsen1.prettify-json
	code --install-extension monokai.theme-monokai-pro-vscode
	code --install-extension ms-azuretools.vscode-docker
	code --install-extension ms-vscode-remote.remote-containers
	code --install-extension ms-vscode-remote.remote-ssh
	code --install-extension ms-vscode-remote.remote-ssh-edit
	code --install-extension ms-vscode-remote.remote-wsl
	code --install-extension code --install-extension ms-vscode-remote.vscode-remote-extensionpack
	code --install-extension ms-vscode.azure-account
	code --install-extension ms-vscode.powershell
	code --install-extension ms-vsts.team
	code --install-extension naumovs.color-highlight
	code --install-extension redhat.vscode-yaml
	code --install-extension Shan.code-settings-sync
	code --install-extension uloco.theme-bluloco-dark
	code --install-extension uloco.theme-bluloco-light
	code --install-extension VisualStudioExptTeam.vscodeintellicode
	code --install-extension vscode-icons-team.vscode-icons
	code --install-extension vscoss.vscode-ansible
	code --install-extension wayou.vscode-todo-highlight

	Set-Checkpoint -CheckpointName $checkpoint -CheckpointValue 1
}

function Install-PowerShellModules {
	$checkpoint = 'PowerShellModules'
	$done = Get-Checkpoint -CheckpointName $checkpoint

	if ($done) {
		Write-BoxstarterMessage "$checkpoint are already installed"
		return
	}

	if (Test-PendingReboot) {
		Invoke-Reboot
	}

	# Installing PowerShell Modules
	Install-Module -Name CredentialManager -Scope AllUsers -SkipPublisherCheck -AllowClobber -Force
	Install-Module -Name Pansies -Scope AllUsers -SkipPublisherCheck -AllowClobber -Force
	Install-Module -Name Pester -Scope AllUsers -SkipPublisherCheck -AllowClobber -Force
	Install-Module -Name platyPS -Scope AllUsers -SkipPublisherCheck -AllowClobber -Force
	Install-Module -Name PowerLine -Scope AllUsers -SkipPublisherCheck -AllowClobber -Force
	Install-Module -Name powershell-yaml -Scope AllUsers -SkipPublisherCheck -AllowClobber -Force
	Install-Module -Name psake -Scope AllUsers -SkipPublisherCheck -AllowClobber -Force
	Install-Module -Name PSCodeHealth -Scope AllUsers -SkipPublisherCheck -AllowClobber -Force
	Install-Module -Name PSFramework -Scope AllUsers -SkipPublisherCheck -AllowClobber -Force
	Install-Module -Name PSModuleDevelopment -Scope AllUsers -SkipPublisherCheck -AllowClobber -Force
	Install-Module -Name PSReadLine -Scope AllUsers -SkipPublisherCheck -AllowClobber -Force
	Install-Module -Name PSScriptAnalyzer -Scope AllUsers -SkipPublisherCheck -AllowClobber -Force
	Install-Module -Name PSUtil -Scope AllUsers -SkipPublisherCheck -AllowClobber -Force

	Set-Checkpoint -CheckpointName $checkpoint -CheckpointValue 1
}

function Install-WindowsUpdates {
	$checkpoint = 'WindowsUpdates'
	$done = Get-Checkpoint -CheckpointName $checkpoint

	if ($done) {
		Write-BoxstarterMessage "$checkpoint are already installed"
		return
	}

	Enable-MicrosoftUpdate
	Install-WindowsUpdate -acceptEula

	Set-Checkpoint -CheckpointName $checkpoint -CheckpointValue 1
}

function Install-OfficePro {
	$checkpoint = 'OfficePro'
	$done = Get-Checkpoint -CheckpointName $checkpoint

	if ($done) {
		Write-BoxstarterMessage "$checkpoint is already installed"
		return
	}

	cup office365proplus --cacheLocation $tempInstallFolder

	# If Teams autorun entry exists, remove it
	$TeamsAutoRun = (Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -ea SilentlyContinue)."com.squirrel.Teams.Teams"
	if ($TeamsAutoRun) {
		Remove-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Run -Name "com.squirrel.Teams.Teams"
	}

	# Stop Teams before modifying config
	Stop-Process -Name Teams -EA SilentlyContinue
	# Teams Config Data
	$TeamsConfig = "$env:APPDATA\Microsoft\Teams\desktop-config.json"
	$TeamsConfigData = Get-Content $TeamsConfig -Raw -ea SilentlyContinue | ConvertFrom-Json

	# If Teams already doesn't have the autorun config, exit
	If ($TeamsConfigData) {
		If ($TeamsConfigData.appPreferenceSettings.openAtLogin -eq $false) {
			# It's already configured to not startup
			exit
		}
		else {
			# If Teams hasn't run, then it's not going to have the openAtLogin:true value
			# Otherwise, replace openAtLogin:true with openAtLogin:false
			If ($TeamsConfigData.appPreferenceSettings.openAtLogin -eq $true) {
				$TeamsConfigData.appPreferenceSettings.openAtLogin = $false
			}
			else
			{ # If Teams has been intalled but hasn't been run yet, it won't have an autorun setting
				$Values = ($TeamsConfigData.appPreferenceSettings | Get-Member -MemberType NoteProperty).Name
				If ($Values -match "openAtLogin") {
					$TeamsConfigData.appPreferenceSettings.openAtLogin = $false
				}
				else {
					$TeamsConfigData.appPreferenceSettings | Add-Member -Name "openAtLogin" -Value $false -MemberType NoteProperty
				}
			}
			# Save
			$TeamsConfigData | ConvertTo-Json -Depth 100 | Out-File -Encoding UTF8 -FilePath $TeamsConfig -Force
		}
	}

	Set-Checkpoint -CheckpointName $checkpoint -CheckpointValue 1
}

function New-InstallCache {
	param
	(
		[String]
		$InstallDrive
	)

	$tempInstallFolder = Join-Path $InstallDrive "temp\install-cache"

	if (-not (Test-Path $tempInstallFolder)) {
		New-Item $tempInstallFolder -ItemType Directory
	}

	return $tempInstallFolder
}

function Update-Path {
	$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

Update-ExecutionPolicy -Policy RemoteSigned

$dataDriveLetter = Get-SystemDrive
$dataDrive = "$dataDriveLetter`:"
$tempInstallFolder = New-InstallCache -InstallDrive $dataDrive

# Set up PowerShell to use the latest package management tools
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Install/Update PowershellGet and PackageManager if needed
try {
	Import-Module PowerShellGet
}
catch {
	throw 'Unable to load PowerShellGet!'
}

# Need to set Nuget as a provider before installing modules via PowerShellGet
$null = Install-PackageProvider NuGet -Force

$packages = Get-Package
if (@($packages | Where-Object { $_.Name -eq 'PackageManagement' }).Count -eq 0) {
	Write-Host -ForegroundColor cyan "PackageManager is installed but not being maintained via the PowerShell gallery (so it will never get updated). Forcing the install of this module through the gallery to rectify this now."
	Install-Module PackageManagement -Force
	Install-Module PowerShellGet -Force

	Write-Host -ForegroundColor:Red "PowerShellGet and PackageManagement have been installed from the gallery. You need to close and rerun this script for them to work properly!"

	Invoke-Reboot
}

# UpdateModule PackageManagement
# UpdateModule PowerShelLGet

# Temporary
Disable-UAC

choco feature enable -n=allowGlobalConfirmation

#############################
# Start Installations
#############################

Set-BaseSettings
if (Test-PendingReboot) { Invoke-Reboot }
Remove-SystemBloat
if (Test-PendingReboot) { Invoke-Reboot }
Install-PowerShellProfile
if (Test-PendingReboot) { Invoke-Reboot }
Install-RequiredApps
if (Test-PendingReboot) { Invoke-Reboot }
Install-OfficePro
if (Test-PendingReboot) { Invoke-Reboot }
Install-VisualStudio
if (Test-PendingReboot) { Invoke-Reboot }
Install-VisualStudioCode
if (Test-PendingReboot) { Invoke-Reboot }
Install-PowerShellModules
if (Test-PendingReboot) { Invoke-Reboot }
Install-SQLServer
if (Test-PendingReboot) { Invoke-Reboot }
Install-WindowsUpdates
if (Test-PendingReboot) { Invoke-Reboot }

##########
# Clean Up
##########

# Clean up desktop shortcuts
Get-ChildItem -Path ([Environment]::GetFolderPath('CommonDesktopDirectory')) -Filter '*.lnk' | Remove-Item
Get-ChildItem -Path $Desktop -Filter '*.lnk' | Remove-Item

# Clean up the cache directory
Remove-Item $tempInstallFolder -Recurse

#--- Restore Temporary Settings ---
Enable-UAC

Clear-Checkpoints