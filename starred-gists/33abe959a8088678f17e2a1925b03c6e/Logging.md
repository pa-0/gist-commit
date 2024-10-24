# logging functions

```powershell
#==============================================================================================
#region Logging Functions
function Write-Log
{
    [cmdletbinding()]
    param([Parameter(
        Mandatory=$true, Position=0, ValueFromPipeline=$true
        )]
        [AllowEmptyString()]
        [string]$Message
    )
    Write-Verbose  ("[{0:s}] [$(get-caller)] {1}`r`n" -f (get-date), $Message)
}

function write-ok($text="")
    { write-emoji -code "u+2705" -text $text }

function write-done($text="")
    { write-emoji -code "u+2705" -text "done. $text" }

function write-angry
    { write-emoji "u+1F975" }

function write-emoji($code='u+2705', $text="")
{
    $StrippedUnicode = $code -replace 'U\+',''
    $UnicodeInt = [System.Convert]::toInt32($StrippedUnicode,16)
    [System.Char]::ConvertFromUtf32($UnicodeInt) + " $text"
}

function Write-Success($Message)
    {
        Write-Host (New-FormattedLog -Type "WIN" -Time (get-date) -Message $Message) -ForegroundColor Green
    }

function Write-Fail($Message)
    {
         Write-Host (New-FormattedLog -Type "ERROR" -Time (get-date) -Message $Message) -ForegroundColor Red
    }

function Write-Debug($Message)
    {
         Write-Host (New-FormattedLog -Type "DEBUG" -Time (get-date) -Message $Message) -ForegroundColor Cyan
     }

function Write-Normal($Message)
    {
        Write-Host (New-FormattedLog -Type "INFO" -Time (get-date) -Message $Message)
}

function Write-Yellow($Message)
    {
        Write-Host (New-FormattedLog -Type "INFO" -Time (get-date) -Message $Message) -ForegroundColor Yellow
    }

function Write-Color($Message,$color)
    {
        Write-Host (New-FormattedLog -Type "INFO" -Time (get-date) -Message $Message) -ForegroundColor $color
    }

function New-FormattedLog ($Type, $Time, $Message)
    {
        ("[{0,-5}] [{1:s}] [{2}] {3}`r" -f $type, $Time, (get-caller 3), $Message)
    }

function get-caller($stackNum = 2)
    {
         process{ return ((Get-PSCallStack)[$stackNum].Command) }
    }

function write-compare
{
    [cmdletbinding()]
    Param($label,$expected,$actual)
    return ("{0,-15} Expected: {1,-45} ==> Actual: {2,-25}" -f $label, "[$expected]", "[$actual]" )
}

function write-header
{
    [cmdletbinding()]
    Param($label,$color= "magenta", [switch]$min, $max = 100)
    $i = $label | measure-object -character | select -expandproperty characters
    $split = (($max-$i)/2)

    if (-not $min)
     { 
        write-host "$('='*$max)" -foregroundcolor $color
      }

    write-host ("{0}  {1}  {2}" -f ('='*($split-4)),$label, ('='*$split)) -foregroundcolor $color
    if (-not $min)
     { 
        write-host "$('='*$max)" -foregroundcolor $color
     }
}
#endregion

#==============================================================================================

Export-ModuleMember -Function Write-Log
Export-ModuleMember -Function write-ok
Export-ModuleMember -Function write-done
Export-ModuleMember -Function write-angry
Export-ModuleMember -Function write-emoji
Export-ModuleMember -Function Write-Success
Export-ModuleMember -Function Write-Fail
Export-ModuleMember -Function Write-Debug
Export-ModuleMember -Function Write-Normal
Export-ModuleMember -Function Write-Yellow
Export-ModuleMember -Function New-FormattedLog
Export-ModuleMember -Function get-caller
Export-ModuleMember -Function write-compar
Export-ModuleMember -Function write-header
#Export-ModuleMember -Function *
```

```powershell
Function Write-ProtocolEntry {

        <#
        .SYNOPSIS

            Output of an event with timestamp and different formatting
            depending on the level. If the Log parameter is set, the
            output is also stored in a file.
        #>

        [CmdletBinding()]
        Param (

            [String]
            $Text,

            [String]
            $LogLevel
        )

        $Time = Get-Date -Format G

        Switch ($LogLevel) {
            "Info"    { $Message = "[*] $Time - $Text"; Write-Host $Message; Break }
            "Debug"   { $Message = "[-] $Time - $Text"; Write-Host -ForegroundColor Cyan $Message; Break }
            "Warning" { $Message = "[?] $Time - $Text"; Write-Host -ForegroundColor Yellow $Message; Break }
            "Error"   { $Message = "[!] $Time - $Text"; Write-Host -ForegroundColor Red $Message; Break }
            "Success" { $Message = "[$] $Time - $Text"; Write-Host -ForegroundColor Green $Message; Break }
            "Notime"  { $Message = "[*] $Text"; Write-Host -ForegroundColor Gray $Message; Break }
            Default   { $Message = "[*] $Time - $Text"; Write-Host $Message; }
        }

        If ($Log) {
            Add-MessageToFile -Text $Message -File $LogFile
        }
    }

    Function Add-MessageToFile {

        <#
        .SYNOPSIS

            Write message to a file, this function can be used for logs,
            reports, backups and more.
        #>

        [CmdletBinding()]
        Param (

            [String]
            $Text,

            [String]
            $File
        )

        try {
            Add-Content -Path $File -Value $Text -ErrorAction Stop
        } catch {
            Write-ProtocolEntry -Text "Error while writing log entries into $File. Aborting..." -LogLevel "Error"
            Break
        }

    }

    Function Write-ResultEntry {

        <#
        .SYNOPSIS

            Output of the assessment result with different formatting
            depending on the severity level. If emoji support is enabled,
            a suitable symbol is used for the severity rating.
        #>

        [CmdletBinding()]
        Param (

            [String]
            $Text,

            [String]
            $SeverityLevel
        )

        If ($EmojiSupport) {

            Switch ($SeverityLevel) {

                "Passed" { $Emoji = [char]::ConvertFromUtf32(0x1F63A); $Message = "[$Emoji] $Text"; Write-Host -ForegroundColor Gray $Message; Break }
                "Low"    { $Emoji = [char]::ConvertFromUtf32(0x1F63C); $Message = "[$Emoji] $Text"; Write-Host -ForegroundColor Cyan $Message; Break }
                "Medium" { $Emoji = [char]::ConvertFromUtf32(0x1F63F); $Message = "[$Emoji] $Text"; Write-Host -ForegroundColor Yellow $Message; Break }
                "High"   { $Emoji = [char]::ConvertFromUtf32(0x1F640); $Message = "[$Emoji] $Text"; Write-Host -ForegroundColor Red $Message; Break }
                Default  { $Message = "[*] $Text"; Write-Host $Message; }
            }

        } Else {

            Switch ($SeverityLevel) {

                "Passed" { $Message = "[+] $Text"; Write-Host -ForegroundColor Gray $Message; Break }
                "Low"    { $Message = "[-] $Text"; Write-Host -ForegroundColor Cyan $Message; Break }
                "Medium" { $Message = "[$] $Text"; Write-Host -ForegroundColor Yellow $Message; Break }
                "High"   { $Message = "[!] $Text"; Write-Host -ForegroundColor Red $Message; Break }
                Default  { $Message = "[*] $Text"; Write-Host $Message; }
            }
        }
    }
