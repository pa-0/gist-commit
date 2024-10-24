########################################
#
# BeginSystemConfig.ps1
#   iex ((New-Object System.Net.WebClient).DownloadString('https://bit.ly/2R7znLX'));
#
# Author: roysubs@hotmail.com
# 
# 2019-11-25 Initial setup
# 2020-10-19 Latest Version
#
########################################
#
# To install this project:
#   iex ((New-Object System.Net.WebClient).DownloadString('https://bit.ly/2R7znLX'))
# The bit.ly url above points at:
#   https://gist.github.com/roysubs/61ef677591f22927afadc9ef2b657cd9/raw
# Can directly edit the project at:
#   https://gist.github.com/roysubs/61ef677591f22927afadc9ef2b657cd9/edit
# Quick download of BeginSystemConfig.ps1 + ProfileExtensions.ps1 + Custom-Tools.psm1
#   https://shorturl.at/cvxAC : https://gist.githubusercontent.com/roysubs/1a5eef75a70065f8f2979ccf2703f322/raw/4d02c6237732e39be069fec7aa14a367b6258f19/Get-ExtensionsAndCustomTools.ps1
#   iex ((New-Object System.Net.WebClient).DownloadString('shorturl.at/cvxAC'))




# Main script goals: must remain always compatible with PowerShell v2 (for Win 7 / Win 2012 etc).
# Note: For testing on a system with PS v3+, can mimic v2 by opening a console with: powershell.exe -version 2
# Should do no *changes* to system in this, except updating PS to latest version + Chocolatey/Boxstarter Package Manager
#
# Key sections:
# Create as function as required in two locations depending on whether the console needs to be elevated or not.
function Write-Header {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host 'Auto-Configure System' -ForegroundColor Green
    Write-Host 'Add profile extensions, update PowerShell, Chocolatey, Boxstarter, and Modules' -ForegroundColor Green
    Write-Host ""
    Write-Host '1. Add single line to $Profile to handle profile extensions and Set-ExecutionPolicy RemoteSigned' -ForegroundColor Yellow
    Write-Host '   This way the profile is minimally affected and changes can be rolled back simply by deleting' -Foreground Yellow
    Write-Host '   the single profile extensions handler line from $Profile (notepad $Profile and delete the line)' -ForegroundColor Yellow
    Write-Host '2. Apply latest PowerShell to system (also add .NET 4.0 / 4.5 required by various tools)' -ForegroundColor Yellow
    Write-Host '   Install or update to latest Chocolatey and Boxstarter.' -ForegroundColor Yellow
    Write-Host '3. Configure selected Modules to User Modules folder.' -ForegroundColor Yellow
    Write-Host '4. Configure selected useful scripts and tools (no installs). ' -ForegroundColor Yellow
    Write-Host '5. (ToDo): Additional tools, Boxstarter configuration etc.' -ForegroundColor Yellow    
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
}

####################
#
# To ready the project:
#   iwr 'https://bit.ly/2R7znLX' | select -expand content | more      # View BeginSystemConfig.ps1 on PS v3+
# Invoke-WebRequest (iwr) is not available on PowerShell v2. v2 compatible syntax is:
#   (New-Object System.Net.WebClient).DownloadString('https://bit.ly/2R7znLX')
#
# GitHub access uses TLS. Sometimes (not always) have to specify this:
#   [Net.ServicePointManager]::SecurityProtocol   # To view current settings
#   [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12  # Set type to TLS 1.2
#      # Note that the above Tls12 is incompatible with Windows 7 which only has SSL3 and TLS as options.
#   [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls    # Set type to TLS
#
# GitHub pages are cached at the endpoint so after uploading to GitHub, the new data will not be immediately
# available and can take from ~10s to 180s to update. Clearing the DNS Client Cache might help:
#   On PowerShell v2, use: [System.Net.ServicePointManager]::DnsRefreshTimeout = 0;
#   On newer versions of PowerShell, can use: Clear-DnsClientCached
#
# Note the caching issues above. Some people sugget using a -Headers switch with iwr to try and get
# around that, but it has now worked reliably for me:
# - i.e. add -Headers @{"Cache-Control"="no-cache"} to iwr.
#   iwr "https://gist.github.com/roysubs/61ef677591f22927afadc9ef2b657cd9/raw" -Headers @{"Cache-Control"="no-cache"} | select -Expand Content
# - Adding the iwr parameter "-DisableKeepAlive" is suggested as a fix to clear the caching, though I have not tested.
# - Preventing DNS caching seems to be a reliable fix so that iex / iwr are not using cached data. One of these should be run before iex / iwr
#   to ensure that the version that iex / iwr pull is the latest.
#     [System.Net.ServicePointManager]::DnsRefreshTimeout = 0
#     Clear-DnsClientCache
# https://stackoverflow.com/questions/18556456/invoke-webrequest-working-after-server-is-unreachable
#
# Note that I have seen the following error on Windows 7 / 10:
#   Exception calling "DownloadString" with "1" argument(s): "The request was aborted: Could not create SSL/TLS secure channel."
# Specifically fixing the security protocol to TLS in that session fixed this in some cases:
#   [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls   # (or optionally Tls12 on Windows 10)
#   [Net.ServicePointManager]::SecurityProtocol       # This will now show Tls instead of "Ssl3, Tls" and then can download
#
####################

####################
#
# Building this used the Posh-Gist Module which allows me to create and update source files (see Modules section below).
# I created a local folder and kept the project files in there and can either manually create the Gists online, or can
# use Posh-Gist with New-Gist. Created Gist-Push.ps1 and Gist-Pull.ps scripts to sync up project.
#
# # Gist-Push.ps1
# $cred = Get-Credential
# Update-Gist -Credential $cred -Id 61ef677591f22927afadc9ef2b657cd9 -Update .\BeginSystemConfig.ps1
# Update-Gist -Credential $cred -Id c37470c98c56214f09f0740fcb21ec4f -Update .\ProfileExtensions.ps1
# Update-Gist -Credential $cred -Id 5c6a16ea0964cf6d8c1f9eed7103aec8 -Update .\Custom-Tools.psm1
# Clear-DnsClientCache
#
# # Gist-Pull.ps1 (PowerShell v2 compatible
# $now = Get-Date -Format "yyyy-MM-dd__HH-mm-ss" # Adding datetime as pull is *dangerous*, can overwrite current work!
# (New-Object System.Net.WebClient).DownloadString('https://gist.github.com/roysubs/61ef677591f22927afadc9ef2b657cd9/raw') | Out-File .\BeginSystemConfig_$now.ps1
# (New-Object System.Net.WebClient).DownloadString('https://gist.github.com/roysubs/c37470c98c56214f09f0740fcb21ec4f/raw') | Out-File .\ProfileExtensions_$now.ps1
# (New-Object System.Net.WebClient).DownloadString('https://gist.github.com/roysubs/5c6a16ea0964cf6d8c1f9eed7103aec8/raw') | Out-File .\Custom-Tools_$now.psm1
# # # Variant if using PowerShell 3+ which has Invoke-WebRequest (iwr):
# # iwr 'https://gist.github.com/roysubs/61ef677591f22927afadc9ef2b657cd9/raw' | select -expand content | Out-File .\temp1.txt
# # iwr 'https://gist.github.com/roysubs/c37470c98c56214f09f0740fcb21ec4f/raw' | select -expand content | Out-File .\temp2.txt
# # iwr 'https://gist.github.com/roysubs/5c6a16ea0964cf6d8c1f9eed7103aec8/raw' | select -expand content | Out-File .\temp3.txt
# # # -Headers @{"Cache-Control"="no-cache"} does not seem to help for caching issues
#
####################

####################
#
# Problems with PowerShell v2
# 
# Invoke-WebRequest (iwr) does not exist on PS v2, but Invoke-Expression (iex) does
# System.Net.WebClient is the easiest way to do it for simple GET request but if you need to do a POST request
# for a form then you will need to use System.Net.HttpWebRequest. We only need WebClient here.
# Alternatively, could download curl or wget or replicate in PowerShell. Good discussion of methods at end of this:
# https://social.technet.microsoft.com/Forums/ie/en-US/55c7e306-cab5-4bdb-9825-1909d41fa2ca/simple-curl-in-powershell-20?forum=winserverpowershell
# (New-Object System.Net.WebClient).DownloadString('https://bit.ly/2R7znLX')
# or ...
# $url = "https://gist.githubusercontent.com/roysubs/61ef677591f22927afadc9ef2b657cd9/raw"
# $output = "C:\0\BeginSystemConfig.txt"
# # $start_time = Get-Date
# $wc = New-Object System.Net.WebClient
# $wc.DownloadFile($url, $output)   # or ... (New-Object System.Net.WebClient).DownloadFile($url, $output)
# # Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"# Often saw the following error on Gist addresses:
# Another issue even for more modern systems is that Invoke-WebRequest does not work if IE is not 'initialized'(!).
# So when writing pipeline or DSC scripts you have to do some extra legwork first or you can use Invoke-RestMethod instead.
# On using BITS:
# Import-Module BitsTransfer (not required on PS v5 setups)
# Start-BitsTransfer -Source <url> -Destination <file-to-create-on-disk>
#
# https://social.technet.microsoft.com/Forums/en-US/eda9171e-879f-473b-bb48-687ad87fedd7/using-serviceui-powershell-and-bits-exception-from-hresult-0x800704dd?forum=ConfigMgrAppManagement
# https://social.technet.microsoft.com/Forums/ie/en-US/f006636c-27b1-46fc-8e7e-0530269c380c/startbitstransfer-powershell-remote-action-errors?forum=winserverpowershell
# https://4sysops.com/archives/use-powershell-to-download-a-file-with-http-https-and-ftp/
# https://www.thewindowsclub.com/download-file-using-windows-powershell
# https://blog.jourdant.me/post/3-ways-to-download-files-with-powershell
# https://superuser.com/questions/362152/native-alternative-to-wget-in-windows-powershell
# https://gallery.technet.microsoft.com/scriptcenter/Downloading-Files-from-dcaaf44c
# https://stackoverflow.com/questions/7715695/http-requests-with-powershell
# https://stackoverflow.com/questions/4988286/what-difference-is-there-between-webclient-and-httpwebrequest-classes-in-net
# https://stackoverflow.com/questions/7715695/http-requests-with-powershell/20941552#20941552
#
# 'Pause' is not available on PowerShell v2 so can use the below, or can just use Confirm-Choice function below (easier)
#    Write-Host "Press Enter to continue...:" ; cmd /c pause | out-null
#
# "Install-Module" does not exist in PowerShell v2
#
# Get-CimInstance fails on PowerShell v2. Need to fix this (todo) for PS v2 for the Adminstrator check.
#   Replace: ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber)
#   With:    (Get-WmiObject Win32_OperatingSystem).BuildNumber)
#   Or: remove that check altogether, it is for 
# 
####################



####################
####################
####################



####################
#
# Header Block
#
# param() must be the first line in a script if used.
# Confirm-Choice and Elevation should be right after that.
#
####################

# param([string]$runsilently)
# $runsilenty = $false
#
# Have attempted ways to call a script online *with* parameters, but have not found a solution yet.
# Simple workaround, just put a Confirm-Choice at start to ask if want to run attended or not. Works well.
# Other options:
# - Create unnamed scriptblock from the url when invoke with call operator &), have not got this working:
#   & $([scriptblock]::Create((New-Object Net.WebClient).DownloadString(https://bit.ly/2R7znLX))) silent
# https://stackoverflow.com/questions/40958417/run-powershell-script-from-url-passing-parameters
# - Download all files to temp folder then use parameters, but again cannot just kick-off from iex, so is
# also not ideal. Downloading and running would work something like:
#   (New-Object System.Net.WebClient).DownloadString('https://bit.ly/2R7znLX') | Out-File "$($env:TEMP)\BeginSystemConfig.ps1" ; "$($env:TEMP)\BeingSystemConfig.ps1" <param1> <param2> ...
# https://stackoverflow.com/questions/33205298/how-to-use-powershell-to-download-a-script-file-then-execute-it-with-passing-in

####################
#
# Note optional settings to force strict limits on script execution:
# Set-StrictMode -Version Latest
# $ErrorActionPreference = 'Stop'
#
####################

