using namespace Microsoft.PowerShell.Commands
using namespace System
using namespace System.IO
using namespace System.Management.Automation

# Ensure we're using the primary write commands from the Microsoft.PowerShell.Utility module.
Set-Alias -Name 'Write-Progress'    -Value 'Microsoft.PowerShell.Utility\Write-Progress'    -Scope Script
Set-Alias -Name 'Write-Debug'       -Value 'Microsoft.PowerShell.Utility\Write-Debug'       -Scope Script
Set-Alias -Name 'Write-Verbose'     -Value 'Microsoft.PowerShell.Utility\Write-Verbose'     -Scope Script
Set-Alias -Name 'Write-Host'        -Value 'Microsoft.PowerShell.Utility\Write-Host'        -Scope Script
Set-Alias -Name 'Write-Information' -Value 'Microsoft.PowerShell.Utility\Write-Information' -Scope Script
Set-Alias -Name 'Write-Warning'     -Value 'Microsoft.PowerShell.Utility\Write-Warning'     -Scope Script
Set-Alias -Name 'Write-Error'       -Value 'Microsoft.PowerShell.Utility\Write-Error'       -Scope Script


function Get-CurrentPath {
<#
    .SYNOPSIS
    Returns the current location's provider path.

    .OUTPUTS
    Returns the ProviderPath except when the current location matches the start to a UNC path.
    In those cases the $executionContext.SessionState.Path.CurrentLocation.Path is returned instead.
#>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    $ProviderPath = (Get-Location).ProviderPath
    $result = if ($ProviderPath -match '\\\\') {
        $executionContext.SessionState.Path.CurrentLocation.Path
    } else {
        $ProviderPath
    }

    return $result
}


function Get-LastExecutionDuration {
<#
    .SYNOPSIS
    Returns the duration of the last executed command.
    This logic was taken from Steve Lee's powershell profile:
        https://gist.github.com/SteveL-MSFT/a208d2bd924691bae7ec7904cab0bd8e
#>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory=$false)]
        [HistoryInfo]$LastCommand = (Get-History -Count 1 -ErrorAction Ignore)
    )

    if ($null -ne $LastCommand) {
        $cmdTime = if ($PSVersionTable.PSEdition -eq 'Desktop') {
            ($LastCommand.EndExecutionTime - $LastCommand.StartExecutionTime).TotalMilliseconds
        } else {
            $LastCommand.Duration.TotalMilliseconds
        }

        $units = 'ms'
        if ($cmdTime -ge 1000) {
            $units = 's'
            $cmdTime = $LastCommand.Duration.TotalSeconds
            if ($cmdTime -ge 60) {
                $units = 'm'
                $cmdTIme = $LastCommand.Duration.TotalMinutes
            }
        }

        if ($cmdTime) { return "$($cmdTime.ToString('#.##'))$units " }
    }

    return ''
}


function Get-PSProfileEditionString {
<#
    .SYNOPSIS
    Returns a formatted string to more easily determine which platform is currently running.
#>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    $Edition = if ($PSVersionTable.PSEdition -eq 'Desktop') {
        'PS'
    } elseif ($PSVersionTable.PSEdition -eq 'Core') {
        'Pwsh' + (. {if ($IsLinux) { '-Linux' } elseif ($IsMacOS) { '-MacOS' } })
    } elseif ([string]::IsNullOrWhiteSpace($PSVersionTable.PSEdition.ToString()) -eq $false) {
        $PSVersionTable.PSEdition.ToString()
    } else {
        [string]::Empty
    }

    return $Edition
}


function Get-PSVersionString {
<#
    .SYNOPSIS
    Returns a string containing the PSProfileEditionString and the PSVersion major minor and patch information.
#>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    $Psv = $PSVersionTable.PSVersion
    return (Get-PSProfileEditionString) +" v$($Psv.Major).$($Psv.Minor).$($Psv.Patch)"
}


function Get-ShellPath {
<#
    .SYNOPSIS
    Creates a .shell directory in the users home and returns the directoryinfo object to the user.

    .DESCRIPTION
    Creates a .shell directory under the users home directory (or the windows users home directory for WSL) and returns
    the directoryinfo object to the user.
#>
    [CmdletBinding()]
    [OutputType([System.IO.DirectoryInfo])]
    param()

    $ShellPath = if ($IsLinux -and [IO.Directory]::Exists("/mnt/c/Users/$env:USER")) {
        Join-Path -Path "/mnt/c/Users/$env:USER" -ChildPath '.shell'
    } else {
        Join-Path -Path (. { if ($env:OS -eq 'Windows_NT') { $HOME } else { $env:HOME } }) -ChildPath '.shell'
    }

    # Create the ShellPath if it doesn't exist.
    return (New-Item -Path $ShellPath -ItemType Directory -Force)
}


