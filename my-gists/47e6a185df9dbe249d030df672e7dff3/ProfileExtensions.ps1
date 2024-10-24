########################################
#
# ProfileExtensions.ps1
#
# The profile extensions is normally called by a single line that is added to
# the end of $Profile, or can be dotsourced manually if required.
#
# The handler line in $Profile performs the following:
# a) It check if $($Profile)_extensions.ps1 exists, if not download it.
# b) It then runs (dotsource) $($Profile)_extensionss.ps1.
#
# Core Notes:
# Do not inject notifications into the console at start time as remember that
# this will be called when all scripts run. Make sure that these extensions always
# have a less than one second load time, anything more complex should be pushed 
# into the Custom-Tools.psm1 Module. Make sure to note the switches to use when
# running scripts, to save on memory overheads:
# -NoProfile -NoLogo (see about_PowerShell.exe)
# Do not migrate gist-functions into custom-tools as they are dependent upon my
# specific GitHub account access, have to keep things generic.
#
# Using the handler line in $Profile allows keeping this set of tools completely
# separate from $Profile so that it can be replaced / updated at any time and
# disabling it is as simple as removing the single line that calls the extensions.
#
# Intent is to only keep core console functionality functions in here that relate
# to these tools (so things like Update-ProfileExtensions would go here) and then
# putting other more complex tools into the Custom-Tools.psm1 Module.
#
########################################

# https://mikefrobbins.com/2015/03/31/powershell-advanced-functions-can-we-build-them-better-with-parameter-validation-yes-we-can/
# Module loading issues: # https://stackoverflow.com/questions/50874428/powershell-loading-modules-inside-of-a-module-scope
# somehow a function to replace more with out-host compatible, function morx { Out-Host -Paging }   # helps with things like terminal-icons
# large things could be downloaded as externalscripts from gists repeatedly! like mklmerts
# sys function throws errors about a registry key (plus fix the CPU stuff in general)
# BackupRoboZeroSize src dst (use standard flags to backup with zerosize)

# Add things to the path that are useful / generic
# e.g. Find the newest .NET framework, check if on path, and if not, add it (to get csc.exe etc on path), same for C:\CmdTools, D:\CmdTools etc etc
# Check latest .NET version: https://help.bittitan.com/hc/en-us/articles/115008111067-How-do-I-check-which-version-of-NET-Framework-I-have-installed-
# $last = "empty" ; foreach ($i in $(dir -attrib d)) { if (Test-Path "$i\csc.exe") { $last = echo $i.Name } }
# setx /M PATH "%PATH%;C:\Windows\Microsoft.NET\Framework\v4.0.30319"

# if Wnidows 7 import PSReadLine as it is not auto-loaded (but is on Windows 10) # https://www.faqforge.com/powershell/get-operating-system-details-powershell/
if ((Get-WMIObject win32_operatingsystem).name -like "*Windows 7*") {Import-Module PSReadLine}

# Variables, create HomeFix in case of network shares (as always want to use C:\ drive, so get the name (Leaf) from $HOME)
$HomeFix = $HOME
$HomeLeaf = split-path $HOME -leaf   # Just get the correct username in spite of any changes to username!
if ($HomeFix -like "\\*") { $HomeFix = "C:\Users\$(Split-Path $HOME -Leaf)" }
# The default Modules and Scripts paths are not created by default in Windows
if (!(Test-Path $HomeFix)) { md $HomeFix -Force -EA silent | Out-Null }
if (!(Test-Path "$HomeFix\Documents\WindowsPowerShell\Modules")) { md "$HomeFix\Documents\WindowsPowerShell\Modules" -Force -EA silent | Out-Null }
if (!(Test-Path "$HomeFix\Documents\WindowsPowerShell\Scripts")) { md "$HomeFix\Documents\WindowsPowerShell\Scripts" -Force -EA silent | Out-Null }
$CustomToolsPath = "$HomeFix\Documents\WindowsPowerShell\Modules\Custom-Tools\Custom-Tools.psm1"

# Running myfunctions will display functions created since the start of the session (i.e. all user-defined functions)
# Keep this at start of the profile extension so that it captures functions in here.
$sysfunctions = gci function:
function MyFunctions {
    "`nTo get help on these functions, use 'def <function-name>', or 'm <function-name>'"
    "Note: If MyFunctions is empty, it usually means that ProfileExtensions has been dotsourced inside this console session`n"
    if (Test-Path $CustomToolsPath) { Import-Module -FullyQualifiedName $CustomToolsPath }
    $myfunctions = (gci function: | where { $sysfunctions -notcontains $_ } | select Name).Name
    $out = ""; foreach ($i in $myfunctions) {$out = "$out, $i"} ; "" ; Write-Wrap $out.trimstart(", ") ; ""
}
Set-Alias mf MyFunctions -Description "Shows all functions defined within the current session"

# This alternative to find user function just parses $profile (so the above method is a lot better) but this is useful for the regex part
# Function Get-MyCommands {
#     Get-Content -Path $profile | Select-String -Pattern "^function.+" | ForEach-Object {
#         [Regex]::Matches($_, "^function ([a-z.-]+)","IgnoreCase").Groups[1].Value
#     } | Where-Object { $_ -ine "prompt" } | Sort-Object
# }
# Running myvars will display variabls created since the start of the session (i.e. all user-defined variables)
# Keep this at start of the profile extension so that it captures variables at session start.

# $AutomaticVariables = Get-Variable
# function cmpv {
#     Compare-Object (Get-Variable) $AutomaticVariables -Property Name -PassThru | Where -Property Name -ne "AutomaticVariables"
# }
# https://4sysops.com/archives/display-and-search-all-variables-of-a-powershell-script-with-get-variable/