```

```powershell
## Set up logging function
function Log-Message
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateSet('Error','Info')]
        [string]$Level,
        [Parameter(Mandatory=$true)]
        [string]$Message
    )

# Get current date and time
$timestamp = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')

# Get current script or function name
$caller = (Get-Variable MyInvocation -Scope 1).Value.InvocationName

# Get current line number
$line = (Get-Variable MyInvocation -Scope 1).Value.ScriptLineNumber

# Get current file name
$file = (Get-Variable MyInvocation -Scope 1).Value.ScriptName

# Build log message
$logMessage = "[$timestamp] [$Level] [$file:$line] $caller: $Message"

# Write log message to file
Add-Content -Path C:\logs\script.log -Value $logMessage

# Write log message to console (optional)
Write-Output $logMessage
}

# Example usage
Log-Message -Level Info -Message "This is an info message"
Log-Message -Level Error -Message "This is an error message"
```

```powershell
# Set up log file path and filename
$logFile = "C:\Logs\Script.log"

# Set up log function
function Write-Log
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet('Error','Info')]
        [string]$Type,
        [Parameter(Mandatory=$true)]
        [string]$Message
    )

    # Get caller information
    $caller = (Get-Variable MyInvocation -Scope 1).Value
    $line = $caller.ScriptLineNumber
    $position = $caller.ScriptLineNumber
    $file = $caller.ScriptName
    $function = $caller.MyCommand.Name

    # Format log message
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp $Type: Line $line, Pos $position, File $file, Function $function - $Message"
    $logMessage = '{0} [{1}] [{2} {3} {4}]: {5}' -f $Timestamp, $Type, $Line - $Function - $File, $Message

    # Write log message to file
    Add-Content -Path $logFile -Value $logMessage

    # Write log message to console
    Write-Output $logMessage
}

# Example usage
Write-Log -Type Error -Message "An error has occurred."
Write-Log -Type Info -Message "This is an info message."
```

```powershell
function Log
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Severity = "Info"
    )

    # Determine the current date and time
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Write the log message to the console
    Write-Output "$Timestamp $Severity: $Message"

    # Append the log message to a log file
    Add-Content -Path "C:\Scripts\Logs\Script.log" -Value "$Timestamp $Severity: $Message"
}

Log -Message "This is an info message"
Log -Message "This is a warning message" -Severity "Warning"
Log -Message "This is an error message" -Severity "Error"
```

```powershell
Function Write-LogEntry
{
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Message,

        [Parameter(
            Mandatory = $false,
            Position = 2
        )]
        [string]
        $Source = '',

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Severity for the log entry (INFORMATION, WARNING or ERROR)"
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet(
            "INFORMATION",
            "WARNING",
            "ERROR"
        )]
        [String]
        $Severity = "INFORMATION",

        [parameter(
            Mandatory = $false,
            HelpMessage = "Name of the log file that the entry will written to"
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $OutputLogFile = $Global:LogFilePath
    )

    Begin
    {
        $TimeStamp = Get-Date -Format '[MM/dd/yyyy hh:mm:ss]'
    }

    Process
    {
        # Get the file name of the source script
        Try
        {
            If ($script:MyInvocation.Value.ScriptName)
            {
                [string]$ScriptSource = Split-Path -Path $script:MyInvocation.Value.ScriptName -LeafBase -ErrorAction 'Stop'
            }
            Else
            {
                [string]$ScriptSource = Split-Path -Path $script:MyInvocation.MyCommand.Definition -LeafBase -ErrorAction 'Stop'
            }
        }
        Catch
        {
            $ScriptSource = ''
        }

        # $LogFormat = "{0} {1}: {2} {3}" -f $TimeStamp, $Severity, $ScriptSource, $Message
        $LogFormat = ("[$TimeStamp] [$Severity]:: In File:$ScriptSource Error:$Error[0].Exception.Message $Message")

        # Add value to log file
        try
        {
            if ( -not (Test-Path -Path $LogFilePath -PathType leaf) )
            {
                Add-Content -Path $OutputLogFile -Value $LogFormat -Encoding Default

            }
        }
        catch
        {
            Write-Host ("[{0}] [{1}]: Unable to append log entry to [{1}], Error: {2}" -f $TimeStamp, $ScriptSource, $OutputLogFile, "$Error[0].Exception.Message") -ForegroundColor Red
        }
    }
}

