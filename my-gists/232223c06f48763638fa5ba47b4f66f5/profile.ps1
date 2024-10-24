<#PSScriptInfo
.VERSION
    2.0.16
.GUID
    afb483cb-cb15-4de8-bda9-8e737bdaf2b5
.AUTHOR
    Taylor Marvin
.COMPANYNAME
    N/A
.COPYRIGHT
    Taylor Marvin (2023)
.PROJECTURI
    https://gist.github.com/tsmarvin/3ec5df59e030886a9f81a693ba01f785
.DESCRIPTION
    Taylor Marvin's PowerShell Profile Script.

    This PowerShell profile script has been designed for compatibility with Windows PowerShell 5.1 and PowerShell
    7.2+ across Windows, Linux, and MacOS. It delivers consistent environment initialization, prompt customization,
    and a wide range of utility functions and enhancements for your PowerShell experience.

    This script imports (or installs and imports) the following modules:
        TM-ProfileUtility        : https://gist.github.com/tsmarvin/fe2d09ed245e6951f77937febfe5bba9
        TM-PSGitHubGistManagement: https://gist.github.com/tsmarvin/c28208e85409e914c7009c336d123a71
        TM-RandomUtility         : https://gist.github.com/tsmarvin/f40ad59f33b12d88dc0682771c1a3fdc
        TM-ValidationUtility     : https://gist.github.com/tsmarvin/823b52ee8a827bd177bc9584f717319b
        TM-SessionHistory        : https://gist.github.com/tsmarvin/77350ac4ca11715b0e7b3d0fde6472e5
        TM-DataManipulation      : https://gist.github.com/tsmarvin/f1da993cee28588113040e1a248de249\

    These modules are imported every time, but their commands are not made public unless git/docker exists in the path.
        TM-GitUtility    : https://gist.github.com/tsmarvin/835fb35a18d3d7c9d2e09455bcd2c04e
        TM-DockerUtility : https://gist.github.com/tsmarvin/3bc7427f4c98d6cd4642fb55d40752fa

    This script also conditionally imports the following modules:
        TM-WindowsUtility                  : https://gist.github.com/tsmarvin/3e9c1a092214fd8269cbe4c2170d49a6
        SetLocationWSLOverride             : https://github.com/tsmarvin/SetLocationWSLOverride
        Microsoft.PowerShell.UnixCompleters: https://github.com/PowerShell/UnixCompleters
        EditorServicesCommandSuite         : https://github.com/SeeminglyScience/EditorServicesCommandSuite
#>

#region Environment Init
using namespace Microsoft.PowerShell.Commands
using namespace System.IO
using namespace System.Management.Automation

# Default all encodings to utf8 no-bom.
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

# Don't start in System32.
if ($executionContext.SessionState.Path.CurrentLocation.Path -ieq 'C:\Windows\System32') {
    Set-Location ~
}

# Ensure we're using the primary write commands from the Microsoft.PowerShell.Utility module.
Set-Alias -Name 'Write-Progress'    -Value 'Microsoft.PowerShell.Utility\Write-Progress'    -Scope Script
Set-Alias -Name 'Write-Debug'       -Value 'Microsoft.PowerShell.Utility\Write-Debug'       -Scope Script
Set-Alias -Name 'Write-Verbose'     -Value 'Microsoft.PowerShell.Utility\Write-Verbose'     -Scope Script
Set-Alias -Name 'Write-Host'        -Value 'Microsoft.PowerShell.Utility\Write-Host'        -Scope Script
Set-Alias -Name 'Write-Information' -Value 'Microsoft.PowerShell.Utility\Write-Information' -Scope Script
Set-Alias -Name 'Write-Warning'     -Value 'Microsoft.PowerShell.Utility\Write-Warning'     -Scope Script
Set-Alias -Name 'Write-Error'       -Value 'Microsoft.PowerShell.Utility\Write-Error'       -Scope Script

function New-PrivateConstantVariable {
<#
    .SYNOPSIS
    Create Private, Constant, Locally Scoped variables for use within the profile.

    .DESCRIPTION
    This function is intended to make the "profile script" variables invisible to the user/debuggers.
    These variables drive some of the profile script functions and previously visibly poluted the users profile session.
    The variables are now less likey to distract the end user, and because the variables are constants they will cause
    an error if the user accidentally tries to reuse them.

    .PARAMETER Name
    The name of the variable that will be created.

    .PARAMETER Value
    The variable value.

    .PARAMETER PassThru
    A switch that indicates that the PSVariable should be returned to the caller.

    .OUTPUTS
    Void unless PassThru is selected. A PSVariable is returned when PassThru is selected.
#>
    [CmdletBinding()]
    [OutputType([Void], [PSVariable])]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [object]$Value,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Local', 'Script')]
        [string]$Scope = 'Script',

        [Parameter(Mandatory = $false)]
        [switch]$PassThru
    )

    $preExistingVar = Get-Variable -Name $Name -Scope $Scope -ErrorAction Ignore
    if ($null -ne $preExistingVar){
        if ($value -eq $preExistingVar.Value){
            return # exit early and don't notify if we're just trying to reset the same value.
        }
    }

    [hashtable]$newVariableSplat = @{
        Name       = $Name
        Value      = $Value
        Visibility = 'Private'
        Option     = 'Constant'
        Scope      = $Scope
        PassThru   = $PassThru
    }
    return (New-Variable @newVariableSplat)
}