function Initialize-ProfileModule {
<#
    .SYNOPSIS
    Initialize-ProfileModule attempts to import a module and will automatically install it if it doesn't exist.

    .PARAMETER Name
    The name of the module to be imported.

    .PARAMETER MinimumVersion
    The minimum version of the module to be imported. Default is '0.0.1'.

    .PARAMETER AllowPrerelease
    Allow the import of prerelease module versions.

    .PARAMETER ArgumentList
    The ArgumentList passed into the Import-Module command.
#>
    [CmdletBinding()]
    [OutputType([Void])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]$Names,

        [Parameter(Mandatory=$false)]
        [string]$MinimumVersion = '0.0.1',

        [Parameter(Mandatory=$false)]
        [switch]$AllowPrerelease,

        [Parameter(Mandatory=$false)]
        [string[]]$ArgumentList = @()
    )

    begin {
        $Scope = if (Test-Admin) { 'AllUsers' } else { 'CurrentUser' }
        $Verbose = if ($PSBoundParameters.ContainsKey('Verbose')) { $PSBoundParameters['Verbose'] } else { $false }

        # Fix missing PSGet versions on windows.
        $PSGet = 'PowerShellGet'
        $PSGV  = '2.2.5'
        if (
            ($env:OS -eq 'Windows_NT') -and
            ($null -eq (Get-Module -Name $PSGet -ListAvailable | Where-Object {$_.Version -eq $PSGV}))
        ) {
            $PSApp = if ($IsWindows) { 'pwsh.exe' } else { 'powershell.exe' }
            # Start the update in another process so that we don't have issues with clobbering.
            $InstallPSGet = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes(@"
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor
                                                    [Net.SecurityProtocolType]::Tls12
if (`$null -eq (Get-PackageProvider -Name 'NuGet' -ErrorAction Ignore)) {
    Install-PackageProvider -Name NuGet -Force
}
Install-Module -Name '$PSGet' -RequiredVersion '$PSGV' -Scope '$Scope' -Repository 'PSGallery' -AllowClobber -Force
"@
))
            if ($Verbose) { $InstallPSGet += ' -Verbose' }
            Start-Process -FilePath $PSApp -Wait -NoNewWindow -ArgumentList '-noprofile', '-ec', $InstallPSGet
        }
    }

    process {
        foreach ($moduleName in $Names){
            $InstallModule = @{
                Name            = $moduleName
                MinimumVersion  = $MinimumVersion
                AllowPrerelease = $AllowPrerelease
                Scope           = $Scope
                Repository      = 'PSGallery'
                AcceptLicense   = $true
                Force           = $true
                Verbose         = $Verbose
            }

            $ImportModuleParams = @{
                Name           = $moduleName
                MinimumVersion = $MinimumVersion
                Scope          = 'Global'
                Verbose        = $Verbose
            }
            if ($ArgumentList.Length -gt 0) {
                $ImportModuleParams.Add('ArgumentList', $ArgumentList)
            }

            try {
                Import-Module @ImportModuleParams -ErrorAction Stop
            } catch [FileNotFoundException] {
                Install-Module @InstallModule
                Import-Module @ImportModuleParams
            }
        }
    }

}


function New-UserProcessEnvVar {
<#
    .SYNOPSIS
    Creates a new environment variable with a value of the current datetime.

    .PARAMETER VarName
    The name of the new environment variable to create.

    .PARAMETER Value
    The value to put into the environment variable.
#>
    [CmdletBinding()]
    [OutputType([Void])]
    param (
        [Parameter(Mandatory)]
        [string]$VarName,

        [Parameter(Mandatory = $false)]
        [string]$Value = [DateTime]::Now
    )

    [Environment]::SetEnvironmentVariable( $VarName, $Value, [EnvironmentVariableTarget]::User )
    [Environment]::SetEnvironmentVariable( $VarName, $Value, [EnvironmentVariableTarget]::Process )
}


function Set-ProfileLinks {
<#
    .SYNOPSIS
    This function consolidates all editions of your PowerShell profile by linking them to a common profile file
    located at the specified $ShellPath.
    Any changes made to this profile script will apply across all your PowerShell sessions and editions.

    .DESCRIPTION
    This function is meant to be used with the profile script found here:
        https://gist.github.com/tsmarvin/3ec5df59e030886a9f81a693ba01f785

    The function begins by checking for the ProfileLink environment variable:
        ((Get-PSProfileEditionString) + '_UpdateProfileLinks')

    If the environment variable exists, the function exits without performing any actions.

    If the environment variable does not exist:
        On Windows:
            First determine whether the $CommandPath is hardlinked to the $ShellProfile ($ShellPath + profile.ps1) file.
            If it is not hardlinkd, prompt the user to create a new hardlink between the files.

        All Platforms:
            The function checks if the $CommandPath is linked to the $Profile.CurrentUserAllHosts script.
            If the $Profile.CurrentUserAllHosts script doesn't exist, prompt the user to create a new link.
            On Linux, a symbolic link will be created, while on Windows, a hardlink will be used instead.

        Finally, the function creates the ProfileLink environment variable and sets it to the current date and time.

    .PARAMETER ShellPath
    This parameter specifies the path to the directory where the shell profile script ('profile.ps1') is located.

    .PARAMETER PSProfileEdition
    This parameter represents the PowerShell edition, as determined by the PowerShell Profile script.

    .PARAMETER CommandPath
    This parameter is used to specify the path of the currently executing script.
#>
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory)]
        [Validation.ValidatePathExists('File')]
        [string]$CommandPath
    )

    # The path to the shell profile script
    $ShellProfile = Join-Path -Path (Get-ShellPath).FullName -ChildPath 'profile.ps1'
    # The name of the environment variable storing the status of profile linking
    $ProfileLink = (Get-PSProfileEditionString) + '_UpdateProfileLinks'

    # Check if the ProfileLink environment variable is empty
    if ([string]::IsNullOrEmpty((Get-Item -Path "Env:\$ProfileLink" -ErrorAction Ignore).Value)) {

        # If the operating system is Windows and the executing script is not linked to the shell profile script
        if (
            ($env:OS -eq 'Windows_NT') -and (
                ($null -eq (Get-Item -Path $CommandPath).Target) -or
                ((Get-Item -Path $ShellProfile -ErrorAction Ignore).Target -notcontains $CommandPath)
            )
        ) {
            # Parameters for creating a new hard link
            $NewHardLinkParams = [hashtable]@{
                ItemType = 'HardLink'
                Force    = $true
                Verbose  = $true
            }

            # If the current executing script is not the same as the shell profile script
            if ($CommandPath -ne $ShellProfile) {
                Write-Warning (
                    "Currently executing profile script '$CommandPath' " +
                    "has not been linked to the ShellProfile '$ShellProfile'."
                )
                # Prompt the user to link the current executing script to the shell profile script
                if ((Read-Host "Link '$CommandPath' to '$ShellProfile'? (Y/N)") -ieq 'Y') {
                    New-Item -Path $ShellProfile -Value $CommandPath @NewHardLinkParams | Out-Null
                }
            }

            if <# the $Profile.CurrentUserAllHosts is not linked to the shell profile script #> (
                ($null -eq (Get-Item -Path $Profile.CurrentUserAllHosts -ErrorAction Ignore).Target) -and
                ((Resolve-Path -Path $CommandPath) -eq (Resolve-Path -Path $ShellProfile))
            ) {
                Write-Warning (
                    "Profile script '$($Profile.CurrentUserAllHosts)' " +
                    "has not been linked to the ShellProfile '$ShellProfile'."
                )
                # Prompt the user to link the profile for all hosts of the current user to the shell profile script
                if ((Read-Host "Link '$($Profile.CurrentUserAllHosts)' to '$ShellProfile'? (Y/N)") -ieq 'Y') {
                    New-Item -Path $Profile.CurrentUserAllHosts -Value $ShellProfile @NewHardLinkParams | Out-Null
                }
            }
        }

        # If the $Profile.CurrentUserAllHosts script doesn't exist then link it to the shell profile.
        if ($null -eq (Get-Item -Path $Profile.CurrentUserAllHosts -ErrorAction Ignore)) {
            Write-Warning "PowerShell Profile '$($Profile.CurrentUserAllHosts)' does not exist."
            $LinkProfilePrompt = (. {
                "$(if ($env:OS -eq 'Windows_NT') { 'Hard' } else { 'Symbolic' })" +
                "Link '$($Profile.CurrentUserAllHosts)' to '$ShellProfile'? (Y/N)"
            })

            # Prompt the user to link the profile for all hosts of the current user to the shell profile script
            if ((Read-Host -Prompt $LinkProfilePrompt) -ieq 'Y') {
                $newItemSplat = @{
                    Path        = $Profile.CurrentUserAllHosts
                    ItemType    = "$(if ($env:OS -eq 'Windows_NT') { 'HardLink' } else { 'SymbolicLink' })"
                    Value       = $ShellProfile
                    Force       = $true
                    Verbose     = $true
                    ErrorAction = 'Stop'
                }
                try {
                    New-Item @newItemSplat | Out-Null
                } catch {
                    Write-Warning (
                        "Failed to create link between '$($Profile.CurrentUserAllHosts)' and '$ShellProfile'. " +
                        "Error: $($_.Exception.Message)"
                    )
                    break # Don't run ProfileLinkCreation
                }
            }
        }

        # Create the ProfileLink environment variable with the current date and time
        New-UserProcessEnvVar -VarName $ProfileLink
    }
}


function Set-WindowTitle {
<#
    .SYNOPSIS
    Sets the window title based on the current PowerShell session and provider.

    .DESCRIPTION
    Updates the window title with the PowerShell version, provider name, and adds an [Admin] prefix
    if the session is running with administrative privileges.
#>
    [CmdletBinding()]
    [OutputType([Void])]
    param()

    try {
        $AdminText = if (Test-Admin) { '[Admin] ' } else { [string]::Empty }
        $Host.Ui.RawUi.WindowTitle = "$AdminText$(Get-PSVersionString) [$($pwd.Provider.Name)]"
    } catch { <# Do Not Fail #> }
}


function Test-Admin {
<#
    .SYNOPSIS
    Tests to determine if the user is running the powershell process as an admin.

    .DESCRIPTION
    On Windows, checks the security group to determine if the user is a member of the local admin group.
    On Linux, checks to see if the user is root, or has sudo enabled.
    On MacOs, always returns false at this time.
#>
    [CmdletBinding()]
    [OutputType([boolean])]
    param()

    $IsAdmin = if ($env:OS -eq 'Windows_NT') {
        [Security.Principal.WindowsPrincipal]::New(
            [Security.Principal.WindowsIdentity]::GetCurrent()
        ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } elseif ($IsLinux -and (($env:USER -ieq 'root') -or ([string]::IsNullOrWhiteSpace($env:SUDO_USER) -eq $false))) {
        $true
    } else {
        $false
    }

    return $IsAdmin
}


function Update-ProfileScriptFromGist {
<#
    .SYNOPSIS
    Update the profile script every 25+ hours.

    .DESCRIPTION
    Update-ProfileScriptFromGist checks the last update time from the environment variable 'ProfileGistUpdate'.
    If it has been more than a 25 hours since the last update, the function starts a new job that updates the profile
    script.

    This function is meant to be used with the profile script found here:
        https://gist.github.com/tsmarvin/3ec5df59e030886a9f81a693ba01f785

    .PARAMETER CommandPath
    The path to the PowerShell profile script.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.Job],[string])]
    param (
        [Parameter(Mandatory)]
        [Validation.ValidatePathExists('File')]
        [string]$CommandPath,

        [Parameter(Mandatory=$false)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$UpdateIntervalHours = 25
    )

    $EnvVarName = 'ProfileGistUpdate'

    $EnvVarValue = (Get-Item -Path "Env:\$EnvVarName" -ErrorAction Ignore).Value
    $UpdateTime = if ([string]::IsNullOrWhiteSpace($EnvVarValue) -eq $false) {
        [DateTime]::Parse($EnvVarValue)
    } else {
        [DateTime]::Now.AddHours(-$UpdateIntervalHours)
    }

    $result = if ($UpdateTime.AddDays(1) -lt [DateTime]::Now) {
        Start-BackgroundGistScriptUpdate -LocalScriptPath $CommandPath
        New-UserProcessEnvVar -VarName $EnvVarName
    } else {
        [string]::Empty
    }

    return $result
}


if ($IsWindows) {
    # Add Support for retrieving hardlink definitions on windows using dotnet core.
    # Recreates the "Target" property with integrated hardlink support which emulates Windows PowerShell functionality.
    # This c# code was based on https://github.com/PowerShell/PowerShell/issues/15139#issuecomment-812567971
    # This functionality is specifically used by Set-ProfileLinks - but its also just nice to have in general.
    $AddWinUtilNTFS = [hashtable]@{
        Name             = 'NTFS'
        Namespace        = 'WinUtil'
        UsingNamespace   = 'System.Text', 'System.Collections.Generic', 'System.IO'
        MemberDefinition = @'
#region WinAPI P/Invoke declarations
public static readonly IntPtr INVALID_HANDLE_VALUE = (IntPtr)(-1); // 0xffffffff;
public const int MAX_PATH = 65535; // Max. NTFS path length.

[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
static extern IntPtr FindFirstFileNameW(
  string lpFileName,
  uint dwFlags,
  ref uint StringLength,
  StringBuilder LinkName
);

[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
static extern bool FindNextFileNameW(
  IntPtr hFindStream,
  ref uint StringLength,
  StringBuilder LinkName
);

[DllImport("kernel32.dll", SetLastError = true)]
static extern bool FindClose(IntPtr hFindFile);

[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
static extern bool GetVolumePathName(
  string lpszFileName,
  [Out] StringBuilder lpszVolumePathName,
  uint cchBufferLength
);
#endregion

/// <summary>
/// Returns the enumeration of hardlinks for the given filepath excluding the input file itself.
/// </summary>
/// <param name="filePath"></param>
/// <returns>
/// If the file has one or more hardlink (including itself) then the enumerate hardlinks (excluding itself)
/// are returned. <br/>
///
/// This means that if the hardlink only links to itself then you will receive an empty array. <br/>
///
/// If the target volume doesn't support enumerating hardlinks, the filePath doesn't exist, or the filePath
/// is the path to a directory than a null value is returned instead.
/// </returns>
public static string[] GetHardLinks(string filePath) {
  string fullFilePath = Path.GetFullPath(filePath);

  // If the filepath is a directory or the file does not exist then return early.
  if (Directory.Exists(fullFilePath) || File.Exists(fullFilePath) == false) { return null; }

  // Generate Volume Path
  StringBuilder sbPath = new(MAX_PATH);
  _ = GetVolumePathName(fullFilePath, sbPath, MAX_PATH); // Get target file volume (e.g. "C:\")

  // Trim the trailing "\" from the volume path, to enable simple concatenation with the volume-relative
  // paths returned by the FindFirstFileNameW() and FindFirstFileNameW() functions, which have a leading "\"
  string volume = sbPath.ToString()[..(sbPath.Length > 0 ? sbPath.Length - 1 : 0)];

  // Loop over and collect all hard links as their full paths.
  uint charCount = MAX_PATH; // in/out character-count variable for the WinAPI calls.
  IntPtr findHandle;
  if (INVALID_HANDLE_VALUE != (findHandle = FindFirstFileNameW(fullFilePath, 0, ref charCount, sbPath))) {
    List<string> result = new();
    // Add each non-self path to the results list
    do {
      string fullHardlinkPath = volume + sbPath.ToString();
      if (fullHardlinkPath.Equals(fullFilePath, StringComparison.OrdinalIgnoreCase) == false) {
        result.Add(fullHardlinkPath); // Add the full path to the result list.
      }
      charCount = MAX_PATH; // Prepare for the next FindNextFileNameW() call.
    } while (FindNextFileNameW(findHandle, ref charCount, sbPath));

    FindClose(findHandle);
    return result.ToArray();
  }
  return null;
}
'@
    }
    try {
        Add-Type @AddWinUtilNTFS -ErrorAction Stop
    } catch {
        # Don't fail if the type already exists
        if ($_.Exception.Message -ne "Cannot add type. The type name 'WinUtil.NTFS' already exists."){
            throw
        }
    }

    Update-TypeData -Force -TypeName System.IO.FileInfo -MemberName Target -MemberType ScriptProperty -Value {
        # Output the target, if the file at hand is a symbolic link (reparse point).
        [string[]]$local:TempTarget = [InternalSymbolicLinkLinkCodeMethods]::GetTarget($this)
        if ($local:TempTarget) {
            , [string[]]$local:TempTarget
        } else {
            [string[]]$local:TempHardlinks = [WinUtil.NTFS]::GetHardLinks($this.FullName)
            if ($null -ne $local:TempHardlinks -and $local:TempHardlinks.Length -gt 0) {
                , [string[]]$local:TempHardlinks
            }
        }
    }
}