Function Write-LogEntry
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory = $false, Position = 2)]
        [string]$Source,

        [parameter(Mandatory = $false)]
        [ValidateSet(0, 1, 2, 3, 4, 5)]
        [int16]$Severity = 1,

        [parameter(Mandatory = $false, HelpMessage = "Name of the log file that the entry will written to.")]
        [ValidateNotNullOrEmpty()]
        [string]$OutputLogFile = $Global:LogFilePath,

        [parameter(Mandatory = $false)]
        [switch]$Outhost
    )
    ## Get the name of this function
    #[string]${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name
    if (-not $PSBoundParameters.ContainsKey('Verbose'))
    {
        $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
    }

    if (-not $PSBoundParameters.ContainsKey('Debug'))
    {
        $DebugPreference = $PSCmdlet.SessionState.PSVariable.GetValue('DebugPreference')
    }
    #get BIAS time
    [string]$LogTime = (Get-Date -Format 'HH:mm:ss.fff').ToString()
    [string]$LogDate = (Get-Date -Format 'MM-dd-yyyy').ToString()
    [int32]$script:LogTimeZoneBias = [timezone]::CurrentTimeZone.GetUtcOffset([datetime]::Now).TotalMinutes
    [string]$LogTimePlusBias = $LogTime + $script:LogTimeZoneBias

    #  Get the file name of the source script
    If ($Source)
    {
        $ScriptSource = $Source
    }
    Else
    {
        Try
        {
            If ($script:MyInvocation.Value.ScriptName)
            {
                [string]$ScriptSource = Split-Path -Path $script:MyInvocation.Value.ScriptName -Leaf -ErrorAction 'Stop'
            }
            Else
            {
                [string]$ScriptSource = Split-Path -Path $script:MyInvocation.MyCommand.Definition -Leaf -ErrorAction 'Stop'
            }
        }
        Catch
        {
            $ScriptSource = ''
        }
    }

    #if the severity is 4 or 5 make them 1; but output as verbose or debug respectfully.
    If ($Severity -eq 4) { $logSeverityAs = 1 }Else { $logSeverityAs = $Severity }
    If ($Severity -eq 5) { $logSeverityAs = 1 }Else { $logSeverityAs = $Severity }

    #generate CMTrace log format
    $LogFormat = "<![LOG[$Message]LOG]!>" + "<time=`"$LogTimePlusBias`" " + "date=`"$LogDate`" " + "component=`"$ScriptSource`" " + "context=`"$([Security.Principal.WindowsIdentity]::GetCurrent().Name)`" " + "type=`"$logSeverityAs`" " + "thread=`"$PID`" " + "file=`"$ScriptSource`">"

    # Add value to log file
    try
    {
        Out-File -InputObject $LogFormat -Append -NoClobber -Encoding Default -FilePath $OutputLogFile -ErrorAction Stop
    }
    catch
    {
        Write-Host ("[{0}] [{1}] :: Unable to append log entry to [{1}], error: {2}" -f $LogTimePlusBias, $ScriptSource, $OutputLogFile, $_.Exception.ErrorMessage) -ForegroundColor Red
    }

    #output the message to host
    If ($Outhost)
    {
        If ($Source)
        {
            $OutputMsg = ("[{0}] [{1}] :: {2}" -f $LogTimePlusBias, $Source, $Message)
        }
        Else
        {
            $OutputMsg = ("[{0}] [{1}] :: {2}" -f $LogTimePlusBias, $ScriptSource, $Message)
        }

        Switch ($Severity)
        {
            0 { Write-Host $OutputMsg -ForegroundColor Green }
            1 { Write-Host $OutputMsg -ForegroundColor Gray }
            2 { Write-Host $OutputMsg -ForegroundColor Yellow }
            3 { Write-Host $OutputMsg -ForegroundColor Red }
            4 { Write-Verbose $OutputMsg }
            5 { Write-Debug $OutputMsg }
            default { Write-Host $OutputMsg }
        }
    }
}
```

```powershell
function Write-ErrorsToFile
{
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $Message,

        [parameter(
            Mandatory = $false
        )]
        [ValidateSet(0, 1, 2, 3, 4, 5)]
        [int16]
        $Severity = 1,

        [parameter(
            Mandatory = $false,
            HelpMessage = "Name of the log file that the entry will written to."
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $OutputLogFile = $Global:LogFilePath
    )

    # $DateStamp = Get-Date -Format 'MM-dd-yyyy'
    # $LogFilePath = "$env:USERPROFILE\Desktop\$DateStamp-$env:ComputerName-GlobalErrors.log"

    if ($Global:Error)
    {
        if ( -not (Test-Path -Path $LogFilePath -PathType leaf) )
        {
            New-Item -Path $LogFilePath -ItemType File -Force
        }

    ($Global:Error | ForEach-Object -Process {
            # Some errors may have the Windows nature and don't have a path to any of the module's files
            $Global:ErrorInFile = if ($_.InvocationInfo.PSCommandPath)
            {
                Split-Path -Path $_.InvocationInfo.PSCommandPath -Leaf
            }

            [PSCustomObject] @{
                TimeStamp  = (Get-Date -Format '[MM/dd/yyyy hh:mm:ss]')
                LineNumber = $_.InvocationInfo.ScriptLineNumber
                InFile     = $ErrorInFile
                Message    = $_.Exception.Message
            }
        } | Sort-Object TimeStamp | Format-Table -HideTableHeaders -Wrap | Out-String).Trim() | Add-Content -Path $LogFilePath -Force -Encoding Default

        if (Test-Path -Path '\\DD2\Logs$' -PathType Container)
        {
            Move-Item -Path "$env:USERPROFILE\Desktop\*.log" -Destination '\\DD2\Logs$' -Force
        }
    }
}
```

