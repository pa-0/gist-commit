<#
.SYNOPSIS
Adds (or remove) a shortcut to "Advanced Security" to Explorer's context menu.

.DESCRIPTION
Adds (or remove) a shortcut to "Advanced Security" to Explorer's context menu.

Use `-Help` for the full Help

.PARAMETER Help
Gets the full help

.PARAMETER Install
Switch to install the required registry keys

.PARAMETER Uninstall
Switch to uninstall the registry keys

.PARAMETER ApplyOn
Which Windows Explorer's item will show the "Advanced Security" option when right-clicked-on.

    - AllFileSystemObjects : All files
    - Directory : On directory items
    - Background : On the background of Explorer window (for the current folder)
    - Drive : On Drives
    - IEURL : On URL files
    - Default : On Directories and Background

.INPUTS
None

.OUTPUTS
None

.EXAMPLE
PS> .\Add-AdvancedSecurityToContextMenu.ps1 -Install -ApplyOn Default

This will install the shortcut on the default items (Directory and Background)

.EXAMPLE
PS> .\Add-AdvancedSecurityToContextMenu.ps1 -Uninstall

This will remove all the configuration on all the possible keys.

#>
[CmdletBinding(DefaultParameterSetName = "Help")]
param (
    [Parameter(ParameterSetName = "Help")]
    [switch]
    $Help,

    [Parameter(ParameterSetName = "Install", Position = 0)]
    [switch]
    $Install,
    [Parameter(ParameterSetName = "Uninstall", Position = 0)]
    [switch]
    $Uninstall,

    # Applied on Directory and Background by default.
    [Parameter(ParameterSetName = "Install", Position = 1)]
    [ValidateSet('AllFileSystemObjects', "Directory", "Background", "Drive", "IEURL", "Default")]
    [string[]]
    $ApplyOn = "Default",

    # Position
    [Parameter(ParameterSetName = "Install")]
    [ValidateSet("Top", "Bottom")]
    [string]
    $Position = "Bottom",

    [Parameter(ParameterSetName = "Install")]
    [Parameter(ParameterSetName = "Uninstall")]
    [switch]
    $EveryWhere
)



