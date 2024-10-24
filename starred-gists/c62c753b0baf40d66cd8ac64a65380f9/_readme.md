# ☄️ Powershell #pwsh Favorit Snipps

## Docs

An A-Z Index of Windows PowerShell commands <https://ss64.com/ps/>

## Restart WSL services

```powershell
Get-Service LxssManager | Restart-Service
Restart-Service -Name LxssManager
```

## Get installed modules and available modules

```powershell
Get-Module -ListAvailable
#Group all modules by name
Get-Module -ListAvailable -All | Format-Table -Property Name, Moduletype, Path -Groupby Name
# Get all installed modules
Get-InstalledModule
# Get specific versions of a module
Get-InstalledModule -Name "AzureRM.Automation" -MinimumVersion 1.0 -MaximumVersion 2.0
# Get all installed scripts
Get-InstalledScript
# Get installed scripts by name
Get-InstalledScript -Name "*update*"
# Get all module repositories
Get-PSRepository
# Get module repositories by name
Get-PSRepository -Name "*NuGet*"
```

## Display the contents of a module manifest

```powershell
# First command
$modulename = Get-Module -list -Name BitsTransfer
# Second command
Get-Content $modulename.Path
```

## Get the session history*

```powershell
Get-History
# Get entries that include a string
Get-History | Where-Object {$_.CommandLine -like "*Service*"}
```

## Display help about a cmdlet

```powershell
Get-Help Format-Table
Get-Help -Name Format-Table
Format-Table -?
# Display basic information one page at a time
help Format-Table
man Format-Table
Get-Help Format-Table | Out-Host -Paging
# Display more information for a cmdlet
Get-Help Format-Table -Detailed
Get-Help Format-Table -Full
# Display available help articles
Get-Help *
Get-help Get-Service -showWindow
# Display help for a script
Get-Help -Name C:\PS-Test\MyScript.ps1
# Update help files for all modules
Update-Help
# Update help files for different languages
Update-Help -UICulture ja-JP, en-US
# Update help files for specified modules
Update-Help -Module Microsoft.PowerShell*
# Get Alias
Get-Alias -Definition Invoke-WebRequest | Format-Table -AutoSize
```

## Get-ExperimentalFeature

```powershell
Get-ExperimentalFeature
# Enable-ExperimentalFeature
Enable-ExperimentalFeature PSImplicitRemotingBatching
```

## ForEach-Object

```powershell
Get-Process | ForEach-Object {$_.ProcessName}
# Get the length of all the files in a directory
Get-ChildItem $PSHOME |  ForEach-Object -Process {if (!$_.PSIsContainer) {$_.Name; $_.Length / 1024; " " }}
# Operate on the most recent System events
$Events = Get-EventLog -LogName System -Newest 1000
$events | ForEach-Object -Begin {Get-Date} -Process {Out-File -FilePath Events.txt -Append -InputObject $_.Message} -End {Get-Date}
# Get property values
Get-Module -ListAvailable | ForEach-Object -MemberName Path
Get-Module -ListAvailable | Foreach Path
```

## Get-Command - Get cmdlets, functions, and aliases

```powershell
Get-Command
# Get commands in the current session
Get-Command -ListImported
# Get cmdlets and display them in order
Get-Command -Type Cmdlet | Sort-Object -Property Noun | Format-Table -GroupBy Noun
# Get commands in a module
Get-Command -Module Microsoft.PowerShell.Security, Microsoft.PowerShell.Utility
# Get information about a cmdlet
Get-Command Get-AppLockerPolicy
# Get the syntax of a cmdlet
Get-Command  -Name Get-Childitem -Args Cert: -Syntax
# Get all commands of all types
Get-Command *
# Get cmdlets by using a parameter name and type
Get-Command -ParameterName *Auth* -ParameterType AuthenticationMechanism
# Get an alias
Get-Command Name dir
# Get Syntax from an alias
Get-Command -Name dir -Syntax
# Get all instances of the Notepad command
Get-Command Notepad -All | Format-Table CommandType, Name, Definition
# Get the name of a module that contains a cmdlet
(Get-Command Get-Date).ModuleName
# Get commands using a fuzzy match
Get-Command get-commnd -UseFuzzyMatching
# Get-Command cmdlet to retrieve all cmdlets from a specific module, pipe the results to the Foreach-Object cmdlet, and use the Get-Help cmdlet inside the script block.
Get-Command -Module PrintManagement| Foreach-Object {get-help $_.name -Examples}
# Get a formatted report of all commands with a synopsis.
(Get-Command).where({ $_.source }) | Sort-Object Source, CommandType, Name | Format-Table -GroupBy Source -Property CommandType, Name, @{Name = "Synopsis"; Expression = {(Get-Help $_.name).Synopsis}}

```