####################
#
# Note on Exit / Return / Throw:
# Exit will normally exit the script and the console when in main body of a script. The only ways to get the script to exit
# but not exit the console are to put an exit inside a function, or to use a throw statement to terminate script processing.
# Using 'exit' in a function is cleaner overall (but note that in a function library called by another script, then 'return'
# should be used). BUT(!), have now discovered that the above is true for running locally, where using 'exit' is best, but
# when calling via iex, the 'exit' will kill the console(!), so falling back to using 'throw'.
# https://stackoverflow.com/questions/2022326/terminating-a-script-in-powershell
# Alao note the global solution here (solution 3). https://blog.danskingdom.com/keep-powershell-console-window-open-after-script-finishes-running/
#
####################

# Variables, create HomeFix in case of network shares (as always want to use C:\ drive, so get the name (Leaf) from $HOME)
# Need paths that fix the "Edwin issue" i.e. UsernName has changed from the path that in $env:USERPROFILE
# And also to fix the issue with VPN network paths, so  check for "\\" in the profile,    # $UserNameFriendly = $env:UserName
$HomeFix = $HOME
$HomeLeaf = split-path $HOME -leaf   # Just get the correct username in spite of any changes to username!
$WinId = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name   # This returns Hostname\WindowsIdentity, where WindowsIdentity can be different from UserProfile folder name
if ($HomeFix -like "\\*") { $HomeFix = "C:\Users\$(Split-Path $HOME -Leaf)" }
$UserModulePath = "$HomeFix\Documents\WindowsPowerShell\Modules"   # $UserModulePath = "C:\Users\$HomeLeaf\Documents\WindowsPowerShell\Modules"
$UserScriptsPath = "$HomeFix\Documents\WindowsPowerShell\Scripts"
$AdminModulesPath = "C:\Program Files\WindowsPowerShell\Modules"
# The default Modules and Scripts paths are not created by default in Windows
if (!(Test-Path $UserModulePath)) { md $UserModulePath -Force -EA silent | Out-Null }
if (!(Test-Path $UserScriptsPath)) { md $UserScriptsPath -Force -EA silent | Out-Null }

$OSver = (Get-WMIObject win32_operatingsystem).Name
$PSver = $PSVersionTable.PSVersion.Major
#     Get-Content -Path $profile | Select-String -Pattern "^function.+" | ForEach-Object {
#         [Regex]::Matches($_, "^function ([a-z.-]+)","IgnoreCase").Groups[1].Value
#         } | Where-Object { $_ -ine "prompt" } | Sort-Object


# https://codingbee.net/powershell/powershell-make-a-permanent-change-to-the-path-environment-variable
# https://www.computerperformance.co.uk/powershell/env-path/
function AddTo-Path {
    param ( 
        [string]$PathToAdd,
        [Parameter(Mandatory=$true)][ValidateSet('System','User')]      [string]$UserType,
        [Parameter(Mandatory=$true)][ValidateSet('Path','PSModulePath')][string]$PathType
    )
    # AddTo-Path "C:\XXX" 'System' "PSModulePath"
    if ($UserType -eq "User"   ) { $RegPropertyLocation = 'HKCU:\Environment' } # also note: Registry::HKEY_LOCAL_MACHINE\ format
    if ($UserType -eq "System" ) { $RegPropertyLocation = 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment' }
    "`nAdd '$PathToAdd' (if not already present) into the $UserType `$$PathType"
    "The '$UserType' environment variables are held in the registry at '$RegPropertyLocation'"
    try { $PathOld = (Get-ItemProperty -Path $RegPropertyLocation -Name $PathType -EA silent).$PathType } catch { "ItemProperty is missing" }
    "`n$UserType `$$PathType Before:`n$PathOld`n"
    $PathOld = $PathOld -replace "^;", "" -replace ";$", ""   # After displaying actual old path, remove leading/trailing ";" (also .trimstart / .trimend)
    $PathArray = $PathOld -split ";" -replace "\\+$", ""      # Create the array, removing network locations???
    if ($PathArray -notcontains $PathToAdd) {
        "$UserType $PathType Now:"   # ; sleep -Milliseconds 100   # Might need pause to prevent text being after Path output(!)
        $PathNew = "$PathOld;$PathToAdd"
        Set-ItemProperty -Path $RegPropertyLocation -Name $PathType -Value $PathNew
        Get-ItemProperty -Path $RegPropertyLocation -Name $PathType | select -ExpandProperty $PathType
        if ($PathType -eq "Path") { $env:Path += ";$PathToAdd" }                  # Add to Path also for this current session
        if ($PathType -eq "PSModulePath") { $env:PSModulePath += ";$PathToAdd" }  # Add to PSModulePath also for this current session
        "`n$PathToAdd has been added to the $UserType $PathType"
    }
    else {
        "'$PathToAdd' is already in the $UserType $PathType. Nothing to do."
    }
}

# Update PSModulePath (User), check/add the default Modules location $UserModulePath to the user PSModulePath
AddTo-Path $UserModulePath "User" "PSModulePath" | Out-Null   # Add the correct Used Modules path to PSModulePath

# Update Path (User), check/add the default Scripts location $UserScriptsPath to the user Path
AddTo-Path $UserScriptsPath "User" "Path" | Out-Null    # Add the correct Used Scripts path to Path

function ThrowScriptErrorAndStop { 
    ""
    throw "This is not an error. Using the 'throw' command here to halt script execution`nas 'return' / 'exit' have issues when run with Invoke-Expression from a URL ..."
}

function Confirm-Choice {
    param ( [string]$Message )
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes";
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No";
    $choices = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no);
    $caption = ""   # Did not need this before, but now getting odd errors without it.
    $answer = $host.ui.PromptForChoice($caption, $message, $choices, 0)   # Set to 0 to default to "yes" and 1 to default to "no"
    switch ($answer) {
        0 {return 'yes'; break}  # 0 is position 0, i.e. "yes"
        1 {return 'no'; break}   # 1 is position 1, i.e. "no"
    }
}

$unattended = $false   # default condition is to ask user for input
$confirm = 'Do you want to continue?'   # Apart from unattended question, this is used for all other $Message values in Confirm-Choice.

if ((Get-ExecutionPolicy -Scope LocalMachine) -eq "Restricted") {
    "Get-ExecutionPolicy -Scope LocalMachine => Restricted"
    "It is highly recommended that you open an Administrator console and open the ExecutionPolicy."
    "Set-ExecutionPolicy RemoteSigned   # or 'Unrestricted' is also ok."
    "This is required to run `$profile and additional scripts in this configuration."
    ""
    if ($(Confirm-Choice "Stop this configuration run until the ExecutionPolicy is configured?`nSelect 'n' to continue anyway (expect errors).") -eq "no") { $unattended = $true }
}

# https://stackoverflow.com/questions/1059663/is-there-a-way-to-wordwrap-results-of-a-powershell-cmdlet#1059686 
# Originally named Write-Wrap
function Write-Wrap {
    <#
    .SYNOPSIS
    Wraps a string or an array of strings at the console width so that no word is broken at line enddings and nearly folds to multiple lines
    .PARAMETER chunk
    A string or an array of strings
    .EXAMPLE
    Write-Wrap -chunk $string
    .EXAMPLE
    $string | Write-Wrap
    #>
    [CmdletBinding()]Param(
        [parameter(Mandatory=1, ValueFromPipeline=1, ValueFromPipelineByPropertyName=1)] [Object[]]$chunk
    )
    PROCESS {
        $Lines = @()
        foreach ($line in $chunk) {
            $str = ''
            $counter = 0
            $line -split '\s+' | % {
                $counter += $_.Length + 1
                if ($counter -gt $Host.UI.RawUI.BufferSize.Width) {
                    $Lines += ,$str.trim()
                    $str = ''
                    $counter = $_.Length + 1
                }
                $str = "$str$_ "
            }
            $Lines += ,$str.trim()
        }
        $Lines
    }
}

####################
#
# Note on using Write-Host: Write-Host is considered bad, or at least, it does not play nicely with the pipeline. Write-Host
# ignores the pipeline and just fires things onto the screen. This is bad from a pipeline perspective as the pipeline does
# things in a different fashion waiting for the pipeline to close etc. So, using Write-Host means that you will see some
# outputs muddled up. i.e. Outputs from the pipeline can happen after a Write-Host that comes later on in a scrip.
# There are good workarounds (mainly to make a function like Write-Host that is pipeline compliant), and they might be
# worth using, but for now I'm just sticking with Write-Host and using the "pipeline cludge" which is to put " | Out-Host"
# on the end of a few pipeline commands that might get jumbled up in ordering to make them adhere to Out-Host sequential
# ordering. i.e. With " | Out-Host" on the end of a Pipeline Cmdlet line, then the output will be ordered sequentially
# along with Write-Host commands.
# Alternatives (pipeline compliant colour outputting Cmdlets):
# https://stackoverflow.com/questions/59220186/usage-of-write-output-is-very-unreliable-compared-to-write-host/59228534#59228534
# https://stackoverflow.com/questions/2688547/multiple-foreground-colors-in-powershell-in-one-command/46046113#46046113
# https://jdhitsolutions.com/blog/powershell/3462/friday-fun-out-conditionalcolor/
# https://www.powershellgallery.com/packages?q=write-coloredoutput
#
# The best approach might be to bypass Write-Host with a custom function (functions take priority over Cmdlets as
# shown here): https://stackoverflow.com/questions/33747257/can-i-override-a-powershell-native-cmdlet-but-call-it-from-my-override
#
####################

""
# Test the path that this script is running from. If this is $null, then it was stated by iex from a URL.
$BeginPath = $MyInvocation.MyCommand.Path   # echo $BeginPath
$UrlConfig            = 'https://gist.github.com/roysubs/61ef677591f22927afadc9ef2b657cd9/raw'
$UrlProfileExtensions = 'https://gist.github.com/roysubs/c37470c98c56214f09f0740fcb21ec4f/raw'
$UrlCustomTools       = 'https://gist.github.com/roysubs/5c6a16ea0964cf6d8c1f9eed7103aec8/raw'

if ($BeginPath -eq $null) {
    "Scripts are being downloaded and installed from internet (github)."
    # This is case when $BeginPath is null, i.e. the script was run via the web, so have to download all scripts.
    # (New-Object System.Net.WebClient).DownloadString('https://bit.ly/2R7znLX') | Out-File "$env:TEMP\BeginSystemConfig.ps1"
    (New-Object System.Net.WebClient).DownloadString($UrlConfig)            | Out-File "$env:TEMP\BeginSystemConfig.ps1" -Force
    (New-Object System.Net.WebClient).DownloadString($UrlProfileExtensions) | Out-File "$env:TEMP\ProfileExtensions.ps1" -Force
    (New-Object System.Net.WebClient).DownloadString($UrlCustomTools)       | Out-File "$env:TEMP\Custom-Tools.psm1" -Force
    $BeginPath = "$env:TEMP\BeginSystemConfig.ps1"
    $ScriptSetupPath = Split-Path $BeginPath   # Copy the files to TEMP as staging area for local or downloaded files
}
else {
    "Scripts are being installed locally from:   $BeginPath"
    # If the path is not null, then the script was run from the filesystem, so the scripts should be here.
    # First, test if all scripts are here, if they are not, then no point in continuing.
    $ScriptSetupPath = Split-Path $BeginPath   # Copy the files to TEMP as staging area for local or downloaded files
    if ((Test-Path "$ScriptSetupPath\BeginSystemConfig.ps1") -and (Test-Path "$ScriptSetupPath\ProfileExtensions.ps1") -and (Test-Path "$ScriptSetupPath\Custom-Tools.psm1")) {
        # If the running scripts are not in TEMP, then copy them there and overwrite
        # Slight issue! When elevating to admin, the called scripts are in TEMP(!), so skip copying as will be to same location!
        if (Test-Path "$ScriptSetupPath\BeginSystemConfig.ps1") { Copy-Item "$ScriptSetupPath\BeginSystemConfig.ps1" "$env:TEMP\BeginSystemConfig.ps1" -Force }
        if (Test-Path "$ScriptSetupPath\ProfileExtensions.ps1") { Copy-Item "$ScriptSetupPath\ProfileExtensions.ps1" "$env:TEMP\ProfileExtensions.ps1" -Force }
        if (Test-Path "$ScriptSetupPath\Custom-Tools.psm1")     { Copy-Item "$ScriptSetupPath\Custom-Tools.psm1"     "$env:TEMP\Custom-Tools.psm1" -Force }
    }
    else {
        "Scripts not found."
        "   - BeginSystemConfig.ps1"
        "   - ProfileExtensions.ps1"
        "   - Custom-Tools.psm1"
        "Make sure that all required scripts are available."
        "Exiting script..."
        pause
        exit
    }
}