begin {

    #region FunctionDeclarations
    function Add-RequiredRegistryKeys {
        [CmdletBinding()]
        param (
            # Specifies a path to one or more locations. Unlike the Path parameter, the value of the LiteralPath parameter is
            # used exactly as it is typed. No characters are interpreted as wildcards. If the path includes escape characters,
            # enclose it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any
            # characters as escape sequences.
            [Parameter(Mandatory = $true,
                Position = 0,
                ValueFromPipelineByPropertyName = $true,
                HelpMessage = "Literal path to the registry key location.")]
            [Alias("PSPath")]
            [Alias("FullPath")]
            [ValidateNotNullOrEmpty()]
            [string[]]
            $LiteralPath
        )
        
        begin {
            $Properties = @{
                ExplorerCommandHandler = "{E2765AC3-564C-40F9-AC12-CD393FBAAB0F}"
                CommandStateSync       = ""
                Position               = $Position
                Icon                   = "ntshrui.dll,-122"
            }
        }
        
        process {
            $LiteralPath | ForEach-Object {
                
                $currentLiteralPath = $_
                $currentLocation = $Locations.Where({$_.FullPath -eq $currentLiteralPath})[0]
                Write-Verbose $("Doing {0} location" -f $currentLocation)
                if (-not (Test-Path -PSPath $currentLiteralPath )) {
                    Write-Verbose $("{0} key doesn't exist. Creating it." -f $currentLiteralPath)
                    New-Item $currentLiteralPath -Force | Out-Null
                } else {
                    Write-Verbose $("{0} key already exists." -f $currentLiteralPath)
                }

                $Properties.GetEnumerator() | ForEach-Object {
                    $newItemPropertySplat = @{
                        LiteralPath  = $currentLiteralPath
                        Name         = $_.Key
                        Value        = $_.Value
                        PropertyType = 'String'
                        ErrorAction  = 'Stop'
                    }
                    try {
                        Write-Verbose $("Adding {0} property with '{1}' value" -f $newItemPropertySplat.Name, $newItemPropertySplat.Value)
                        New-ItemProperty @newItemPropertySplat | Out-Null
                    }
                    catch [System.IO.IOException] {
                        switch ($_) {
                            {$_.CategoryInfo.Category -eq [System.Management.Automation.ErrorCategory]::ResourceExists} { Write-Error $_ -ErrorAction Ignore }
                            Default {Write-Error $_ -ErrorAction Stop}
                        }
                    }
    
                    catch {
                        Write-Error $_ -ErrorAction Stop
                    }
                
                }
            }
            
        }
        
        end {
            
        }
    }
    function Write-ColoredInformation {
        param (
            [Parameter(Mandatory)]
            [Alias('Message')]
            [Object]$MessageData,
            [Parameter()]
            [Alias('Color')]
            [System.ConsoleColor]$ForegroundColor = $Host.UI.RawUI.ForegroundColor,
            [System.ConsoleColor]$BackgroundColor = $Host.UI.RawUI.BackgroundColor,
            [switch]$NoNewLine
        )
        $msg = [System.Management.Automation.HostInformationMessage]@{
            Message = $MessageData
            BackgroundColor = [System.ConsoleColor]$BackgroundColor
            ForegroundColor = [System.ConsoleColor]$ForegroundColor
            NoNewLine = $NoNewLine.IsPresent
        }
        Write-Information $msg -InformationAction Continue
    }
    #endregion
    #region Begin.Processing
    switch ($PSCmdlet.ParameterSetName) {
        "Help" { 
            Write-Verbose "Getting help"
            if ($Help.IsPresent) {
                Get-Help -Name $MyInvocation.MyCommand.Path -Full
            } else {
                Get-Help -Name $MyInvocation.MyCommand.Path
            }
        }
        { $_ -in "Install", "Uninstall" } {
            if ($EveryWhere) {
                Write-Verbose "Testing Admin rights"
                $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
                if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
                    Write-Error -Message "You need administrator rights to Install on System" -ErrorAction Stop
                }
            }
            Write-Verbose "Checking HKEY_CLASSES_ROOT PSDrive"
            if ($EveryWhere -and -not (Test-Path "HKCR:\")) {
                Write-Verbose "Adding HKCR PSDrive for Local Machine"
                New-PSDrive -Name HKCR -PSProvider Registry -Root HKLM:\Software\Classes -ErrorAction Stop | Out-Null
            }
            elseif (-not (Test-Path "HKCR:\")) {
                Write-Verbose "Adding HKCR PSDrive for Current User"
                New-PSDrive -Name HKCR -PSProvider Registry -Root HKCU:\Software\Classes -ErrorAction Stop | Out-Null
            }
        }
        Default {}
    }

    #endregion Begin.Processing

    #region VariableDeclarations
    $Locations = @(
        [PSCustomObject]@{
            Name          = '*'
            Alias         = "AllFileSystemObjects"
            PathUnderRoot = "\*\shell\Windows.RibbonPermissionsDialog"
            Description   = "Applies to all Explorer Items of the Windows Explorer, excluding directories"
        },
        [PSCustomObject]@{
            Name          = 'Directory'
            Alias         = "Directory"
            PathUnderRoot = "\Directory\shell\Windows.RibbonPermissionsDialog"
            Description   = "Applies to all directory items of the Windows Explorer"
            IsDefault     = $true
        },
        [PSCustomObject]@{
            Name          = 'Background'
            Alias         = "Background"
            PathUnderRoot = "\Directory\Background\shell\Windows.RibbonPermissionsDialog"
            Description   = "Applies to the empty background of the Windows Explorer, so the currently opened directory"
            IsDefault     = $true
        },
        [PSCustomObject]@{
            Name          = 'Drive'
            Alias         = "Drive"
            PathUnderRoot = "\Drive\shell\Windows.RibbonPermissionsDialog"
            Description   = "Applies to Drive objects of the Windows Explorer"
        },
        [PSCustomObject]@{
            Name          = 'IEURL'
            Alias         = "IEURL"
            PathUnderRoot = "\IE.AssocFile.URL\shell\Windows.RibbonPermissionsDialog"
            Description   = "Applies to URL objects of the Windows Explorer"
        } | 
        Add-Member -MemberType ScriptProperty -Name FullPath -Value { Join-Path -Path "HKCR:" -ChildPath $this.PathUnderRoot } -PassThru |
        Add-Member -MemberType ScriptMethod -Name ToString -Force -Value { "{0}{1}" -f $this.Name, $(if ($this.Name.Length -le 1) { " ($($this.Alias))" }) } -PassThru
    )
    Write-Verbose $("{0} Locations have been defined" -f $Locations.Length)

    #endregion

}

#region Process
process {

    switch ($PSCmdlet.ParameterSetName) {
        #region Process.Install
        'Install' { 
            Write-Verbose "Selecting the locations"
            $ActOn = switch ($ApplyOn) {
                'Default' { 
                    Write-Verbose $("Using the default locations: {0}" -f ($Locations.Where({ $_.IsDefault }) -join ', ') )
                    $Locations.Where({ $_.IsDefault }) 
                }
                { $_ -in $Locations.Alias } {
                    $curApplyOn = $_
                    Write-Verbose $("Adding the location: {0}" -f $( $Locations.Where({ $_.Alias -eq $curApplyOn })[0] ))
                    $Locations.Where({ $_.Alias -eq $curApplyOn })
                }
                Default { 
                    Write-Verbose $("Using the default locations: {0}" -f ($Locations.Where({ $_.IsDefault }) -join ', ') )
                    $Locations.Where({ $_.IsDefault }) 
                }
            }
            Write-Verbose "Calling Add-RequiredRegistryKeys on the selected Locations"
            $ActOn | Add-RequiredRegistryKeys
            Write-ColoredInformation -Color Green -Message "Installation Done" # | Write-Information -InformationAction Continue
        }
        'Uninstall' {
            Write-Verbose "Removing the keys"
            $Locations | ForEach-Object {
                if (Test-Path -LiteralPath $_.FullPath) {
                    Write-Verbose $("Removing the key {0}" -f $_.FullPath)
                    Remove-Item -PSPath $_.FullPath -ErrorAction SilentlyContinue
                } else {
                    Write-Verbose $("{0} does not exist" -f $_.FullPath)
                }
            }
            Write-ColoredInformation -Color Magenta -Message "Removal Done" #  | Write-Information -InformationAction Continue
        }
        Default {}
    }
    #endregion
}
#endregion
end {

}