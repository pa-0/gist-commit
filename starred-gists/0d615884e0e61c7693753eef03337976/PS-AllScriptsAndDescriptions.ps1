<#############################
## 2015-07-10, 14:45 - 
## Check if Session running with evevated / administrator privledges
#############################>
  ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

  #Ref: http://www.jonathanmedd.net/2014/01/testing-for-admin-privileges-in-powershell.html
  
<#############################
## 2015-07-10, 11:10 - 
## List a windows enviroment variable, e.g. Powershell module path %PSModulePath% 
#############################>

    Get-ChildItem Env:PSModulePath | FL

<###################################################################
 ###################################################################
 
   20150708 -- https://gist.github.com/orrwil/924f4e2e6148690231c5 
 
 ###################################################################
 ###################################################################>


<#############################
## 2015-04-13, 11:10 - 
## Windows Start up apps 
#############################>
C:\Users\<user_Payroll>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup

<#############################
## 2015-03-12, 11:49 - 
## Download file from website to specific location
#############################>
wget $URL -OutFile .\fileName.ext

<#############################
## 2015-03-09, 10:45 - 
## Pause / Wait for a random number of seconds
#############################>
Start-Sleep -Seconds (Get-Random -Maximum 35 -Minimum 8)

<#############################
## 2015-03-05, 17:10 - 
## SQL, pad all strings with leading zeros, including null values
#############################>

UPDATE [dbname].[dbo].[table] 
SET col =  RIGHT('0000000'+ISNULL(col,''),7)

<#############################
## 2015-03-05, 15:10 - 
## Remove empty folders and output folder names that are too long, Error:  
##            "Get-ChildItem : The specified path, file name, or both are too long"
#############################>
$allFolders = Get-ChildItem S:\ -recurse -ErrorAction SilentlyContinue -ErrorVariable err | Where-Object {$_.PSIsContainer -eq $True} #13323, 12938
foreach ($errorRecord in $err)
{
    if ($errorRecord.Exception -is [System.IO.PathTooLongException])
    {
        Write-Warning "Path too long in directory '$($errorRecord.TargetObject)'."
    }
    else
    {
        Write-Error -ErrorRecord $errorRecord
    }
}
$emptyFolders = $allFolders | Where-Object {$_.GetFiles().Count -eq 0 -and $_.GetDirectories().Count -eq 0} #385, 27
$emptyFolders | Remove-Item 

<#############################
## 2015-02-27, 15:10 - 
## Block comment in Powershell ise
#############################>

Alt + Shift + Up/Down arrow, #

<#############################
## 2015-02-27, 15:10 - 
## Run access as admin
#############################>

invoke-item "C:\Program Files (x86)\Microsoft Office\OFFICE12\MSACCESS.EXE"

<#############################
## 2015-02-12, 14:00 - 
## SQL Server Post Deployment Script FTC - check somthing doesnt exist before attempting to create
## Ensuring script is sucessful weither FTC needs created or already exists - Idempotence, i.e. 
## can run multiple times with same results
#############################>

-- Check if FTC exists and if not create 
IF NOT EXISTS (SELECT 1 FROM sys.fulltext_catalogs WHERE name = 'FTC_<appName>')
BEGIN
	CREATE FULLTEXT CATALOG [FTC_D<appName>] WITH ACCENT_SENSITIVITY = OFF
	AS DEFAULT
PRINT 'Created Catalog'
END
ELSE PRINT 'Catalog already exists'

<#############################
## 2015-02-06, 11:40 - 
## Measure command performance over multiple samples. 
## Ref: http://zduck.com/2013/benchmarking-with-Powershell/
#############################>

# benchmark.psm1
# Exports: Benchmark-Command

function Benchmark-Command ([ScriptBlock]$Expression, [int]$Samples = 1, [Switch]$Silent, [Switch]$Long) {
<#
.SYNOPSIS
  Runs the given script block and returns the execution duration.
  Hat tip to StackOverflow. http://stackoverflow.com/questions/3513650/timing-a-commands-execution-in-powershell
  
.EXAMPLE
  Benchmark-Command { ping -n 1 google.com }
#>
  $timings = @()
  do {
    $sw = New-Object Diagnostics.Stopwatch
    if ($Silent) {
      $sw.Start()
      $null = & $Expression
      $sw.Stop()
      Write-Host "." -NoNewLine
    }
    else {
      $sw.Start()
      & $Expression
      $sw.Stop()
    }
    $timings += $sw.Elapsed
    
    $Samples--
  }
  while ($Samples -gt 0)
  
  Write-Host
  
  $stats = $timings | Measure-Object -Average -Minimum -Maximum -Property Ticks
  
  # Print the full timespan if the $Long switch was given.
  if ($Long) {  
    Write-Host "Avg: $((New-Object System.TimeSpan $stats.Average).ToString())"
    Write-Host "Min: $((New-Object System.TimeSpan $stats.Minimum).ToString())"
    Write-Host "Max: $((New-Object System.TimeSpan $stats.Maximum).ToString())"
  }
  else {
    # Otherwise just print the milliseconds which is easier to read.
    Write-Host "Avg: $((New-Object System.TimeSpan $stats.Average).TotalMilliseconds)ms"
    Write-Host "Min: $((New-Object System.TimeSpan $stats.Minimum).TotalMilliseconds)ms"
    Write-Host "Max: $((New-Object System.TimeSpan $stats.Maximum).TotalMilliseconds)ms"
  }
}

Export-ModuleMember Benchmark-Command

<#############################
## 2015-02-06, 10:20 - 
## Ignore # in get content
#############################>

$list = gc \\<serverName>\<serverName>\Servers.txt |  Where-Object {!($_.StartsWith("#"))}


<#############################
## 2015-01-26, 17:43 - 
## Get All users in AD group and insert to Staff Directory
#############################>

$ADGroupMembers = Get-ADGroup '<AD_Group_Name>' -Properties Member
$SQLCmd = @()
$SQLCmd  += "USE <database> `nGO"

