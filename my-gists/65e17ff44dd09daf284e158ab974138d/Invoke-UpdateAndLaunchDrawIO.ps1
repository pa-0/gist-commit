#Requires -Version 7


[CmdletBinding(DefaultParameterSetName = "Check")]
param (
    # Check Switch
    [Parameter(ParameterSetName="Check", Mandatory)]
    [Parameter(ParameterSetName="CheckAndUpdate")]
    [switch]
    $Check,
    # Update Switch
    [Parameter(ParameterSetName = "CheckAndUpdate", Mandatory)]
    [Alias('CheckAndUpdate')]
    [switch]
    $Update,
    [Parameter(ParameterSetName="Check")]
    [Parameter(ParameterSetName="CheckAndUpdate")]
    [switch]
    $DoNotLaunch,
    # Install Shortcut
    [Parameter(ParameterSetName = "InstallShortcut")]
    [switch]
    $InstallShortcut,
    [Parameter(ParameterSetName = "Help")]
    [switch]
    $Help

)

begin {
    switch ($PSCmdlet.ParameterSetName) {
        "Help" {
            Write-Verbose "Getting help"
            if ($Help.IsPresent) {
                Get-Help -Name $MyInvocation.MyCommand.Path -Full
            }
            else {
                Get-Help -Name $MyInvocation.MyCommand.Path
            }
        }
        Default {

        }
    }

    #region Declarations

    $ExecutableDestination = Join-Path $(Get-Item $MyInvocation.MyCommand.Path).Directory -ChildPath "Executables"
    $LatestReleaseBaseURI = "https://github.com/jgraph/drawio-desktop/releases/latest/download/"

    $script:ExecLinkPath = Join-Path $(Get-Item $MyInvocation.MyCommand.Path).Directory -ChildPath "draw_io.exe"
    # $latestYamluri = $LatestReleaseBaseURI + "latest.yml"
    #endregion

    #region Functions

    function Invoke-CheckDrawIOUpdate {
        param (
            # LatestInfo Yaml URI
            [Parameter(Mandatory)]
            [string]
            $LatestInfoYamlURI,
            # Executable Destination
            [Parameter(Mandatory)]
            [string]
            $ExecutableDestination,
            # LatestInfo Return
            [Parameter()]
            [ref]
            $LatestInfo
        )
        begin {
            $null = try {
                Invoke-WebRequest -Uri $LatestInfoYamlURI -OutVariable IWRLatestYaml -ErrorAction Stop
            }
            catch [System.Net.Http.HttpRequestException] {
                if ($_.Exception.InnerException.HResult -eq -2146232800) {
                    Write-Warning "SSL Error, retrying"
                    Invoke-WebRequest -Uri $LatestInfoYamlURI -OutVariable IWRLatestYaml
                }
            }
            catch {
                Write-Error $_ -ErrorAction Stop
            }
            $enc = [Text.Encoding]::UTF8
            $LatestInfo.Value = $enc.GetString($IWRLatestYaml.Content) | ConvertFrom-Yaml
            # $LatestInfo
        }
        process {
            $CurrentNoInstallExecutable = "draw.io-{0}-windows-no-installer.exe" -f $LatestInfo.Value.version

            $latestIsPresent = Test-Path -Path (Join-Path -Path $ExecutableDestination -ChildPath $CurrentNoInstallExecutable)

        }
        end {
            return (-not $latestIsPresent)
            if ($latestIsPresent) {
                Write-Information "Latest version already present" -InformationAction Continue
            }
            else {
                Write-Information "Update is available" -InformationAction Continue
            }
        }
    }

    function Invoke-UpdateDrawIO {
        [CmdletBinding()]
        param (
            # LatestInfo
            [Parameter(Mandatory)]
            [hashtable]
            $LatestInfo,
        
            # Executable Destination
            [Parameter(Mandatory)]
            [string]
            $ExecutableDestination
        )
        
        begin {
            $DrawIONoInstallExecFileName = "draw.io-{0}-windows-no-installer.exe" -f $LatestInfo.version
            $LatestDrawIONoInstallExecURI = $LatestReleaseBaseURI + $DrawIONoInstallExecFileName
        }
        
        process {
            $invokeWebRequestSplat = @{
                Uri = $LatestDrawIONoInstallExecURI
                OutFile = $(Join-Path -Path $ExecutableDestination -ChildPath $DrawIONoInstallExecFileName )
            }
            $null = Invoke-WebRequest @invokeWebRequestSplat

            $LatestNoInstallExec = Get-Item $invokeWebRequestSplat.OutFile
            try {
                $LinkItemSplat = @{
                    ErrorAction = 'Stop'
                    Path = $ExecLinkPath
                }
                if (Test-Path @LinkItemSplat) {
                    Remove-Item @LinkItemSplat
                }
                New-Item @LinkItemSplat -ItemType HardLink -Value $LatestNoInstallExec.FullName | Out-Null
            }
            catch {
                Remove-Item $LatestNoInstallExec
                Write-Warning "Could not update the Link"
                Write-Error $_ -ErrorAction Stop
            }
        }
        
        end {
            
        }
    }
    
    function Install-ScriptShortcut {
        [CmdletBinding()]
        param (
            # Target
            [Parameter(Mandatory)]
            [string]
            $Target,
            # Path
            [Parameter(Mandatory)]
            [string]
            $Path,
            # Arguments
            [Parameter()]
            [string[]]
            $Argument
        )
        
        begin {
            $WshShell = New-Object -comObject WScript.Shell
        }
        
        process {
            if ($Path -notmatch "^.*(\.lnk)$") { 
                $Path += ".lnk"
            }
            
            $Shortcut = $WshShell.CreateShortcut($Path)
            $Shortcut.TargetPath = $Target
            if ($null -ne $Argument) {
                $Shortcut.Arguments = $Argument -join ' '
            }
        }
        
        end {
            $Shortcut.Save()
        }
    }

    #endregion
}


process {
    $LatestInfo = $null
    $DrawIOUpdateSplat = @{
        LatestInfoYamlURI = ($LatestReleaseBaseURI + "latest.yml")
        ExecutableDestination = $ExecutableDestination
        LatestInfo = ([ref]$LatestInfo)
    }
    switch ($PSCmdlet.ParameterSetName) {
        "Check" {
            Invoke-CheckDrawIOUpdate @DrawIOUpdateSplat | Out-Null
        }
        "CheckAndUpdate" {
            if (Invoke-CheckDrawIOUpdate @DrawIOUpdateSplat) {
                $DrawIOUpdateSplat.Remove('LatestInfoYamlURI')
                Invoke-UpdateDrawIO @DrawIOUpdateSplat
            }
        }
        "InstallShortcut" {
            $installScriptShortcutSplat = @{
                Target = "pwsh.exe"
                Argument = @("-NoLogo", "-NoProfile", "-File", $("""{0}""" -f $MyInvocation.MyCommand.Path), "-CheckAndUpdate")
                Path = $(Join-Path $(Get-Item $MyInvocation.MyCommand.Path).Directory -ChildPath "InvokeDrawIO")
            }

            Install-ScriptShortcut @installScriptShortcutSplat
        }
        Default {

        }
    }
    
}

end {
    switch ($PSCmdlet.ParameterSetName) {
        {$_ -in "Check","CheckAndUpdate"} {
            if (-not $DoNotLaunch) {
                Invoke-Item $ExecLinkPath
            }
        }
        Default {

        }
    }
    
}