# Import the main profile utility module or install it if it doesn't exist.
New-PrivateConstantVariable -Name 'ProfileUtil' -Value 'TM-ProfileUtility'
New-Variable -Name 'PrfMinVer' -Option private, readonly -Scope Script -Value '0.0.14' -Force -ErrorAction Ignore
try {
    try {
        Import-Module $script:ProfileUtil -MinimumVersion $script:PrfUtlMinVer -ErrorAction Stop
    } catch [FileNotFoundException] {
        # Start this in another process so that if we need to update PSGet later we still can.
        New-PrivateConstantVariable -Name 'PSApp' -Value (. {
            if ($PSVersionTable.PSEdition -eq 'Desktop') {
                'powershell.exe'
            } elseif ($IsWindows) {
                'pwsh.exe'
            } else {
                'pwsh'
            }
        } )
        New-PrivateConstantVariable -Name 'InstallProfileUtil' -Value (
            "Install-Module -Name ""$script:ProfileUtil"" " +
                "-RequiredVersion ""$script:PrfMinVer"" "   +
                "-Scope ""CurrentUser"" "                   +
                '-Repository "PSGallery" '                  +
                '-AllowClobber '                            +
                '-Force'
        )
        Start-Process -FilePath $script:PSApp -ArgumentList '-noprofile', '-c', $script:InstallProfileUtil -Wait -NoNewWindow
        Import-Module $script:ProfileUtil -MinimumVersion $script:PrfMinVer -ErrorAction Stop
    }
} catch {
    Write-Warning "Failed to load reqired module '$script:ProfileUtil'. Error: $($_.Exception.Message)"

    New-PrivateConstantVariable -Name 'Reset' -Value (
        Read-Host -Prompt 'Redownload the latest profile script and reset profile utility modules? (Y/N)'
    )

    if ($Reset -ieq 'Y'){
        # Remove existing profile utility modules
        Get-Module -Name 'TM-*' -ListAvailable | Foreach-Object {
            Write-Verbose "Removing module $($_.Name) v$($_.Version)" -Verbose
            Uninstall-Module $_ -Force
        }

        # Re-download the script and save it to the currently running file.
        Set-Content -Path $PSCommandPath -Encoding UTF8 -Value (
            Invoke-RestMethod -Method Get -Uri 'https://api.github.com/gists/3ec5df59e030886a9f81a693ba01f785'
        ).Files.'Profile.ps1'.Content

        # Re-Run the script and exit so we don't try to process the rest of the script twice.
        . $PSCommandPath
        exit
    } else {
        Write-Warning 'Exiting early to prevent additional errors.'
        break
    }
}

# Set prompt function variables.
New-PrivateConstantVariable -Name 'IsAdmin' -Value (Test-Admin)
New-PrivateConstantVariable -Name 'GitExists' -Value (Test-ApplicationExistsInPath -ApplicationName 'git')

# Create the ShellPath location for use in the Set-ProfileLinks function and a variable for use by the end user.
New-Variable -Name 'ShellPath' -Option Constant -Scope Script -Value (Get-ShellPath).FullName -ErrorAction Ignore

#endregion Environment Init


#region Script Actions

# Load the "Non-Public Profile" (if it exists).
New-PrivateConstantVariable -Name 'NonPublicProfile' -Value (
    Join-Path -Path $script:ShellPath -ChildPath 'NonPublicProfile.ps1'
)
if ([IO.File]::Exists($script:NonPublicProfile)) { . $script:NonPublicProfile }

# Import (or Install and Import) Profile Utility Modules
Initialize-ProfileModule -Name 'TM-DataManipulation', 'TM-ValidationUtility' -MinimumVersion '0.0.4'
Initialize-ProfileModule -Name 'TM-SessionHistory', 'TM-PSGitHubGistManagement' -MinimumVersion '0.0.6'
Initialize-ProfileModule -Name 'TM-RandomUtility' -MinimumVersion '0.0.7'
Initialize-ProfileModule -Name 'TM-GitUtility','TM-DockerUtility' -MinimumVersion '0.0.8'