# Loop through the member property of AD group to build a SQL insert
foreach($user in $ADGroupMembers.member)
{
    # If the cannonical user name (member property) contains a number (payroll) then capture it and build a SQL insert
    if ($user -match '\d+')
    {
        # Get the numerical match
        $payroll = $Matches[0]
        # Get the users properties from Active Directory
        $ADUser=Get-ADUser -Filter {SamAccountName -like $payroll} -Properties Manager,PostalCode,SamAccountName,GivenName, displayName, objectGUID, Title, surname, OfficePhone, Description,`
              Department, EmailAddress, Enabled, StreetAddress, extensionAttribute7, Office, City, State, POBox, MobilePhone, pager, fax, HomePhone, personalTitle, whenCreated, whenChanged
        #Amend the date formats
        $created=Get-date($ADuser.whenCreated) -Format s #yyyy'-'MM'-'dd' 'HH':'mm':'ss
        $changed=Get-date($ADuser.whenChanged) -Format s
        # If the property has a value and it contains an apostrophe, Replace aposrrophies with double apostrophies where name fiels have content
        if ($ADUser.Manager -AND $ADUser.Manager.Contains("'")) {$ADUser.Manager = $ADuser.Manager.Replace("'","''")}
        if ($ADUser.displayName -AND $ADUser.displayName.Contains("'")) {$ADUser.displayName = $ADUser.displayName.Replace("'","''")}
        if ($ADUser.surname -AND $ADUser.surname.Contains("'")) {$ADUser.surname = $ADUser.surname.Replace("'","''")}
        if ($ADUser.EmailAddress -AND $ADUser.EmailAddress.Contains("'")) {$ADUser.EmailAddress = $ADUser.EmailAddress.Replace("'","''")}
        # build SQL insert statement for user
        $SQL="INSERT INTO <table> VALUES ('" + $ADuser.Manager + "', '" + $created  + "', '" + $ADUser.PostalCode + "', '" + $ADUser.SamAccountName + "', '" `
            + $ADUser.GivenName + "', '" + $changed + "', '" + $ADUser.displayName + "', '" + $ADUser.objectGUID + "', '" + $payroll + "', '" + $ADUser.Title `
            + "', '" + $ADUser.surname + "', '" + $ADUser.OfficePhone + "', '" + $ADUser.Description + "', '" + $ADUser.Department + "', '" + $ADUser.EmailAddress `
            + "', '" + [int](!$ADUser.Enabled) + "', '" + $ADUser.StreetAddress + "', '" + $ADUser.Description + "', '" + $ADUser.extensionAttribute7 + "', '" + $ADUser.Office `
            + "', '" + $ADUser.City + "', '" + $ADUser.State + "', '" + $ADUser.POBox + "', '" + $ADUser.MobilePhone + "', '" + $ADUser.pager  + "', '" + $ADUser.fax `
            + "', '" + $ADUser.HomePhone + "', '" + $ADUser.personalTitle + "');"
        # Add SQL user insert statement to a list 
        $SQLCmd  += $SQL 
    }
} $SQLCmd | clip.exe


<#############################
## 2015-01-15, 11:43 - 
## Find files or AD Groups containing specific text
#############################>

ls $sourceBackupRootFolder | where {$_.Name -like '<Name>*'}
(Get-ADGroup -Filter 'Name -like "*Pedestrian*"' -Properties members).members

<#############################
## 2015-01-08, 12:03 - 
## Find SQL Stored procedures containing specific text
#############################>

SELECT ROUTINE_NAME, ROUTINE_DEFINITION 
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_DEFINITION LIKE '%s<database>.<table>%' 
AND ROUTINE_TYPE='PROCEDURE'


<#############################
## 2015-01-06, 10:03 - 
## Check schema owners for all SQL DB's
#############################>

$destServer = '<serverName>'
$destSQLInstance = "$destServer\<instanceName>"
$destSQLPSPath = "SQLSERVER:\SQL\$destSQLInstance\Databases"

Import-Module sqlps -Verbose
    Set-Location $destSQLPSPath 
    $dbnames = Get-ChildItem $destSQLPSPath 
   $a =  foreach ($db in $dbnames)
    {
        $dbstr = $db.Name.ToString()
        Write-Output "****************`n**$dbstr`n****************"
        Invoke-Sqlcmd -SuppressProviderContextWarning -Query "USE $dbstr;
          SELECT s.name, u.name AS owner
           FROM sys.schemas s, sys.database_principals u
           WHERE s.principal_id = u.principal_id;"
    } 
    $a | Out-File C:\Temp\SQL_Schema_Owner.txt

	
<#############################
## 2014-12-18, 10:03 - 
## Get collation, owner, backup type etc all SQL User DB's
#############################>
	
Import-Module sqlps -Verbose
$destSQLPSPath = "SQLSERVER:\SQL\<serverName>\<instanceName>\Databases"
Set-Location $destSQLPSPath  
Get-ChildItem 

	**IN SQL** (Probably easier and more sensible to run in SQL as opposed to powershell, as there is no messing with object)
	SELECT DISTINCT name, recovery_model_desc,compatibility_level,collation_name, suser_sname( owner_sid ) AS owner
	FROM [sys].[databases]
	 WHERE database_id > 4 --Exclude System DBs
	
	
<#############################
## 2014-12-15, 13:57 - 
## Save a read only document
#############################>

Set-ItemProperty .\DC99.RunAllChecks.ps1 -name IsReadOnly -value $false
<Save> 
Set-ItemProperty .\DC99.RunAllChecks.ps1 -name IsReadOnly -value $true

<#############################
## 2014-12-10, 11:45 - 
## Rename all files in folder with customisable incremental number
#############################>	

	Get-ChildItem *.jpg | ForEach-Object  -begin { $count=1 }  -process { rename-item $_ -NewName "image$count.jpg"; $count++ }
	## $dbname = $fname.Substring(0,$fname.IndexOf("_201")) --Get 1st x characters part of filename