####################
#
# Self-elevate script if required.
#
####################

####################
#
# With the new setup, use the users Module folder instead of C:\ProgramData\WindowsPowerShell\Modules
# \\ad.ing.net\WPS\NL\P\UD\200024\YA64UG\Home\My Documents\WindowsPowerShell\Modules
# Redirect to => C:\Users\YA64UG\Documents\WindowsPowerShell\Modules
# Profile loading times are *extremely* slow when running on an ING EndPoint connection.
# Laptop without EndPoint => PowerShell loads in <1 sec
# Laptop with EndPoint    => PowerShell loads in 6.5 to 9 sec
# Laptop with EndPoint    => PowerShell loads in 3.5 sec (if move rofile extensions to C:\ locally)
# Laptop with EndPoint    => PowerShell loads in 1 sec (if also load C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1)
# Plan is then:
#    a) Try to move to profile.ps1 under System32 (will only work if TestAdministrator -eq True)
#    b) Use default user folder if cannot do that. i.e. \\ad.ing.net\WPS\NL\P\UD\200024\YA64UG\Home\My Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
# But this is not a problem because b) is only a problem if on a laptop with VPN because if on a server etc, the default user folder is fine!
# So, if on my laptop:
#    Profile = [C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1] + [C:\User\YA64UG\WindowsPowerShell\profile.ps1]
#        if(Test-File $Profile) { rename $Profile $Profile-disabled }
#    Modules = [C:\Users\YA64UG\Documents\WindowsPowerShell\Modules]
#        Check that this is in $env:PSModulePath
#        Delete the H: version of Modules completely!
#
# 1. if(Test-Administrator -eq True) => ask if want Admin install C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1 or Default User install
#        Suggest to only do an Admin install on personal laptop
# 2. 
# 3. Scripts => C:\Users\YA64UG\Documents\WindowsPowerShell\Scripts
#        Make sure that this is on the path
# mklinks => C:\PS\ (so profile will be at C:\PS\profile.ps1), C:\PS\Scripts, C:\PS\Modules
# No, can't do this as might not be admin!
# Just leave at normal locations but have go definitions to jump to these locations.
# 
# # To get around the ING problem with working from home.
# By mirroring the normal profile location, then everything else will work normally.
# Profile extensions will be placed in the local profile location rather than the ING one.
# "Microsoft.PowerShell_profile.ps1_extensions.ps1"
# By only appyling this to systems from ING, everything else will work normally.
# So the below is what should be pushed to C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1
#
# # # # if ($env:USERNAME -eq "ya64ug") {
# if ($(get-wmiobject -class Win32_ComputerSystem).PrimaryOwnerName -eq "ING")
#     $PROFILE.CurrentUserAllHosts = "$HomeFix\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
#     $PROFILE.CurrentUserCurrentHost = "$HomeFix\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
#     . $PROFILE
#     cd $HomeFix
# }
#
# $PROFILE = "$HomeFix\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
#
# Note that the above breaks the $PROFILE definition!
# ($PROFILE).GetType()
# IsPublic IsSerial Name                                     BaseType
# -------- -------- ----                                     --------
# True     True     String                                   System.Object
# 
# $PROFILE | Format-List * -Force
# AllUsersAllHosts       : C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1
# AllUsersCurrentHost    : C:\Windows\System32\WindowsPowerShell\v1.0\Microsoft.PowerShell_profile.ps1
# CurrentUserAllHosts    : \\ad.ing.net\WPS\NL\P\UD\200024\YA64UG\Home\My Documents\WindowsPowerShell\profile.ps1
# CurrentUserCurrentHost : \\ad.ing.net\WPS\NL\P\UD\200024\YA64UG\Home\My Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
# Length                 : 107
# 
# But, after the change above, making $PROFILE a single string:
# $PROFILE | Format-List * -Force
# C:\Users\ya64ug\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
# 
# So instead, just change those parts:
# $PROFILE.CurrentUserAllHosts = "$HomeFix\Documents\WindowsPowerShell\profile.ps1"
# $PROFILE.CurrentUserCurrentHost = "$HomeFix\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
#
# More here: https://devblogs.microsoft.com/scripting/understanding-the-six-powershell-profiles/
#
####################



# Define general Test-Administrator here and the full code to auto-elevate the script to run as Admin
# Moving away from auto-elevation so can manage everything in User folders (so scripts can run on any system)
function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# if ( ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -ne $True) {
#     Write-Header
#     Write-Host "Script can only continue if user is Elevated / Administrator ..." -ForegroundColor White -BackgroundColor Red
#     Write-Host "Current console is not Elevated so will attempt to auto-elevate." -ForegroundColor Red -BackgroundColor White
#     Write-Host ""
#     # if (!(Test-Path("$($env:TEMP)\ElevatedScriptStop.txt"))) { New-Item -ItemType File "$($env:TEMP)\ElevatedScriptStop.txt" }
#     if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
#         # if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {   # Avoid Get-CimInstance for PS v2 compatibility
#         # if (((Get-WmiObject Win32_OperatingSystem).BuildNumber) -ge 6000) {
# 
#         # If the script was run locally, just copy that (and all other scripts) to $env:TEMP and use them.
#         # If the script was run from a url, then download latest copies from there.
#         if ($BeginPath -eq $null) { 
#             (New-Object System.Net.WebClient).DownloadString('https://bit.ly/2R7znLX') | Out-File "$($env:TEMP)\BeginSystemConfig.ps1"
#         }
#         # Scripts were copied to TEMP earlier, will only be changed if was downloaded from Gist
#         $CommandLine = "-File `"" + "$($env:TEMP)\BeginSystemConfig.ps1" + "`""
#         if (Test-Path (Join-Path -Path "$($PSHOME)" -ChildPath "powershell.exe")) { $HostBinary = Join-Path -Path "$($PSHOME)" -ChildPath "powershell.exe" } # PowerShell 5.1
#         if (Test-Path (Join-Path -Path "$($PSHOME)" -ChildPath "pwsh.exe")) { $HostBinary = Join-Path -Path "$($PSHOME)" -ChildPath "pwsh.exe" }   # PowerShell Core 6 / 7
#         try { Start-Process -FilePath $HostBinary -Verb Runas -ArgumentList $CommandLine -EA silent }
#         catch { echo "wtf" }
#         "Stopping script here using a 'throw' statement as exit/return can close window"    
#         "when script is called from internet URL."
#         ""
#         ThrowScriptErrorAndStop
#     }
# }

# An argument for downloading and then running scripts is that we can then self-elevate the script.
# This is not possible if calling the script from a URL via Invoke-Expression, so for this situation
# modify the block to download the script and then call the script.
# Add this snippet at the beginning of any script that requires elevation to run properly. It works by
# starting a new elevated PowerShell window and then re-executes the script in this new window, if necessary.
# If User Account Control (UAC) is enabled, you will get a UAC prompt. If the script is already running in an
# elevated PowerShell session or UAC is disabled, the script will run normally. This code also allows you to
# right-click the script in File Explorer and select "Run with PowerShell".
# http://www.expta.com/2017/03/how-to-self-elevate-powershell-script.html
# This is the unmodified code block from the above. Try to use with as little modification sa possible.
# In fact, no need to modify, just prompt at start of script if want to run unattended or attended.
#
# if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
#     if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
#         $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
#         Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
#         Exit
#     }
# }
# In fact, *must* modify. If elevating, the script will restart, but if called from iex, then it has nothing
# to restart! In that case, must download the scripts and run them locally.

# iwr 'https://gist.github.com/roysubs/c37470c98c56214f09f0740fcb21ec4f/raw' | select -expand content | Out-File .\temp\ProfileExtensions.ps1
# iwr 'https://gist.github.com/roysubs/5c6a16ea0964cf6d8c1f9eed7103aec8/raw' | select -expand content | Out-File .\temp\Custom-Tools.psm1
# iwr 'https://gist.github.com/roysubs/908525ae135e7d31a4fd13bd111b50e9/raw' | select -expand content | Out-File .\temp\Gist-Push.ps1

Write-Header

# Elevation will restart the script so don't ask this question until after that point
if ($(Confirm-Choice "Prompt all main action steps during setup?`nSelect 'n' to make all actions unattended.") -eq "no") { $unattended = $true }



####################
#
# Main Script
#
####################



$start_time = Get-Date   # Put following lines at end of script to time it
# $hr = (Get-Date).Subtract($start_time).Hours ; $min = (Get-Date).Subtract($start_time).Minutes ; $sec = (Get-Date).Subtract($start_time).Seconds
# if ($hr -ne 0) { $times += "$hr hr " } ; if ($min -ne 0) { $times += "$min min " } ; $times += "$sec sec"
# "Script took $times to complete"   # $((Get-Date).Subtract($start_time).TotalSeconds)



# Set-ExecutionPolicy RemoteSigned
Write-Host ""
Write-Host "Try to set the execution policy to RemoteSigned for this system" -ForegroundColor Yellow -BackgroundColor Black
try {
    Set-ExecutionPolicy RemoteSigned -Force   # Need 
} catch {
    Write-Host "`nWARNING: 'Set-ExecutionPolicy RemoteSigned' failed to execute." -ForegroundColor Yellow
    Write-Host "This is often due to Group Policy restrictions on corporate builds.`n" -ForegroundColor Yellow
    Write-Host "'Get-ExecutionPolicy -List' (show current execution policy list):`n"
    Get-ExecutionPolicy -List | ft
}

# Set TLS for GitHub compatibility
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls } catch { }   # Windows 7 compatible
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch { }   # Windows 10 compatible

# BeingSystemConfig.ps1 to initialise everything, including chocolatey / boxstarter setup.
# Boxstarter module should be installed to get access to Install-BoxstarterPackage

Write-Host ""
Write-Host 'The object of this script is to configure basic System and PowerShell configurations.'
Write-Host 'Avoiding extensive modifications and sticking to core functionality. This control'
Write-Host 'script calls online Gists for all configuration (can also be run offline if the'
Write-Host 'internet is unavailable and the files are all in the same folder). To customise for'
Write-Host 'your own needs, the three Gists can be copied, edited, and then executed using a single'
Write-Host 'command to distribute all required settings to a new system.'
Write-Host ""
Write-Host "# The current script is used to chain together these system configurations" -ForegroundColor DarkGreen
Write-Host "iwr '$UrlConfig' | select -expandproperty content | more" -ForegroundColor Magenta
Write-Host "(New-Object System.Net.WebClient).DownloadString('$UrlConfig')"
Write-Host "# The Profile Extension script extends `$profile" -ForegroundColor DarkGreen
Write-Host "iwr '$UrlProfileExtensions' | select -expandproperty content | more" -ForegroundColor Magenta
Write-Host "(New-Object System.Net.WebClient).DownloadString('$UrlProfileExtensions')"
Write-Host "# Custom-Tools.psm1 Module to make useful generic functions available to console." -ForegroundColor DarkGreen
Write-Host "iwr '$UrlCustomTools' | select -expandproperty content | more" -ForegroundColor Magenta
Write-Host "(New-Object System.Net.WebClient).DownloadString('$UrlCustomTools')"
Write-Host ""

# Deprecated requirement to install as Admin, but leave this for reference.
# Write-Host "Script can only continue if user is Elevated / Administrator ..." -ForegroundColor White -BackgroundColor Red
# if ( ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -ne $True) {
#     Write-Host "Current console is not Elevated so script will exit. Rerun as Administrator to fix this." -ForegroundColor Red -BackgroundColor White
#     Write-Host ""
#     ThrowScriptErrorAndStop
# } else {
#     Write-Host "Current console is Elevated so script can continue." -ForegroundColor Green
# }

Write-Host 'Please review the above URLs to check that the changes are what you expect before continuing.'
Write-Host ""
# https://stackoverflow.com/questions/12522539/github-gist-editing-without-changing-url

if ($unattended -eq $false) { if ($(Confirm-Choice $confirm) -eq "no") { ThrowScriptErrorAndStop } }



####################
#
# Setup Profile Extensions and Custom Tools Module
#
####################