## Find all commands in a specified repository

```powershell
Find-Command -Repository PSGallery | Select-Object -First 10
# Find a command by name
Find-Command -Repository PSGallery -Name Get-TargetResource
# Find modules with similar names
Find-Module -Name *todo*
Find-Module -Repository PSGallery -Includes DscResource -name *task*
Find-Module  -filter telegram
# Find and install a module
Find-Module -Name PowerShellGet | Install-Module
# Install a module using its minimum version
Install-Module -Name PowerShellGet -MinimumVersion 2.0.1
# Install a specific version of a module
Install-Module -Name PowerShellGet -RequiredVersion 2.0.0
# Install a module only for the current user
Install-Module -Name PowerShellGet -Scope CurrentUser
# find script
Find-Script -Name "POSH*"
Find-Script -Name "*update*"
Find-Script -Name "Check-ModuleUpdate" -allversions
# search dependencies
Find-Script -Name "Check-ModuleUpdate" -IncludeDependencies
# Find a script and install it
Find-Script -Repository "Local1" -Name "Required-Script2"
Find-Script -Repository "Local1" -Name "Required-Script2" | Install-Script
get-command -name "get-service" -Syntax
Get-Command -Name "Required-Script2"
Get-InstalledScript -Name "Required-Script2"
Get-InstalledScript -Name "Required-Script2" | Format-List *
# Install a script with AllUsers scope
Install-Script -Repository "Local1" -Name "Required-Script3" -Scope "AllUsers"
Get-InstalledScript -Name "Required-Script3"
# Install a script and its dependencies
Find-Script -Repository "Local1" -Name "Script-WithDependencies2" -IncludeDependencies
# package provider
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force   # Always need this, required for all Modules
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted   # Set Microsoft PowerShell Gallery to 'Trusted'
```

## Uninstall a module

```powershell
Uninstall-Module -Name SpeculationControl
# Use the pipeline to uninstall a module
Get-InstalledModule -Name SpeculationControl | Uninstall-Module
# Uninstall a script
Uninstall-Script -Name UpdateManagement-Template
# Use the pipeline to uninstall a script
Get-InstalledScript -Name UpdateManagement-Template | Uninstall-Script
# Update all modules
Update-Module
Update-Module -Force
# Update a module by name
Update-Module -Name SpeculationControl
# View what-if Update-Module runs
Update-Module -WhatIf
# Update a module to a specified version
Update-Module -Name SpeculationControl -RequiredVersion 1.0.14
# Update the specified script
Update-Script -Name UpdateManagement-Template -RequiredVersion 1.1
Get-InstalledScript -Name UpdateManagement-Template
# check available providers
get-packageprovider
# Register a package Source
Register-PackageSource -name test -ProviderName NuGet -Location https://www.nuget.org/api/v2
find-package -name jquery -provider Nuget -Source https://www.nuget.org/api/v2
install-package -name jquery -provider Nuget -Source https://www.nuget.org/api/v2
uninstall-package jquery
Install-Module -Name ChocolateyGet
# AutoModuleInstallAndUpdate
# https://www.powershellgallery.com/packages/AutoModuleInstallAndUpdate
Install-Script -Name AutoModuleInstallAndUpdate
AutoModuleInstallAndUpdate.ps1 -Confirm:$false -UpdateExistingInstalledModules -IncludeAnyManuallyInstalledModules -AllowPrerelease -Scope AllUsers -KeepPriorModuleVersions
# Measure the amount of loaded modules.
Write-Host "Number of modules loaded = " + (Get-Module).Count
```

## PSReadLine

