<#
.SYNOPSIS
This will type the clipboard

.DESCRIPTION
This command will type the clipboard after a configurable delay, set at 2 seconds by default

.PARAMETER SecondsToSleep
Seconds to sleep before sending the clipboard

.EXAMPLE
PS> Invoke-TypeClipboard
#>
function Invoke-TypeClipboard {
    [CmdletBinding()]
    param (
        # Sleep for X Seconds, defaults to 2 seconds
        [Parameter()]
        [int]
        $SecondsToSleep = 2
    )
    
    begin {
        $wshell = New-Object -ComObject wscript.shell
    }
    
    process {
        $wshell.SendKeys( $(Get-Clipboard) )
    }
    
    end {
        
    }
}