Write-Host ''
Write-Host ''
Write-Host "`n========================================" -ForegroundColor Green
Write-Host ''
Write-Host '1. Configure Custom-Tools and setup Profile Extensions in $Profile.' -ForegroundColor Green
Write-Host ''
Write-Host '   Check for the profile extensions in same folder as $Profile. If not present, the' -ForegroundColor Yellow
Write-Host '   latest profile extensions will be downloaded from Gist. A single line will then be' -ForegroundColor Yellow
Write-Host '   added into $Profile to load the profile extensions from $Profile into all new consoles.' -ForegroundColor Yellow
Write-Host ''
Write-Host '   To force the latest profile extensions, either rerun this script which will overwrite it' -ForegroundColor Yellow
Write-Host '   or delete the profile extensions and it will be downloaded on opening the next console.' -ForegroundColor Yellow
Write-Host ''
Write-Host '   The reason for having the profile extensions separately is to keep the profile clean and' -ForegroundColor Yellow
Write-Host '   to keep additions synced against a known working online copy.' -ForegroundColor Yellow
if($OSver -like "*Server*") {
    Write-Host ''
    Write-Host "   The Operating System is of type 'Server' so profile extensions will *not* load" -ForegroundColour Yello -BackgroundColor Black
    Write-Host "   by default in any console. Profile extensions can be loaded on demand by running" -ForegroundColour Yellow -BackgroundColor Black
    Write-Host "   the 'Enable-Extensions' function that will now be setup in `$profile." -ForegroundColour Yellow -BackgroundColor Black
}
Write-Host ''
Write-Host "========================================`n" -ForegroundColor Green

Write-Host ''
Write-Host ""
Write-Host "Update and reinstall Custom-Tools.psm1 Module." -ForegroundColor Yellow -BackgroundColor Black
Write-Host "The Module contains many generic functions (including some required later in this setup)."
Write-Host "View functions in the module with 'myfunctions' / 'mods' / 'mod custom-tools' or view module contents with:"
Write-Host "   get-command -module custom-tools" -ForegroundColor Yellow

$CustomTools = "$HomeFix\Documents\WindowsPowerShell\Modules\Custom-Tools\Custom-Tools.psm1"
if ([bool](Get-Module Custom-Tools -ListAvailable) -eq $true) {
    if ($PSver -gt 4) { Uninstall-Module Custom-Tools -EA Silent -Force -Verbose }   # Uninstall-Module is only in PS v4+
    else { "Need to be running PS v5 or higher to run Uninstall-Module" }
}
if (!(Test-Path (Split-Path $CustomTools))) { New-Item (Split-Path $CustomTools) -ItemType Directory -Force }   # Create folder if required
if (Test-Path ($CustomTools)) { rm $CustomTools }   # Delete old version of the .psm1 if it was already there
"$BeginPath is currently running script."
"$(Split-Path $BeginPath)\Custom-Tools.psm1 will be used to load Custom-Tools Module."

if ($BeginPath -eq $null) {
    # Case when scripts were downloaded
    # try { (New-Object System.Net.WebClient).DownloadString("$UrlCustomTools") | Out-File $CustomTools ; echo "Downloaded Custom-Tools.psm1 Module from internet ..." }
    # catch { Write-Host "Failed to download! Check internet/TLS settings before retrying." -ForegroundColor Red }
    Copy-Item "$ScriptSetupPath\Custom-Tools.psm1" $CustomTools -Force
} 
else {
    # First try to use the version in same folder as BeginSystemConfig
    Copy-Item "$ScriptSetupPath\Custom-Tools.psm1" $CustomTools -Force
    Write-Host "$ScriptSetupPath\Custom-Tools.psm1 was copied to Custom-Tools Path: $CustomTools"
    Write-Host "Using local version of Custom-Tools.psm1 from $BeginPath ..."
}

# If still have nothing, try to download from Github
#     else {
#         try { (New-Object System.Net.WebClient).DownloadString("$UrlCustomTools") | Out-File $CustomTools }
#         catch { Write-Host "Failed to download! Check internet/TLS settings before retrying." -ForegroundColor Red }
#     }
# }

Import-Module Custom-Tools -Force -Verbose  # Don't require full path, it should search for it in standard PSModulePaths
$x = ""; foreach ($i in (get-command -module Custom-Tools).Name) {$x = "$x, $i"} ; "" ; Write-Wrap $x.trimstart(", ") ; ""

# Alternative method to dotsource all scripts in a given folder along with $Profile
# $MyFunctionsDir = "$env:USERPROFILE\Documents\WindowsPowerShell\Functions"
# Get-ChildItem "$MyFunctionsDir\*.ps1" | % {.$_}

if ($unattended -eq $false) { if ($(Confirm-Choice $confirm) -eq "no") { ThrowScriptErrorAndStop } }



$ProfileFolder     = $Profile | Split-Path -Parent
$ProfileFile       = $Profile | Split-Path -Leaf
$ProfileExtensions = Join-Path $ProfileFolder "$($ProfileFile)_extensions.ps1"
Write-Host "Profile           : $Profile"
Write-Host "ProfileExtensions : $ProfileExtensions"
Write-Host ""
Write-Host "Note that the Profile path below is determined by the currently running 'Host'."
Write-Host "i.e. The host is usually either the PowerShell Console, or PowerShell ISE, or"
Write-Host "Visual Studio Code, each of which will have their own Profile path which you can"
Write-Host "see by typing `$Profile from within that given host. Other hosts can exist, such"
Write-Host "as PowerShell Core running under Linux, but the above are the most usual on Wwindows."
Write-Host ""
Write-Host "You can see more information on the current host by typing '`$host' at the console:"
$host   # Will show the current host

# Create $Profile folder and file if they do not exist
if (!(Test-Path $ProfileFolder)) { New-Item -Type Directory $ProfileFolder -Force }
if (!(Test-Path $Profile)) { New-Item -Type File $Profile -Force }

# Create a backup of the extensions in case user has modified this directly.
if (Test-Path ($ProfileExtensions)) {
    Write-Host "`nCreating backup of existing profile extensions in case download fails ..."
    Move-Item -Path "$($ProfileExtensions)" -Destination "$($ProfileExtensions)_$(Get-Date -format "yyyy-MM-dd__HH-mm-ss").txt" 
}

Write-Host "`nGet latest profile extensions (locally if available or download) ..."

if ($BeginPath -eq $null) {   # If BeginPath is null, files should still be in env:TEMP from previous download
    # try { (New-Object System.Net.WebClient).DownloadString("$UrlProfileExtensions") | Out-File $ProfileExtensions -Force ; echo "Downloaded profile extensions from internet ..." }
    # catch { Write-Host "Failed to download! Check internet/TLS settings before retrying." -ForegroundColor Red }
    Copy-Item "$ScriptSetupPath\ProfileExtensions.ps1" $ProfileExtensions -Force
} else {
    # First try to use the version in same folder as BeginSystemConfig
    Copy-Item "$ScriptSetupPath\ProfileExtensions.ps1" $ProfileExtensions -Force
    Write-Host "$ScriptSetupPath\ProfileExtensions.ps1 was copied to $ProfileExtensions"
    Write-Host "Using local version of Profile Extensions from $BeginPath ..."
}
# # If still have nothing, try to download from Github
# else {
#     try { (New-Object System.Net.WebClient).DownloadString("$UrlProfileExtensions") | Out-File $UrlProfileExtensions }
#     catch { Write-Host "Failed to download! Check internet/TLS settings before retrying." -ForegroundColor Red }
# }

# If the script was run from a url, then download latest copies from there.
# For working offline, use the latest profile extensions locally if available by copying to TEMP and using same logic.

# if ($null -eq $BeginPath ) {
#     if (Test-Path "$($env:TEMP)\ProfileExtensions.ps1") {
#         Copy-Item "$($env:TEMP)\ProfileExtensions.ps1" $ProfileExtensions -Force
#         echo "`nUsing local profile extensions from $($env:TEMP)\ProfileExtensions.ps1..."
#     } else {
#         # If $ProfileExtensions was not there, just get from online
#         try { (New-Object System.Net.WebClient).DownloadString("$UrlProfileExtensions") | Out-File $ProfileExtensions ; echo "Downloaded profile extensions from internet ..."}
#         catch { Write-Host "Failed to download! Check internet/TLS settings before retrying." -ForegroundColor Red }
#     }
# }

if (Test-Path ($ProfileExtensions)) {
    Write-Host "`nDotsourcing new profile extensions into this current session ..."
    . $ProfileExtensions
}
else {
    Write-Host "`nProfile extensions could not be loaded locally (missing) or downloaded from internet."
    Write-Host "If downloaded from internet, check internet/TLS settings before retrying."
    pause
}
# If running on a server OS, or "Administrator" or hostname is "SJ*CAL", do not autoload extensions.
# In that case, put a function into $profile to enable:   . Enable-Extensions

if ($OSver -like "*Server*") {

    # Remove the Enable-Extensions line by getting the content *minus* the line to remove "-NotMatch" and adding it back into the profile
    Write-Host "`nRemoving profile extensions handler line from `$Profile to ensure that it is positioned at the end of the script ..."
    Set-Content -Path $profile -Value (Get-Content -Path $profile | Select-String -Pattern '^if \(\!\(Test-Path \("\$\(\$Profile\)_extensions\.ps1\"\)\)\) \{ try { \(New' -NotMatch)
    Set-Content -Path $profile -Value (Get-Content -Path $profile | Select-String -Pattern '^function Enable-Extensions { if' -NotMatch)
    # Set-Content -Path $profile -Value (Get-Content -Path $profile | Select-String -Pattern '^if \($MyInvocation.InvocationName -eq "Enable-Extensions"\)' -NotMatch)

    # Append the Enable-Extensions line to end of $profile
    Write-Host "`nAdding updated profile extensions handler line to `$Profile ...`n"

    $ProfileExtensionsHandler  = "function Enable-Extensions { if (Test-Path (""`$(`$Profile)_extensions.ps1"")) { "   # Need separate line for the $($Profile) expansion
    $ProfileExtensionsHandler += 'if ($MyInvocation.InvocationName -eq "Enable-Extensions") { "`nWarning: Must dotsource Enable-Extensions or it will not be added!`n`n. Enable-Extensions`n" } else { . "$($Profile)_extensions.ps1" -EA silent } } }'
    Add-Content -Path $profile -Value $ProfileExtensionsHandler -PassThru
    Write-Host ""
    Write-Host "The profile extensions handler has *not* been added to `$Profile as the Operating System" -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "is of type 'Server'. However, the 'Enable-Extensions' function has been added to `$Profile" -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "and can be loaded at any time using by dotsourcing into the current session:" -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "   . Enable-Extensions" -ForegroundColor Cyan -BackgroundColor Black
    Write-Host ""

} else {

    # Want to put these lines at the end of $profile, so strip the matching lines and rewrite to the same file
    # Set-Content -Path "C:\myfile.txt" -Value (Get-Content -Path "C:\myfile.txt" | Select-String -Pattern 'H\|159' -NotMatch)
    Write-Host "`nRemoving profile extensions handler line from `$Profile to ensure that it is positioned at the end of the script ..."
    # Set-Content -Path $profile -Value (Get-Content -Path $profile | Select-String -Pattern '^\[Net\.ServicePointManager\]::SecurityProtocol' -NotMatch)
    # Remove the Tls setting as not compatible with PowerShell v2
    # Set-Content -Path $profile -Value (Get-Content -Path $profile | Select-String -Pattern '^\$UrlProfileExtensions \= ' -NotMatch) -EA SilentlyContinue
    Set-Content -Path $profile -Value (Get-Content -Path $profile | Select-String -Pattern '^if \(\!\(Test-Path \("\$\(\$Profile\)_extensions\.ps1\"\)\)\) \{ try { \(New' -NotMatch)
    # Then append the lines in the correct order to the end of $profile. Note "-PassTru" switch to display the result as well as writing to file
    Write-Host "`nAdding updated profile extensions handler line to `$Profile ...`n"
    # $ProfileExtensionsHandler = "`$UrlProfileExtensions = ""$UrlProfileExtensions"" ; "
    $ProfileExtensionsHandler  = "if (!(Test-Path (""`$(`$Profile)_extensions.ps1""))) { try { (New-Object System.Net.WebClient).DownloadString('$UrlProfileExtensions') | Out-File ""`$(`$Profile)_extensions.ps1"" } "
    $ProfileExtensionsHandler += 'catch { "Could not download profile extensions, check internet/TLS before opening a new console." } } ; '
    $ProfileExtensionsHandler += '. "$($Profile)_extensions.ps1" -EA silent'
    Add-Content -Path $profile -Value $ProfileExtensionsHandler -PassThru
    Write-Host ""
    Write-Host "The profile extensions handler has been added to `$Profile and so will be" -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "loaded by default in all console sessions." -ForegroundColor Yellow -BackgroundColor Black
    Write-Host ""
    # Considerations for building strings: https://powershellexplained.com/2017-11-20-Powershell-StringBuilder/
    # Alternatively, doing three Add-Content lines with -NoNewLine would also work fine.
    # Added ErrorAction (EA) SilentlyContinue to suppress errors if cannot reach the URL
    # Removed the Tls setting as this is not compatible with PowerShell v2
    # Add-Content -Path $profile -Value "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12" -PassThru
}