```powershell
<#
    .SYNOPSIS
    Writes a message to a log file.

    .DESCRIPTION
        Writes an informational, warning or error message to a log file. Log entries can be written in basic (default) or cmtrace format. When using basic format, you can choose to include a date/time stamp if required.

    .PARAMETER Message
        THe message to write to the log file

    .PARAMETER Severity
        The severity of message to write to the log file. This can be Information, Warning or Error. Defaults to Information.

    .PARAMETER Path
        The path to the log file. Recommended to use Set-LogPath to set the path.
        #.PARAMETER AddDateTime (currently not supported)
        Adds a datetime stamp to each entry in the format YYYY-MM-DD HH:mm:ss.fff

    .EXAMPLE
        Write-LogEntry -Message "Searching for file" -Severity Information -Path C:\MyLog.log

        Description
        -----------
        Writes a basic log entry

    .EXAMPLE
        Write-LogEntry -Message "Searching for file" -Severity Warning -LogPath C:\MyLog.log -CMTraceFormat

        Description
        -----------
        Writes a CMTrace format log entry

    .EXAMPLE
        $Script:LogPath = "C:\MyLog.log"
        Write-LogEntry -Message "Searching for file" -Severity Information

        Description
        -----------
        First line creates the script variable LogPath
        Second line writes to the log file.
#>

function Write-LogEntry
{
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [String]
        $Message,

        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "Severity for the log entry (Information, Warning or Error)"
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet(
            "Information",
            "Warning",
            "Error")]
        [String]
        $Severity = "Information",

        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "The full path of the log file that the entry will written to"
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript(
            { (Test-Path -Path $_.Substring(0, $_.LastIndexOf("\")) -PathType Container) -and (Test-Path -Path $_ -PathType Leaf -IsValid) }
        )]
        [String]
        $Path = $LogFilePath,

        [Parameter(
            ParameterSetName = "CMTraceFormat",
            HelpMessage = "Indicates to use cmtrace compatible logging"
        )]
        [Switch]
        $CMTraceFormat
    )

    # Construct date and time for log entry (based on current culture)
    $Date = Get-Date -Format (Get-Culture).DateTimeFormat.ShortDatePattern
    $Time = Get-Date -Format (Get-Culture).DateTimeFormat.LongTimePattern.Replace("ss", "ss.fff")

    # Determine parameter set
    if ($CMTraceFormat)
    {
        # Convert severity value
        switch ($Severity)
        {
            "Information"
            {
                $CMSeverity = 1
            }
            "Warning"
            {
                $CMSeverity = 2
            }
            "Error"
            {
                $CMSeverity = 3
            }
        }

        # Construct components for log entry
        $Component = (Get-PSCallStack)[1].Command
        $ScriptFile = $MyInvocation.ScriptName

        # Construct context for CM log entry
        $Context = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
        $LogText = "<![LOG[$($Message)]LOG]!><time=""$($Time)"" date=""$($Date)"" component=""$($Component)"" context=""$($Context)"" type=""$($CMSeverity)"" thread=""$($PID)"" file=""$($ScriptFile)"">"
    }
    else
    {
        # Construct basic log entry
        # AddDateTime parameter currently not supported
        #if ($AddDateTime) {
        $LogText = "[{0} {1}] {2}: {3}" -f $Date, $Time, $Severity, $Message
        $logMessage = '{0} [{1}] [{2} {3} {4}]: {5}' -f $Timestamp, $Type, $Line - $Function - $File, $Message
        #}
        #else {
        #    $LogText = "{0}: {1}" -f $Severity, $Message
        #}
    }

    # Add value to log file
    try
    {
        Out-File -InputObject $LogText -Append -NoClobber -Encoding Default -FilePath $Path -ErrorAction Stop
    }
    catch [System.Exception]
    {
        Write-Warning -Message "Unable to append log entry to $($Path) file. Error message: $($_.Exception.Message)"
    }
}
```