$sysvariables = gci variable:
# Display all variables defined in this PowerShell session
function myvars {
    Write-Host ""
    Write-Host "Show all PowerShell vars : variable  or  gci variable:  (or, e.g. gci variable:s* (starting with s etc)" -F Yellow
    Write-Host "Show all Environment vars: env  or  gci env:            (or, e.g. gci env:s* (starting with s etc)`n" -F Yellow
    Write-Host 'Get-Variable |%{ "Name : {0}`r`nValue: {1}`r`n" -f $_.Name,$_.Value }'
    Write-Host "https://stackoverflow.com/questions/12465989/list-all-previously-loaded-powershell-variables`n"
    gci variable: | where {
        $sysvariables -notcontains $_ -and $_.Name -ne 'sysvariables' -and $_.Name -ne 'args' -and $_.Name -ne 'input' -and `
        $_.Name -ne 'MaximumAliasCount' -and $_.Name -ne 'MaximumDriveCount' -and $_.Name -ne 'MaximumErrorCount' -and $_.Name -ne 'MaximumFunctionCount' -and $_.Name -ne 'MaximumVariableCount' -and `
        $_.Name -ne 'MyInvocation' -and $_.Name -ne 'PSBoundParameters' -and $_.Name -ne 'PSCommandPath' -and $_.Name -ne 'PSScriptRoot'
    }
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

function Get-ProfileFunctions {
    Write-Host "Functions in profile:`n" -F Yellow
    Get-Content -Path "$($profile)_extensions.ps1" | Select-String -Pattern "^function" | ForEach-Object {   # "^function.+"
        $functionName = ($_ -split "{")[0] -replace "function ", ""
        $functionParam = ($_ -split "\(")   # (($_ -split "(")[1] -split ")")[0]
        $functionComment = ($_ -split "   # ")[1]
        echo "$functionName $functionParam $functionComment"
    }
}

# Test if the current session is elevated
function Test-Admininstrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
Set-Alias Test-Admin Test-Admininstrator

function Get-Uptime {
    $wmi = gwmi -class Win32_OperatingSystem -computer "."
    $LBTime = $wmi.ConvertToDateTime($wmi.Lastbootuptime)
    [TimeSpan]$uptime = New-TimeSpan $LBTime $(get-date)
    $s = "" ; if ($uptime.Days -ne 1) {$s = "s"}
    return "$($uptime.days) day$s $($uptime.hours) hr $($uptime.minutes) min $($uptime.seconds) sec"
}
Set-Alias -Name uptime -Value Get-Uptime
# Alternative for uptime, could be useful as supports WinRM remote connections
#     param([parameter(Mandatory=$false)][string]$computer=".")
#     # $computer = read-host "Please type in computer name you would like to check uptime on"
#     $lastboottime = (Get-WmiObject -Class Win32_OperatingSystem -computername $computer).LastBootUpTime
#     $sysuptime = (Get-Date) - [System.Management.ManagementDateTimeconverter]::ToDateTime($lastboottime)
#     Write-Host "$computer has been up for: " $sysuptime.days "days" $sysuptime.hours "hours" $sysuptime.minutes "minutes" $sysuptime.seconds "seconds"

function Write-Wrap {
    <#
    .SYNOPSIS
    wraps a string or an array of strings at the console width without breaking within a word
    # Was called Word-Wrap originally!
    .PARAMETER chunk
    a string or an array of strings
    .EXAMPLE
    word-wrap -chunk $string
    .EXAMPLE
    $string | word-wrap
    .LINK
    https://stackoverflow.com/questions/1059663/is-there-a-way-to-wordwrap-results-of-a-powershell-cmdlet
    #>
    [CmdletBinding()]
    Param ( 
        [parameter (Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Object[]] $chunk
    )
    # PROCESS block is always mandatory for proper pipeline usage, but BEGIN / END are optional to run-once at start / end of invocation.
    # PROCESS is used to specify the code that will continually execute on every object that might be passed to the function.
    # [parameter (Mandatory=1,ValueFromPipeline=1,ValueFromPipelineByPropertyName=1)]
    # https://www.sapien.com/blog/2019/05/13/advanced-powershell-functions-begin-to-process-to-end/
    PROCESS {
        $Lines = @()
        foreach ($line in $chunk) {
            $str = ''
            $counter = 0
            $line -split '\s+' | %{
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



# Quite often have to check TLS settings for uploading to git etc
function TLS12 {
    "Before [Net.ServicePointManager]::SecurityProtocol is " + $([Net.ServicePointManager]::SecurityProtocol)
    "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    "After  [Net.ServicePointManager]::SecurityProtocol is " + $([Net.ServicePointManager]::SecurityProtocol)
}
function TLS {
    "Before [Net.ServicePointManager]::SecurityProtocol is " + $([Net.ServicePointManager]::SecurityProtocol)
    "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls
    "After  [Net.ServicePointManager]::SecurityProtocol is " + $([Net.ServicePointManager]::SecurityProtocol)
}
function Get-SecurityProtocol { [Net.ServicePointManager]::SecurityProtocol }   # Show TLS / SLS



####################
#
# Make sure to always dot-source this or changes will not update in the current session.
# . Update-ProfileExtensions
# . Update-CustomTools
# . pect   # Combination of Update-ProfileExtensions and Update-Custom-Tools
#
# Get-GistProject is a helper function to locate the most likely source folder.
# PromptDefault is another helper function to always reset the Prompt to PowerShell defaults.
# This is done as if ProfileExtensions.ps1 / Custom-Tools.ps1 have errors in them, the
# Prompt can be wiped. This corrects that.
#
# This has to remain in the ProfileExtensions to be able to quickly update and test these
# as if Custom-Tools breaks through changes, it will not be possible to recover.
#
####################

function PromptDefault {
    # get-help about_Prompt
    # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_prompts?view=powershell-7
    function global:prompt {
        "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) ";
        # .Link
        # https://go.microsoft.com/fwlink/?LinkID=225750
        # .ExternalHelp System.Management.Automation.dll-help.xml

        $Elevated = ""
        $user = [Security.Principal.WindowsIdentity]::GetCurrent();
        if ((New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {$Elevated = "Administrator: "}
        # $TitleVer = "PS v$($PSVersionTable.PSversion.major).$($PSVersionTable.PSversion.minor)"
        $TitleVer = "PowerShell"
        $Host.UI.RawUI.WindowTitle = "$($Elevated)$($TitleVer)"
    }
}

function Get-GistProject {
    # Try to find a folder with the source files to update them
    $ProjectRoot = ""
    # The last in the list will take precedence. Ideally, should keep the files in the first two, so the last
    # two folders take precedence since they should only be there if really needed).
    if (Test-Path "D:\0 Cloud\OneDrive\Gist") { $ProjectRoot = "D:\0 Cloud\OneDrive\Gist" }
    if (Test-Path "$HomeFix\Gist") { $ProjectRoot = "$HomeFix\Gist" }   # If laptop has no D: drive for OneDrive
    if (Test-Path "C:\0\Gist") { $ProjectRoot = "C:\0\Gist" }           # ING laptop, try not to use
    if (Test-Path "D:\Gist") { $ProjectRoot = "D:\Gist" }               # Tmporary location, try not to use
    if ($null -eq $ProjectRoot) { "No Gist setup folder was found, cannot be run from this system." ; break }
    return $ProjectRoot
}

function Update-ProfileExtensions {
    # Update and dotsource the latest profile extensions (local if available, or download)
    $jumpfrom = Get-Location   # Save the current location
    $ProjectRoot = Get-GistProject
    Set-Location $ProjectRoot
    ""
    "About to update the Profile Extensions for $profile :"
    ""
    "Previous directory:  $jumpfrom"
    "Current directory:   $ProjectRoot"
    "Previous directory will be returned to after Toolkit configuration completes."

    # Create $Profile if it does not exist for this host (could be in VS Code or ISE etc)
    if (!(Test-Path $(Split-Path $Profile))) { New-Item -Type Directory $(Split-Path $Profile) }
    if (!(Test-Path $Profile)) { New-Item -Type File $Profile }
   
    $ProfileExtensions = "$($Profile)_extensions.ps1"
    $UrlProfileExtensions = 'https://gist.github.com/roysubs/c37470c98c56214f09f0740fcb21ec4f/raw'
    
    function BackupProfile {
        if (Test-Path ($ProfileExtensions)) {
            Write-Host "`nCreating backup of existing profile extensions ..."
            Copy-Item -Path "$($ProfileExtensions)" -Destination "$($ProfileExtensions)_$(Get-Date -format "yyyy-MM-dd__hh-mm-ss").txt"
        }
    }

    if (Test-Path ".\ProfileExtensions.ps1") {
        Write-Host "`nProfileExtensions.ps1 found in current directory, so will use this file ..."
        BackupProfile
        Copy-Item ".\ProfileExtensions.ps1" "$($ProfileExtensions)" -Force

    } else {
        $updateonline = read-host "No local file found, download latest Profile Extensions from internet (default is y) (y/n)? "
        if ($updateonline -eq 'y' -or $updateonline -eq '') {
            Update-Help -ErrorAction SilentlyContinue   # Use erroraction silentl here as it's very common for some of the modules to fail to update, just ignore that
            BackupProfile
            try {
                (New-Object System.Net.WebClient).DownloadString("$UrlProfileExtensions") | Out-File "$($Profile)_extensions.ps1"
                Write-Host "`nDownload completed ..." -F Green
                Write-Host "Profile Extensions are at:"
                Write-Host $ProfileExtensions -F Yellow
            } catch {
                Write-Host "`nCould not download profile extensions, check internet/TLS before trying again." -ForegroundColor Red
            }
        }
    }

    Write-Host "`nCheck profile extensions handler line is in `$Profile ...`n"
    # Remove it if it exsts
    Set-Content -Path $profile -Value (Get-Content -Path $profile | Select-String -Pattern '^if \(\!\(Test-Path \("\$\(\$Profile\)_extensions\.ps1\"\)\)\) \{ try { \(New' -NotMatch)
    # Add it back in
    $ProfileExtensionsHandler = "if (!(Test-Path (""`$(`$Profile)_extensions.ps1""))) { try { (New-Object System.Net.WebClient).DownloadString('$UrlProfileExtensions') | Out-File ""`$(`$Profile)_extensions.ps1"" } catch { ""Could not download profile extensions, check internet/TLS before opening a new console."" } } ; "
    $ProfileExtensionsHandler += '. "$($Profile)_extensions.ps1" -EA silent'
    Add-Content -Path $profile -Value $ProfileExtensionsHandler -PassThru
    Write-Host "`nThe above line has been added to `$Profile`n"

    Write-Host "`nRun (dotsource) profile extensions into current session ..."
    . "$($Profile)_extensions.ps1" -EA silent
    "$($Profile)_extensions.ps1"
    # pause
    Set-Location $jumpfrom   # Return to saved location
    Write-Host ""
}

function Update-CustomTools {
    Write-Host ""
    Write-Host "Update Custom-Tools.psm1 Module (reinstall from Gist if required)." -ForegroundColor Yellow -BackgroundColor Black
    Write-Host "get-command -module custom-tools" -ForegroundColor Green
    
    $jumpfrom = Get-Location   # Save the current location
    $ProjectRoot = (Get-GistProject).ToString()
    echo $ProjectRoot
    Set-Location Get-GistProject
    ""
    "About to update the Custom-Tools Module in the User Modules folder and reload:"
    ""
    "Previous directory:  $jumpfrom"
    "Current directory:   $ProjectRoot"
    "Previous directory will be returned to after Toolkit configuration completes."
    
    # $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    # if ((New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) -eq $true ) {
    $CustomTools = "$HomeFix\Documents\WindowsPowerShell\Modules\Custom-Tools\Custom-Tools.psm1"
    $CustomToolsNew = "$ProjectRoot\Custom-Tools.psm1"
    # Install/Uninstall vs Import/Remove : https://devblogs.microsoft.com/scripting/how-to-remove-a-loaded-module/
    Remove-Module Custom-Tools -Force -Verbose -EA Silent
    if (Test-Path ($CustomTools)) { rm "$CustomTools" -Force }   # Delete old version if there
    if (!(Test-Path (Split-Path $CustomTools))) { New-Item (Split-Path $CustomTools) -ItemType Directory -Force }
    if (Test-Path $CustomToolsNew) { Copy-Item $CustomToolsNew $CustomTools -Force }
    . Import-Module Custom-Tools -Force -Verbose

    . PromptDefault   # This is required because the Remove-Module statement removes the function that set the prompt
    PromptDefault   # This is required because the Remove-Module statement removes the function that set the prompt
    Set-Location $jumpfrom   # Return to saved location
}

# $updateonline = read-host "No local file found, download latest Custom-Tools.psm1 from internet (default is y) (y/n)? "
# if ($updateonline -eq 'y' -or $updateonline -eq '') {
#     try {
#         (New-Object System.Net.WebClient).DownloadString('https://gist.github.com/roysubs/5c6a16ea0964cf6d8c1f9eed7103aec8/raw') | Out-File $CustomTools
#         Write-Host "`nDownload completed ..." -F Green
#         Write-Host "Custom-Tools.psm1 are at:"
#         Write-Host $CustomTools -F Yellow
#     } catch {
#         Write-Host "`nCould not download Custom-Tools Module, check internet/TLS before trying again." -ForegroundColor Red
#     }
# }

function Update-ToolkitLocal {
    # Update reload (with dotsource) latest Profile Extensions and Custom-Tools (local if available, or download)
    $jumpfrom = Get-Location   # Save the current location
    $ProjectRoot = Get-GistProject
    Set-Location $ProjectRoot
    ""
    "About to update both the Profile Extensions and the Custom-Tools Module:"
    ""
    "Previous directory:  $jumpfrom"
    "Current directory:   $ProjectRoot"
    "Previous directory will be returned to after Toolkit configuration completes."
    
    # Check if this function has been run dot sourced, by checking the value of $MyInvocation.InvocationName, if '.' then it was dotsourced, if 'cd' then not dotsourced
    # https://social.technet.microsoft.com/Forums/sqlserver/en-US/8e4d9f20-8479-40c1-b09f-982ab485e56e/how-to-find-out-if-a-script-is-ran-or-dotsourced?forum=winserverpowershell
    if ( $MyInvocation.InvocationName -eq 'Update-ToolkitLocal' -or $MyInvocation.InvocationName -eq 'pect') { "`nWarning: Command cannot run without being dotsourced! Please rerun as:`n`n   . Update-ToolkitLocal`n   . pect   # (Alias for Update-ToolkitLocal)`n" }
    else {
        . Update-CustomTools
        # . Import-Module Custom-Tools -Force -Verbose

        . Update-ProfileExtensions
        # . ./ProfileExtensions.ps1   # dotsource this version in case the profile folder version failed to update
    }
    # if (Test-Path $jumpfrom) { Set-Location $jumpfrom }   # Return to saved location

    . PromptDefault   # This is required because the Remove-Module statement removes the function that set the prompt(!)
    Set-Location $jumpfrom   # Return to saved location
}

Set-Alias pect Update-ToolkitLocal   # pect stands for "Profile Extensions Custom Tools"

function Update-ToolkitGist {
    # Same as pect, but pull from Gist first then deploy
    . iex ((New-Object System.Net.WebClient).DownloadString('https://bit.ly/2R7znLX'))
}
Set-Alias pectfromgist Update-ToolkitGist

function Remove-Toolkit {   # Work in Progress ... Cleanly remove all traces of Toolkit from system

    Write-Host "`nRemove the profile extensions handler line from `$Profile ..."
    # get the content *minus* the line to remove "-NotMatch"
    Set-Content -Path $profile -Value (Get-Content -Path $profile | Select-String -Pattern '^if \(\!\(Test-Path \("\$\(\$Profile\)_extensions\.ps1\"\)\)\) \{ try { \(New' -NotMatch)
    Set-Content -Path $profile -Value (Get-Content -Path $profile | Select-String -Pattern '^function Enable-Extensions { if' -NotMatch)

    Write-Host "`nRemove the profile extensions file from the `$Profile folder ..."
    rm "$(Split-Path $Profile)_extensions.ps1*"   # remove the extensions and any backups from the $Profile folder

    Write-Host "`nRemove Custom-Tools.psm1 Module from User / System locations ..."
    Uninstall-Module Custom-Tools
    pause
    Remove-Module Custom-Tools
    pause
    rm "$HomeFix\Documents\WindowsPowerShell\Modules\Custom-Tools\Custom-Tools.ps1*"   # remove the extensions and any backups from the $Profile folder
    pause
    # Uninstall-Module Custom-Tools
    # Remove-Module Custom-Tools
    # Import-Module -FullyQualifiedName C:\Users\Boss\Documents\WindowsPowerShell\Modules\Custom-Tools\Custom-Tools.psm1 -Force -Verbose

    # Reset Prompt in case it was modified
    function global:prompt {
        "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) ";
        $Elevated = ""
        $user = [Security.Principal.WindowsIdentity]::GetCurrent();
        if ((New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {$Elevated = "Administrator: "}
        # $TitleVer = "PS v$($PSVersionTable.PSversion.major).$($PSVersionTable.PSversion.minor)"
        $TitleVer = "PowerShell"
        $Host.UI.RawUI.WindowTitle = "$($Elevated)$($TitleVer)"
    }

    Write-Host "`nToolkit has been completely removed and defaults restored"
    Write-Host "To reinstall the toolkit:`n`niex ((New-Object System.Net.WebClient).DownloadString('https://bit.ly/2R7znLX'))`n`n"
}




####################
#
# GO / CD Functions
#
# Leaning towards keeping this in the Profile Extensions as if Custom-Tools breaks as
# it will while I'm doing updates, at least this will allow me quick access to folders
# to fix things.
#
# This defines the hash table, then the "go" function, then performs the alias.
# Note how the "cd" alias is set, this is quite specific and is inside the "go" function.
#    Set-Alias cd Set-Location -Option AllScope
# Has to be AllScope in this way.
#
####################


# https://stackoverflow.com/questions/26008148/convert-a-hashtable-to-a-string-of-key-value-pairs
# To join things into a string, can either concatenate with a separator then strip the trailing separator character
# I normally do it in a clunky way of combining then trimming, which is fine, but there are better ways
### Method 1: Using the OFS (Output Field Separator)
# $myhash = @{"foo"=4;"bar"=5}
# $OFS =';'
# [string]($myhash.GetEnumerator() | % { "$($_.Key)=$($_.Value)" })   # OFS will automatically apply as separator!
### Method 2: Using Join (this is probably clearer/better)
# $myhash = @{"foo"=4;"bar"=5}
# ($myhash.GetEnumerator() | % { "$($_.Key)=$($_.Value)" }) -join ';'
### Method 3: foreach then trim the last character (this is how I would normally do this)
# $myhash = @{"foo"=4;"bar"=5}
# foreach($pair in $myhash.GetEnumerator()) {
#     $output += $pair.key + "=" + $pair.Value + ";"
#     $output = $output.TrimEnd(";")
# }
# $output

function Import-GoHash ($key, $value) {

    $HomeFix = $HOME
    $HomeLeaf = split-path $HOME -leaf   # Just get the correct username in spite of any changes to username!
    if ($HomeFix -like "\\*") { $HomeFix = "C:\Users\$(Split-Path $HOME -Leaf)" }

    # This is the base hash table that can be added to
    $gohash_base = @{
        share   = $env:HOMESHARE
        home    = "$HomeFix::$env:USERPROFILE"
        homec   = $HomeFix
        # inghome = "$(Split-Path (Split-Path $ProfileNetShare))\Desktop"
        inghome = "\\ad.ing.net\WPS\NL\P\UD\200024\$HomeLeaf\Home"   # ING only!
        user    = $HomeFix
        000     = "C:\0::D:\0"
        pssys     = "C:\Windows\System32\WindowsPowerShell\v1.0"
        ps        = "$HomeFix\Documents\WindowsPowerShell"   # For network profile, force C:\ , # Split-Path $profile
        prof      = "$HomeFix\Documents\WindowsPowerShell"   # For network profile, force C:\ , # Split-Path $profile
        scripts   = "$HomeFix\Documents\WindowsPowerShell\Scripts"   # For network profile, force C:\ , # "$(Split-Path $Profile)\Scripts"
        appdata   = "$HomeFix\AppData\Roaming::$env:APPDATA"   # C:\Users\<user>\AppData\Roaming
        roaming   = "$HomeFix\AppData\Roaming::$env:APPDATA"   # C:\Users\<user>\AppData\Roaming
        local     = "$HomeFix\AppData\Local"   # C:\Users\<user>\AppData\Local
        cappdata  = "$HomeFix\AppData\Roaming"   # C:\Users\<user>\AppData\Roaming
        appdatac  = "$HomeFix\AppData\Roaming"   # C:\Users\<user>\AppData\Roaming
        temp      = "$HomeFix\AppData\Local\Temp::$env:TEMP"    # TEMP = TMP = C:\Users\<Username>\AppData\Local\Temp
        tempu     = "$HomeFix\AppData\Local\Temp::$env:TEMP"    # 'u' for User
        temps     = "C:\Windows\Temp"  # Temp Folder (System)   # 's' for System
        tempa     = "C:\Windows\Temp"  # Temp Folder (Admin)    # 'a' for Admin
        tmp       = "$HomeFix\AppData\Local\Temp::$env:TMP"     # TEMP = TMP = C:\Users\<Username>\AppData\Local\Temp
        tmpu      = "$HomeFix\AppData\Local\Temp::$env:TEMP"    # 'u' for User
        tmps      = "C:\Windows\Temp"  # Temp Folder (System)   # 's' for System
        tmpa      = "C:\Windows\Temp"  # Temp Folder (Admin)    # 'a' for Admin
        win       = "C:\Windows"
        dotnet    = "c:\Windows\Microsoft.NET\Framework"
        dotnet64  = "c:\Windows\Microsoft.NET\Framework64"
        sys       = "C:\Windows\System32"   # Use to point this at 'System', but it is useless, nothing of value is in there, so just point sys at 'System32' also
        sys32     = "C:\Windows\System32"   
        hosts     = "C:\Windows\System32\drivers\etc"
        etc       = "C:\Windows\System32\drivers\etc"
        mod       = "$HomeFix\Documents\WindowsPowerShell\Modules"
        modu      = "$HomeFix\Documents\WindowsPowerShell\Modules"     # 'u' for User
        ingmod  = "\\ad.ing.net\WPS\NL\P\UD\200024\$HomeLeaf\Home\My Documents\WindowsPowerShell\Modules"
        cmodu   = "$HomeFix\Documents\WindowsPowerShell\Modules"   # For when on netowrk profile, force C:\
        mods    = "C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules"  # System
        moda    = "C:\Program Files\WindowsPowerShell\Modules"          # Admin
        ingdown = "\\ad.ing.net\WPS\NL\P\UD\200024\$HomeLeaf\Home\Downloads"    # Or, $env:HOMESHARE\My Documents\Downloads
        down    = "$HomeFix\Downloads"   # User, note HOMESHARE for ING path, $env:HOMESHARE\My Documents\Downloads
        downc   = "$HomeFix\Downloads"   # 'c' suffix for "force C:\"
        cdown   = "$HomeFix\Downloads"   # 'c' prefix for "force C:\"
        desk    = "$HomeFix\Desktop"     # User
        deskc   = "$HomeFix\Desktop"     # 'c' suffix for "force C:\"
        cdesk   = "$HomeFix\Desktop"     # 'c' prefix for "force C:\"
        # ingdesk = "$(Split-Path (Split-Path (Split-Path $ProfileNetShare)))\Desktop"
        ingdesk = "\\ad.ing.net\WPS\NL\P\UD\200024\$env:USERNAME\Desktop"   # Note that this is NOT under Home
        docs    = "$HomeFix\Documents"         # User
        docsc   = "$HomeFix\Documents"   # For when on netowrk profile, force C:\
        cdocs   = "$HomeFix\Documents"   # For when on netowrk profile, force C:\
        # ingdocs = "$(Split-Path (Split-Path (Split-Path $ProfileNetShare)))\My Documents"
        ingdocs = "\\ad.ing.net\WPS\NL\P\UD\200024\$HomeLeaf\Home\My Documents"
        quickautomatic = "$HomeFix\Recent\AutomaticDestinations"    # shell:recent\AutomaticDestinations
        quickcustom = "$HomeFix\Recent\CustomDestinations"          # shell:recent\CustomDestinations
        startup  = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"   # startup folder
        startupc = "$HomeFix\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"   # 'c' suffix for "force C:\"
        cstartup = "$HomeFix\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"   # 'c' prefix for "force C:\"
        startupall = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"  # Startup, All Users
        startupa = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"    # Startup, Admin
        startups = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"    # Startup, System
        # Lots of registry hacks: https://www.howtogeek.com/370022/windows-registry-demystified-what-you-can-do-with-it/
        # Important Virus Locations to check: https://www.symantec.com/connect/articles/most-common-registry-key-check-while-dealing-virus-issue
        # https://www.techsupportalert.com/content/deeper-windows-registry.htm
        regexploreruser   = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
        regexplorersys    = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
        regstartupuser    = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
        regstartupsys     = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
        reginstallsys     = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"   # https://www.sciencedirect.com/topics/computer-science/installed-program
        reginstalluser    = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
        reginstall32node  = "HKLM:\SOFTWARE\WOW6432NODE\Microsoft\Windows\CurrentVersion\Uninstall"   # 32-bit apps installed to a 64-bit system go here
        reginstallmsiroot = "HKCR:Installer\Products"                       # Apps are then under "<ProductCode>\SourceList\Net"
        reginstallmsiuser = "HKCU:\SOFTWARE\Microsoft\Installer\Products"   # Apps are then under "<ProductCode>\SourceList\Net"
        regenv            = "HKCU:\Environment"
        pd     = "C:\ProgramData"
        pf     = "C:\Program Files"
        pf64   = "C:\Program Files"
        pf32   = "C:\Program Files (x86)"
        pf86   = "C:\Program Files (x86)"
        onedrive     = "$env:OneDrive::D:\0 Cloud\OneDrive::\\HP1\Drive-D\0 Cloud\OneDrive"   # Test on UNC paths, https://stackoverflow.com/questions/14939777/powershell-operation-on-unc-hangs-too-long
        googledrive  = "$env:USERPROFILE\Google Drive::D:\0 Cloud\Google Drive::\\HP1\Drive-D\0 Cloud\Google Drive"
        dropbox      = "$env:USERPROFILE\Dropbox::D:\0 Cloud\Dropbox::\\HP1\Drive-D\0 Cloud\Dropbox"
        scripts_ahk  = "D:\0 Cloud\OneDrive\0_Scripts_AutoHotkey::\\HP1\Drive-D\0 Cloud\OneDrive\0_Scripts_AutoHotkey"
        ahk          = "D:\0 Cloud\OneDrive\0_Scripts_AutoHotkey::\\HP1\Drive-D\0 Cloud\OneDrive\0_Scripts_AutoHotkey"
        scripts_wotr = "D:\0 Cloud\OneDrive\0_Scripts_AutoHotkey\WOTR::\\HP1\Drive-D\0 Cloud\OneDrive\0_Scripts_AutoHotkey\WOTR"
        wotr         = "D:\0 Cloud\OneDrive\0_Scripts_AutoHotkey\WOTR::\\HP1\Drive-D\0 Cloud\OneDrive\0_Scripts_AutoHotkey\WOTR"
        scripts_ps   = "D:\0 Cloud\OneDrive\0_Scripts_PowerShell::\\HP1\Drive-D\0 Cloud\OneDrive\0_Scripts_PowerShell"
        scripts_py   = "D:\0 Cloud\OneDrive\0_Scripts_Python::\\HP1\Drive-D\0 Cloud\OneDrive\0_Scripts_Python"
        py           = "D:\0 Cloud\OneDrive\0_Scripts_Python::\\HP1\Drive-D\0 Cloud\OneDrive\0_Scripts_Python"
        choco   = "C:\ProgramData\Chocolatey"
        choc    = "C:\ProgramData\Chocolatey"
        cbin    = "C:\ProgramData\Chocolatey\bin"   # All choco executables and shims for managed apps are in here (and this is on the path)
        clib    = "C:\ProgramData\Chocolatey\lib"   # All managed installs go here
        box     = "C:\ProgramData\Boxstarter"
        scoop   = "$env:USERPROFILE\scoop"
        backup  = "D:\Backup"
        ubuntu   = "C:\Users\Boss\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu18.04onWindows_79rhkp1fndgsc\LocalState\rootfs"   # For Ubuntu
        opensuse = "C:\Users\Boss\AppData\Local\Packages\46932SUSE.openSUSELeap42.2_022rs5jcyhyac\LocalState\rootfs"                   # For OpenSUSE
        debian   = "C:\Users\Boss\AppData\Local\Packages\46932SUSE.openSUSELeap42.2_022rs5jcyhyac\LocalState\rootfs"                   # For Debian
        centos   = "C:\Users\Boss\AppData\Local\Packages\46932SUSE.openSUSELeap42.2_022rs5jcyhyac\LocalState\rootfs"                   # For CentOS
        gist     = "C:\0\Gist::$HomeFix\Gist::D:\Gist::D:\0 Cloud\OneDrive\Gist"    # Current location for my Gist projects
        cmdtools = "C:\CmdTools::D:\CmdTools"            # Console Tools, maybe rename to C:\ConsoleTools / C:\ConsoleApps
        customtools = "$HomeFix\Documents\WindowsPowerShell\Modules\Custom-Tools"   # Custom-Tools
        ct          = "$HomeFix\Documents\WindowsPowerShell\Modules\Custom-Tools"   # ct = Custom-Tools folder
        pe          = "$HomeFix\Documents\WindowsPowerShell"                        # pe = ProfileExtensions folder
        me          = "C:\0::D:\0::$env:USERPROFILE\0"   # I use C:\0 as a convenient temp folder in drives so always sorts at top of dir listing, quick to get into
        # Special folder paths are stored in:   # https://www.winhelponline.com/blog/windows-10-shell-folders-paths-defaults-restore/
        # https://ss64.com/ps/syntax-hash-tables.html
        # https://mcpmag.com/articles/2012/05/08/powershell-dissect-arrays-hash-tables.aspx
        # Quick Access
        # https://answers.microsoft.com/en-us/windows/forum/all/where-are-quick-access-links-stored/54e64725-c7d1-402c-ad6a-8004418b4a49
    }

    $goxml = "$env:TEMP\ps_go_hash.xml"
    $gonew = "$env:TEMP\ps_gohash_added.txt"   # Keep a separate copy of added / redefined items to apply to new setups
    # if (!(Test-Path $gonew)) { New-Item -ItemType File $gonew  }

    try { $gohash = Import-Clixml $goxml -EA Silent }   # Could also test $gohashtype = $gohash.gettype().Name
    catch { $gohash = $gohash_base }                    # Could not create a Hashtable from $goxml, so we reset it
    # if ($null -eq $gohash) { $gohash = $gohash_base } # Could not create a Hashtable from $goxml, so we reset it

    if ($null -ne $key -and $null -ne $value) {         # Only do if key and value are defined
        $gohash.Add( $key, $value )
        $keynew = "Import-GoHash '$key' '$value'"   # Create them as commands that will re-create in a new session
        # Could also use: (Get-Content -Path $myFile).Contains($myText))
        # Select-String -Quiet: the output is a Boolean value indicating whether the pattern was found.
        $b = Select-String -Quiet -Pattern $keynew -Path $gonew
        if (-not $b) { Add-Content -Path $gonew -Value $keynew }
    }

    $gohash | Export-Clixml $goxml   # Export the updated Hashtable back to the xml file as serialized data
}


# -List : just show the paths, comma separated
# if there is a clash, should mention that!! i.e. cd temp
$ProfileExtensionsGoTogglePathTesting = $true
function go ($JumpTo, [switch]$DisableCDAlias, [switch]$ResetGoHash, [switch]$ResetCDHistory, [switch]$TogglePathTesting, [switch]$ForceJumpTo, [switch]$List) {

    # function is not stand-alone. Depends on Import-GoHash
    # Param( [Parameter(ValueFromPipeline=$true)][string]$JumpTo )   # Mandatory=$true
    # ToDo: If the folder does not exist, is it useful to create it? Should definitely be optional
    # ToDo: Possibly these values should be pushed into the registry, then can be updated by user easily?
    # https://4sysops.com/archives/interacting-with-the-registry-in-powershell/
    # Populate the path_history file, do this before the Bypass so capture normal cd access in there
    $goxml = "$env:TEMP\ps_go_hash.xml"                ; if (!(Test-Path $goxml)) { Import-GoHash }
    $path_history = "$($env:TEMP)\ps_go_path_history.txt" ; if (!(Test-Path $path_history)) { New-Item -ItemType File $path_history | Out-Null }
    $path_source = Get-Location   # if no move is made, do NOT add this to the history! Have to be careful on when this is added
    $cd_date = Get-Date -format "yyyy-MM-dd HH:mm:ss"

    if ($ResetGoHash -eq $true) { rm $goxml -EA Silent ; Import-GoHash ; break }     # If reset GoHash switch: delete hash table and rebuild
    if ($ResetCDHistory -eq $true) { if (Test-Path $path_history) { Clear-Content $path_history ; break } }   # If reset CD history switch: clear path history
    # Case to disable the 'cd' alias with the -DisableCD switch
    if ($DisableCDAlias -eq $true) {
        # See "get-help about_Command_Precedence" for more details on the precedence rules.
        Remove-Item -Path Alias:cd
        Set-Alias cd Set-Location -Option AllScope
        # Check the value of $MyInvocation.InvocationName, if '.' then it was dotsourced, if 'cd' then not dotsourced
        # https://social.technet.microsoft.com/Forums/sqlserver/en-US/8e4d9f20-8479-40c1-b09f-982ab485e56e/how-to-find-out-if-a-script-is-ran-or-dotsourced?forum=winserverpowershell
        "`nCommands run:`n`nRemove-Item -Path Alias:cd`nSet-Alias cd Set-Location"
        Get-Alias cd
        ""
        "To re-assign 'cd' to the 'go' function, run 'EnableCDAlias'"
        break
    }
    if ($null -eq $gohash -or $gohash.Count -eq 0) { if (!(Test-Path $goxml)) { Import-GoHash } else { $gohash = Import-Clixml $goxml }}

    if ($TogglePathTesting -eq $true) { 
        if ($ProfileExtensionsGoTogglePathTesting -eq $true) { $ProfileExtensionsGoTogglePathTesting = $false } else { $ProfileExtensionsGoTogglePathTesting = $true }
        "Path testing (check all paths when running 'cd.' / 'cd:' / 'go :' is now: $ProfileExtensionsGoTogglePathTesting"
        break
    }

    if ($List -eq $true) {
        if (!(Test-Path $goxml)) { Import-GoHash } else { $gohash = Import-Clixml $goxml }
        $longest = 0 ; $gohash.GetEnumerator() | % { $keylength = ($_.Key).length ; if ($longest -lt $keylength) { $longest = $keylength } }
        # $gohash.GetEnumerator() | Sort -Property Name   # Note: This is the only correct way to sort hash tables!
        $output = "`n " + ($gohash.GetEnumerator() | % {
            $keypadding = $longest - ($_.Key).length
            "$($_.Key)$(" " * $keypadding) = $($_.Value)`n"
        }) -replace "^ ", "" | sort
        Write-Host $output ; break
        break
        # ($gohash.GetEnumerator() | % { go through and work out longest length, set the = sign to 1 character after that
        # $output += ($gohash.GetEnumerator() | % { "$($_.Key)`t=`t$($_.Value)`r`n" }) ; Write-Host $output ; break
        # $output = ($gohash.GetEnumerator() | % { "$($_.Key)=$($_.Value)" }) -join '  ### ' ; Write-Wrap $output ; break }
    }
    
    # Above switches all 'break' after applying so no need to test on them after here
    if ($null -eq $JumpTo) {
        Import-GoHash   # Need to populate $gohash
        $gohash.GetEnumerator() | Sort -Property Name   # Note: This is the correct way to sort hash tables!
        ""
        "Total number of defined jump locations: $($gohash.Count)"
        ""
        "The 'go' function is aliased by 'cc' and 'cd' (and globally replaces the built-in cd alias"
        "for the Set-Location Cmdlet (but 'Set-Location' and 'sl' themselves remains unchanged)."
        "Just use 'cd' as normal, but with the below extensions (and remember that 'go' and 'cc' will also work)."
        ""
        "   cd                  # On its own, show all pre-defined jump locations"
        "   cd pf               # Jump to 'C:\Program Files', one of the locations shown in 'cd'"
        "   cd etc|temps|tempu  # Jump to 'etc' (for hosts file), or System Temp, or User Temp"
        "   cd regstartupsys    # Jump to the System startup key in the Registry (using the Registry PSProvider)"
        "   cd./cd: (or 'go :') # Show history of locations cd'd to"
        "   cd <history_index>  # Jump to the location tied to the index shown in the history"
        ""
        "   go -ResetHashTable  # Reset the jump location hash table"
        "   go -ResetCDHistory  # Reset/delete current history locations"
        "   go -TestCDHistory   # Check validity of location in cd history"
        "   go -DisableCDAlias  # Revert the 'cd' alias back to 'Set-Location'"
        ""
        '   Import-GoHash "jump-name" "C:\my\path"   # Define and add a jump location into the hash table'
        "If '::' separators are used, will try each folder in order until success."
        'e.g.  Import-GoHash "films" "C:\Downloads\Films::D:\Downloads\Films::E:\Media\Films"'
        "   'cd films'   will then try each location till it finds a hit."
        ""
        break
    }

    # Bypass: if the path exists as a relative path or as an absolute, then just do a normal 'cd' and exit.
    # [System.IO.Path]::IsPathRooted($JumpTo)   # IsPathRooted checks for C:\, need in case C:\new\path as non-relative
    # We don't technically need to differentiate "rooted" (i.e. absolute) and non-rooted, but note here in case need in future.
    # Note: this won’t check whether the path provided exists or not. http://msdn.microsoft.com/en-us/library/system.io.path.ispathrooted.aspx
    $HasDirMoved = $false
    if ($ForceJumpTo -ne $true -and $JumpTo -ne "..." -and $JumpTo -ne "...." -and $JumpTo -ne ".....") {   # Block a normal 'cd' if the folder exists if the $ForceJumpTo switch used
        if (Test-Path $JumpTo) { Set-Location $JumpTo ; $HasDirMoved = $true }                       # try going to the exact location
        elseif (Test-Path "$(pwd)\$JumpTo") { Set-Location "$(pwd)\$JumpTo" ; $HasDirMoved = $true }   # otherwise, try relative path case (only used for other PSProviders)
    }   

    if ($HasDirMoved -ne $true) {

        # Note the use of "cd .." in first instance to add the location to the CD history, then "Set-Location .." after that.
        if ($JumpTo -eq "...")   { cd .. ; Set-Location .. ; break }
        if ($JumpTo -eq "....")  { cd .. ; Set-Location .. ; Set-Location .. ; break }
        if ($JumpTo -eq ".....") { cd .. ; Set-Location .. ; Set-Location .. ; Set-Location .. ; break }

        # Display the cd index history on "cd :" (also 'cd:' and 'cd.' functions are created separately)
        if ($JumpTo -eq ":") {
            ""
            if ($null -eq (Get-Content $path_history -EA silent)) {
                "Path history is empty`n"
            }
            else {
                $paths_array = Get-Content $path_history
                $path_history_count = ($paths_array).Count
                For ( $i = 0; $i -lt $path_history_count ; $i++ ) {
                    $line = $paths_array[$i]
                    $x = $path_history_count - $i   # Must update the count before outputting the line
                    if ($ProfileExtensionsGoTogglePathTesting -eq $true) { 
                        if (!(Test-Path $line)) {
                            $line += "   ::   [BROKEN PATH]"
                            Write-Host "$x :: $line" -BackgroundColor Black -ForegroundColor Red
                        }
                        else {
                            "$x :: $line"
                        }
                    }
                    else {
                        "$x :: $line"
                    }
                }
                "`nTo go to a previous folder, use 'cd <history_index>' (index numbers listed on left)"
                "Note that to minimise repetition in the entries, if a location earlier in the history is"
                "cd'd into, the old history entry will be removed and replaced by an entry at position 1.`n"
            }
            break
        }

        if ($JumpTo -is [int]) {    # Jump to a location in path history if $JumpTo is an integer
            $oldpath = (Get-Content $path_history)[-$JumpTo]   # get n'th last line(!) counting backwards
            "JumpTo -> index $JumpTo in cd history: $oldpath`n"
            if (Test-Path $oldpath) { Set-Location $oldpath ; $HasDirMoved = $true }
            else { "The path stored in cd history index $JumpTo is missing: $oldpath`n"}
            break
        }

        if ($gohash.ContainsKey($JumpTo)) {    # Finally, parse the $JumpTo value from hashtable and jump to that folder
            $arrPaths = $gohash[$JumpTo] -split "::"
            foreach ($i in $arrPaths) {
                if (Test-Path $i) {
                    if ($HasDirMoved -ne $true) {   # This test is to only jump to the *first* match in the hashtable value then stop
                        Set-Location $i
                        $HasDirMoved = $true
                        "JumpTo -> " + $gohash[$JumpTo]
                    }
                }
            }
            if ($HasDirMoved -eq $false) {
                echo "   Paths do not exist:`n   $($arrPaths)"
            }
        } elseif (Test-Path "C:\Users\$JumpTo") {
            cd "C:\Users\$JumpTo"
        } else {
            "'$JumpTo' was not found either as a subfolder of the current folder or as a defined jump location."
            "Type 'cd' or 'go' on its own to see all currently defined jump locations."
        }
    }

    if ($HasDirMoved -eq $true) {
        # Remove any duplicates
        $x = ""; foreach ($i in (Get-Content $path_history)) { if ($i -ne $path_source) { $x += "$i`n" } }
        Set-Content -Path $path_history -Value "$x$path_source" -Force   # add current value into list (unless it is the last value!)
        break
    }
}

# Below 'cd' manipulation is referencing the 'go' function in the Custom-Tools Module, so only do these if 'go' is available.
# Tried to put these into a function then call it.
# function EnableCDAlias {
if (Get-Command go -EA Silent) {
    Set-Alias cc go
    if (Test-Path Alias:cd) { Remove-Item -Path Alias:cd }    # Remove the default:   cd -> Set-Location
    # See "get-help about_Command_Precedence" for more details on the precedence rules.
    # Due to precedence rules, alias is above function so have to remove cd as an alias before reassinging
    # Remove-Alias was not added until PS v6 so have to use Remove-Item with the Alias PSProvider
    Set-Alias cd go -Option AllScope
    # Without -Option AllScope, the above generates the following error:
    # Set-alias : The AllScope option cannot be removed from the alias 'cd'.
    # At line:1 char:1
    # + Set-alias cd go
    # + ~~~~~~~~~~~~~~~
    #     + CategoryInfo          : WriteError: (cd:String) [Set-Alias], SessionStateUnauthorizedAccessException
    #     + FullyQualifiedErrorId : AliasAllScopeOptionCannotBeRemoved,Microsoft.PowerShell.Commands.SetAliasCommand
}
# }
# EnableCDAlias
    
    
function cd. { go : }
function cd: { go : }

# "cd\" is a built-in PowerShell function which maps to "Set-Location \", so bypasses the go/cd function
# meaning that cd/go history location will not be stored (.e.g. "cd C:\Windows\System32" then "cd\").
# Re-aliasing "cd\" as AllScope to use the cd/go function fixes this.
function go_root { go \ }
Set-Alias cd\ go_root -Option AllScope

# For the following, the first move has to use the cd/go function (so that the previous location is recorded!)
# but then use Set-Location afterwards so that those locations are not recorded in history.
function cd...   { Push-Location ; cd .. ; Set-Location .. }   # Go up 2 folder levels.
function cd....  { Push-Location ; cd .. ; Set-Location .. ; Set-Location .. }   # Go up 3 folder levels.
function cd..... { Push-Location ; cd .. ; Set-Location .. ; Set-Location .. ; Set-Location .. }   # Go up 4 folder levels.
function ..      { Push-Location ; cd .. }   # Go up 1 folder levels.
function ...     { Push-Location ; cd .. ; Set-Location .. }   # Go up 2 folder levels.
function ....    { Push-Location ; cd .. ; Set-Location .. ; Set-Location .. }   # Go up 3 folder levels.
function .....   { Push-Location ; cd .. ; Set-Location .. ; Set-Location .. ; Set-Location .. }   # Go up 4 folder levels.
Set-Alias dc cd   # Define this as it is a common typo.
function mc ($dir) {   # mc "Make Directory and CD into Directory" = md + cd 
    if(!([string]::IsNullOrWhiteSpace($dir))) {
        try { md $dir } catch { "Could not create $dir, may not have permissions" }
        try { cd $dir } catch { "Could not cd into $dir." }
    } else { "Make Dir + CD into Dir : No directory specified" }
}

# Must use $intput instead of $args to allow use of any additional Get-ChildItem switches ($args results in an error if trying that)
function l { Get-ChildItem $input | Format-Wide Name -AutoSize }    # wide autosized, could use  -Exclude .*  to remove . / .. listings
function ll { Get-ChildItem $input -Force | sort Directory,Name }   # -Force causes all Hidden items to be shown!
Set-Alias d Get-ChildItem
Set-Alias dur Get-ChildItem   # dir typo
Set-Alias dor Get-ChildItem   # dir typo



#region Fix important *nix commands.
#
# Optional region for cross-compatible Windows / Linux scripts
# PowerShell comes with some predefined aliases built-in that are designed to
# ease the transition from *nx to PowerShell. While this is well-intentioned,
# it causes problems in cross-platform PowerShell scripting. This code removes
# the predefined aliases that would otherwise hide important *nix commands.
#
# foreach ($nxCommand in @('cat','cp','curl','diff','echo','kill','ls','man','mount','mv','ps','pwd','rm','sleep','tee','type','wget')) {
#     if (Test-Path -LiteralPath alias:${nxCommand}) {
#         Remove-Item -LiteralPath alias:${nxCommand} -Force
#     }
# }
# New-Alias -Name type -Value cat
# function ls {
#     param()
#     if ($args -notcontains '--color') {
#         $args += '--color'
#     }
#     & ls.exe @args
# }
#
#endregion



####################
#
# Altering the position and size of the PowerShell console is the only actual visible
# change made to the environment (all the rest are just functions that can be used).
#
# The reason for this is that PowerShell too often opens a new console with the bottom of
# the console off the bottom of the screen. This fixes that once and for all.
#
# ToDo: Only move and resize if script is opened from $Profile... not sure possible
# https://poshoholic.com/2008/03/18/powershell-deep-dive-using-myinvocation-and-invoke-expression-to-support-dot-sourcing-and-direct-invocation-in-shared-powershell-scripts/
# https://stackoverflow.com/questions/59395318/move-manipulate-powershell-console-windows-on-opening/59406472#59406472
# https://stackoverflow.com/questions/59953946/powershell-calculate-pixel-height-of-start-bar
# This might be a better way to research, as can change the state between Normal and Maximised
# https://communary.net/2015/10/11/change-the-powershell-console-size-and-state-programmatically/
#
# Removed this from the Set-MaxWindowSize function:
# $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
# $CurrentUserPrincipal = New-Object Security.Principal.WindowsPrincipal $CurrentUser
# $Adminrole = [Security.Principal.WindowsBuiltinRole]::Administrator
# If (($CurrentUserPrincipal).IsInRole($AdminRole)){$Elevated = "Administrator"}    
# 
# $Title = $Elevated + " $ENV:USERNAME".ToUpper() + ": $($Host.Name) " + $($Host.Version) + " - " + (Get-Date).toshortdatestring() 
# $Host.UI.RawUI.set_WindowTitle($Title)
#
####################

# Add-Type -Name Window -Namespace Console -MemberDefinition '
# [DllImport("Kernel32.dll")] 
# public static extern IntPtr GetConsoleWindow();
# [DllImport("user32.dll")]
# public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int W, int H); '

function Global:Set-ConsolePosition ($x, $y, $w, $h) {
    # Keep this function in ProfileExtensions as used during updates
    # Note: the DLL code below must not be indented from the left-side or will break
    Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")] 
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int W, int H); '
    # Do the Add-Type outside of the function as repeating it in a session can cause errors
    $consoleHWND = [Console.Window]::GetConsoleWindow();
    $consoleHWND = [Console.Window]::MoveWindow($consoleHWND, $x, $y, $w, $h);
    # $consoleHWND = [Console.Window]::MoveWindow($consoleHWND,75,0,600,600);
    # $consoleHWND = [Console.Window]::MoveWindow($consoleHWND,-6,0,600,600);
}

function Global:Set-MaxWindowSize {
    # Keep this function in ProfileExtensions as used during updates
    # https://gallery.technet.microsoft.com/scriptcenter/Set-the-PowerShell-Console-bd8b2ad1
    # https://stackoverflow.com/questions/5197278/how-to-go-fullscreen-in-powershell
    # "Also note 'Mode 300' and 'Alt-Enter' to fullscreen the console`n"

    if ($Host.Name -match "console") {
        $MaxHeight = $host.UI.RawUI.MaxPhysicalWindowSize.Height - 5    # 1
        $MaxWidth = $host.UI.RawUI.MaxPhysicalWindowSize.Width - 15     # 15
        $MyBuffer = $Host.UI.RawUI.BufferSize
        $MyWindow = $Host.UI.RawUI.WindowSize
        $MyWindow.Height = ($MaxHeight)
        $MyWindow.Width = ($Maxwidth-2)
        $MyBuffer.Height = (9999)
        $MyBuffer.Width = ($Maxwidth-2)
        # $host.UI.RawUI.set_bufferSize($MyBuffer)
        # $host.UI.RawUI.set_windowSize($MyWindow)
        $host.UI.RawUI.BufferSize = $MyBuffer
        $host.UI.RawUI.WindowSize = $MyWindow
    }
}

# Only run this the first time that Profile Extensions are run in this session (k.e. ". pect" will not reactivate)
if ($null -eq $ProfileExtensionsFirstRun) {
    Set-ConsolePosition 75 0 600 600
    Set-MaxWindowSize
}
$ProfileExtensionsFirstRun = $false