Write-Host ""
if ($unattended -eq $false) { if ($(Confirm-Choice $confirm) -eq "no") { ThrowScriptErrorAndStop } }

# Update-Help to download latest help files
# Note that Update-Help does not exist in vanilla Windows 7 / PowerShell v2 (!)
# Check Last Modified Date of  "$($env:TEMP)\Update-Help-Check.flag"
# Create / Touch file in $env:TEMP
# https://superuser.com/questions/251263/the-last-access-date-is-not-changed-even-after-reading-the-file-on-windows-7
####################
#
# DEPRECATE ALL OF THIS !!!
# Takes too long to complete, and anyway, 'm' in the Custom-Tools performs the same task to update all help files.
#
####################
# $updatefile = "$($env:TEMP)\ps_Update-Help-$($PSVersionTable.PSVersion.ToString()).flag"
# if (Test-Path $updatefile) { [datetime]$updatetime = (Get-Item $updatefile).LastWriteTime }
# [int]$helpolderthan = 20
# [datetime]$dateinpast = (Get-Date).AddDays(-$helpolderthan)
# 
# if (Test-Administrator -eq $true) {
#     Write-Host ""
#     Write-Host ""
#     Write-Host "n========================================" -ForegroundColor Green
#     Write-Host "Update Help Files if more than $helpolderthan days old." -F Yellow -B Black
#     Write-Host "Checking PowerShell Help definitions ..." -F Yellow -B Black
#     Write-Host "" 
#     Write-Host "Note: This section will only show if you are running as Administrator." 
#     Write-Host "========================================" -ForegroundColor Green
#     Write-Host ""
# 
#     if ($PSVersionTable.PSVersion.Major -eq 2) {
#         Write-Host "Update-Help Cmdlet does not exist on PowerShell v2." -ForegroundColor Red
#         Write-Host "Skipping help definitions update ..." -ForegroundColor Red
#     } else {
# 
#         if (Test-Path $updatefile) {
#             "Current Date minus $helpolderthan         : $((Get-Date).AddDays(-$helpolderthan))"   # Note that this has a "-" so this is back 20 days from the current day
#             "Date on help update flag file : $updatetime"
# 
#             if ($updatetime -lt $dateinpast) {
#                 Write-Host "Help files only update if more than $($helpolderthan.ToString()) days old. A flag file is" -ForegroundColor Green
#                 Write-Host "kept in the user Temp folder timestamped at last update time to check this ..." -ForegroundColor Green
#                 Write-Host "The flag file is more than days old, so Help file definitions will update ..." -ForegroundColor Green
#                 (Get-ChildItem $updatefile).LastWriteTime = Get-Date   # touch the flat file to today's date
#                 Update-Help -ErrorAction SilentlyContinue
#                 # Run this with -EA silent due to the various errors that always happen as a result of bad manifests, which will be similar to:
#                 # Note that this will not suppress all error messages! so need to add | Out-Null also
#                 #   update-help : Failed to update Help for the module(s) 'AppvClient, ConfigDefender, Defender, HgsClient, HgsDiagnostics, HostNetworkingService,
#                 #   Microsoft.PowerShell.ODataUtils, Microsoft.PowerShell.Operation.Validation, UEV, Whea, WindowsDeveloperLicense' with UI culture(s) {en-GB} : Unable to
#                 #   connect to Help content. The server on which Help content is stored might not be available. Verify that the server is available, or wait until the server is
#                 #   back online, and then try the command again.
#             } else {
#                 Write-Wrap "The flag file used to determine if help definitions should be updated is less than $($helpolderthan.ToString()) days old so help file will not be updated ..."
#             }
#         } else {
#             Write-Host "No help definitions checkfile found, creating a new checkfile and Update-Help will run ..."
#             New-Item -ItemType File $updatefile
#             Update-Help -ErrorAction SilentlyContinue
#         }
#     }
#     Write-Host ""
#     if ($unattended -eq $false) { if ($(Confirm-Choice $confirm) -eq "no") { ThrowScriptErrorAndStop } }
# }
# else {
#     "Must be Administrator to update help files"
# }



####################
#
# Update PowerShell, Chocolatey, Boxstarter
#
####################



if (Test-Administrator -eq $true) {
    Write-Host ''
    Write-Host ''
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host ''
    Write-Host '2. Update PowerShell, Chocolatey, Boxstarter' -ForegroundColor Green
    Write-Host ''
    Write-Host '   Only run the web-installers if not already found to be installed.' -ForegroundColor Yellow
    Write-Host '   Check various system configurations and update if required.' -ForegroundColor Yellow
    Write-Host ''
    Write-Host '   Also, if on Windows 7, test for Service Pack 1, .NET 4.5 etc.' -ForegroundColor Yellow
    Write-Host ''
    Write-Host "========================================`n" -ForegroundColor Green
    Write-Host ''

    if ($unattended -eq $false) { if ($(Confirm-Choice $confirm) -eq "no") { ThrowScriptErrorAndStop } }

    Write-Host ""
    Write-Host "Test for profile, create if it does not currently exist" -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "$profile"
    if(!(Test-Path (Split-Path $profile))) { New-Item -ItemType Directory (Split-Path $profile) }   # Create profile folder if not already there
    if(!(Test-Path $profile)) { New-Item -ItemType File $profile }                                  # Create $profile if not already there

    Write-Host ""
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
    } catch {
        Write-Host "`nWARNING: 'Set-ExecutionPolicy Bypass -Scope Process -Force' failed to execute." -ForegroundColor Yellow
        Write-Host "This is often due to Group Policy restrictions on corporate builds.`n" -ForegroundColor Yellow
        Write-Host "'Get-ExecutionPolicy -List' (show current execution policy list):`n"
        Get-ExecutionPolicy -List | ft
    }
    # The actual error in this case was:
    #   Set-ExecutionPolicy : Windows PowerShell updated your execution policy successfully, but the setting is overridden
    #   by a policy defined at a more specific scope. Due to the override, your shell will retain its current effective
    #   execution policy of Unrestricted. Type "Get-ExecutionPolicy -List" to view your execution policy settings. For more
    #   information please see "Get-Help Set-ExecutionPolicy".
    # Note that the 'Unrestricted' setting is more open than the setting attempted in the above.
    # However, iff you have 'Administrator' access (which is required to run this script), then it should run ok.

    # To take and run the string was a little awkward. Tried:
    # dotsourcing, &, Start-Job, but in the end Invoke-Expression (iex) was required!
    # https://stackoverflow.com/questions/12850487/invoke-a-second-script-with-arguments-from-a-script

    function IfExistSkipCommand ($toCheck, $toRun) {
        if (Test-Path($toCheck)) {
            Write-Host "Item exists        : $toCheck" -ForegroundColor Green
            Write-Host "Will skip installer: $toRun`n" -ForegroundColor Cyan
        } else {
            Write-Host "Item does not exist: $toCheck" -ForegroundColor Green
            Write-Host "Will run installer : $toRun`n" -ForegroundColor Cyan
            Invoke-Expression $toRun

        }
    }

    # Chocolatey, assume ok if choco.exe is there
    Write-Host "Test for Chocolatey, download and install if it does not currently exist" -ForegroundColor Yellow -BackgroundColor Black
    IfExistSkipCommand "C:\ProgramData\chocolatey\choco.exe" "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
    # Manually apply the chocolateyProfile
    if (Test-Path("C:\ProgramData\chocolatey\helpers\chocolateyProfile.psm1")) { Import-Module "C:\ProgramData\chocolatey\helpers\chocolateyProfile.psm1" }
    $env:Path += ";C:\ProgramData\chocolatey"   # Add to Path just for this script session
    # To update System Path: [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\bin", "Machine")
    # To update User Path:   [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\bin", "User")

    # Boxstarter, assume ok if BoxstarterShell.ps1 is there
    Write-Host ""
    Write-Host "Test for Boxstarter, download and install if it does not currently exist" -ForegroundColor Yellow -BackgroundColor Black
    IfExistSkipCommand "C:\ProgramData\Boxstarter\BoxstarterShell.ps1" "choco upgrade -y Boxstarter"
    if (-not (Get-Module -ListAvailable 'Boxstarter.Chocolatey')) { Import-Module 'C:\ProgramData\Boxstarter\Boxstarter.Chocolatey\Boxstarter.Chocolatey.psd1' }
    # Get-Module                  # Display *loaded* modules
    # Get-Module -ListAvailable   # Display *available and NOT loaded* modules

    # PowerShell 5+
    Write-Host "Test for PowerShell, download and install if it is not at least version 5.x" -ForegroundColor Yellow -BackgroundColor Black
    if ($PSVersionTable.PSversion.Major -lt 5) { choco upgrade -y PowerShell }

    # Chocolatey add-ons, best not to install anything at this stage, but leave here as a reminder
    # Write-Host "Test for Chocolatey add-ons, download and install" -ForegroundColor Yellow -BackgroundColor Black
    # choco upgrade -y ChocoShortcuts
    # https://stackoverflow.com/questions/56728440/how-to-import-chocolatey-function-core-and-extension-to-powershell-sessions

    ####################
    # Windows 7 checks (SP1 etc, Work in progress ...)
    ####################
    # Remember internal versions: Windows 7 is "6.1", Win 8 is "6.2", Win 10 is "6.3" or something like that(!)
    # For SP0 : (Get-WmiObject -Class Win32_OperatingSystem).Version -eq 6.1.7600
    if ([Environment]::OSVersion.Version.Major -eq 6) {

        Write-Host ''
        Write-Host "`n========================================" -ForegroundColor DarkGreen
        Write-Host ''
        Write-Host 'Subsection if OS is Windows 7' -ForegroundColor DarkGreen
        Write-Host ''
        Write-Host '- Check for SP1, install if required.' -ForegroundColor DarkGreen
        Write-Host '- Check for a .NET Framework that is at least 4.5+.' -ForegroundColor DarkGreen
        Write-Host ''
        Write-Host "========================================`n" -ForegroundColor DarkGreen
        Write-Host ''

        $colOS = Get-WmiObject -class Win32_OperatingSystem -computername '.'   # $Strcomputer 
        foreach($objComp in $colOS) { 
            $OScaption = $objComp.Caption 
            $OSdescription = $objComp.Description 
            $SPversion = $objComp.ServicePackMajorVersion 
        }

        Write-Host "Rough Windows 7 checks ... work on these on vanilla Windows 7 setup ..."
        Write-Host "Win32_OperatingSystem Caption = $OScaption"
        Write-Host "Win32_OperatingSystem Description = $OSdescription"
        Write-Host "Win32_OperatingSystem ServicePackMajorVersion = $SPversion"

        # Install Service Pack 1 for Windows 7 if not present
        Write-Host ""
        Write-Host "Test for Service Pack 1, install if required ..."
        if ($SPversion -ne 1) { choco install kb976932 -y }   # Install SP1 if on Win 7 and not installed

        # Test for a version of .NET 4.x that is *at least* 4.5
        # https://stackoverflow.com/questions/3487265/powershell-script-to-return-versions-of-net-framework-on-a-machine
        $colVers = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
          Get-ItemProperty -name Version,Release -EA 0 | where { $_.PSChildName -match '^(?!S)\p{L}'} |
          Select Version
          # Select PSChildName, Version, Release

        $dotnet45required = $true
        foreach($objVer in $colVers) { 
            $version = $objVer.Version
            if ($version -match '^4\.[56789]') { $dotnet45required = $false }
        }
        Write-Host ""
        Write-Host "Test for .NET 4.5+, install if required ..."
        if ($dotnet45required -eq $true) { choco install dotnet4.5 -y }   # .NET 4.5
    }
}



####################
#
# Install selected Modules
#
####################