```powershell
<#
.SYNOPSIS
    A short one-line action-based description, e.g. 'Tests if a function is valid'

.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.

.NOTES
    Information or caveats about the function e.g. 'This function is not supported in Linux'

.LINK
    Specify a URI to a help page, this will show when Get-Help -Online is used.

.EXAMPLE
    Write-LogEntry -Message ("Removed {0} built-in App PROVISIONED Package's" -f $d) -Outhost

    Write-LogEntry ("Reboot is required for remving the Feature on Demand package: {0}" -f $FeatName)

    Write-LogEntry -Message ("Removed {0} built-in App PROVISIONED Package's" -f $d) -Outhost

    Write-LogEntry -Message ("Removed {0} built-in App PROVISIONED Package's" -f $d) -Outhost

    try
        {
            Show-ProgressStatus -Message ("Removing Feature on Demand V2 package: {0}" -f $Feature) -Step $f -MaxStep $OnDemandFeatures.count -Outhost

            $results = Remove-WindowsCapability -Name $Feature -Online -ErrorAction Stop
            if ($results.RestartNeeded -eq $true)
            {
                Write-LogEntry ("Reboot is required for remving the Feature on Demand package: {0}" -f $FeatName)
            }
        }
        catch [System.Exception]
        {
            Write-LogEntry -Message ("Failed to remove Feature on Demand V2 package: {0}" -f $_.Message) -Severity 3 -Outhost
        }

        $ErrorMessage = $_.Exception.Message

Write-LogEntry ("Unable to remove item from [{0}]. Error [{1}]" -f $Path.FullName, $ErrorMessage) -Source ${CmdletName} -Severity 3 -Outhost

Write-LogEntry -Message ("Failed to copy files: {0}. Error [{1}]" -f $ErrorMessage) -Source ${CmdletName} -Severity 3 -Outhost

Write-LogEntry ("Unable to remove item from [{0}] because it does not exist any longer" -f $Item.FullName) -Source ${CmdletName} -Severity 2 -Outhost

Write-LogEntry -Message ("Removed {0} built-in App PROVISIONED Package's" -f $d) -Outhost

Write-LogEntry ("Reboot is required for remving the Feature on Demand package: {0}" -f $FeatName)

Write-LogEntry -Message ("Removed {0} built-in App PROVISIONED Package's" -f $d) -Outhost

Write-LogEntry -Message ("Removed {0} built-in App PROVISIONED Package's" -f $d) -Outhost

try
{
    Show-ProgressStatus -Message ("Removing Feature on Demand V2 package: {0}" -f $Feature) -Step $f -MaxStep $OnDemandFeatures.count -Outhost

    $results = Remove-WindowsCapability -Name $Feature -Online -ErrorAction Stop
    if ($results.RestartNeeded -eq $true)
    {
        Write-LogEntry ("Reboot is required for remving the Feature on Demand package: {0}" -f $FeatName)
    }
}
catch [System.Exception]
{
    Write-LogEntry -Message ("Failed to remove Feature on Demand V2 package: {0}" -f $_.Message) -Severity 3 -Outhost
}
#>

Function Write-LogEntry
{
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message,

        [Parameter(
            Mandatory = $false,
            Position = 2
        )]
        [string]
        $Source = '',

        [parameter(
            Mandatory = $false
        )]
        [ValidateSet(0, 1, 2, 3, 4)]
        [int16]
        $Severity,

        [parameter(
            Mandatory = $false,
            HelpMessage = "Name of the log file that the entry will written to"
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $OutputLogFile = $Global:LogFilePath,

        [parameter(
            Mandatory = $false
        )]
        [switch]
        $Outhost
    )

    Begin
    {
        [string]$LogTime = (Get-Date -Format 'HH:mm:ss.fff').ToString()
        [string]$LogDate = (Get-Date -Format 'MM-dd-yyyy').ToString()
        [int32]$script:LogTimeZoneBias = [timezone]::CurrentTimeZone.GetUtcOffset([datetime]::Now).TotalMinutes
        [string]$LogTimePlusBias = $LogTime + $script:LogTimeZoneBias

    }

    Process
    {
        # Get the file name of the source script
        Try
        {
            If ($script:MyInvocation.Value.ScriptName)
            {
                [string]$ScriptSource = Split-Path -Path $script:MyInvocation.Value.ScriptName -Leaf -ErrorAction 'Stop'
            }
            Else
            {
                [string]$ScriptSource = Split-Path -Path $script:MyInvocation.MyCommand.Definition -Leaf -ErrorAction 'Stop'
            }
        }
        Catch
        {
            $ScriptSource = ''
        }


        If (!$Severity)
        {
            $Severity = 1
        }

        $LogFormat = "<![LOG[$Message]LOG]!>" + "<time=`"$LogTimePlusBias`" " + "date=`"$LogDate`" " + "component=`"$ScriptSource`" " + "context=`"$([Security.Principal.WindowsIdentity]::GetCurrent().Name)`" " + "type=`"$Severity`" " + "thread=`"$PID`" " + "file=`"$ScriptSource`">"

        # Add value to log file
        try
        {
            Out-File -InputObject $LogFormat -Append -NoClobber -Encoding Default -FilePath $OutputLogFile -ErrorAction Stop
        }
        catch
        {
            Write-Host ("[{0}] [{1}] :: Unable to append log entry to [{1}], error: {2}" -f $LogTimePlusBias, $ScriptSource, $OutputLogFile, $_.Exception.Message) -ForegroundColor Red
        }
    }
    End
    {
        If ($Outhost -or $Global:OutTohost)
        {
            If ($Source)
            {
                $OutputMsg = ("[{0}] [{1}] :: {2}" -f $LogTimePlusBias, $Source, $Message)
            }
            Else
            {
                $OutputMsg = ("[{0}] [{1}] :: {2}" -f $LogTimePlusBias, $ScriptSource, $Message)
            }

            Switch ($Severity)
            {
                0 { Write-Host $OutputMsg -ForegroundColor Green }
                1 { Write-Host $OutputMsg -ForegroundColor Gray }
                2 { Write-Warning $OutputMsg }
                3 { Write-Host $OutputMsg -ForegroundColor Red }
                4 { If ($Global:Verbose) { Write-Verbose $OutputMsg } }
                default { Write-Host $OutputMsg }
            }
        }
    }
}
```

```powershell
Function Format-ElapsedTime
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $TS
    )

    $elapsedTime = ""
    if ($ts.Minutes -gt 0)
    {
        $elapsedTime = [string]::Format( "{0:00} min. {1:00}.{2:00} sec", $ts.Minutes, $ts.Seconds, $ts.Milliseconds / 10 )
    }
    else
    {
        $elapsedTime = [string]::Format( "{0:00}.{1:00} sec", $ts.Seconds, $ts.Milliseconds / 10 )
    }
    if ($ts.Hours -eq 0 -and $ts.Minutes -eq 0 -and $ts.Seconds -eq 0)
    {
        $elapsedTime = [string]::Format("{0:00} ms", $ts.Milliseconds)
    }
    if ($ts.Milliseconds -eq 0)
    {
        $elapsedTime = [string]::Format("{0} ms", $ts.TotalMilliseconds)
    }
    return $elapsedTime
}

