<#
.SYNOPSIS
  Dynamic Multi-Platform PowerShell Profile Loader
.DESCRIPTION
  Safe this script named 'profile.ps1' in either $PROFILE.AllUsersAllHosts or
  $PROFILE.CurrentUserAllHosts.
  Check for updates here:   https://gist.github.com/jpawlowski/77f8f07603b4d7e796c7ac02dc5d3241/raw/47619f3f887c81645822b1c10c8c6b8722984eb7/profile.ps1
  (see: https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_profiles#the-profile-variable)

  It will automatically create a directory structure for every PS host
  application, platform and PowerShell edition you use and replicate itself as
  the respective *_profile.ps1 script to help structuring your profile
  systematically.

  If you use this script for your PowerShell Core setup on Windows, it will
  also replicate itself to the legacy PowerShell Desktop edition, also known
  as Windows PowerShell.
  Your PowerShell Core profile becomes the leading profile and all your profile
  scripts and files will be synced automatically. That will make you feel at
  home for those cases you need to go back and quickly use Windows PowerShell
  for whatever reason.

  Why sync the two folders instead of using a symlink?
  The answer is simple: To improve stability when syncing the PowerShell
  profile, for example using OneDrive. It also provides maximum compatibility
  as the entire profile is wholly transparent to any 3rd-party tools.

  If you're not ready to make the switch to PowerShell Core just yet, this
  profile script will simply work as well. When you're ready to switch over,
  simply rename your profile folder from 'WindowsPowerShell' to 'PowerShell'
  and you're good to go with PowerShell Core. Like explained above, you will
  keep a fallback to Windows PowerShell whenever needed.

  As you start using other PowerShell host applications besides the standalone
  powershell.exe or pwsh.exe shell, the profile will automatically be expanded
  for those. For example, when you start to use Visual Studio Code for
  PowerShell development (or its predecessor Windows PowerShell ISE for
  PowerShell 5), the same folder structure is automatically provided. You may
  then improve your profile settings and behaviours for that particular host
  application. (Maybe have a different PowerShell prompt setup?)

  Lastly, if you would like to share the same PowerShell profile on Linux and
  macOS, you can do so and share common functions and scripts that you want
  to use everywhere. There are also platform specific folders to target specific
  needs and address differences between all your working environments.
.INPUTS
  None
.OUTPUTS
  None
.NOTES
  Author:         Julian Pawlowski, Twitter: @Loredo, GitHub: @jpawlowski
  Creation Date:  2021-11-01
.LINK
  Source: https://github.com/jpawlowski/PowerShell-profile.template
#>

# Multi-platform compatibility for Windows PowerShell
if (-Not $PSEdition) {
    $Global:PSEdition = 'Desktop'
    $Global:IsCoreCLR = $false
}
if ($PSEdition -eq 'Desktop') {
    $Global:IsLinux = $false
    $Global:IsMacOS = $false
    $Global:IsWindows = $true
}

$myName = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$ProfileFileName = $myName.Split('_')
$count = 1
$ProfileDirectories = New-Object -TypeName psobject
$FirstUseHost = $false

# Invoke path on macOS when run directly
# from iTerm or standalone login shell
if (
    $IsMacOS -and
    ($myName -eq 'profile')
) {
    function Get-macOSPaths {
        [CmdLetBinding()]
        Param()
        $PathFiles = @()
        $PathFiles  += '/etc/paths'
        $PathFiles += Get-ChildItem -Path /private/etc/paths.d | Select-Object -Expand FullName
        $PathFiles | ForEach-Object {
            Get-Content -Path $_ | ForEach-Object {
                $_
            }
        }
    }

    $macOSPaths = $env:PATH -split ':'
    Get-macOSPaths | ForEach-Object {
        If ($_ -notin $macOSPaths) {
            Write-Verbose "Adding $_ to Path"
            $env:PATH = "${env:PATH}:$_"
        }
    }
    Remove-Item Function:Get-macOSPaths

    # Homebrew support
    if (Test-Path -LiteralPath '/opt/homebrew/bin/brew' -PathType Leaf -ErrorAction SilentlyContinue) {
        $HBPaths = /opt/homebrew/bin/brew shellenv
        if ($HBPaths) {
            foreach ($line in $HBPaths.Split("\n")) {
                $line = ($line -replace '(^export )').Split('=')
                $linePaths = (($line[1] -replace '[";]') -replace '\$\{.*\}' ).Split(':')
                $macOSPaths = Get-Item -Path $('env:' + $line[0]) -ErrorAction SilentlyContinue

                if ($macOSPaths) {
                    $macOSPaths = $macOSPaths -split ':'
                    foreach ($linePath in $linePaths) {
                        If ($linePath -notin $macOSPaths) {
                            Write-Verbose ("Adding $linePath to " + $line[0])
                            $Value = $linePath + ':' + (Get-Item -Path $('env:' + $line[0])).Value
                            Set-Item -Path $('env:' + $line[0]) -Value $Value
                        }
                    }
                } else {
                    Write-Verbose ("Adding $linePaths to " + $line[0])
                    Set-Item -Path $('env:' + $line[0]) -Value $linePaths
                }
            }
        }
    }
}

# Test each Arg for match of abbreviated '-NonInteractive' command.
$Global:NonInteractive = $false
if (
    ([Environment]::GetCommandLineArgs() | Where-Object { $_ -like '-NonI*' }) -or
    -Not [Environment]::UserInteractive
) {
    $Global:NonInteractive = $true
}

# Only initialize minimal profile environment for
# non-interactive sessions as -NoProfile would miss A LOT
if ($NonInteractive) {
    exit 0
}

## CurrentUserAllHosts + AllUsersAllHosts
#
if ($ProfileFileName[0] -eq 'profile') {
    $myself = $MyInvocation.MyCommand.Path
    $UpdatedSelf = $false
    $UpdatedWPS = $false

    if ($PROFILE.CurrentUserAllHosts -eq $myself) {
        $Global:PSProfileType = 'personal'
    } else {
        $Global:PSProfileType = 'system'
    }
    Write-Host "`nLoading $SyncProfileNameType profile:" -ForegroundColor Green
    Add-Member -InputObject $ProfileDirectories -MemberType NoteProperty -Name $myName -Value (Join-Path $PSScriptRoot 'Profile')

    $shellName = [Regex]::Escape((Join-Path ' ' 'PowerShell').Trim())
    if (-Not $IsCoreCLR) {
        $shellName = [Regex]::Escape((Join-Path ' ' 'WindowsPowerShell').Trim())
    }

    # Duplicate self to CurrentUserCurrentHosts
    if (Test-Path $PROFILE.CurrentUserCurrentHost) {
        if ((Get-FileHash $myself).hash -ne (Get-FileHash $PROFILE.CurrentUserCurrentHost).hash) {
            Write-Host "  $count. Cloning self to:" -ForegroundColor White
            $DestinationName = $PROFILE.CurrentUserCurrentHost -replace "(.+(?=$shellName))"
            Write-Host "       $DestinationName"
            Copy-Item $myself $PROFILE.CurrentUserCurrentHost
            $count++
            $UpdatedSelf = $true
        }
    } else {
        Write-Host "  $count. Cloning self to:" -ForegroundColor White
        $DestinationName = $PROFILE.CurrentUserCurrentHost -replace "(.+(?=$shellName))"
        Write-Host "       $DestinationName"
        Copy-Item $myself $PROFILE.CurrentUserCurrentHost
        $count++
        $UpdatedSelf = $true
        $FirstUseHost = $PROFILE.CurrentUserCurrentHost
    }

    # On Windows, perform sync to WindowsPowerShell folder
    if ($IsWindows) {
        $SyncSource = $PSScriptRoot
        $SyncDestination = $PSScriptRoot -replace '(PowerShell$)','WindowsPowerShell'
        if (-Not $IsCoreCLR) {
            $SyncSource = $PSScriptRoot -replace '(WindowsPowerShell$)','PowerShell'
            $SyncDestination = $PSScriptRoot
        }

        # Duplicate self only when running PS Core edition
        if ($IsCoreCLR) {
            New-Item -ItemType Directory -Force -Path (Join-Path $SyncDestination 'Profile')  | Out-Null

            $WPSProfile = Join-Path $SyncDestination 'profile.ps1'
            if (Test-Path $WPSProfile) {
                if ((Get-FileHash $myself).Hash -ne (Get-FileHash $WPSProfile).Hash) {
                    if (-Not $UpdatedSelf) {
                        Write-Host "  $count. Cloning self to:" -ForegroundColor White
                        $count++
                    }
                    $shellName = [Regex]::Escape((Join-Path ' ' 'WindowsPowerShell').Trim())
                    $DestinationName = $WPSProfile -replace "(.+(?=$shellName))"
                    Write-Host "       $DestinationName"
                    Copy-Item $myself $WPSProfile
                }
            } else {
                if (-Not $UpdatedSelf) {
                    Write-Host "  $count. Cloning self to:" -ForegroundColor White
                    $count++
                }
                $shellName = [Regex]::Escape((Join-Path ' ' 'WindowsPowerShell').Trim())
                $DestinationName = $WPSProfile -replace "(.+(?=$shellName))"
                Write-Host "       $DestinationName"
                Copy-Item $myself $WPSProfile
            }
        }

        $SyncProfileName = Join-Path $SyncSource 'profile.ps1'

        # When running Windows PowerShell, only sync from PS Core folder if the profile.ps1
        # is already in sync.
        if (
            (-Not $IsCoreCLR) -and
            (Test-Path $SyncProfileName -PathType Leaf) -and
            ((Get-FileHash $myself).Hash -ne (Get-FileHash $SyncProfileName).Hash)
        ) {
            if (Test-Path (Join-Path $SyncSource 'Profile') -PathType Container) {
                Write-Host '  ' -NoNewline
                Write-Host ' ! ' -NoNewline -ForegroundColor Black -BackgroundColor Yellow
                Write-Host ' Sync from PowerShell Core profile folder paused.' -ForegroundColor Yellow
                Write-Host '      Start PowerShell Core shell once to re-enable.' -ForegroundColor Yellow
            } else {
                Write-Host '  ' -NoNewline
                Write-Host ' i ' -NoNewline -ForegroundColor Black -BackgroundColor Cyan
                Write-Host ' Detected independent profile setup for PowerShell Core: Profile sync disabled.' -ForegroundColor Cyan
            }
        }

        # Duplicate PowerShell Core profile content to WindowsPowerShell folder
        elseif (
            ($IsCoreCLR) -or
            (Test-Path $SyncProfileName)
        ) {
            # Cleanup orphan files in WindowsPowerShell folder
            Get-ChildItem -Directory $SyncDestination -Filter 'Profile*' | ForEach-Object {
                $Source = $_.FullName
                $Destination = Join-Path $SyncSource $_.Name
                Get-ChildItem $Source -Recurse | ForEach-Object {
                    $ModifiedDestination = $($_.FullName).Replace("$Source","$Destination")

                    if (
                        (Test-Path -Path $_.FullName -PathType Container) -and
                        (-Not (Test-Path -Path $ModifiedDestination -PathType Container))
                    ) {
                        if (-Not $UpdatedWPS) {
                            Write-Host "  $count. Syncing profile to WindowsPowerShell folder:" -ForegroundColor White
                            $count++
                            $UpdatedWPS = $true
                        }
                        $shellName = [Regex]::Escape((Join-Path ' ' 'WindowsPowerShell').Trim())
                        $DestinationName = $_.FullName -replace "(.+(?=$shellName))"
                        Write-Host '      -' -NoNewline -ForegroundColor DarkRed
                        Write-Host $DestinationName
                        Remove-Item $_.FullName -Force -Recurse
                    }
                    elseif (
                        (Test-Path -Path $_.FullName -PathType Leaf) -and
                        (-Not (Test-Path -Path $ModifiedDestination -PathType Leaf))
                    ) {
                        if (-Not $UpdatedWPS) {
                            Write-Host "  $count. Syncing profile to WindowsPowerShell folder:" -ForegroundColor White
                            $count++
                            $UpdatedWPS = $true
                        }
                        $shellName = [Regex]::Escape((Join-Path ' ' 'WindowsPowerShell').Trim())
                        $DestinationName = $_.FullName -replace "(.+(?=$shellName))"
                        Write-Host '      -' -NoNewline -ForegroundColor DarkRed
                        Write-Host $DestinationName
                        Remove-Item $_.FullName
                    }
                }
            }

            # Copy files from PowerShell Core to WindowsPowerShell folder
            Get-ChildItem -Directory $SyncSource -Filter 'Profile*' | ForEach-Object {
                $Source = $_.FullName
                $Destination = Join-Path $SyncDestination $_.Name
                Get-ChildItem $Source -Recurse | ForEach-Object {
                    $ModifiedDestination = $($_.FullName).Replace("$Source","$Destination")
                    if (Test-Path -Path $ModifiedDestination) {
                        if (
                            ( Test-Path -Path $_.FullName -PathType Leaf ) -and
                            ( (Get-FileHash $_.FullName).hash -ne (Get-FileHash $ModifiedDestination).hash )
                        ) {
                            if (-Not $UpdatedWPS) {
                                Write-Host "  $count. Syncing profile to WindowsPowerShell folder:" -ForegroundColor White
                                $count++
                                $UpdatedWPS = $true
                            }
                            $shellName = [Regex]::Escape((Join-Path ' ' 'WindowsPowerShell').Trim())
                            $DestinationName = $ModifiedDestination -replace "(.+(?=$shellName))"
                            Write-Host '      +' -NoNewline -ForegroundColor DarkGreen
                            Write-Host $DestinationName
                            Copy-Item $_.FullName $ModifiedDestination
                        }
                    } else {
                        if (-Not $UpdatedWPS) {
                            Write-Host "  $count. Syncing profile to WindowsPowerShell folder:" -ForegroundColor White
                            $count++
                            $UpdatedWPS = $true
                        }
                        $shellName = [Regex]::Escape((Join-Path ' ' 'WindowsPowerShell').Trim())
                        $DestinationName = $ModifiedDestination -replace "(.+(?=$shellName))"
                        Write-Host '      +' -NoNewline -ForegroundColor DarkGreen
                        Write-Host $DestinationName
                    Copy-Item $_.FullName $ModifiedDestination
                    }
                }
            }
        }
    }
}

## CurrentUserCurrentHost + AllUsersCurrentHost
#
else {
    $ProfileFileName[0] = $ProfileFileName[0].Replace('Microsoft.', '')
    $ProfileFileNameName = $ProfileFileName[0]
    if ((-Not $IsCoreCLR) -and ($ProfileFileNameName -eq 'PowerShell')) {
        $ProfileFileNameName = 'Windows PowerShell'
    }
    Write-Host ("`nLoading $SyncProfileNameType profile for $ProfileFileNameName host:") -ForegroundColor Green
    Add-Member -InputObject $ProfileDirectories -MemberType NoteProperty -Name $myName -Value (Join-Path $PSScriptRoot ('Profile_' + $ProfileFileName[0]))
}

## Any profile
#

$PlatformDirectory = '_Platform_Windows'
if ($IsLinux) {
    $PlatformDirectory = '_Platform_Linux'
}
elseif ($IsMacOS) {
    $PlatformDirectory = '_Platform_macOS'
}

# List profile directories in scope
$SyncProfileNameDirectories = ,$ProfileDirectories.$myName
if ($IsCoreCLR -or ($myName -notlike '*_*')) {
    $SyncProfileNameDirectories += Join-Path $ProfileDirectories.$myName $PlatformDirectory
}
if ($IsCoreCLR) {
    $SyncProfileNameDirectories += Join-Path $ProfileDirectories.$myName '_Edition_Core'
    if ($IsWindows) {
        $SyncProfileNameDirectories += Join-Path $ProfileDirectories.$myName (Join-Path $PlatformDirectory '_Edition_Core')
        $SyncProfileNameDirectories += Join-Path $ProfileDirectories.$myName (Join-Path $PlatformDirectory '_Edition_Desktop')
    }
}

# Read configuration files
$Global:PSProfileConfig = @{}
foreach ($ProfileDirectory in $SyncProfileNameDirectories) {
    New-Item -ItemType Directory -Force -Path (Join-Path $ProfileDirectory 'Config') | Out-Null
    New-Item -ItemType Directory -Force -Path (Join-Path $ProfileDirectory 'Functions') | Out-Null

    # Make sure to also create host directories in PowerShell core profile folder
    if ($IsWindows -and -Not $IsCoreCLR) {
        $search = [Regex]::Escape((Join-Path ' ' (Join-Path 'WindowsPowerShell' ' ')).Trim())
        $replace = (Join-Path ' ' (Join-Path 'PowerShell' ' ')).Trim()
        $WPSProfileDirectory = $ProfileDirectory -replace $search, $replace
        New-Item -ItemType Directory -Force -Path (Join-Path $WPSProfileDirectory 'Config') | Out-Null
        New-Item -ItemType Directory -Force -Path (Join-Path $WPSProfileDirectory 'Functions') | Out-Null
    }

    if (
        (($ProfileDirectory -match '_Edition_Desktop$') -and $IsCoreCLR) -or
        (($ProfileDirectory -match '_Edition_Core$') -and -Not $IsCoreCLR)
    ) {
        continue
    }

    Push-Location (Join-Path $ProfileDirectory 'Config')
    Get-ChildItem *.config.json -File -Recurse | ForEach-Object {
        $search = [Regex]::Escape((Join-Path $PSScriptRoot ' ').Trim())
        $SyncProfileNameConfigPath = $_.FullName -replace "(^$search)"
        $SyncProfileNameConfigPath = $SyncProfileNameConfigPath.Split((Join-Path ' ' ' ').Trim())

        # Ignore path that contains blanks
        if ($SyncProfileNameConfigPath -contains '* *') {
            continue
        }

        #TODO:
        # Create a global object or multidimensional hashtable / hash of hashes
        # at $Global:PSProfileConfig (whatever the wording is, I'm coming from Perl, the heck!)
        # that is based on the directory path and at the end of the node
        # (leaf it is in PS, I get it!) it as the pre-loaded object that
        # was created by Convert-FromJson based on the actual file input.
        #
        # Of course the filename should also be presented in the layers
        # of that global object/hashtable/whatever...
        # There must be a 1-to-1 relationship between file path, file name
        # and the object/hashtable/whatever path so it is predictible where
        # the configuration values can be accessed by other PS scripts
        # effortless.

    }
    Pop-Location
}

# Import functions
$FoundFunctions = $false
$FoundPlatforms = $null
foreach ($ProfileDirectory in $SyncProfileNameDirectories) {

    if (
        (($ProfileDirectory -match '_Edition_Desktop$') -and $IsCoreCLR) -or
        (($ProfileDirectory -match '_Edition_Core$') -and -Not $IsCoreCLR)
    ) {
        continue
    }

    $subdir = Split-Path $ProfileDirectory -Leaf
    $SyncProfileNameSubType = $subdir.Split('_')[2]
    if (($SyncProfileNameSubType -eq 'Core') -or ($SyncProfileNameSubType -eq 'Desktop')) {
        $SyncProfileNameSubType = "PowerShell $SyncProfileNameSubType Edition"
    }

    Push-Location (Join-Path $ProfileDirectory 'Functions')
    Get-ChildItem *.ps1 -File -Recurse | ForEach-Object {
        $name = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
        $name = $name -replace '(^[0-9]\w*-)'
        if ($FoundFunctions) {
            if (($subdir -notmatch 'Profile.*$') -and ($FoundPlatforms -notcontains $subdir)) {
                Write-Host ''
                Write-Host ("      $SyncProfileNameSubType" + ':') -ForegroundColor DarkYellow
                Write-Host '      ' -NoNewline
                $FoundPlatforms += ,$subdir
            }
        } else {
            Write-Host ("  $count. " + $prefix + 'Importing functions:') -ForegroundColor White
            if (($subdir -notmatch 'Profile.*$') -and ($FoundPlatforms -notcontains $subdir)) {
                Write-Host ("      $SyncProfileNameSubType" + ':') -ForegroundColor DarkYellow
                $FoundPlatforms += ,$subdir
            }
            Write-Host '     ' -NoNewline
            $FoundFunctions = $true
            $count++
        }

        $ErrorActionPreference = 'Stop'
        $caught = $false

        try {
            . $_.FullName >$null | Out-Null
        }
        catch {
            $caught = $true
            Write-Host " $name" -NoNewline -ForegroundColor Red
        }

        if (-Not $caught) {
                Write-Host " $name" -NoNewline -ForegroundColor DarkCyan
        }
    }
    Pop-Location
}
if ($FoundFunctions) {
    Write-Host ''
}
Remove-Variable FoundPlatforms
Remove-Variable FoundFunctions

$Global:IsAdmin = Test-Administrator

# Invoke other scripts
foreach ($ProfileDirectory in $SyncProfileNameDirectories) {

    if (
        (($ProfileDirectory -match '_Edition_Desktop$') -and $IsCoreCLR) -or
        (($ProfileDirectory -match '_Edition_Core$') -and -Not $IsCoreCLR)
    ) {
        continue
    }

    Push-Location $ProfileDirectory
    Get-ChildItem *.ps1 | ForEach-Object {
        $name = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
        $name = $name -replace '(^[0-9]\w*-)'
        Write-Host "  $count. Invoking $name ..." -ForegroundColor White
        . $_.FullName
        $count++
    }
    Pop-Location
}

# Initially invoke host profile as those will not detect new profile
# files in their first session
if (
    $FirstUseHost -and
    (($FirstUseHost -notlike '*Microsoft.PowerShell_profile.ps1')) -and
    ($myName -eq 'profile')
) {
    & "$FirstUseHost"
}