if ($env:OS -eq 'Windows_NT') {
    # Load the TM-WindowsUtility module and then ensure the ConsoleArgWriter utility exists.
    Initialize-ProfileModule -Name 'TM-WindowsUtility' -MinimumVersion '0.0.9'
    New-PrivateConstantVariable -Name 'ShellBinPath' -Value (Join-Path -Path $script:ShellPath -ChildPath 'bin')
    if ((Test-Path -Path $script:ShellBinPath -PathType Container) -eq $false) {
        New-Item -Path $script:ShellBinPath -ItemType Directory -Force | Out-Null
    }
    New-ConsoleArgWriter -ShellBinPath $script:ShellBinPath
} elseif ($IsLinux) {
    # Load the SetLocationWSLOverride and UnixCompleters modules and then import Unix shell completers.
    Initialize-ProfileModule -Name 'SetLocationWSLOverride' -MinimumVersion '1.1.1'
    Initialize-ProfileModule -Name 'Microsoft.PowerShell.UnixCompleters'
    Import-UnixCompleters
}

# Import EditorServicesCommandSuite when using vscode - module is used for some keybindings.
if ($null -ne (Get-ChildItem -Path 'Env:\VSCODE_*')) {
    Initialize-ProfileModule -Name 'EditorServicesCommandSuite' -AllowPrerelease
}

# Link all profiles, and the calling script, to the shell profile. Reduces the places to change on script update.
Set-ProfileLinks -CommandPath $PSCommandPath

# Once a day - Check for updates to the Profile script.
New-PrivateConstantVariable -Name 'UpdateProfileJob' -Value (Update-ProfileScriptFromGist -CommandPath $PSCommandPath)
if ([string]::IsNullOrEmpty($script:UpdateProfileJob) -eq $false) {
    Receive-Job -Job $script:UpdateProfileJob -Wait -AutoRemoveJob
}

#endregion Script Actions

function Prompt {
<#
    .SYNOPSIS
    Customizes the PowerShell command prompt with additional information.

    .DESCRIPTION
    This function updates the PowerShell command prompt to include the following information:
        - The Current date and time.
        - The Admin context (if applicable).
        - The PSProvider name (if not FileSystem).
        - The Current directory path.
        - The current Git branch (if applicable).
        - The Last command execution duration.
        - The Last command execution status
            - As either (Y) (N) for Windows PowerShell and 💚 or 🚨 for all other editions.
#>
    [CmdletBinding()]
    [OutputType([string])]
    param ()
    begin {
        $lastSuccess = $?
        $SuccessStatus = if ($PSVersionTable.PSEdition -eq 'Desktop') {
            if ($lastSuccess) { '(Y) ' } else { '(N) ' }
        } else {
            if ($lastSuccess) { "💚" } else { "🚨" }
        }
        $currentLastExitCode = $LASTEXITCODE
        $PathSep = [IO.Path]::DirectorySeparatorChar
        Set-WindowTitle
    }

    process {
        if ($script:IsAdmin) {
            # Add admin to command prompt
            Write-Host '[' -NoNewline -ForegroundColor White
            Write-Host 'Admin' -NoNewline -ForegroundColor Red
            Write-Host '] ' -NoNewline -ForegroundColor White
        }

        Write-Host "$([DateTime]::Now.ToString('yyyy-MM-ddTHH:mm:ss.ffzz')) " -NoNewline
        if ($pwd.Provider.Name -ne 'FileSystem') {
            # Add Provider type to prompt if its not filesystem.
            Write-Host '[' -NoNewline -ForegroundColor White
            Write-Host $pwd.Provider.Name -NoNewline -ForegroundColor Green
            Write-Host '] ' -NoNewline -ForegroundColor White
        }

        if ($script:GitExists) { Write-Host (Get-GitBranch) -NoNewline -ForegroundColor White }

        $CurrentPath = Get-CurrentPath
        $PromptPath = if ($CurrentPath.Split($PathSep).count -lt 4) {
            $CurrentPath
        } elseif ($CurrentPath.StartsWith('\\') -and ($CurrentPath.Split('\').count -ge 6)) {
            $PathSplit = $CurrentPath.Split('\')
            "\\$($PathSplit[2])\...\$($PathSplit[-2])\$($PathSplit[-1])"
        } else {
            $PathSplit = $CurrentPath.Split($PathSep)
            "$($PathSplit[0])$PathSep...$PathSep$($PathSplit[-2])$PathSep$($PathSplit[-1])"
        }
        Write-Host $PromptPath -NoNewline -ForegroundColor White
    }

    end {
        Set-SessionHistory
        $global:LASTEXITCODE = $currentLastExitCode
        return "`n$(Get-LastExecutionDuration)${SuccessStatus}PS$('>' * ($nestedPromptLevel + 1)) "
    }
}