# Module duplication deployment with Azure DevOps:
# https://stackoverflow.com/questions/58686463/powershell-module-deployment-duplication
#
# https://github.com/PowerShell/PowerShellGet/issues/234 - discussions of hoops have to go through to remove old and install newest version
# try {
#     # If the module is already installed, use Update, otherwise use Install
#     if ([bool](Get-Module $MyModuleName -ListAvailable)){
#          Update-Module $MyModuleName -ErrorAction Stop   # -Credential $Credential
#     } else {
#          Install-Module $MyModuleName -Repository $MyRepoName -Scope CurrentUsers -ErrorAction Stop   # -Credential $Credential
#     }
# } catch {
#     # But if something went wrong, just -Force it, hard.
#     Install-Module $MyModuleName -Repository $MyRepoName -Scope CurrentUsers -Force -SkipPublisherCheck -AllowClobber   # -Credential $Credential
# }
# https://winaero.com/blog/fix-install-module-missing-powershell/


Write-Host ''
Write-Host ''
Write-Host "`n========================================" -ForegroundColor Green
Write-Host ''
Write-Host '3. Install latest versions of selected Modules' -ForegroundColor Green
Write-Host ""
Write-Host '   Install some sample PowerShell Gallery Modules.' -ForegroundColor Yellow
Write-Host '   Also install the latest Custom-Tools.psm1 Module.' -ForegroundColor Yellow
Write-Host ''
Write-Host "========================================" -ForegroundColor Green
Write-Host ''
Write-Host ""
Write-Host "fimo *code* | select Name,Description    " -ForegroundColor Yellow -NoNewLine ; Write-Host "# fimo => Find-Module. Accepts * and ? wildcards" -ForegroundColor Green
Write-Host "fimo PSCX | select *                     " -ForegroundColor Yellow -NoNewLine ; Write-Host "# Show all properties for the PSCX module" -ForegroundColor Green
Write-Host "fimo PSCX | select -expand Description   " -ForegroundColor Yellow -NoNewLine ; Write-Host "# Show all info for a single property" -ForegroundColor Green
Write-Host "inmo PSCX                      " -ForegroundColor Yellow -NoNewLine ; Write-Host "# inmo => Install-Module" -ForegroundColor Green
Write-Host "gcm -module Posh-Gist          " -ForegroundColor Yellow -NoNewLine ; Write-Host "# gcm => Get-Command" -ForegroundColor Green
Write-Host "gcm *ssh*                      " -ForegroundColor Yellow -NoNewLine ; Write-Host "# Show all commands containing 'ssh'" -ForegroundColor Green
Write-Host "Get-InstalledModule            " -ForegroundColor Yellow -NoNewLine ; Write-Host "# " -ForegroundColor Green
Write-Host "gmo -ListAvailable             " -ForegroundColor Yellow -NoNewLine ; Write-Host "# gmo => Get-Module. List all available modules on your computer" -ForegroundColor Green
Write-Host "gmo -All                       " -ForegroundColor Yellow -NoNewLine ; Write-Host "# gmo => Get-Module. List all loaded modules" -ForegroundColor Green
Write-Host '$env:PSModulePath              ' -ForegroundColor Yellow -NoNewLine ; Write-Host "# To view all module paths that are loaded" -ForegroundColor Green
Write-Host 'Remove-Module PSCX             ' -ForegroundColor Yellow -NoNewLine ; Write-Host "# Removes from current session only. Does not uninstall" -ForegroundColor Green
Write-Host 'Uninstall-Module PSCX          ' -ForegroundColor Yellow -NoNewLine ; Write-Host "# Uninstall. Cannot uninstall if other modules have this as a dependency." -ForegroundColor Green
Write-Host ""
Write-Host "All Modules that are on `$env:PSModulePath are automatically loaded in all PowerShell sessions."
Write-Host "From PowerShell 3.0 onwards, only the Module header is loaded when a console is started, and the"
Write-Host "full Module is only loaded when a function is called from it, or a '#Requires -Modules' directive" 
Write-Host "is in a script forcing it to be loaded. Can also use -Global switch to Import-Module cmdlet,"
Write-Host "to import the module into the global scope, allowing outside scripts to access their functionality."
Write-Host "http://msdn.microsoft.com/en-us/library/dd878284(v=vs.85).aspx"
Write-Host "The `$PSModulePath locations are currently:`n" ; Write-Host "$($env:PSModulePath -replace ";", "`n")" -ForegroundColor Yellow
Write-Host ""
# Write-Host "Note that as this script is running as Administrator, all of the installed Modules will be placed in:"
# Write-Host "C:\Program Files\WindowsPowerShell\Modules" -ForegroundColor Yellow
Write-Host ""

if ($PSVersionTable.PSVersion.Major -eq 2) {
    Write-Host ''
    Write-Host ''
    Write-Host "====================" -ForegroundColor Red
    Write-Host ''
    Write-Host "Import-Module Cmdlet does not exist on PowerShell v2 so Module." -ForegroundColor Red
    Write-Host "configuration will not continue. Configuration script will exit here." -ForegroundColor Red
    Write-Host "You can rerun the configuration script once PowerShell is updated." -ForegroundColor Red
    Write-Host ''
    Write-Host "====================" -ForegroundColor Red
    Write-Host ''
    Write-Host ""
    ThrowScriptErrorAndStop
}

Write-Host ""
if ($unattended -eq $false) { if ($(Confirm-Choice $confirm) -eq "no") { ThrowScriptErrorAndStop } }



# This approach is very, very fast and can be used to check against the versions of installed modules to see whether you are up-to-date.
function Get-PublishedModuleVersion($Name) {
    # access the main module page, and add a random number to trick proxies
    $url = "https://www.powershellgallery.com/packages/$Name/?dummy=$(Get-Random)"
    $request = [System.Net.WebRequest]::Create($url)
    # do not allow to redirect. The result is a "MovedPermanently"
    $request.AllowAutoRedirect=$false
    try
    {
        # send the request
        $response = $request.GetResponse()
        # get back the URL of the true destination page, and split off the version
        $response.GetResponseHeader("Location").Split("/")[-1] -as [Version]
        # make sure to clean up
        $response.Close()
        $response.Dispose()
    }
    catch
    {
        Write-Warning $_.Exception.Message
    }
}
# Get-PublishedModuleVersion -Name ISESteroids

function Install-ModuleToDirectory {
    [CmdletBinding()] [OutputType('System.Management.Automation.PSModuleInfo')]
    param(
        [Parameter(Mandatory = $true)] [ValidateNotNullOrEmpty()]                                    $Name,
        [Parameter(Mandatory = $true)] [ValidateNotNullOrEmpty()] [ValidateScript({ Test-Path $_ })] $Destination
    )

    if (!(Test-Path $UserModulePath)) { New-Item $UserModulePath -ItemType Directory -Force }

    if (($Profile -like "\\*") -and (Test-Path (Join-Path $UserModulePath $Name))) {
        if (Test-Administrator -eq $true) {
            "remove module from network share and move to $Destination"
            # Nothing in here will happen unless working on laptop with a network share
            Uninstall-Module $Name -Force -Verbose
            # Install-Module $MyModule -Scope CurrentUser -Force -Verbose   # This will *always* install to network share if in use so use Save-Module
            Find-Module -Name $Name -Repository 'PSGallery' | Save-Module -Path $Destination   # Install the module to the custom destination.
            Import-Module -FullyQualifiedName (Join-Path $Destination $Name)
        }
        else {
            Write-Host "Module found on network share module path but need to be administrator and connected to VPN" -ForegroundColor Yellow -BackgroundColor Black
            Write-Host "to correctly move Modules into the users module folder on C:\" -ForegroundColor Yellow -BackgroundColor Black
        }
    }
    elseif (Test-Path (Join-Path $AdminModulesPath $Name)) {
        if (Test-Administrator -eq $true) {
            "remove module from $AdminModulesPath and move to $Destination"
            Uninstall-Module $Name -Force -Verbose
            # Install-Module $MyModule -Scope CurrentUser -Force -Verbose   # This will *always* install to network share if in use so use Save-Module
            Find-Module -Name $Name -Repository 'PSGallery' | Save-Module -Path $Destination   # Install the module to the custom destination.
            Import-Module -FullyQualifiedName (Join-Path $Destination $Name)
        }
        else {
            Write-Host "Module found on in Admin Modules folder: $(split-path $AdminModulesPath) C:\Program Files\WindowsPowerShell\Modules." -ForegroundColor Yellow -BackgroundColor Black
            Write-Host "Need to be Admin to correctly move Modules into the users module folder on C:\" -ForegroundColor Yellow -BackgroundColor Black
        }
    }
    # Get-InstalledModule   # Shows only the Modules installed by PowerShellGet.
    # Get-Module            # Gets the modules that have been imported or that can be imported into the current session.
    elseif (Test-Path (Join-Path $Destination $Name)) {
        # https://stackoverflow.com/questions/48424152/compare-system-version-in-powershell
        # To use the repository, you either need PowerShell 5 or install the PowerShellGet module manually (which is
        # available for download on powershellgallery.com) to get Find/Save/Install/Update/Remove-Script for Modules.
        # https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/getting-latest-powershell-gallery-module-version
        # https://stackoverflow.com/questions/52633919/powershell-sort-version-objects-descending
        # "1.." -match "\b\d(\.\d{0,5}){0,3}\d$"
        # https://techibee.com/powershell/check-if-a-string-contains-numbers-in-it-using-powershell/2842
        $ModVerLocal = (Get-Module $Name -ListAvailable -EA Silent).Version
        $ModVerOnline = Get-PublishedModuleVersion $Name
        $ModVerLocal = "$(($ModVerLocal).Major).$(($ModVerLocal).Minor).$(($ModVerLocal).Build)"      # reuse the [version] variable as a [string]
        $ModVerOnline = "$(($ModverOnline).Major).$(($ModverOnline).Minor).$(($ModverOnline).Build)"  # reuse the [version] variable as a [string]
        # if ($ModuleVersionOnline -ne "") { $ModuleVersionOnline = "$($ModuleVersionOnline.split(".")[0]).$($ModuleVersionOnline.split(".")[1]).$($ModuleVersionOnline.split(".")[2])" }
        echo "Local Version:  $ModVerLocal"
        echo "Online Version: $ModVerOnline"
        if ($ModVerLocal -eq $ModVerOnline) {
            echo "$Name is installed and latest version, nothing to do!"
        }
        else {
            if ([bool](Get-Module $Name) -eq $true) { Uninstall-Module $Name -Force -Verbose }
            rm (Join-Path $Destination $Name) -Force -Recurse -Verbose
            Find-Module -Name $Name -Repository 'PSGallery' | Save-Module -Path $Destination -Force -Verbose   # Install the module to the custom destination.
            Import-Module -FullyQualifiedName (Join-Path $Destination $Name) -Force -Verbose
        }
    }
    else {   # Final case is no module is in network share, or local admin modules, or local user modules so now just install it
        Get-PublishedModuleVersion $Name
        Find-Module -Name $Name -Repository 'PSGallery' | Save-Module -Path $Destination -Force -Verbose   # Install the module to the custom destination.
        Import-Module -FullyQualifiedName (Join-Path $Destination $Name) -Force -Verbose
    }

    # Finally, output the Path to the newly installed module and the functions contained in it
    (Get-Module $Name | select Path).Path
    $out = ""; foreach ($i in (Get-Command -Module $Name).Name) {$out = "$out, $i"} ; "" ; Write-Wrap $out.trimstart(", ") ; ""
    # return (Get-Module)
}


# Force installation to User Modules, even if running as Admin. i.e. keep all installations in User space.
# Default user space location for Modules is here, but if Admin, it will try to install to C:\Program Files\WindowsPowerShell
# We want to force installation into user space, but there is no command to do this
# There is a command to force installation to AllUser space: Install-Module <Name> -Scope AllUsers
# $ModulePath = "$(Split-Path $Profile)\Modules1"   # This is where all modules must go. It should be on path (must add if required)
# $ModulePathTest = foreach ($i in ($env:PSModulePath).split(";")) { if ($i -like $ModulePath) { $True } }   # Get 
# if ($ModulePathTest -eq $null) { }   # Need to add this if not present

Write-Host "WARNING: Some errors may happen in the below as Modules might have functions that clash" -ForegroundColor Yellow -BackgroundColor Black
Write-Host "with existing Cmdlets and Functions. If so, note those that you want to force and then" -ForegroundColor Yellow -BackgroundColor Black
Write-Host "rerun with the '-AllowClobber' switch if you want to give priority to a given Module." -ForegroundColor Yellow -BackgroundColor Black
Write-Host ""
# https://www.reddit.com/r/PowerShell/comments/2l9itf/useful_module_megathread/
# https://rkeithhill.wordpress.com/2013/10/18/psreadline-a-better-line-editing-experience-for-the-powershell-console/
# https://devblogs.microsoft.com/scripting/the-search-for-a-better-powershell-console-experience/
# https://haacked.com/archive/2011/04/19/writing-a-nuget-package-that-adds-a-command-to-the.aspx/

Write-Host ''
Write-Host "Install NuGet Provider" -ForegroundColor Yellow -BackgroundColor Black
Write-Host "Note: this is required for various modules so want this at latest version (at least 2.8.5.201)."
Write-Host "Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser"
if ($PSver -gt 4) { Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser }
# Get-PackageProvider | where Name -eq "NuGet" | select Version | select -ExpandProperty Version

Write-Host '' -ForegroundColor Green
Write-Host 'General Module creation points:' -ForegroundColor Green
Write-Host '- Create a folder named with the same name as the module psm1. e.g. "MyModule"'
Write-Host '- Create a file called MyModule.psm1 in that folder to hold your functions'
Write-Host '- Use New-ModuleManifest to create a MyModule.psd1 in that folder for the metadata'
Write-Host '- Update the ModuleRoot and FunctionsToExport properties in the MyModule.psd1'
Write-Host '- #Requires -Modules Module1,Module2,... directive in scripts that require Module functions'
Write-Host 'Note: Need to put "Export-ModuleMember -Alias * -Function *" to export aliases in the Module'
Write-Host 'Note: Need to use -Force on all of the below to make sure to re=import'
Write-Host 'Extremely good overview: https://powershellexplained.com/2017-05-27-Powershell-module-building-basics/'-ForegroundColor Magenta
Write-Host ''
Write-Host ''
Write-Host "Make sure that PowerShell Gallery (which is run by Microsoft) is Trusted ..." -ForegroundColor Yellow -BackgroundColor Black
if ((Get-PSRepository -Name PSGallery).InstallationPolicy -eq 'Trusted') { "PSGallery is already Trusted" }
else {
    Write-Host "Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted"
    if ($PSver -gt 4) { Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted } else { Write-Host "Must be PV v5 or higher to run this" -ForegroundColor Red }
}

# $dependencies = @{   # Taken this hash table and Module installer from https://github.com/pauby/PSTodoWarrior/blob/master/build.ps1
#     InvokeBuild         = 'latest'
#     Configuration       = 'latest'
#     PowerShellBuild     = 'latest'
#     Pester              = 'latest'
#     PSScriptAnalyzer    = 'latest'
#     PSPesterTestHelpers = 'latest'
#     PSDeploy            = 'latest'  # Maybe pin the version in case he breaks this...
#     PSTodoTxt           = 'latest'
# }
# 
# # Dependencies
# if (-not (Get-Command -Name 'Get-PackageProvider' -EA silent)) {
#     $null = Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser
#     Write-Verbose 'Bootstrapping NuGet package provider.'
#     Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null
# } elseif ((Get-PackageProvider).Name -notcontains 'nuget') {
#     Write-Verbose 'Bootstrapping NuGet package provider.'
#     Get-PackageProvider -Name NuGet -ForceBootstrap
# }
# 
# # Trust the PSGallery is needed
# if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
#     Write-Verbose "Trusting PowerShellGallery."
#     Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
# }

Write-Host ''
Write-Host "Install-Module PSReadLine" -ForegroundColor Yellow -BackgroundColor Black
# Write-Host "   Out-Default"
Write-Host "View Module Contents: " -NoNewLine ; Write-Host "get-command -module psreadline" -ForegroundColor Yellow
Write-Host "Note: this is installed by default on Windows 10 but not on Windows 7. It is required for many"
Write-Host "console functions:"
Write-Host " - History searches with Ctrl+R."
Write-Host " - Type part of a command then F8 to see go to last matching command."
Write-Host " - Ctrl+Alt+Shif+? to see all PSReadLine shortcuts."
Write-Host "For Windows 10, there is nothing to do, but for Windows 7 (even with PowerShell 5.1)"
Write-Host "it must also be loaded into every session (unlike Windows 10 where it loads by default)."
Write-Host "A line in the profile extensions tests for Win 7 then imports PSReadLine if required."
if (-not (Get-Module -ListAvailable PSReadLine)) { 
    if ($PSver -gt 4) {
        Install-Module PSReadLine -Scope CurrentUser -Force -Verbose 
    }
    else {
        Write-Host "Need to be on PS v5 or higher to run 'Install-Module PSReadLine'" -ForegroundColor Red
    }
}
Import-Module PSReadLine -Scope Local -EA Silent
$x = ""; foreach ($i in (get-command -module PSReadLine).Name) {$x = "$x, $i"} ; "" ; Write-Wrap $x.trimstart(", ") ; ""

Write-Host ''
Write-Host "Install-Module PSScriptAnalyzer (Script Analysis Tool)" -ForegroundColor Yellow -BackgroundColor Black
# Write-Host "   Get-ScriptAnalyzerRule, Invoke-Formatter, Invoke-ScriptAnalyzer"
Write-Host "View Module Contents: " -NoNewLine ; Write-Host "get-command -module posh-gist" -ForegroundColor Yellow
# if (-not (Get-Module -ListAvailable PSScriptAnalyzer)) { Install-Module PSScriptAnalyzer -Scope CurrentUser -Force -Verbose }
Install-ModuleToDirectory PSScriptAnalyzer $UserModulePath

Write-Host ''
Write-Host "Install-Module Sudo" -ForegroundColor Yellow -BackgroundColor Black
# Write-Host "   New-SudoSession, Remove-SudoSession, Restore-OriginalSystemConfig, Start-SudoSession"
Write-Host "View Module Contents: " -NoNewLine ; Write-Host "get-command -module sudo" -ForegroundColor Yellow
# if (-not (Get-Module -ListAvailable Sudo)) { Install-Module Sudo -Scope CurrentUser -Force -Verbose }
Install-ModuleToDirectory Sudo $UserModulePath

Write-Host ''
Write-Host "Install-Module Posh-Git (Git Management Cmdlets)" -ForegroundColor Yellow -BackgroundColor Black
# Write-Host "   Add-PoshGitToProfile, Add-SshKey, Enable-GitColors, Expand-GitCommand, Get-AliasPattern,"
# Write-Host "   Get-GitBranch, Get-GitDirectory, Get-GitStatus, Get-PromptPath, Get-SshAgent, Get-SshPath,"
# Write-Host "   Invoke-NullCoalescing, Start-SshAgent, Stop-SshAgent, TabExpansion, tgit, Update-AllBranches,"
Write-Host "Write-GitStatus, Write-Prompt, Write-VcsStatus"
Write-Host "View Module Contents: " -NoNewLine ; Write-Host "get-command -module posh-git" -ForegroundColor Yellow
# if (-not (Get-Module -ListAvailable Posh-Git)) { Install-Module Posh-Git -Scope CurrentUser -Force -Verbose }
Install-ModuleToDirectory Posh-Git $UserModulePath

Write-Host ''
Write-Host "Install-Module Posh-Gist (Gist Management Cmdlets)" -ForegroundColor Yellow -BackgroundColor Black
# Write-Host "   Get-Gist, Get-GistCommits, Get-GistStar, New-Gist, Remove-Gist, Update-Gist"
Write-Host "View Module Contents: " -NoNewLine ; Write-Host "get-command -module posh-gist" -ForegroundColor Yellow
# if (-not (Get-Module -ListAvailable Posh-Gist)) { Install-Module Posh-Gist -Scope CurrentUser -Force -Verbose }
Install-ModuleToDirectory Posh-Gist $UserModulePath

Write-Host ''
Write-Host "Install-Module PowerShellForGitHub   # (GitHub Management Cmdlets)" -ForegroundColor Yellow -BackgroundColor Black
Write-Host "This is a PowerShell module that provides command-line interaction and automation for the GitHub v3 API."
Write-Host "https://github.com/microsoft/PowerShellForGitHub/blob/master/USAGE.md#examples"
Write-Host "http://stevenmaglio.blogspot.com/2019/08/powershellforgithubadding-get.html"
Write-Host "https://wilsonmar.github.io/powershell-github/"
Write-Host "https://hant.kutu66.com/GitHub/article_142903 (need to translate)"
Write-Host "View Module Contents: " -NoNewLine ; Write-Host "get-command -module PowerShellForGitHub" -ForegroundColor Yellow
Install-ModuleToDirectory PowerShellForGitHub $UserModulePath

Write-Host ''
Write-Host "Install-Module Posh-SSH (SSH Cmdlets)" -ForegroundColor Yellow -BackgroundColor Black
# Write-Host "   Get-PoshSSHModVersion, Get-SFTPChildItem, Get-SFTPContent, Get-SFTPLocation, Get-SFTPPathAttribute,"
# Write-Host "   Get-SFTPSession, Get-SSHPortForward, Get-SSHSession, Get-SSHTrustedHost, Invoke-SSHCommand,"
# Write-Host "   Invoke-SSHCommandStream, Invoke-SSHStreamExpectAction, Invoke-SSHStreamExpectSecureAction,"
# Write-Host "   Invoke-SSHStreamShellCommand, Move-SFTPItem, New-SFTPFileStream, New-SFTPItem, New-SFTPSymlink,"
# Write-Host "   New-SSHDynamicPortForward, New-SSHLocalPortForward, New-SSHRemotePortForward, New-SSHShellStream,"
# Write-Host "   New-SSHTrustedHost, Remove-SFTPItem, Remove-SFTPSession, Remove-SSHSession, Remove-SSHTrustedHost,"
# Write-Host "   Rename-SFTPFile, Set-SFTPContent, Set-SFTPLocation, Set-SFTPPathAttribute, Start-SSHPortForward,"
# Write-Host "   Stop-SSHPortForward, Test-SFTPPath, Get-SCPFile, Get-SCPFolder, Get-SCPItem, Get-SFTPFile,"
# Write-Host "   Get-SFTPItem, New-SFTPSession, New-SSHSession, Set-SCPFile, Set-SCPFolder, Set-SCPItem, Set-SFTPFile,"
# Write-Host "   Set-SFTPFolder, Set-SFTPItem"
Write-Host "View Module Contents: " -NoNewLine ; Write-Host "get-command -module posh-ssh" -ForegroundColor Yellow -NoNewline ; Write-Host "   # fimo *ssh* for other SSH tools" -ForegroundColor Green
# if (-not (Get-Module -ListAvailable Posh-SSH)) { Install-Module Posh-SSH -Scope CurrentUser -Force -Verbose }
# (gcm -mod posh-ssh | select Name | % { $_.Name + "," } | Out-String).replace("`r`n", " ").trim(", ")
Install-ModuleToDirectory Posh-SSH $UserModulePath

Write-Host ''
Write-Host "Install-Module PSColor (Color Get-ChildItem / gci / dir / ls output)" -ForegroundColor Yellow -BackgroundColor Black
# Write-Host "   Out-Default"
Write-Host "View Module Contents: " -NoNewLine ; Write-Host "get-command -module pscolor" -ForegroundColor Yellow
Write-Host "Note: modifies Out-Default, so do not import by default, have setup 'color' function"
Write-Host "in profile extensions to activate this when required."
# if (-not (Get-Module -ListAvailable PSColor)) { Install-Module PSColor -Scope CurrentUser -Force -Verbose }
Install-ModuleToDirectory PSColor $UserModulePath

Write-Host ''
Write-Host "Install-Module Windows-ScreenFetch (System Utility)" -ForegroundColor Yellow -BackgroundColor Black
Write-Host "View Module Contents: " -NoNewLine ; Write-Host "get-command -module windows-screenfetch" -ForegroundColor Yellow
# if (-not (Get-Module -ListAvailable Windows-ScreenFetch)) { Install-Module Windows-ScreenFetch -Scope CurrentUser -Force -Verbose }
Install-ModuleToDirectory Windows-ScreenFetch $UserModulePath

Write-Host ''
Write-Host "Install-Module HistoryPx -AllowClobber (Enhanced Get-History tools)" -ForegroundColor Yellow -BackgroundColor Black
# Write-Host "   Get-CaptureOutputConfiguration, Get-ExtendedHistoryConfiguration, Set-CaptureOutputConfiguration"
# Write-Host "   Set-ExtendedHistoryConfiguration, Clear-History, Get-History, Out-Default"
Write-Host 'HistoryPx uses proxy commands to add extended history information to'
Write-Host 'PowerShell. This includes the duration of a command, a flag indicating whether'
Write-Host 'a command was successful or not, the output generated by a command (limited to'
Write-Host 'a configurable maximum value), the error generated by a command, and the'
Write-Host 'actual number of objects returned as output and as error records.  HistoryPx'
Write-Host 'also adds a "__" variable to PowerShell that captures the last output that you'
Write-Host 'may have wanted to capture, and includes commands to configure how it decides'
Write-Host 'when output should be captured.  Lastly, HistoryPx includes commands to manage'
Write-Host 'the memory footprint that is used by extended history information.'
Write-Host "View Module Contents: " -NoNewLine ; Write-Host "gcm -module historypx" -ForegroundColor Yellow

Write-Host "https://poshoholic.com/2014/10/30/making-history-more-fun-with-powershell/"
Write-Host "https://poshoholic.com/2014/10/21/transform-repetitive-script-blocks-into-invocable-snippets-with-snippetpx/"
Write-Host "https://poshoholic.com/2014/10/31/raise-your-powershell-game-with-historypx-debugpx-and-typepx/"
# if (-not (Get-Module -ListAvailable HistoryPx)) { Install-Module HistoryPx -AllowClobber -Scope CurrentUser -Force -Verbose }
Install-ModuleToDirectory HistoryPx $UserModulePath

Write-Host ''
Write-Host "Example of querying Modules" -ForegroundColor Yellow -BackgroundColor Black
Write-Host "Sort all available module sorting by version (which is 'Name' field in this view)"
Write-Host "Get-Module -ListAvailable | group version | sort Name -Descending" -ForegroundColor Yellow
#            Get-Module -ListAvailable | group version | sort Name -Descending | Out-Host
Write-Host ''
Write-Host ''
Write-Host "To show more info for those at 2.0.0.0"
Write-Host "Get-Module -ListAvailable | ? { `$_.Version -eq '2.0.0.0' }" -ForegroundColor Yellow
#            Get-Module -ListAvailable | ? { $_.version -eq '2.0.0.0' } | select Version,Name | sort -Descending | ft | Out-Host
Write-Host "More info on commands in a specific module from this view (e.g. the VpnClient Module):"
Write-Host "Get-Command -Module VpnClient | ft" -ForegroundColor Yellow
#            Get-Command -Module VpnClient | ft | Out-Host