Function Format-DatePrefix
{
    [string]$LogTime = (Get-Date -Format 'HH:mm:ss.fff').ToString()
    [string]$LogDate = (Get-Date -Format 'MM-dd-yyyy').ToString()
    return ($LogDate + " " + $LogTime)
}
```

```powershell
<#
.EXAMPLE
    Write-LogEntry -Message ("Unable to process appx removal because the Windows OS version [{0}] was not tested" -f $OSInfo.version)

    Write-LogEntry -Message "Failed removing AppxProvisioningPackage: $($Error[0].Exception.Message)" -Severity Error

    Write-LogEntry -Message "Failed : $($Error[0].Exception.Message)" -Severity Warning
    Write-LogEntry -Message "Failed : $($Error[0].Exception.Message)" -Severity Warning -CMTraceFormat

    Write-LogEntry ("LGPO applying [{3}] to registry: [{0}\{1}\{2}] as a Group Policy item" -f 'hello','Testing','one','two') -CMTraceFormat

    try
    {
        Show-ProgressStatus -Message ("Removing Feature on Demand V2 package: {0}" -f $Feature) -Step $f -MaxStep $OnDemandFeatures.count -Outhost

        $results = Remove-WindowsCapability -Name $Feature -Online -ErrorAction Stop
        if ($results.RestartNeeded -eq $true)
        {
            Write-LogEntry ("Reboot is required for removing the Feature on Demand package: {0}" -f $FeatName)
        }
    }
    catch [System.Exception]
    {
        Write-LogEntry -Message ("Failed to remove Feature on Demand V2 package: {0}" -f $_.Message) -Severity 3 -Outhost
    }
# >