<#############################
## 2014-12-03, 16:45 - 
## 1. Enable SQL PS-Snapin on LOKI, 2. Add powershell ISE, 3. Upgrade to PS v4??
#############################>	
  1.	{As Admin}  Set-ExecutionPolicy RemoteSigned
	    			Import-Module sqlps -DisableNameChecking

  2.	{As Admin} 	 Import-Module ServerManager 
					 Add-WindowsFeature PowerShell-ISE

  3. Install WMF v.4  (Windows6.1-KB2819745-x64-MultiPkg.msu)					 
<#############################
## 2014-11-28, 15:45 - 
## Failed attempt to get specific files types modified in last day
#############################>	

	ls -Path C:\ -Recurse -Exclude {'C:\Windows\*', 'C:\Program Files\*'} | 
	Where-Object {$_.LastWriteTime -gt (Get-Date).AddDays(-1) -and $_.Extension -eq ".docx" }

<#############################
## 2014-11-26, 11:15 - 
## Edit powershell scripts on central share (\\<serverName>\PowerShell_Scripts)
#############################>	
	Set-ItemProperty .\Create-SQLInsert_NewUser-MainStaffDir.ps1 -Name IsReadOnly -Value $false
	psEdit .\Create-SQLInsert_NewUser-MainStaffDir.ps1
	Set-ItemProperty .\Create-SQLInsert_NewUser-MainStaffDir.ps1 -Name IsReadOnly -Value $true

<#############################
## 2014-11-19, 12:05 - 
## Test odbc DSN(data source name) -- Only works for Windows Connections
#############################>	
	$conn = new-object system.data.odbc.odbcconnection
	$conn.connectionstring = "DSN=<serverName>"
	$conn.open()
	$conn
	$conn.Close()

<#############################
## 2014-09-26, 14:35 - 
## List all files & folders (Directory listing) from share to Excel
#############################>

	PS> net use S: \\<serverName>\<path>

	PS C:\Scripts> Get-ChildItem S:\ -Recurse | Select-Object DirectoryName, BaseName, LastWriteTime, Length | Export-Csv -Path C:\Temp\ServiceOpsFileListing.csv -Encoding ASCII -NoTypeInformation 


<#############################
## 2014-11-11, 09:54 - 
## Create csv from space separated fie  
#############################>

	cat C:\Users\<user>\Documents\MartyS\german.data.txt | 
		foreach{$_ -replace " ", ","} | sc german.csv

<#############################
## 2014-11-07, 10:24 - 
## Check if Runnaing with elevated privledges (Administrator)
#############################>

	$winid=[System.Security.Principal.WindowsIdentity]::GetCurrent()
	$winprin=new-object System.Security.Principal.WindowsPrincipal($winid)
	$adm=[System.Security.Principal.WindowsBuiltInRole]::Administrator
	$isadmin=$winprin.IsInRole($adm)
	if ($isadmin) { "You're in an elevated session." }
	else { "You're NOT in an elevated session." }


<#############################
## 2014-08-15, 10:24 - 
## Get user that created a folder 
#############################>

	Get-Acl '\\<serverName>\d$\Backup'

<#############################
## 2014-08-15, 10:24 - 
## 1. Copy multiple file fypes from one folder to another
## 2. Send command line to clipboard 
#############################>

cp 'C:\<path>\*' -Include *.ps1, *.txt \\<serverName>\Scripts -WhatIf

write ' blah ' | clip.exe

<#############################
## 2014-08-06, 10:24 - 
## Function added to startup profile, of all users in all hosts = $PSHOME/Profile.ps1
## (this would be better in a tools module)
#############################>

<#
.SYNOPSIS
Get a list of users Active Directory Group membership

.DESCRIPTION
Input a users payroll number to get back a list of AD Geoup that the user is a member of.

.PARAMETER userName
Gets passed as identity parameter

.EXAMPLE
Get-ADMembership <user_Payroll> | Select-String -pattern "2013"

.EXAMPLE
PowerShell will number them for you when it displays your help text to a user.
#>