# Download various scripts to the $Profile Scripts folder
Write-Host ''
Write-Host ''
Write-Host "`n========================================" -ForegroundColor Green
Write-Host ''
Write-Host '4. Downoad latest versions of online scripts.' -ForegroundColor Green
Write-Host ''
Write-Host '   Place in the default PowerShell script folder and add to path' -ForegroundColor Yellow
Write-Host '   making them fully usable in any console. Can add more scripts' -ForegroundColor Yellow
Write-Host '   easily to be deployed to all systems at setup as required.' -ForegroundColor Yellow
Write-Host "   C:\Users\$env:Username\Documents\WindowsPowerShell\Scripts" -ForegroundColor Cyan
Write-Host ''
Write-Host "========================================`n" -ForegroundColor Green
Write-Host ""

# $UserScriptsPath = "$(Split-Path $Profile)\Scripts"   # Old path was "C:\ProgramData\Scripts"
mkdir $UserScriptsPath -Force | Out-Null

$RegistrySystemPath = 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment'   # System
$RegistryUserPath = "HKCU:\Environment"
$PathOld = (Get-ItemProperty -Path $RegistryUserPath -Name PATH).Path
$PathArray = $PathOld -Split ";" -replace "\\+$", ""

$FoundPath = 0
foreach ($Path in $PathArray) {
    if ($Path -contains $UserScriptsPath ) {
        $FoundPath = 1
    }
}