Function Write-LogEntry
{
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $Message,

        [Parameter(
            Mandatory = $false,
            Position = 2
        )]
        [string]
        $Source = '',

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Severity for the log entry (Information, Warning or Error)"
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet(
            "Information",
            "Warning",
            "Error"
        )]
        [String]
        $Severity = "Information",

        [parameter(
            Mandatory = $false,
            HelpMessage = "Name of the log file that the entry will written to"
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $OutputLogFile = $Global:LogFilePath,

        [parameter(
            Mandatory = $false
        )]
        [switch]
        $Outhost,

        [Parameter(
            ParameterSetName = "CMTraceFormat",
            HelpMessage = "Indicates to use cmtrace compatible logging"
        )]
        [Switch]
        $CMTraceFormat
    )

    Begin
    {
        [string]$LogTime = (Get-Date -Format 'HH:mm:ss.fff').ToString()
        [string]$LogDate = (Get-Date -Format 'MM-dd-yyyy').ToString()
        [int32]$script:LogTimeZoneBias = [timezone]::CurrentTimeZone.GetUtcOffset([datetime]::Now).TotalMinutes
        [string]$LogTimePlusBias = $LogTime + $script:LogTimeZoneBias

        $TimeStamp = Get-Date -Format '[MM/dd/yyyy hh:mm:ss]'
    }

    Process
    {
        # Get the file name of the source script
        Try
        {
            If ($script:MyInvocation.Value.ScriptName)
            {
                [string]$ScriptSource = Split-Path -Path $script:MyInvocation.Value.ScriptName -Leaf -ErrorAction 'Stop'
            }
            Else
            {
                [string]$ScriptSource = Split-Path -Path $script:MyInvocation.MyCommand.Definition -Leaf -ErrorAction 'Stop'
            }
        }
        Catch
        {
            $ScriptSource = ''
        }

        if ($CMTraceFormat)
        {
            # Convert severity value
            switch ($Severity)
            {
                "Information"
                {
                    $CMSeverity = 1
                }
                "Warning"
                {
                    $CMSeverity = 2
                }
                "Error"
                {
                    $CMSeverity = 3
                }
            }

            $LogFormat = "<![LOG[$Message]LOG]!>" + "<time=`"$LogTimePlusBias`" " + "date=`"$LogDate`" " + "component=`"$ScriptSource`" " + "context=`"$([Security.Principal.WindowsIdentity]::GetCurrent().Name)`" " + "type=`"$CMSeverity`" " + "thread=`"$PID`" " + "file=`"$ScriptSource`">"
        }
        else
        {
            $LogFormat = "{0} {1}: {2}" -f $TimeStamp, $Severity, $ScriptSource + $Message
        }

        # Add value to log file
        try
        {
            Out-File -InputObject $LogFormat -Append -NoClobber -Encoding Default -FilePath $OutputLogFile -ErrorAction Stop
        }
        catch
        {
            Write-Host ("[{0}] [{1}] :: Unable to append log entry to [{1}], error: {2}" -f $LogTimePlusBias, $ScriptSource, $OutputLogFile, $_.Exception.Message) -ForegroundColor Red
        }
    }

    End
    {
        If ($Outhost -or $Global:OutTohost)
        {
            If ($Source)
            {
                $OutputMsg = ("[{0}] [{1}] :: {2}" -f $LogTimePlusBias, $Source, $Message)
            }
            Else
            {
                $OutputMsg = ("[{0}] [{1}] :: {2}" -f $LogTimePlusBias, $ScriptSource, $Message)
            }

            Switch ($Severity)
            {
                0 { Write-Host $OutputMsg -ForegroundColor Green }
                1 { Write-Host $OutputMsg -ForegroundColor Gray }
                2 { Write-Warning $OutputMsg }
                3 { Write-Host $OutputMsg -ForegroundColor Red }
                4 { If ($Global:Verbose) { Write-Verbose $OutputMsg } }
                default { Write-Host $OutputMsg }
            }
        }
    }
}

$DateStamp = Get-Date -Format 'MM-dd-yyyy'

if ($Global:Error)
{
    if ( -not (Test-Path -Path "$env:USERPROFILE\Desktop\$DateStamp-Errors.log" -PathType leaf) )
    {
        New-Item -Path "$env:USERPROFILE\Desktop\$DateStamp-Errors.log" -ItemType File -Force
    }

    ($Global:Error | ForEach-Object -Process {
        # Some errors may have the Windows nature and don't have a path to any of the module's files
        $Global:ErrorInFile = if ($_.InvocationInfo.PSCommandPath)
        {
            Split-Path -Path $_.InvocationInfo.PSCommandPath -Leaf
        }

        [PSCustomObject] @{
            TimeStamp  = (Get-Date -Format '[MM/dd/yyyy hh:mm:ss]')
            LineNumber = $_.InvocationInfo.ScriptLineNumber
            InFile     = $ErrorInFile
            Message    = $_.Exception.Message
        }
    } | Out-String).Trim() | Sort-Object TimeStamp | Format-Table -Wrap | Add-Content -Path "$env:USERPROFILE\Desktop\$DateStamp-Errors.log" -Force

    if (Test-Path -Path '\\DD2\Logs$' -PathType Container)
    {
        Copy-Item -Path "$env:USERPROFILE\Desktop\*" -Destination '\\DD2\Logs$' -Filter *.log -Container:$false
    }
}

if ($Global:Error)
{
    $Message = (
        $Global:Error | ForEach-Object -Process {
            # Some errors may have the Windows nature and don't have a path to any of the module's files
            $Global:ErrorInFile = if ($_.InvocationInfo.PSCommandPath)
            {
                Split-Path -Path $_.InvocationInfo.PSCommandPath -Leaf
            }

            [PSCustomObject] @{
                TimeStamp  = (Get-Date -Format '[MM/dd/yyyy hh:mm:ss]')
                LineNumber = $_.InvocationInfo.ScriptLineNumber
                InFile     = $ErrorInFile
                Message    = $_.Exception.Message
            }
        }
    )
}

if ( -not (Test-Path -Path "$env:USERPROFILE\Desktop\$DateStamp-Errors.log" -PathType leaf) )
{
    New-Item -Path "$env:USERPROFILE\Desktop\$DateStamp-Errors.log" -ItemType File -Force
}

$Message | Sort-Object TimeStamp | Format-Table -AutoSize -Wrap
Sort-Object TimeStamp | Format-Table -AutoSize -Wrap

$Message | Add-Content -Path "$Env:USERPROFILE\Desktop\$DateStamp-Errors.log" -Force -Encoding UTF8

if (Test-Path -Path '\\DD2\Logs$' -PathType Container)
{
    Copy-Item -Path "\\dd2\Logs$\$DateStamp-Errors.log" -Destination '\\DD2\Logs$' -Filter *.log -Recurse -Container:$false
}

Get-Content -Path 'asd'
Write-LogEntry ("Unable to Copy item from [{0}] because it does not exist any longer" -f $Source.FullName) -Severity Warning

Write-LogEntry -Message ("Error {0}" -f $Error[0].Exception.Message"") -Severity Error

$Error.Clear()

Remove-Module -Name PSLogging -Force
Import-Module -Name PSLogging

Set-Variable -Name sScriptVersion -Value '1.0'
Set-Variable -Name sLogPath -Value '\\dd2\Logs$\Logging'
Set-Variable -Name sLogName -Value "$(Get-Date -Format 'MM-dd-yyyy')-Log.log "
Set-Variable -Name sLogFile -Value (Join-Path -Path $sLogPath -ChildPath $sLogName)

Start-Log -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion

Write-LogInfo -LogPath $sLogFile -Message '<description of what is going on>...' -ToScreen

Try
{
    get-fooboohoo
}
Catch
{
    Write-LogError -LogPath $sLogFile -Message $_.Exception -ExitGracefully -ToScreen
}

If ($?)
{
    Write-LogInfo -LogPath $sLogFile -Message 'Completed Successfully.'
    Write-LogInfo -LogPath $sLogFile -Message ' '
}

$Global:Error.Clear()

Stop-Log -LogPath $sLogFile

Import-Module -Name EZLog
$LogFilePath = "\\dd2\Logs$\Logging-$(Get-Date -Format 'MM-dd-yyyy').log"
$PSDefaultParameterValues = @{
    'Write-EZLog:LogFile'   = $LogFilePath
    'Write-EZLog:Delimiter' = ';'
    'Write-EZLog:ToScreen'  = $true
}

$levelNumber = Get-LevelNumber -Level $PSBoundParameters.Level
$invocationInfo = [Get-PSCallStack]($Script:Logging.CallerScope)

# Split-Path throws an exception if called with a -Path that is null or empty

[string] $fileName = [string]::Empty
if (-not [string]::IsNullOrEmpty($invocationInfo.ScriptName))
{
    $fileName = Split-Path -Path $invocationInfo.ScriptName -Leaf
}
$logMessage = [hashtable] @{
    timestamp    = [datetime]::now
    timestamputc = [datetime]::UtcNow
    level        = Get-LevelName -Level $levelNumber
    levelno      = $levelNumber
    lineno       = $invocationInfo.ScriptLineNumber
    pathname     = $invocationInfo.ScriptName
    filename     = $fileName
    caller       = $invocationInfo.Command
    message      = [string] $Message
    rawmessage   = [string] $Message
    body         = $Body
    execinfo     = $ExceptionInfo
    pid          = $PID
}

if ($PSBoundParameters.ContainsKey('Arguments'))
{
    $logMessage["message"] = [string] $Message -f $Arguments
    $logMessage["args"] = $Arguments
}

Remove-Module -Name Logging -Force
Import-Module -Name Logging

Add-LoggingTarget -Name File -Configuration @{
    Path              = "\\dd2\logs$\%{+%d-%m-%Y}-$env:COMPUTERNAME.log" # <Required> Sets the file destination (eg. 'C:\Temp\%{+%Y%m%d}.log' It supports template's like $Logging.Format)
    PrintBody         = $true # <N\R> Prints body message too
    PrintException    = $true # <N\R> Prints stacktrace
    Append            = $true # <N\R> Append to log file
    Level             = 'DEBUG' # <N\R> Sets the logging level for this target
    Format            = '[%{timestamputc:+%d-%m-%Y %T} %{level}] [InFile: %{filename}] [line: %{lineno}] %{message}' # <N\R> Sets the logging format for this target
    RotateAfterAmount = 7 # <N\R> Sets the amount of files after which rotation is triggered
}

get-fooboohoo

Write-Log -Level 'WARNING' -Message 'Hello, Powershell!'
Write-Log -Level 'WARNING' -Message 'Hello, {0}!' -Arguments 'Powershell'
Write-Log -Level 'WARNING' -Message 'Hello, {0}!' -Arguments 'Powershell' -Body @{source = 'Logging' }

# Write-Log -Level 'ERROR' -Message "$Error"

Write-Log -Level 'INFO' -Message "Test"

$Global:Error.Clear()

New-ScriptLog -LogType Memory -MessagesOnConsole @("Error", "Verbose")
Add-LoggingTarget -Name Console -Configuration @{
    $ColorMapping  = @{
        'DEBUG'   = 'Blue'
        'INFO'    = 'Green'
        'WARNING' = 'Yellow'
        'ERROR'   = 'Red'
    }
    Level          = 'INFO'
    Format         = '[%{filename}] [%{caller}] %{message}'
    PrintException = $true
}

Set-LoggingDefaultLevel -Level 'Verbose'
Set-LoggingDefaultFormat -Format '[%{timestamputc:+%d-%m-%Y %T} %{level}] [InFile: %{filename}] [line: %{lineno}] %{message}'
Add-LoggingTarget -Name File -Configuration @{
    Path              = '\\dd2\logs$\%{+%d-%m-%Y}-Errors.log'
    PrintBody         = $true
    PrintException    = $true
    Append            = $true
    RotateAfterAmount = 7
}

Set-LoggingCallerScope -CallerScope 2
Set-LoggingDefaultLevel -Level 'INFO'
Add-LoggingTarget -Name File -Configuration @{
    Path              = '\\dd2\logs$\%{+%d-%m-%Y}-MosesAutomation.log'
    PrintBody         = $false
    PrintException    = $false
    Append            = $true
    RotateAfterAmount = 7
}
New-ScriptLog -Path "\\dd2\DeploymentShare$\Logs" -BaseName "Verbose" -MessagesOnConsole "Verbose"

Write-Log -Level INFO -Message 'End Moses Automation Setup'

# <https://www.powershellgallery.com/packages/LogTools>

# <https://github.com/jesymoen/PowerShellLogTools>

# To enable logging of Write-Verbose, Write-Warning and Write-Error use the following

# - Create a logfile

# - Add-LogFileHooking

# - Run Initialize-LogOutput to initialize the logfile

# Check to see if the log directory exists, and if not creates it and returns it as a variable

$Global:LogDir = New-LogDirectory -Name "\\dd2\logs$"

# Create the logfile name

$ErrorLogfile = New-LogFileName -LogBaseName ErrorLogfile -LogDir $LogDir -Extension log

# Enable logfile hooking which will redirect the Write-Verbose, Write-Warning, Write-Error, and Write-Debug cmdlets

# Enable-LogFileHooking -LogFile $ErrorLogfile -ThrowExceptionOnWriteError

if ($ErrorLogfile)
{
    # Set a variable to indicate that logging is enabled
    $LoggingEnabled = $true
}
else
{
    # Set a variable to indicate that logging is not enabled
    $LoggingEnabled = $false
}

# Removes the LogFileHooking feature, including associated aliases that hook Write-Verbose, Write-Warning, Write-Debug and Write-Error, and global variables

if ($LoggingEnabled)
{
    # Removes the LogFileHooking feature, including associated aliases that hook Write-Verbose, Write-Warning, Write-Debug and Write-Error, and global variables.
    # Disable-LogFileHooking

    # Deletes old logfiles more than the value of 'RetentionDays' days old.
    Clear-LogFileHistory -Path $LogDir -RetentionDays 7
}
$LogDir = New-LogDirectory -Name "\\dd2\logs$"
$ErrorLogfile = New-LogFileName -LogBaseName ErrorLogfile -LogDir $LogDir -Extension log
Get-Variable -Name MyInvocation | Initialize-LogFile -Logfile $ErrorLogfile
Enable-LogFileHooking -LogFile $ErrorLogfile -ThrowExceptionOnWriteError

Get-ChildItem C:\test.txt

$Global:Error.Clear()
```