```powershell
# Get all key mappings
Get-PSReadLineKeyHandler -Bound -Unbound
# Get bound keys
Get-PSReadLineKeyHandler
# Get specific key bindings
Get-PSReadLineKeyHandler -Chord Enter, Shift+Enter
# Remove a binding
Remove-PSReadLineKeyHandler -Chord Ctrl+B
# Bind the arrow key to a function
Set-PSReadLineKeyHandler -Chord UpArrow -Function HistorySearchBackward
# Bind a key to a script block
# This example shows how a single key can be used to run a command. The command binds the key Ctrl+B to a script block that clears the line, inserts the word "build", and then accepts the line.
Set-PSReadLineKeyHandler -Chord Ctrl+B -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('build')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}
# Get options and their values
Get-PSReadLineOption
# Set foreground and background colors
Set-PSReadLineOption -Colors @{ "Comment"="`e[32;47m" }
# Set bell style
Set-PSReadLineOption -BellStyle Audible -DingTone 1221 -DingDuration 60
# Set multiple color options
Set-PSReadLineOption -Colors @{
  Command            = 'Magenta'
  Number             = 'DarkGray'
  Member             = 'DarkGray'
  Operator           = 'DarkGray'
  Type               = 'DarkGray'
  Variable           = 'DarkGreen'
  Parameter          = 'DarkGreen'
  ContinuationPrompt = 'DarkGray'
  Default            = 'DarkGray'
}
# readline history
# https://docs.microsoft.com/en-us/powershell/module/psreadline/set-psreadlineoption?view=powershell-7.1
#
Set-PSReadLineOption -PredictionSource History

```

## Diffrerent commands

```powershell
# pick a random name from a list
$NameList=’John’,’Charlotte’,’Sean’,’Colleen’,’Namoli’,’Maura’,’Neula’
Get-Random -InputObject $NameList
# Turn off the power to your computer with PowerShell
# Try without doing anything bad
Stop-Computer -WhatIf
# Stop the local computer
Stop-Computer
# Determine your version of PowerShell and host operating system
# Currently operating version
$PSVersionTable.PSVersion
# Current Host operating System
# If this value is $NULL you are currently running Windows PowerShell 5.x
# else it returns the host environment from the open Source release
$PSVersionTable.OS
# Grabbing the location your script lives in
$PSScriptRoot
#these will work the same, despite the order difference
get-service -name "ALG" -ComputerName "localhost"
get-service -ComputerName "localhost" -name "ALG"
get-service -name "alg"
get-service "ALG"
#this will fail if notepad isn't open
stop-process -name notepad -whatif
# exclude microsoft defender antivirus
Add-MpPreference -ExclusionPath 'D:\apps'
# run program minimized
# https://get-cmd.com/?p=4214
Start-Process notepad.exe C:\Temp\TextFile.txt -WindowStyle Minimized
# Show Env
Get-ChildItem Env: | Sort-Object -Property Name
# Get running scheduled tasks on a Windows system.
(get-scheduledtask).where({$_.state -eq 'running'})
# Save to variable and output to console
($var = netstat)
# Check job for errors
#1 works with both terminating and non terminating errs
$j = start-job { ls :} | wait-job; try { rcjb $j -ErrorAction Stop } catch { "err $_" }
#2
$j = start-job { ls :} | wait-job; "err " + $j.ChildJobs[0].Error + $job.ChildJobs[0].JobStateInfo.State
```

## Errors catching

```powershell
# Ensure that errors in PowerShell are caught
try
 {
  Get-Childitem c:\Foo -ErrorAction stop
 }
 catch [System.Management.Automation.ItemNotFoundException]
 {

  'oops, I guess that folder was not there'
 }
# Verbose logging,
Function MyFunction
{
    [cmdletbinding()]
    param()
    Write-verbose "Some verbose message"
    Write-host "some host message" -ForegroundColor Green
}
write-host "running normally" -ForegroundColor Yellow
MyFunction
write-host "running with -verbose" -ForegroundColor Yellow
MyFunction -Verbose
```

## Working with JSON data in PowerShell

```powershell
# $response = Invoke-WebRequest -Uri '<a href="https://jsonplaceholder.typicode.com/users">https://jsonplaceholder.typicode.com/users</a>' -UseBasicParsing
# $response = Invoke-WebRequest -Uri "https://jsonplaceholder.typicode.com/users"
$response = Invoke-WebRequest -Uri 'https://jsonplaceholder.typicode.com/users' -UseBasicParsing
$users = $response | ConvertFrom-Json
$users | FT
# Now we could do whatever we want with these users
foreach ($user in $users) {
write-host "$($user.name) has the email: $($user.email)"
}
```

***Build simple HTML with PowerShell***

```powershell
$SampleDoc=@'
This is a simple text Document in PowerShell
That I am going to make into a Tiny web page
🙂
'@
ConvertTo-Html -InputObject $SampleDoc
```

## REST API | PowerShell and the REST API for the IT pro

```powershell
# https://devblogs.microsoft.com/scripting/powershell-and-the-rest-api-for-the-it-pro/
Invoke-RestMethod https://devblogs.microsoft.com/powershell/feed/
Invoke-RestMethod -Uri ‘https://blogs.technet.microsoft.com/heyscriptingguy/rss.aspx
```

## Functions

```powershell
# https://devblogs.microsoft.com/scripting/powershell-for-programmers-how-to-write-a-function-the-right-way/
# https://devblogs.microsoft.com/scripting/doing-more-with-functions-verbose-logging-risk-mitigation-and-parameter-sets/
Function MyFunction
{
param($P1, $P2)
Write-host $p1 -foregroundcolor cyan
Write-host $p2 -foregroundcolor Magenta
}
get-command myfunction -Syntax
# pipe
function PipeValueTest
{
param($p1) #no pipe specified
Write-host "$p1 was received" -ForegroundColor Green
}
"hello" | PipeValueTest #pipe will fail to grab data
# Pipeline By Value
function PipeValueTest
{
param([parameter(ValueFromPipeline)]$p1) #no data type to care out
Write-host "$p1 was recieved" -ForegroundColor Green
}
PipeValueTest -p1 "hi" #we can still use it normally
"hello" | PipeValueTest #now we can pipe it
# Objects
#Accessing the properties and methods
$service = get-service alg
$service.DisplayName
$service.GetType()
#you don't need them in variables for quick one-offs
(get-service Winmgmt).DependentServices
#for whatever reason they didn't make -inputobject a positional parameter
$service = get-service alg
Get-Member -InputObject $service
#We can utilize the pipe though, and get member has a GM alias.
$service | Get-Member
get-process powershell_ise | GM
#This will force all the properties to come out in a list with their names and values
$service | Format-List -Property *
get-process powershell_ise | FL * #Nice shortcuts
```

## COMPARSION

```powershell
# https://devblogs.microsoft.com/scripting/powershell-for-programmers-what-happened-to-my-operators/
# (1 == 1) Instead you need:
If(1 -eq 1)
{
  write-host "Hello World" -ForegroundColor Cyan
}
#no wild cards: literal *
If("hello" -eq "h*")
{
  write-host "equal!" -ForegroundColor green
}
else
{
  write-host "not equal!" -ForegroundColor red
}

#wild cards enabled
If("hello" -like "h*")
{
  write-host "equal!" -ForegroundColor green
}
else
{
  write-host "not equal!" -ForegroundColor red
}
#Check pattern
If("I've got 1 digit inside!" -match "\d")
{
  write-host "match!" -ForegroundColor green
  #cool way to see *what* matched (will only pull the first match)
  $matches[0]
}
#wild cards + case sensitivity
If("hello" -clike "H*")
{
  write-host "equal!" -ForegroundColor green
}
else
{
  write-host "not equal!" -ForegroundColor red
}
```

## Test network connection (localhost or other host)

```powershell
Test-NetConnection 192.168.0.170 -CommonTCPPort rdp
Test-NetConnection 192.168.0.170 -CommonTCPPort SMB
```

## Get PWSH version

```powershell
$PSVersionTable
```

## get local users

```powershell
Get-WmiObject -Class Win32_UserAccount
Get-LocalGroupMember -name users
Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True'" | select name, fullname
Get-WmiObject -Class Win32_UserAccount |? {$_.localaccount -eq $true} | select name, fullname
Get-LocalGroup | %{ $groups = "$(Get-LocalGroupMember -Group $_.Name | %{ $_.Name } | Out-String)"; Write-Output "$($_.Name)>`r`n$($groups)`r`n" }
```

## find out the process id (pid) listening on port

```powershell
# CMD
netstat -aon | findstr ":80" | findstr "LISTENING"
# Use this process id with task list command to find the process name.
tasklist /fi "pid eq 4"
# PWSH
Get-Process -Id (Get-NetTCPConnection -LocalPort 80).OwningProcess
```

## Examples Other

```powershell
# WARN  Shovel executables are not registered   Fixable with running following command:
Get-ChildItem 'D:\apps\shims' -Filter 'scoop.*' | Copy-Item -Destination { Join-Path $_.Directory.FullName (($_.BaseName -replace 'scoop', 'shovel') + $_.Extension) }
```

## CONFIGURING THE DEFAULT SHELL FOR OPENSSH IN WINDOWS

```powershell
> New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Program Files\PowerShell\7\pwsh.exe" -PropertyType String -Force

```

## Search Task and Kill It

```powershell
TASKLIST /V | grep wsl
taskkill /F /PID 12524
```