if ($FoundPath -eq 0) {
    $PathNew = $PathOld + ";" + $UserScriptsPath
    Set-ItemProperty -Path $RegistryUserPath -Name PATH -Value $PathNew
    (Get-ItemProperty -Path $RegistryUserPath -Name PATH).Path
}

function Download-Script ($url) {
    $FileName = ($url -split "/")[-1]   # Could also use:  $url -split "/" | select -last 1   # 'hi there, how are you' -split '\s+' | select -last 1
    $OutPath = Join-Path $UserScriptsPath $FileName 
    Write-Host "Downloading  $FileName to $OutPath ..."
    try { (New-Object System.Net.WebClient).DownloadString($url) | Out-File $OutPath }
    catch { "Could not download $FileName ..." }
}

# function Download-Script ($url, $FinalName) {
#     if ($url -eq '') { "Require URL to perform download." ; break}
#     $DownloadName = ($url -split "/")[-1]   # Could also use:  $url -split "/" | select -last 1   # 'hi there, how are you' -split '\s+' | select -last 1
#     $OutPath = Join-Path $ScriptsPath $DownloadName
#     "Checking for '$OutPath' ..."
#     if ($null -eq $FinalName) { $FinalName = $DownloadName }
#     if (!(Test-Path "$ScriptsPath\$DownloadName") -and !(Test-Path "$ScriptName\$FinalName")) {
#         "Downloading '$DownloadName' to '$OutPath' ..."
#         try { (New-Object System.Net.WebClient).DownloadString($url) | Out-File $OutPath }
#         catch { "Failed to download $FileName. Check internet connection, particularly TLS / VPN." }
#         if ($FinalName -ne "") {
#             if (Test-Path "$ScriptsPath\$DownloadName") {
#                 if (Test-Path "$ScriptPath\$FinalName") { Move-Item }
#                 Move-Item "$ScriptsPath\$DownloadName" "$ScriptsPath\$FinalName" -Force
#                 "Renamed '$DownloadName' to '$FinalName'" 
#            }
#         }
#     }
# }

# Can also install scripts with the *-Script Cmdlets
# Install-Script, Find-Script, Publish-Script, Save-Script, Uninstall-Script, Update-Script
# -Scope AllUsers    => C:\Program Files\WindowsPowerShell\Scripts
# -Scope CurrentUser => C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Scripts *or* ING VPN
# Due to the Corporate VPN issue, use the "Find-Script | Save-Script trick"
$UserScripts = "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Scripts"

Download-Script 'https://gallery.technet.microsoft.com/scriptcenter/Powershell-function-to-add-a7ac5229/file/166758/1/Add-Path.ps1'
# https://superwidgets.wordpress.com/2017/01/04/powershell-script-to-report-on-computer-inventory/

Download-Script 'https://gallery.technet.microsoft.com/scriptcenter/Powershell-Script-to-ping-15e0610a/file/127965/4/Ping-Report-v3.ps1'
if (Test-Path "$UserScriptsPath\Ping-Report-v3.ps1") { Move-Item "$UserScriptsPath\Ping-Report-v3.ps1" "$UserScriptsPath\Ping-Report.ps1" -Force }   # remove the -v3 from filename

Download-Script 'https://gallery.technet.microsoft.com/scriptcenter/Fast-asynchronous-ping-IP-d0a5cf0e/file/124575/1/Ping-IPrange.ps1'

# mklement0 Tools: https://gist.github.com/mklement0/146f3202a810a74cb54a2d353ee4003f
#    function Show-OperatorHelp { / function Show-TypeHelp { , Shows documentation for built-in .NET types, etc
Download-Script 'https://gist.githubusercontent.com/mklement0/146f3202a810a74cb54a2d353ee4003f/raw/044746494a61c212cad196a1a12c086e826ba719/Show-OperatorHelp.ps1'
Download-Script 'https://gist.githubusercontent.com/mklement0/50a1b101cd53978cd147b4b138fe6ef4/raw/9c4dfd2878dfdf8d74eccae707183cdfe536f436/Show-TypeHelp.ps1'
Download-Script 'https://gallery.technet.microsoft.com/scriptcenter/Check-for-Key-Presses-with-7349aadc/file/148286/2/Test-KeyPress.ps1'

# Set-Window.ps1
Download-Script 'https://gallery.technet.microsoft.com/scriptcenter/Set-the-position-and-size-54853527/file/146291/1/Set-Window.ps1'

# ConsoleArt demonstration script
Download-Script 'https://gist.github.com/shanenin/f164c483db513b88ce91/raw'
if (Test-Path "$UserScriptsPath\raw") { Move-Item "$UserScriptsPath\raw" "$UserScriptsPath\ConsoleArt.ps1" -Force }


# Registry 
# Download-Script 'https://gallery.technet.microsoft.com/scriptcenter/Get-RegistryKeyLastWriteTim-63f4dd96/file/131343/1/Get-RegistryKeyLastWriteTime.ps1'
# try { Find-Script Get-RegistryKey | Save-Script -Path $UserScripts } catch { "Could not connect to PSGallery for Get-ReistryKey.ps1"}

### First run of Install-Script does the following:
# PATH Environment Variable Change
# Your system has not been configured with a default script installation path yet, which means you can only run a
# script by specifying the full path to the script file. This action places the script into the folder 'C:\Program
# Files\WindowsPowerShell\Scripts', and adds that folder to your PATH environment variable. Do you want to add the
# script installation path 'C:\Program Files\WindowsPowerShell\Scripts' to the PATH environment variable?
# [Y] Yes  [N] No  [S] Suspend  [?] Help (default is "Y"): y


# ToDo: Archive all downloaded scripts in case links are broken
# ToDo: add try / throw for failure on download





Write-Host ''
Write-Host ''
Write-Host "`n========================================" -ForegroundColor Green
Write-Host ''
Write-Host '5. Install-BoxstarterPackage installations.' -ForegroundColor Green
Write-Host ""
Write-Host '   Call online script using Boxstarter to run through chocolately packages,' -ForegroundColor Yellow
Write-Host '   registry updates package installs and other system configuration tasks.' -ForegroundColor Yellow
Write-Host '   As using Boxstarter for this, the process will perform reboots when required.' -ForegroundColor Yellow
Write-Host ''
Write-Host "========================================`n" -ForegroundColor Green
Write-Host ""
Write-Host " Work in progress ..."
Write-Host " We might still be running in PowerShell v2 at this point which is not ideal."
Write-Host " Possible workaround: create a file in startup that kicks of the"
Write-Host " Install-BoxstarterPackage <url> after a reboot at this point. This can then"
Write-Host " handle all other tasks, windows updates, chocolatey package installs etc as"
Write-Host " the powershell session will come up in v5.1 after reboot and then it will be"
Write-Host " easier. But I don't know if this is the right approach ... would be good to"
Write-Host " get feedback from the Boxstarter maintainers."
Write-Host ""
Write-Host " How in general can I restart Things to get into v5.1, or, should I just run"
Write-Host " Boxstarter here and it will gracefully move from v2 to v5.1 as part of its"
Write-Host " normal operation? Need to test unless someone can advise me on that."
Write-Host ""
Write-Host ""
Write-Host "End of configuration" -ForegroundColor Red -BackgroundColor White
Write-Host ""
Write-Host ""


if (Get-Command Help-ToolkitConfig -EA Silent) { Help-ToolkitConfig }   # Show the release notes held in Custom-Tools
Write-Host ""
Write-Host ""
Write-Host "Run 'Help-ToolkitConfig' to review the above notes."
Write-Host ""
Write-Host "Run 'Help-ToolkitCoreApps' to review important system apps to install."
Write-Host ""
# Clean up TEMP folder - no, don't do this, in case the scripts were deliberately run from this location
# if (Test-Path "$env:TEMP\BeginSystemConfig.ps1") { Remove-Item "$env:TEMP\BeginSystemConfig.ps1" -Force }
# if (Test-Path "$env:TEMP\ProfileExtensions.ps1") { Remove-Item "$env:TEMP\ProfileExtensions.ps1" -Force }
# if (Test-Path "$env:TEMP\Custom-Tools.psm1")     { Remove-Item "$env:TEMP\Custom-Tools.psm1" -Force }

$hr = (Get-Date).Subtract($start_time).Hours ; $min = (Get-Date).Subtract($start_time).Minutes ; $sec = (Get-Date).Subtract($start_time).Seconds
if ($hr -ne 0) { $times += "$hr hr " } ; if ($min -ne 0) { $times += "$min min " } ; $times += "$sec sec"
"`nScript took $times to complete.`n"   # $((Get-Date).Subtract($start_time).TotalSeconds)

if ( $MyInvocation.InvocationName -eq 'BeginSystemConfig.ps1') { "`nWarning: Toolkit configuration was not dotsourced, so ProfileExtensions will not be active. Either restart a new PowerShell session or rerun as dotsourced:`n`n   . BeginSystemConfig.ps1`n" }
