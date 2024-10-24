<#
.SYNOPSIS
This script can disable and enable Windows Explorer Hotkeys using the Windows Key

.DESCRIPTION
This script can disable and enable Windows Explorer Hotkeys using the Windows Key.

You cannot disable and enable with a single command. You will need to run this script
twice (once disabling, again enabling).

.PARAMETER Help
If you need to get the help.

.PARAMETER KeysToDisable
Arrays of keys you want to disable, like "V" or @('V','W'), or "VW"

.PARAMETER KeysToEnable
Arrays of keys you want to enable, like "V" or @('V','W'), or "VW"

.EXAMPLE
PS> .\Invoke-WindowsShortcutHandlerManagement.ps1 -KeysToDisable 'V'

.NOTES

#>
[CmdletBinding(DefaultParameterSetName = "Help")]
param (
    [Parameter(ParameterSetName = "Help")]
    [switch]
    $Help,
    # Keys to disable
    [Parameter(ParameterSetName = "Install")]
    [string]
    $KeysToDisable,
    # Keys to Enable
    [Parameter(ParameterSetName = "Uninstall")]
    [string]
    $KeysToEnable
)
begin {
    $regKeySplat = @{
        Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        Name = 'DisabledHotkeys'
    }

    $OriginalRegKey = Get-ItemProperty @regKeySplat -ErrorAction Ignore
    $OriginalValue = ($OriginalRegKey.DisabledHotkeys).ToCharArray()

    #region HelpText

    $HelpText = @"
"@

    #endregion
}
process {
    # get-item "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" | Set-ItemProperty -Name DisabledHotkeys -Value 'V'
    switch ($PSCmdlet.ParameterSetName) {
        'Help' { 
            Write-Information $HelpText
            Get-Help -Name $MyInvocation.MyCommand.Path -Full
        }
        'Install' {
            # Que les caractères mots, et en majuscule
            $FilteredKeys = $KeysToDisable.ToUpper().ToCharArray().Where({$_ -match "\w"})

            $TargetValue = $OriginalValue + $FilteredKeys | Sort-Object -Unique
            
            $disableSplat = $regKeySplat.Clone()
            $disableSplat.Value = ($TargetValue -join "").Trim()

            Set-ItemProperty @disableSplat
        }
        'Uninstall' { 
            # Que les caractères mots, et en majuscule
            $FilteredKeys = $KeysToEnable.ToUpper().ToCharArray().Where({$_ -match "\w"})

            $TargetValue = $OriginalValue.Where({$FilteredKeys -notcontains $_})
            
            $enableSplat = $regKeySplat.Clone()
            $enableSplat.Value = ($TargetValue -join "").Trim()

            Set-ItemProperty @enableSplat 
        }
        Default {}
    }

}
end {

}