<##
#
#
# MODULE OF:
#
#
# ..One-Hundred-and-One one-liners of powershell..
#
# Author: Chris Dek.
#
# Usage: From the powershell cmdlet run the command:
# Import-Module .\Hundred-OneLines.psm1 
# ..wait for a while to load.
#
# After loading, type each variable exported in the command shell to load the relevant data
#
# Example: PS C:> $diskinfo
#
# Note: Most of the exported cmds below 
# require admin priviledges (RUN THIS FILE AS ADMIN.)
#
#
#
#
##>
function Extract-MetadataCmd {
[CmdletBinding()]
param($commandName,
[Parameter(Mandatory=$true,Position=1)]
$outputFile =$(Throw "Please define the output path for the proxy function body!")
) 
$proxyfuncbody = [Management.Automation.ProxyCommand]::Create((New-Object Management.Automation.CommandMetaData(Get-Command $($commandName))))
Set-Content -Path $outputFile -Value $proxyfuncbody
}

#Retrieve VSS for current disk
$vssout = Get-CimInstance -ClassName Win32_shadowCopy | Select { $_.InstallDate,$_.ID }
#Retrieve CPU architecture
$is64bit = (Get-WmiObject -Class Win32_ComputerSystem).SystemType -match "(x64)"
#Retrieve bios info, verify virtualization VT-d on BIOS
$biosout =  Get-WmiObject -ComputerName $env:COMPUTERNAME -Class Win32_BIOS
$vtdbiosOK = Get-WmiObject -Class Win32_Processor |  Select VirtualizationFirmwareEnabled
#Verify remote desktop enabled/disabled
#Remote desktop checker-regvals
$isRDPoff = $((Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server').fDenyTSConnections -eq 1)
$isRDPon = $((Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-tcp').UserAuthentication -eq 1)
###$isRDPoff = $((Get-CimInstance Win32_TSGeneralSetting -Namespace \root\cimv2\TerminalServices).AllowTSConnections -eq 1)
#General OS info
$osout = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $env:COMPUTERNAME | Select Caption, BuildNumber, Description, ServicePackMajorVersion, ServicePackMinorVersion
#General User account info (local accounts)
$accout = Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True'"
$userlogon = Get-WmiObject -Class Win32_LoggedOnUser -ComputerName $env:COMPUTERNAME | Select {$_}
#usb driver and other PC hardware information
$usbdrives = Get-WmiObject -Class Win32_PnPEntity | Where {$_.DeviceID -like "*USB*" } | Select DeviceID, ErrorDescription, Status
$physMedia = Get-WmiObject -Class Win32_PhysicalMedia | Select Manufacturer, Tag, Status, Removable, WriteProtectOn
#network adapter information
$adaptinfo = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Select IPAddress, MacAddress, IPSubnet
#Verify that network address rand. is enabled
$adaptrndOn = $((Get-ItemProperty -Path 'HKLM:\Software\Microsoft\WlanSvc\Interfaces\{2CA63505-D7C7-40CB-A511-02DC9A38F2DD}').RandomMacState[0].toString() -eq 1)
#disk/partition information
$diskinfo = Get-CimInstance -ClassName Win32_LogicalDisk | Select DeviceID, FileSystem, FreeSpace
$partinfo = Get-CimInstance -ClassName Win32_LogicalDisk | Select VolumeName, VolumeSerialNumber, Status, StatusInfo
#Get eventlog files avail. and statuses
$eventinfo = Get-WmiObject -Class Win32_NTEventlogFile | Select -Unique CreationDate, CSName, Description, LogFileName, Readable, Writeable
#Currently logged on user info
$currprofileinfo = Get-CimInstance -ClassName Win32_NetworkLoginProfile -Namespace "root\cimv2" | Select {$_}
$profilesconn = Get-WmiObject -Class Win32_NetworkLoginProfile | Select Name, AccountExpires, AuthorizationFlags, HomeDirectory, LastLogon, LastLogoff
#Windows features, programs not installed/disabled
$featuresDis = Get-WindowsOptionalFeature -Online | Select $_.FeatureName | Where { $_.State -eq "Disabled" }  | Format-Table -AutoSize
$IISExists = (Test-Path $env:SystemDrive\inetpub\wwwroot) -and ((Get-ChildItem -Path "$env:windir\system32\inetsrv\*\*.dll").Length -gt 0) -and (Test-Path $env:windir\System32\inetsrv)
##Check by reg. val for installed IIS. This does not run if not installed.
#$IISExistsReg = (Get-ItemProperty HKLM:\Software\Microsoft\INetStp -Name "PathWWWRoot" -eq "$env:SystemDrive\inetpub\wwwroot") -and (Get-ItemProperty "HKLM:\Software\Microsoft\INetStp" -Name "InstallPath" -eq "$env:windir\system32\inetsrv")
$IISRunsOK = (Get-WmiObject -Class Win32_Service -ComputerName $env:COMPUTERNAME -Filter "Name='IISADMIN'").State -eq "Running"
#Checks for default .net framework directories and other installation files (sql srv '14 and for VS (X64) '15)
$dotNExists = (Test-Path $env:windir\Microsoft.NET\Framework\) -or (Test-Path $env:windir\Microsoft.NET\Framework64\) -and ((Get-ChildItem -Path $env:windir\Microsoft.NET\Framework64\ -Recurse).Length -ge 1070) -or ((Get-ChildItem -Path $env:windir\Microsoft.NET\Framework64\ -Recurse).Length -ge 1100) -and ((Get-ChildItem -Path $env:windir\Microsoft.NET\assembly\ | Where {$_.Name -like "GAC*" } ).Length -eq 3)
$SqlInstalledOK = (Test-Path "$env:ProgramFiles\Microsoft SQL Server\MSSQL12.SQLEXPRESS") -or (Test-Path "${env:ProgramFiles(x86)}\Microsoft SQL Server\MSSQL12.SQLEXPRESS") -and ( ((Get-ChildItem "$env:ProgramFiles\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\Binn\*.dll").Length -gt 10) -or ((Get-ChildItem "${env:ProgramFiles(x86)}\Microsoft SQL Server\MSSQL12.SQLEXPRESS\MSSQL\Binn\*.dll").Length -gt 10) ) -and ((Get-ItemProperty -Path "HKLM:\Software\Microsoft\Microsoft SQL Server\Instance Names\SQL").SQLEXPRESS -like "*SQLEXPRESS*")
$SqlAgentRunsOK = (Get-Service -Name 'SQLAgent$SQLEXPRESS').Status -eq "Stopped"
$SqlExpressRunsOK = (Get-Service -Name 'MSSQL$SQLEXPRESS').Status -eq "Stopped"
$VSInstalledOK = (Test-Path "$env:ProgramFiles\Microsoft Visual Studio 14.0\Common7") -or (Test-Path "${env:ProgramFiles(x86)}\Microsoft Visual Studio 14.0\Common7") -and ($env:VS140COMNTOOLS -ne "" -or  $env:VS120COMNTOOLS -ne "" -or $env:VS110COMNTOOLS -ne "") -and (Test-Path $env:VS140COMNTOOLS\1033) -and ((Get-ChildItem -Path $env:VS140COMNTOOLS -Recurse).Length -gt 10) -and ( ((Get-ChildItem -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\InstalledProducts").Name -like "*Microsoft*").Length -ge 5 ) -and ( ((Get-ChildItem -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\InstalledProducts").Name -like "*ASP*").Length -ge 2 ) -and  ((Get-ItemPropertyValue -Path "HKLM:\Software\WOW6432Node\Microsoft\VisualStudio\14.0" -Name  "InstallDir").Length -ge 1)
$VCPPRedistOK = ((Test-Path -PathType Leaf $env:windir\system32\msvcr110.dll) -or (Test-Path -PathType Leaf $env:windir\system32\msvcr100.dll) -or (Test-Path -PathType Leaf $env:windir\system32\msvcr120.dll)) -and ((Get-ItemPropertyValue -Path "HKLM:\Software\Classes\Installer\Products\1926E8D15D0BCE53481466615F760A7F" -Name "Version" -ErrorAction SilentlyContinue) -like "1678*") -or ((Get-ItemPropertyValue -Path "HKLM:\Software\Classes\Installer\Dependencies\{ca67548a-5ebe-413a-b50c-4b9ceb6d66c6}" -Name "Version" -ErrorAction SilentlyContinue) -like "11.0*") -or ((Get-ItemPropertyValue -Path "HKLM:\Software\Classes\Installer\Dependencies\{050d4fc8-5d48-4b8f-8972-47c82c46020f}" -Name "Version" -ErrorAction SilentlyContinue) -like "12.0*") -or ((Get-ItemPropertyValue -Path "HKLM:\Software\Classes\Installer\Dependencies\{d992c12e-cab2-426f-bde3-fb8c53950b0d}" -Name "Version" -ErrorAction SilentlyContinue) -like "14.0*")
#This section checks for Git,Mercurial vcontrol installations.
$VerCInstalledOK = ((Test-Path -PathType Leaf $env:ProgramFiles\TortoiseHg\*.exe) -or (Test-Path -PathType Leaf $env:ProgramFiles\Git\bin\*.exe) -or (Test-Path -PathType Leaf ${env:ProgramFiles(x86)}\Git\bin\*.exe) -or (Test-Path $env:ProgramData\Git\config) -or (Test-Path $env:ProgramFiles\TortoiseHg) -or (Test-Path ${env:ProgramFiles(x86)}\TortoiseHg)) -and (Test-Path -PathType Leaf $env:USERPROFILE\.gitconfig) -and (Test-Path -PathType Leaf $env:ProgramFiles\Git\mingw64\etc\gitconfig) -and (($env:Path -match 'git') -or ($env:Path -match 'Hg') -or ($env:Path -match 'Tortoise')) -and (Test-Path -PathType Leaf $env:USERPROFILE\mercurial.ini)
$FoldersUnderGitVControl = Get-ChildItem -Path $env:SystemDrive -Recurse | Where {($_ -like "*.gitattributes") -or ($_ -like "*.gitignore")}
$FoldersUnderMercurialVControl = Get-ChildItem $env:SystemDrive\*\*\*\.hg -Recurse | Where {($_ -match 'requires') -or ($_ -match 'branch') -or ($_ -match 'hgrc') -or ($_ -match '00changelog')}
$VStudioVersionsInstalled = (Get-Item "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\").GetSubKeyNames()
$VStudioAppIDsInstalled = Get-ChildItem -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\" | Select {$_.GetValue("SecurityAppID")}
$VStudioRelevantInstalls = Get-WmiObject -Class Win32_Product -Computer . | Where {$_.Name -like "*Visual Studio*" } | Format-Table -AutoSize
#Network firewalls, vpns etc..
$allNetInfo = Get-WmiObject Win32_NetworkAdapterConfiguration -ErrorAction 'Stop' | Select-Object -Property @{L='DeviceID'; E={$_.Index}}, DNSDomain, PhysicalAdapter, Manufacturer, Description, IPEnabled | Format-Table -ShowError
$isLocalActive = Test-Connection -ComputerName $env:COMPUTERNAME -Quiet
$isFirewallactive = ((netsh advfirewall show domain state)[3] -match "ON")
$ipAddressExtn = (Invoke-WebRequest -Uri "http://checkip.dyndns.com").Content -replace "[a-z]|[A-Z]","" -replace "(<>)|(</>)|(:)",""
#Mobile Dev. Management information
$webAppinfo = Get-CimInstance -Namespace "Root\cimv2\mdm" -ClassName "MDM_WebApplication"
$wifiProfileinfo = (netsh wlan show all)[141..156]
$wifiProfilesByName = (netsh wlan show all)[159..287]
#HDD and other drive relevant information..
$volIDinfo = Get-WmiObject Win32_Volume -filter "drivetype=3" | Select DeviceID
$hddinfo = Get-WmiObject Win32_DiskDrive | Select DeviceID,Signature,Model
$partitioninfo = Get-WmiObject -Class Win32_DiskPartition | Select Index, Availability, Access, BlockSize, HiddenSectors, Size | Format-Table -AutoSize
$pshelldrvinfo = Get-PSDrive
#Ports Information, connections etc..
$sslportsopen = netstat -na  | findstr :443 | Where {$_ -match "ESTABLISHED" -or $_ -match "LISTENING"}
$winrmportsopen = netstat -na | findstr :5985 | Where {$_ -match "ESTABLISHED" -or $_ -match "LISTENING"}
#Sql relevant information SQL SERVER 2014 (NOTE: The SQL service must be running locally with WinRM Svc enabled to use Wmi classes and SQLPS module installed/enabled for the query commands)
#Default database used here is 'master', change accordingly. 
$sqlInstances = (Get-CimInstance -ComputerName $env:COMPUTERNAME -Namespace "root\Microsoft\SqlServer\ComputerManagement12" -ClassName ServerSettings).InstanceName
$ChecksqlCmdOK = Invoke-Sqlcmd -Query "Print 'Query OK'" -ServerInstance ".\$sqlInstances" -Verbose
$sqlDatabases = Invoke-Sqlcmd -Query "select @@servername as InstanceName,name as DatabaseName from sys.databases" -ServerInstance ".\$sqlInstances"
$sqlTables = Invoke-Sqlcmd -Query "select name from sys.tables" -ServerInstance ".\$sqlInstances" -Database "master"
$sqlSProcedures = Invoke-Sqlcmd -Query "Select * from sys.procedures" -ServerInstance ".\$sqlInstances" -Database "master" | Format-Table -AutoSize
$sqlBaseParams = Invoke-Sqlcmd -Query "Select object_id, name, parameter_id, system_type_id, user_type_id, max_length, precision, is_nullable from sys.all_parameters" -ServerInstance ".\$sqlInstances" -Database "master" | Format-Table -AutoSize
$sqlSrvVersion = Invoke-Sqlcmd -Query "select @@version" -ServerInstance ".\$sqlInstances" -QueryTimeout 3
$sqlPKeys = Invoke-Sqlcmd -Query "select * from sys.key_constraints" -ServerInstance ".\$sqlInstances" -Database "master"
$sqlFKeys = Invoke-Sqlcmd -Query "select * from sys.foreign_key_columns" -ServerInstance ".\$sqlInstances" -Database "master"
#ASP .NET/core information..
$alldotnetversions = Get-WmiObject Win32_Product | Where {$_.Name -like "*.NET*"} | Format-Table -AutoSize
$allaspversions =  Get-WmiObject Win32_Product | Where {$_.Name -match "ASP\.NET"}
$aspcoreversioninfo = Get-ChildItem -Path "HKLM:\Software\WoW6432Node\Microsoft\Updates\.NET Core" -ErrorAction SilentlyContinue
$aspcoreinstalledOK = ((Get-Item -Path "HKLM:\Software\WoW6432Node\Microsoft\Updates\.NET Core" -ErrorAction Stop).GetSubKeyNames().Count -ge 1) -and ((Get-ChildItem -Path "HKLM:\Software\WoW6432Node\Microsoft\Updates\.NET Core" -ErrorAction Stop)[0].GetValue("ThisVersionInstalled") -eq "Y")
#For these stats you need to enable WinRM service
$aspperfstats1 = Get-CimInstance -Class Win32_PerfFormattedData_ASPNET_ASPNET -ComputerName $env:COMPUTERNAME -Namespace "root\CIMV2"
$aspperfstats2 = Get-CimInstance -Class Win32_PerfFormattedData_aspnetstate_ASPNETStateService -ComputerName $env:COMPUTERNAME -Namespace "root\CIMV2"
$aspperfstats3 = Get-CimInstance -Class Win32_PerfRawData_aspnetstate_ASPNETStateService -ComputerName $env:COMPUTERNAME -Namespace "root\CIMV2"
$aspperfstats4 = Get-CimInstance -Class Win32_PerfRawData_ASPNET_ASPNETApplications -ComputerName $env:COMPUTERNAME -Namespace "root\CIMV2"
$allaspnetwmiproviders = gwmi  -List "*ASPNET*" | Format-Table Name -AutoSize
#Powershell information..
$psversionfullstring = "Current PS Version is {0}.{1}.{2}.{3} - Edition Mode: {4}" -f $PSVersionTable.PSVersion.Major,$PSVersionTable.PSVersion.Minor,$PSVersionTable.PSVersion.Build,$PSVersionTable.PSVersion.Revision,$PSVersionTable.PSEdition
$pshoststring = "Current PS Host is {0}, of Instance {1} LANG: {2}" -f $Host.Version, $Host.InstanceId, $Host.CurrentCulture
$pslangcultureOK = ($Host.CurrentCulture -eq $Host.CurrentUICulture)
$psrunspaceOK = $Host.IsRunspacePushed
$psdbgOK = $Host.DebuggerEnabled
$psscriptblocklogOK = (Test-Path -Path "HKLM:\SOFTWARE\WoW6432Node\Policies\Microsoft\PowerShell\ScriptBlockLogging") -or (Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging") -or (Test-Path -Path "HKCU:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging")
#HDD limit info..
$freespacepercent = gwmi Win32_LogicalDisk -Filter "DeviceID='C:'" | Select Name, FileSystem,FreeSpace,BlockSize,Size | % {$_.BlockSize=(($_.FreeSpace)/($_.Size))*100;$_.FreeSpace=($_.FreeSpace/1GB);$_.Size=($_.Size/1GB);$_}| Format-Table Name, @{n='FS';e={$_.FileSystem}},@{n='Free, Gb';e={'{0:N2}'-f $_.FreeSpace}}, @{n='Free,%';e={'{0:N2}'-f $_.BlockSize}} -AutoSize
$diskutillessthan30percent = (Get-WmiObject -Class Win32_LogicalDisk -ComputerName $env:COMPUTERNAME | Select { ( ([Math]::Round(($_.Size)/1GB) - [Math]::Round(($_.FreeSpace)/1GB)) /100 ) -ge 30.0})
$isquotaOff = (Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $env:COMPUTERNAME -Namespace "root\cimv2").QuotasDisabled
$isquotaSupported = (Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $env:COMPUTERNAME -Namespace "root\cimv2").SupportsDiskQuotas
$getmappeddiskinfo = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $env:COMPUTERNAME | Where { $_.DriveType -eq 4 }
#Applications and settings..
$allMSInstallations = Get-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Select DisplayName, Publisher, CacheLocation | Where {$_.Publisher -like "Microsoft*"} | Format-Table -AutoSize
$allGoogleInstallations = Get-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Select DisplayName, Publisher, CacheLocation | Where {$_.Publisher -like "Google*" } | Format-Table -AutoSize
$allAdobeInstallations = Get-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Select DisplayName, Publisher, CacheLocation | Where {$_.Publisher -like "Adobe*" } | Format-Table -AutoSize
$allMetroAppInstalls = Get-AppxPackage | Format-Table -AutoSize
$allprinters = Get-CimInstance -ClassName Win32_PrinterConfiguration -ComputerName $env:COMPUTERNAME | Select Name, SettingID, Duplex, PaperSize
$allsoundcards = Get-CimInstance -ClassName Win32_SoundDevice -ComputerName $env:COMPUTERNAME | Select ProductName, Status, StatusInfo, SystemName
$allmonitors = Get-CimInstance -ClassName WIn32_DesktopMonitor -ComputerName $env:COMPUTERNAME
$allkeyboardlayoutfriendlynames = (Get-ChildItem -Path "HKLM:\SYSTEM\ControlSet001\Control\Keyboard Layouts") | %{ $_.GetValue("Layout Text") }
$allkeyboardlayouthexcodes = (Get-ChildItem -Path "HKLM:\SYSTEM\ControlSet001\Control\Keyboard Layouts").Name -replace "HKEY_LOCAL_MACHINE\\SYSTEM\\ControlSet001\\Control\\Keyboard Layouts\\",""
$allInstalledkeyboardlayouts = Get-ItemProperty -Path "HKCU:\Keyboard Layout\Preload"
$isdefaultlayoutENUS = ((Get-ItemProperty -Path "HKCU:\Keyboard Layout\Preload").1 -eq "00000409")
$isdefaultlayoutGR = ((Get-ItemProperty -Path "HKCU:\Keyboard Layout\Preload").1 -eq "00000408")
$isdefaultlayoutFR = ((Get-ItemProperty -Path "HKCU:\Keyboard Layout\Preload").1 -eq "0000040c")
$isdefaultInstalledlayoutENUS = ((Get-WmiObject -Class Win32_Keyboard -ComputerName $env:COMPUTERNAME -Namespace "root\CIMV2").Layout -eq "00000409")
#Other Hardware info..
$cpuinfo = Get-CimInstance -ClassName Win32_Processor -ComputerName $env:COMPUTERNAME -Namespace "root\CIMV2"
$moboinfo = Get-CimInstance -ClassName Win32_MotherBoardDevice -ComputerName $env:COMPUTERNAME -Namespace "root\CIMV2"
$memoryinfo = Get-CimInstance -ClassName Win32_PhysicalMemory -ComputerName $env:COMPUTERNAME -Namespace "root\CIMV2"
$isRamSamsung = ((Get-CimInstance -ClassName Win32_PhysicalMemory -ComputerName $env:COMPUTERNAME -Namespace "root\CIMV2").PartNumber -like "M*B*-*") -or ((Get-CimInstance -ClassName Win32_PhysicalMemory -ComputerName $env:COMPUTERNAME -Namespace "root\CIMV2").PartNumber -like "M*T*-*")
$isRamHynix = ((Get-CimInstance -ClassName Win32_PhysicalMemory -ComputerName $env:COMPUTERNAME -Namespace "root\CIMV2").PartNumber -like "HM*-*") -or  ((Get-CimInstance -ClassName Win32_PhysicalMemory -ComputerName $env:COMPUTERNAME -Namespace "root\CIMV2").PartNumber -like "HY*-*")
$isRamKingston = ( ((Get-CimInstance -ClassName Win32_PhysicalMemory -ComputerName $env:COMPUTERNAME -Namespace "root\CIMV2").PartNumber -like "KHX*/*") -or ((Get-CimInstance -ClassName Win32_PhysicalMemory -ComputerName $env:COMPUTERNAME -Namespace "root\CIMV2").PartNumber -like "KVR*/*") )
$ramCount = Get-CimInstance -Class Win32_PhysicalMemory -ComputerName $env:COMPUTERNAME -Namespace "root\CIMV2" | Select Name | Measure-Object -Property Name -Sum -ErrorAction SilentlyContinue | Select Count -ErrorAction SilentlyContinue
$islaptop = ( ((Get-CimInstance -ClassName Win32_PhysicalMemory -ComputerName $env:COMPUTERNAME).ConfiguredVoltage /1000 -ge 1.2) -or ((Get-CimInstance -ClassName Win32_PhysicalMemory -ComputerName $env:COMPUTERNAME).ConfiguredVoltage /1000 -le 1.6) ) -or ((Get-CimInstance -ClassName Win32_PhysicalMemory -ComputerName $env:COMPUTERNAME).ConfiguredVoltage /1000 -ne 2.6) -and ( (Get-CimInstance -ClassName Win32_Battery -ComputerName $env:COMPUTERNAME).DesignVoltage /1000 -le 14)
#OS Recovery Information..
$recovPartitioninfo = (Get-CimInstance -ClassName Win32_OSRecoveryConfiguration -ComputerName $env:COMPUTERNAME).Name | Select {$_ -replace "\\",""} 
$autoRebootEnabled = (Get-CimInstance -ClassName Win32_OSRecoveryConfiguration -ComputerName $env:COMPUTERNAME).AutoReboot
#Additional OS File System sizing Information..
$programfilesdirsize = "{0:N3} Gigabytes" -f ((Get-ChildItem -Path $env:ProgramFiles -Recurse -Filter * | Measure-Object -Sum -Property Length).Sum / 1GB)
$downloadsdirsize = "{0:N3} Gigabytes" -f ((Get-ChildItem -Path "$env:USERPROFILE\Downloads" -Recurse -Filter * | Measure-Object -Sum -Property Length).Sum / 1GB)

##
#
#Variables and Functions exported here...
#
##
Export-ModuleMember -Function 'Extract-MetadataCmd'
Export-ModuleMember -Variable 'vssout'
Export-ModuleMember -Variable 'is64bit'
Export-ModuleMember -Variable 'biosout'
Export-ModuleMember -Variable 'vtdbiosOK'
Export-ModuleMember -Variable 'isRDPoff'
Export-ModuleMember -Variable 'isRDPon'
Export-ModuleMember -Variable 'osout'
Export-ModuleMember -Variable 'accout'
Export-ModuleMember -Variable 'userlogon'
Export-ModuleMember -Variable 'usbdrives'
Export-ModuleMember -Variable 'physMedia'
Export-ModuleMember -Variable 'adaptinfo'
Export-ModuleMember -Variable 'adaptrndOn'
Export-ModuleMember -Variable 'diskinfo'
Export-ModuleMember -Variable 'partinfo'
Export-ModuleMember -Variable 'eventinfo'
Export-ModuleMember -Variable 'currprofileinfo'
Export-ModuleMember -Variable 'profilesconn'
Export-ModuleMember -Variable 'featuresDis'
Export-ModuleMember -Variable 'IISExists'
Export-ModuleMember -Variable 'IISRunsOK'
Export-ModuleMember -Variable 'dotNExists'
Export-ModuleMember -Variable 'SqlInstalledOK'
Export-ModuleMember -Variable 'SqlAgentRunsOK'
Export-ModuleMember -Variable 'SqlExpressRunsOK'
Export-ModuleMember -Variable 'VSInstalledOK'
Export-ModuleMember -Variable 'VCPPRedistOK'
Export-ModuleMember -Variable 'VerCInstalledOK'
Export-ModuleMember -Variable 'FoldersUnderGitVControl'
Export-ModuleMember -Variable 'FoldersUnderMercurialVControl'
Export-ModuleMember -Variable 'VStudioVersionsInstalled'
Export-ModuleMember -Variable 'VStudioAppIDsInstalled'
Export-ModuleMember -Variable 'VStudioRelevantInstalls'
Export-ModuleMember -Variable 'allNetInfo'
Export-ModuleMember -Variable 'isLocalActive' 
Export-ModuleMember -Variable 'isFirewallactive'
Export-ModuleMember -Variable 'ipAddressExtn'
Export-ModuleMember -Variable 'webAppinfo'
Export-ModuleMember -Variable 'wifiProfileinfo'
Export-ModuleMember -Variable 'wifiProfilesByName'
Export-ModuleMember -Variable 'volIDinfo'
Export-ModuleMember -Variable 'hddinfo'
Export-ModuleMember -Variable 'partitioninfo'
Export-ModuleMember -Variable 'pshelldrvinfo'
Export-ModuleMember -Variable 'sslportsopen'
Export-ModuleMember -Variable 'winrmportsopen'
Export-ModuleMember -Variable 'sqlInstances'
Export-ModuleMember -Variable 'ChecksqlCmdOK'
Export-ModuleMember -Variable 'sqlDatabases'
Export-ModuleMember -Variable 'sqlTables'
Export-ModuleMember -Variable 'sqlSProcedures'
Export-ModuleMember -Variable 'sqlBaseParams'
Export-ModuleMember -Variable 'sqlSrvVersion'
Export-ModuleMember -Variable 'sqlPKeys'
Export-ModuleMember -Variable 'sqlFKeys'
Export-ModuleMember -Variable 'alldotnetversions'
Export-ModuleMember -Variable 'allaspversions'
Export-ModuleMember -Variable 'aspcoreversioninfo'
Export-ModuleMember -Variable 'aspcoreinstalledOK'
Export-ModuleMember -Variable 'aspperfstats1'
Export-ModuleMember -Variable 'aspperfstats2'
Export-ModuleMember -Variable 'aspperfstats3'
Export-ModuleMember -Variable 'aspperfstats4'
Export-ModuleMember -Variable 'allaspnetwmiproviders'
Export-ModuleMember -Variable 'psversionfullstring'
Export-ModuleMember -Variable 'pshoststring'
Export-ModuleMember -Variable 'pslangcultureOK'
Export-ModuleMember -Variable 'psrunspaceOK'
Export-ModuleMember -Variable 'psdbgOK'
Export-ModuleMember -Variable 'psscriptblocklogOK'
Export-ModuleMember -Variable 'freespacepercent'
Export-ModuleMember -Variable 'diskutillessthan30percent'
Export-ModuleMember -Variable 'isquotaOff'
Export-ModuleMember -Variable 'isquotaSupported'
Export-ModuleMember -Variable 'getmappeddiskinfo'
Export-ModuleMember -Variable 'allMSInstallations'
Export-ModuleMember -Variable 'allGoogleInstallations'
Export-ModuleMember -Variable 'allAdobeInstallations'
Export-ModuleMember -Variable 'allMetroAppInstalls'
Export-ModuleMember -Variable 'allprinters'
Export-ModuleMember -Variable 'allsoundcards'
Export-ModuleMember -Variable 'allmonitors'
Export-ModuleMember -Variable 'allkeyboardlayoutfriendlynames'
Export-ModuleMember -Variable 'allInstalledkeyboardlayouts'
Export-ModuleMember -Variable 'allkeyboardlayouthexcodes'
Export-ModuleMember -Variable 'isdefaultlayoutENUS'
Export-ModuleMember -Variable 'isdefaultlayoutGR'
Export-ModuleMember -Variable 'isdefaultlayoutFR'
Export-ModuleMember -Variable 'isdefaultInstalledlayoutENUS'
Export-ModuleMember -Variable 'cpuinfo'
Export-ModuleMember -Variable 'moboinfo'
Export-ModuleMember -Variable 'memoryinfo'
Export-ModuleMember -Variable 'isRamSamsung'
Export-ModuleMember -Variable 'isRamHynix'
Export-ModuleMember -Variable 'ramCount'
Export-ModuleMember -Variable 'isRamKingston'
Export-ModuleMember -Variable 'islaptop'
Export-ModuleMember -Variable 'recovPartitioninfo'
Export-ModuleMember -Variable 'autoRebootEnabled'
Export-ModuleMember -Variable 'programfilesdirsize'
Export-ModuleMember -Variable 'downloadsdirsize'