function Get-ADMembership{
        [CmdletBinding()]                
    param(
        [Parameter(Mandatory=$true)]
        [string]$userName
                 
    )
    BEGIN {}

    PROCESS{
         foreach ($user in $userName) {
             (GET-ADUSER -Identity $user -Properties MemberOf | Select-Object MemberOf).MemberOf
         }
    }
    
    END {}

	
<#############################
## 2014-07-30, 10:20 - 
## Compre the content of files in 2 web folders, listing any files different
#############################>


$FolderA = '\\<serverName>\<path>' 
$FolderB = '\\<serverName>\<path>' 

$FileListA = Get-ChildItem $FolderA -File -Recurse

ForEach ($File in $FileListA)
{
    If (Compare-Object (Get-Content $File.FullName) (Get-Content $File.FullName.Replace($FolderA,$FolderB)))
    {
            $File.FullName
            $File.FullName.Replace($folderA, $folderB)
    }
}


<#############################
## 2014-07-24, 10:50 - 
## Extract user details from Active Directory and generate a SQL Statement for insertion into applications local Staff Directory (E.g. BB)
## Statement is pasted into clipboard
## Saved to 'C:\Scripts\Copy-SQLInsert_NewUSer.ps1'
#############################>

$payroll= Read-Host 'Enter New Users <domain> user name, e.g. dfp-user1 '    #Get users payroll/ <domain> username from screen
$StaffDir_payroll=$payroll -replace "-","" #Remove dashes from <domain> user name
$ADUser=Get-ADUser -Filter {SamAccountName -like $payroll} -Properties * 
$created=Get-date($ADuser.whenCreated) -Format s #yyyy'-'MM'-'dd' 'HH':'mm':'ss --Format Date To Be Compatable With SQL
$changed=Get-date($ADuser.whenChanged) -Format s
$SQL="INSERT INTO <table> VALUES ('" `
	+ $ADuser.Manager + "', '" + $created  + "', '" + $ADUser.PostalCode + "', '" + $ADUser.SamAccountName + "', '" + $ADUser.GivenName `
    + "', '" + $changed + "', '" + $ADUser.displayName + "', '" + $ADUser.objectGUID + "', '" + $StaffDir_payroll + "', '" + $ADUser.Title `
    + "', '" + $ADUser.surname + "', '" + $ADUser.OfficePhone + "', '" + $ADUser.Description + "', '" + $ADUser.Department + "', '" + $ADUser.EmailAddress `
    + "', '" + $ADUser.Enabled + "', '" + $ADUser.StreetAddress + "', '" + $ADUser.Description + "', '" + $ADUser.extensionAttribute7 + "', '" + $ADUser.Office `
    + "', '" + $ADUser.City + "', '" + $ADUser.State + "', '" + $ADUser.POBox + "', '" + $ADUser.MobilePhone + "', '" + $ADUser.pager  + "', '" + $ADUser.fax `
    + "', '" + $ADUser.HomePhone + "', '" + $ADUser.personalTitle + "', '" + $env:username + "', " + "getdate()" + ", '" + $env:username + "', " + "getdate()" + ")"
$SQL | clip.exe                 #paste SQL insert statement to clipboard
Write-host "`n SQL insert statement has been pasted to clipboard. `n `n Don't forget to add '$payroll' to '<serverName>\<local_group>'"

<#############################
## 2014-07-16, 11:20 - 
## Server uptime
#############################>
	
Invoke-Command -scriptblock {New-TimeSpan -Start (Get-EventLog -LogName System -Message "The Event log service was started." -Newest 1).TimeGenerated} -ComputerName R2ESSD,SQL_CORE_1,IIS_CORE_1 | Select-Object PSComputerName,Days,Hours,Minutes

<#############################
## 2014-07-08, 09:30 - 
## ISE Transcription
#############################>

	Downloaded module from http://www.powertheshell.com/transcript/
	Extracted to C:\Windows\system32\WindowsPowerShell\v1.0\Modules\Transcript*
	Import-module
	Updated profile to transcribe to C:\Scripts\DailyChecks\Logs\ISE_Transcript\
	
	* find default module paths - $env:PSModulePath -split ';'
	
	2014-07-08, 10:00 - Eventually got log module working but it was causing issues with the display of listing folders.

<#############################
## 2014-07-07, 11:30 - 
## Remove an alias
#############################>

	clear-item -path alias:sman

<#############################
## 2014-06-09, 13:45 - 
## Unable to update-help for powershell becaus of proxy credentials.
#############################>

	$wc = New-Object System.Net.WebClient 
	$wc.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials 
	$wc.DownloadString('http://microsoft.com')

Ref: http://blog.stangroome.com/2013/08/02/powershell-update-help-and-an-authenticating-proxy/

Connect-WithCustomers | Get-Feedback | Enable-Change
	
<#############################
## 2014-05-22, 12:45 - 
## Migrate 2005 app from dev to test
#############################>
$devSource='\\<serverName>\<path>\*' 
$testDest='\\<serverName>\<path>\*' 

rm $testDest -Exclude web.config -Recurse -WhatIf
cp -Path $devSource -Destination $testDest -Exclude web.config -Recurse -WhatIf

<#############################
## 2014-05-20, 17:00 - 
## Profile update on AS-APP2010, encrypt web.config
#############################>

Set-Location C:\Windows\Microsoft.NET\Framework\v4.0.30319

function encrypt {
	$appFolder=$args[0]	
    if ((Get-Location).Path -ne 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319'){
        Set-Location 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319'
    }
    if (Test-Path -Path "$appFolder\web.config"){
        .\aspnet_regiis.exe -pef "appSettings" "$appFolder"  -prov "DataProtectionConfigurationProvider"; 
		notepad.exe $appFolder\web.config
    }
    else {
        write-host "`t`n Incorrect Web Config Folder: $appFolder `n" -ForegroundColor Red
    }
}
function decrypt {
	$appFolder=$args[0]	
    if ((Get-Location).Path -ne 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319'){
        Set-Location 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319'
    }
    if (Test-Path -Path "$appFolder\web.config"){
        .\aspnet_regiis.exe -pdf "appSettings" "$appFolder"; 
	notepad.exe $appFolder\web.config   
    }
    else 
    {
        write-host "`t`n Incorrect Web Config Folder: $appFolder `n" -ForegroundColor Red
    }
}

<#############################
## 2014-05-14, 12:00 - 
## Get MAC & IP Addresses
#############################>

$comp='<BadgeNo>'
$obj=Get-WmiObject "Win32_NetworkAdapterConfiguration" -ComputerName $comp
$obj.MacAddress
$obj.IPAddress

<#############################
## 2014-05-14, 11:40 - 
## Get last logged on (or current) user 
#############################>

Last Loggged on: 
	$comp='<<BadgeNo>>'
	Get-ADComputer $comp -Properties ManagedBy | Select-Object ManagedBy
	
Current Loggged on User:
	$comp='<BadgeNo>'
	Get-WmiObject -Class win32_computersystem -ComputerName $comp | select username

<#############################
## 2014-05-08, 15:40 - 
## Get .net (dot net) version
#############################>

Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
Get-ItemProperty -name Version -EA 0 |
Where { $_.PSChildName -match '^(?!S)\p{L}'} |
Select PSChildName, Version

<#############################
## 2014-05-07, 15:40 - 
## Server 2008R2 copy installed features from one server to another
#############################>
Import-Module Servermanager
Get-WindowsFeature | ? {$_.Installed -AND $_.SubFeatures.Count -eq 0 } | Export-Clixml \\tsclient\C\Temp\TITAN_WinFeatures_SubsOnly.xml
	##Copy xml file to destination server
Import-Module Servermanager
PS C:\> Import-Clixml \\tsclient\C\Temp\TITAN_WinFeatures_SubsOnly.xml | Add-WindowsFeature
(Ref: http://blog.basefarm.com/blog/configuring-windows-server-2008-r2-features/)

<#############################
## 2014-04-11, 10:12 - 
## Check multiple servers for specific file & list the files
#############################>

$sl = get-content('C:\Scripts\MBSA\l1.txt')
$file = ''
$files = ''
foreach ($s in $sl)
{
    $file = Get-ChildItem "\\$s\C$\Documents and Settings\<adminuser>\SecurityScans\*.mbsa"
    $files = $files + "`n" + $file
}
$files


<#############################
## 2014-04-09, 11:40 - 
## Trim dates from a list of files in a folder
#############################>

$fullnames = ls "\\isuclarofp3\isss\IT Security - Do not delete\MBSA\July 2013" -Name
$shortnames = ''
foreach ($fullname in $fullnames){
        $len = $fullname.length
        $newname = $fullname.substring(7,$len -22)
        $shortnames = $shortnames + $newname + "`n"
    }
    
	
<#############################
## 2014-04-03, 13:05 - 
## Search for AD-Groups with name like
#############################>

$ADGroups = Get-ADGroup -Filter 'Name -like "<AD_Group_Name_Part>*"' | Select-Object name


<#############################
## 2014-03-31, 13:05 - 
## remove back files older than 28 day, pausing for keypress 
#############################>

$TargetFolder = "D:\Backup2005"
 foreach ($File in Get-ChildItem $TargetFolder -recurse -Filter *.bak)
 { 
    if ($File.CreationTime -le ($(Get-Date).AddDays(-28))) 
    {
        Remove-Item $File.FullName -force -WhatIf
    }
}
Write-Host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
<#############################
## 2014-03-28, 16:20 - 
## Serach Active Directory by Surname, First Name for payroll number
#############################>

$InputName =  $args[0]      #   , 'DislayName -like "Brown, B*"'
$OUs = "OU1", "OU2"
$Users = @()

$NamePart = $InputName -split ", "
$Filter = "sn -like ""$($NamePart[0])"" -and givenName -like ""*$($NamePart[1])*"" "

foreach($OU in $OUs){
    $Users += Get-ADUser -Filter $Filter -SearchBase $OU -Properties DisplayName, SamAccountName, nicsssc-User-LastComputer 
  }

$Users | Sort-Object DisplayName | FT  nicsssc-User-LastComputer, SamAccountName, DisplayName -AutoSize

<#############################
## 2014-03-28, 15:00 - 
## Open web browser and display organisational chart for the payroll number passed as a parameter
## Note: this was added to profile
#############################>

function org 
{
    $OrgBrowserBase='http://mysite/OrganizationView.aspx?ProfileType=User&accountname=<domain>\'
    $Payroll=$args[0]    #(Read-Host "`n Enter Payroll No: ")
    $Url = $OrgBrowserBase + $Payroll
    $IE=new-object -ComObject InternetExplorer.Application
     $IE.navigate2("$Url")
     # $IE.visible=$true
     # Write-Host `n
}  


<#############################
## 2014-03-18, 16:20 - 
## Top 10 largest files by size
#############################>

ls "\\<serverName>\d$\<path>" | Sort-Object Length -Desc | Select-Object Name, @{Name="MegaBytes";Expression={$_.Length / 1MB}} -First 10

<#############################
## 2014-03-13, 16:20 - 
## Quert remote event log
#############################>
Get-EventLog -LogName System -ComputerName <serverName> -Newest 50 -Message *lmsprintqueue*

<#############################
## 2014-03-11, 15:25 - 
## Check which account SQL instance is running under
#############################>
$serverlistfile = "C:\Scripts\DailyChecks\ALL_SQL_Servers.txt"
$sqlservers = (Get-Content $serverlistfile) -notmatch '#';

foreach($sqlserver in $sqlservers)
{
get-wmiobject win32_service -comp $sqlserver -filter "Name Like 'MSSQL%'" | Where-Object {$_.State -eq "Running"} | Select-Object SystemName,name,startname 
}

<#############################
## 2014-03-04, 16:15 - 
## Check software installed on remote PC
#############################>
Start > "WMIC" > RC Run As Admin
wmic:root\cli>/node:<BadgeNo>
wmic:root\cli>product get name,version

or

Get-WmiObject win32_product -ComputerName <BadgeNo> | Select Name, Version

<#############################
## 2014-02-20, 15:15 - 
## Check if 3GB switch enabled
#############################>

<BadgeNo>\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SystemStartOptions :
 WIN7, 3GB ON =  NOEXECUTE=OPTIN  3GB  USERVA=3072
 WIN7, 3GB OFF =  NOEXECUTE=OPTIN
 XP, 3GB OFF = NOEXECUTE=OPTIN  FASTDETECT

<#############################
## 2013-11-19, 09:30 - 
## Get currently logged in user on remote PC
#############################>
Get-WmiObject -Class win32_computersystem -ComputerName <BadgeNo> | select username

<#############################
## 2013-11-01, 15:30 - 
## Get user details from multiple OU's
#############################>
$OUs = 'OU1', 'OU2'
$OUs | ForEach {Get-ADUser -Filter * -SearchBase $_} | Select-Object Name, SamAccountName | Export-Csv -Path C:\<path> 


<#############################
## 2013-10-10, 16:20 - 
## Count files by type
#############################>
Get-ChildItem $path -File -Recurse | Group-Object Extension

$path = C:\Scripts\Copy of TestDeleteFiles.BAK
Get-ChildItem $path -File -Recurse | Group-Object Extension  

<#############################
## 2013-10-10, 13:50 - 
## Create application shortcut
#############################>
$AppPath = "Path to Application"
$SCname = Application Shortcut name
'invoke-item $AppPath' >> $SCname.ps1

'invoke-item "C:\Program Files\Red Gate\SQL Data Compare 10\RedGate.SQLDataCompare.UI.exe"' >> SQL_Shortcut_Test.ps1


<#############################
## 2013-10-03, 16:30 - 
## TCP Port test? EXTERNAL & INTERNAL  
#############################>

0. SINGLE LINE TEST
	$socket = new-object System.Net.Sockets.TcpClient("<serverName>", "<port>")  
	$socket = new-object System.Net.Sockets.TcpClient("<IP_Address>", "<port>")
	
1. FROM OUTSIDE THE SERVER USING POWERSHELL EQUIVILANT OF TELNET	
	$computer = '<IP_Address>' #IP_Address
	 $port = '<port>' #<port>
	 $Socket = New-Object Net.Sockets.TcpClient
	 $Socket.Connect($Computer, $Port)
	if ($Socket.Connected) {       
				"${Computer}: Port $Port is open"
				$Socket.Close() }

	 http://www.powershelladmin.com/wiki/Check_for_open_TCP_ports_using_PowerShell
 
 2. FROM ON THE SERVER
	netstat -an
 
<#############################
## 2013-10-02, 13:15 - 
## Run an msi without Privledge Elevator
#############################>
Running the .msi from an elevated (Run As Administrator) PowerShell prompt anppeard to install an msi that wouldnt work for me.

<#############################
## 2013-09-26, 10:15 - 
## Add a timestamp to a results log
#############################>
$Results = "whatever"
$Outfile = "C:\Scripts\DailyChecks\Logs\<LogName>.txt"
$Timestamp = Get-Date -Format "yyyy-MM-ddThh:mm" 
$Log = $Timestamp + ": `n`t " + $Results	##Newline + tab
$Log | Out-File -filepath $Outfile -append

<#############################
## 2013-09-20, 09:45 - 
## Restarting service on remote PC (<badge>, KeyLines, HASP License Manager (hasplms)
## NOTE:-  To run powershell commands on remote XP/2003 machines requires Windows
##			Management Framework = WinRM 2.0 + Powershell 2.0 to be installed
##			(Download  KB968930), Link: http://support.microsoft.com/kb/968929
##			Then enable/configured remoting/with "winRM quickconfig"

## NOTE2: - Server version WindowsServer2003-KB968930-x86-ENG (1).exe, downloaded on 2014-04-09, note there is no updated to PS v3 for 2003.
##		Also had to enable dependancy HTTP SSL & 
##  	then ran Enable-PSRemoting as it guides through steps as opposed  "winRM quickconfig" and the service changes
##		winrm s winrm/config/client '@{TrustedHosts="<serverName>"}' 
## In the ender needed to create session to FQDN <serverName>.<sub-domain>.<domain>

#################################################################
## 2014-04-10 - Could not connect to <serverName> via remote session. 
##	System event log showed that WinRM service turned off at 00:21
##  App event log showed group policy sucessfully applied @ 00:23
##		Doubt there is too much point pushing this with older servers? That being said this is now enable by default on 2012!!

###############################################################
## 2014-05-16 - TITAN Remoting
##	get-service winrm --already running
## PS C:\Windows\system32> Enable-PSRemoting -force
##		WinRM already is set up to receive requests on this machine.
## 		Set-WSManQuickConfig : Access is denied.

## C:\Windows\system32> netstat -a --check server listening ports
##	Proto  Local Address          Foreign Address
##	TCP    0.0.0.0:80             <serverName>:0
##	TCP    0.0.0.0:135            <serverName>:0
## Get payroll & badge number
#############################>

$names = Get-Content C:\Scripts\ISB_StaffNames.txt
foreach ($name in $names){
Get-Aduser -Filter {DisplayName -eq $name} -Properties DisplayName, SamAccountName, nicsssc-User-LastComputer | 
    FT  nicsssc-User-LastComputer, SamAccountName, DisplayName -A 
}



<#############################
## 2013-07-19, 14:35 - 
## Total File Size
#############################>

PS C:\Scripts> Get-ChildItem -Path \\<serverName>\Backup2005\ -Recurse -File -Filter *.trn | Measure-Object -Sum Length

	Count    : 30308
	Sum      : 4300902400
	Property : Length

<#############################
## 2013-07-07, 16:35 - 
## Map user drive to admin account
#############################>

NET USE Y: "\\<serverName>\<path>" /SAVECRED

## Note: to connect to edrms share, drive must be mapped/connected to as standard user and most likely need remapped each time user p/w changes.

<#############################
## 2013-07-07, 12:40 - 
## Obtain user SID for reg edits
#############################>

Get-ADUser (Read-Host "`n Enter Payroll No: ") -Properties * | FT Name,objectSid -A

<#
Sent the above to DK as an easier way to obtain SID's, but unfortunately Get-ADUser not available.
Checked my "notepad $PROFILE" and found nothing.
Looks like need to install remote server admin tools (RSAT), then turn on Active Directory Module 
for Windows PowerShell within Windows Features. 
Finally import-module activedirectory
#>

<#############################
## 2013-07-02, 10:01 - 
## Lock remote SCCM workstation
#############################>

rundll32.exe user32.dll,LockWorkStation


<#############################
## 2013-07-02, 10:01 - 
## Search AD Users by surname, returning payroll and full name
#############################>

Get-Aduser -Filter {Name -like "*todd*"} -Properties DisplayName, SamAccountName | FT DisplayName, SamAccountName -A


<#############################
## 2013-06-21, 12:44 - 
## Output users AD details to csv, Blue Badge users
#############################>

$Users = Get-Content C:\Temp\DFPUsers.txt
$ADUserDetails = 
foreach ($User in $Users)
{
    Get-ADUser $User -Properties * 
}

$ADUserDetails | Select-Object Manager, SamAccountName, GivenName, DisplayName, ObjectGUID, nicsssc-User-EquivalentGrade, Surname, mail  | Export-Csv -Path C:\Temp\DFP.csv 



<#############################
## 2013-06-10, 15:10 - 
## Download a file from website
#############################>

	Invoke-WebRequest -URI http://... -OutFile C:\temp\ubuntu1310.img.gz


<#############################
## 2013-06-06, 17:10 - 
## Report which listener is down
#############################>

	$ListenerProcessCmdLines = gwmi win32_process -ComputerName <serverName> | Where-Object {$_.Name -like "gri*"} | Select-Object CommandLine
    ## If all listeners aint up, print out a process command line which shows region process relates to.
	
    $ListenerRegions = @('north','south','east','west')
    foreach ($region in $ListenerRegions)
        {
            $RegionalListenerCount = ($ListenerProcessCmdLines | Select-String -Pattern $region).Matches.Count
            if ($RegionalListenerCount -ne 3)
            {
                Write-Host "`t LISTENER DOWN IN $region `n" -ForegroundColor Red
            }
        }


<#############################
## 2013-06-03, 12:30 - 
## Powershell as a scheduled task to delete files on <serverName>
#############################>
Schedule task Actions to start a program:
	PROGRAM: 	C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe 
	ARGUEMENTS:	-command "& "C:\Scripts\DeleteOldestFiles.ps1""
					
			$BackupLocation = "D:\restore"
			$NumFilesKeep = 3

			$Files = Get-ChildItem $BackupLocation 
				
				if($Files.Count -gt $NumFilesKeep)
				{
					Get-ChildItem -Path $BackupLocation | Sort-Object LastWriteTime -Descending | 
						Select-Object -Last ($Files.Count - $NumFilesKeep) | Remove-Item -Force 
				}

<#############################
## 2013-06-03, 10:30 - 
## Alternative RMCS Listener Check
#############################>

gwmi win32_process -ComputerName <serverName> | Where-Object {$_.Name -like "gri*"} | Sort CreationDate | Format-Table CommandLine

<#############################
## 2013-03-13, 10:30 - 
## Find last 20 files modified within sub-folders
#############################>

Get-ChildItem -file -recurse | Sort-Object LastWriteTime -Descending | Select-Object -First 20


<#############################
## 2013-02-27, 10:30 - 
## Check if a local / domain account is locked out
#############################>

$Server = "<serverName>"
$Account = "<user>"

(Get-WmiObject -Class Win32_UserAccount -ComputerName $Server -Filter "FullName='$Account'").Lockout

Get-ADUser <user_Payroll> - Properties LockedOut | Select-Object Name, Enabled | FL


<#############################
## 2013-02-27, 09:45 - 
## Log all input and output from console to text file with timestamp
#############################>
Start-Transcript -path  C:\Scripts\DailyChecks\Logs\PS_Transcript\$(Get-Date -format 'yyMMddThhmm').txt -NoClobber


<#############################
## 2013-02-21, 14:35 - 
## Get AD Groups with names like 
#############################>
Get-ADGroup -Filter {name -like "<AD_Group_Name*"}


<#############################
## 2013-02-07, 13:35 - 
## Delete all files except 2 most recent in backup subfolders 
#############################>
$LastWriteTime = Get-ChildItem -file | Sort-Object LastWriteTime -Descending | Select-Object -ExpandProperty LastWriteTime -First 1
-- Originally started on date, then decided filecount was safer incase backup hadnt run

$BackupLocation = "\\<badge>\C$\Scripts\TestDeleteFiles"
$NumFilesKeep = 2

ForEach ($SubFolder in Get-ChildItem $BackupLocation -Directory) 
{
	$Files = Get-ChildItem $BackupLocation'\'$SubFolder -File
    
	if($Files.Count -gt $NumFilesKeep)
	{
		Get-ChildItem -Path $BackupLocation'\'$SubFolder -File | Sort-Object LastWriteTime -Descending | 
			Select-Object -Last ($Files.Count - $NumFilesKeep) | Remove-Item -Force
	}
}

<#############################
## 2013-02-04, 14:30 - 
## Check EXOR listeners running
#############################>

cd '\\<serverName>\<path>'
Get-Process -Name gri* -ComputerName <serverName> | Measure-Object
cd C:\Scripts


#* Count = 15
#* 3 listeners for each of 4 area's & 1 for test


<#############################
## 2013-02-04, 12:30 - 
## Get service tag of server
#############################>

wmic bios get serialnumber


<#############################
## 2013-01-25, 12:30 - 
## Set up a one off scheduled defrag 
#############################>
cmd.exe									# doing this from cmd prompt
defrag.exe E: -f >> C:\WTO_Defrag.bat	# create a batch file containing the defrag command
AT 08:00AM C:\WTO_Defrag.bat			# Schedule the batch file to run tomorrow at 8AM

<#############################
## 2013-01-25, 11:30 - 
## Get list of filenames from a specified folder and provide 1st 3 characters
#############################>

Get-ChildItem -Path C:\Users\<user>\Documents\@Email\@Archive -Name |  # get the file names
%{$_.substring(0,3)} |          # foreach "filename" take / get the 1st 3 characters
Sort-Object | Get-Unique        # standard powershell for obtaining unique strings


<#############################
## 2013-01-23, 10:30 - 
## Get file content(Server List), but ignore comments (old servers)
#############################>

$servers = (Get-Content $serverlistfile) -notmatch '^#'

<#############################
## 2013-01-19, 11:50 - 
## Count number of files in folder
#############################>

(Get-ChildItem  -recurse | where-object {-not ($_.PSIsContainer)}).Count


<#############################
## 2013-01-16, 16:30 - 
## Search/find files in sub folders that contain specific text
#############################>

## Files containing a specific string
 Get-ChildItem -Path 'Y:\07 DB Migrations\Use Of Consultants\*.sql' -Recurse | Select-String -Pattern PercentageVariance

## Files with string in name 
 Get-ChildItem -Filter *Pointer* -Recurse 
<#############################
## 2013-01-10, 14:40 - 
## Open website from command line
## Add program shortcut as alias 
#############################>

1. Start-Process "<url>"
2. function npp 
{ 
    Invoke-Item 'C:\Program Files\Notepad++\notepad++.exe'
}
**Added to user profile: 
"C:\Users\<adminuser>\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"


<#############################
## 2012-12-05, 11:40 - 
## Find local PC name / service tag
#############################>

$env:COMPUTERNAME
ls env:  --list all local variables
.$PROFILE -- reload profile
function prompt {"PS \\$env:COMPUTERNAME\$(Get-Location)>"} -- Display Computer  Name in prompt
$env:Path = $env:Path + ";C:\Program Files\Notepad++"  --Add a new path to look for program files

<#############################
## 2012-12-05, 11:40 - 
## Find a users AD groups containing specific text
#############################>

(GET-ADUSER -Identity $EmpID -Properties MemberOf | Select-Object MemberOf).MemberOf | Select-String -pattern $String


<#############################
## 2012-12-04, 12:10 - 
## Powershell as admin (<adminuser>) aliases
#############################>

1. New-Alias sql 'C:\Program Files\Microsoft SQL Server\100\Tools\Binn\VSShell\Common7\IDE\Ssms.exe'
2. new-alias mgt compmgmt
3. New-Alias whois Get-ADUser


<#############################
## 2012-12-03, 13:20 - 
## List members of an AD Security Group or a local group membership 
#############################>

(Get-ADGroup '<Group>' -Properties Member).member

$grp="<AD_Group_Name"
(Get-ADGroup $grp -Properties Member).member

    net localgroup <group_name> > BlueBadgeNIDirectUsers.txt


<#############################
## 2012-11-29, 12:10 - 
## Run program as admin
#############################>

C:\Windows\System32\runas.exe /user:<domain>\<adminuser> "--program--"


<#############################
## 2012-11-29, 09:30 - 
## Replace carriage returns with commas
#############################>
 
 $list -replace "\n", ","
 
 
<#############################
## 2012-11-26, 15:05 - 
## Check a list of PC's for currently logged in user
#############################>

 Get-WmiObject Win32_computersystem -ComputerName(Get-Content -path C:\Scripts\Victor\PCList_Users.txt) | FL Name,Username

 Get-WmiObject Win32_computersystem -ComputerName <Name> | FL Name,Username

 
<#############################
## 2012-11-26, 14:30 - 
## Reset idle / disconnected remote desktop / terminal rervices connections
#############################>

query session /server:servername

reset session [ID] /server:servername


<#############################
## 2012-11-26, 15:30 - 
## IE As Admin
#############################>

C:\Windows\System32\runas.exe /savecred  /user:<domain>\<user> "C:\Program Files\Internet Explorer\IEXPLORE.EXE"


<#############################
## 2012-11-26, 15:10 - 
## Run computer management
#############################>

Powershell > Shift + RC > Run As diff user > <user>
compmgmt.msc
devmgmt.msc (Device Manager)


<#############################
## 2012-11-26, 12:40 - 
## 1. Get all files modified on 26-11-2012
## 2. Get all files modified in last 5 days
#############################>

	ls | Where-Object {$_.LastWriteTime.month -eq 11 -AND $_.LastWriteTime.year -eq 2012 -AND $_.LastWriteTime.day -eq 26}

	ls -Path C:\ -Recurse | Where-Object {$_.LastWriteTime -gt (Get-Date).AddDays(-5)}

<#############################
## 2012-11-14, 12:40 - 
## Compare my AD Groups with Lee's
#############################>

PS C:\Scripts> Compare-Object -ReferenceObject ((GET-ADUSER -Identity <user_Payroll> -Properties MemberOf | Select-Object MemberOf).MemberOf) -DifferenceObject ((GET-ADUSER -Identity 1386354 -Properties MemberOf | Select-Object MemberOf).MemberOf)

Compare-Object -ReferenceObject ((GET-ADUSER -Identity <user_Payroll> -Properties MemberOf | 
Select-Object MemberOf).MemberOf) -DifferenceObject ((GET-ADUSER -Identity <user_Payroll> -Properties MemberOf | 
Select-Object MemberOf).MemberOf)



<#############################
## 2012-11-14, 17:00 - 
## Get last used PC from 
#############################>

Get-ADUser (Read-Host "`n Enter Payroll No: ") -Properties * | FL Name,nicsssc-User-LastComputer


<#############################
## 2012-11-05, 13:00 - 
## Ping a list of servers
#############################>

PS C:\Temp\DailyChecks> Test-Connection -ComputerName (Get-Content .\ISB_Servers.txt)


<#############################
## 2012-11-02, 15:35 - 
## Search AD properties for one's containing the word "phone", then add it to standard Get-user "whois" search
#############################>
PS C:\Scripts> whois <user_Payroll> -Properties *| Get-Member | select-string -pattern "phone"

	System.String HomePhone {get;set;}
	System.String MobilePhone {get;set;}
	System.String OfficePhone {get;set;}
	System.String telephoneNumber {get;set;}

PS C:\Scripts> whois <user_Payroll> -Properties * | FL Name,telephoneNumber 

	Name            : <name> <user_Payroll>
	telephoneNumber : 40168


<#############################
## 2012-10-26, 13:35 - 
## Output to a file the differences between 2 text files, later amended to one reference file and drfference object created on the fly.
#############################>

PS C:\Scripts\Victor> Compare-Object -ReferenceObject (Get-Content .\<user>_ADMemberOf.txt) -DifferenceObject (Get-Content .\<user2>_ADMemberOf.txt) >> ADDifference_Will-Mich2.txt

PS C:\Scripts> Compare-Object -ReferenceObject ((GET-ADUSER -Identity <userID> -Properties MemberOf | Select-Object MemberOf).MemberOf) -DifferenceObject ((GET-ADUSER -Identity roads-whitec -Properties MemberOf | Select-Object MemberOf).MemberOf) >> DK_ActiveDicectoryAdmin.txt


<############################
## 2012-10-26, 12:35 - 
## List AD_Groups user is member off
#############################>

PS C:\Scripts> (GET-ADUSER -Identity <payroll> -Properties MemberOf | Select-Object MemberOf).MemberOf >> C:\Scripts\Victor\<user>_ADMemberOf.txt


<############################
## 2012-10-16, 16:25 - 
## List local user accounts on specified computer and if they are disabled
#############################>

Get-WmiObject -Class Win32_UserAccount -ComputerName <serverName> -Filter "LocalAccount='$true'"|Select-Object Name,Disabled|Format-Table -AutoSize



