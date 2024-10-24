
function Multiply-Timespan([TimeSpan]$timespan, [double]$multiplier) {
    [long]$ticks = $timespan.Ticks * $multiplier
    return [TimeSpan]::FromTicks($ticks)
}

function Show-Progress{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)][PSObject[]]$InputObject,
        [Parameter(Mandatory=$true)] $TotalItems,
        [string]$Activity = "Processing items"
    )
    begin {
        [int]$Count = 0
        $startTime = Get-Date
    }
    process {
        $_
        $Count++
        $partComplete = 1.0 * $Count / $TotalItems
        $now = Get-Date
        $passed = $now - $startTime
        $remaining = Multiply-Timespan ($now - $startTime) ((1 - $partComplete) / $partComplete)
        $status = "{0} / {1} ( {2:P1} )" -f ($Count, $TotalItems, $partComplete, $remaining)
        $moreInfo = "passed: {0:hh\:mm\:ss}     remaining: {1:hh\:mm\:ss}" -f $passed,$remaining
        Write-Progress -Id 1 `
                       -Activity $Activity `
                       -PercentComplete (100 * $partComplete) `
                       -Status ($status) `
                       -CurrentOperation ($moreInfo)
    }
    end {
        Write-Progress -Id 1 -Activity $Activity -Completed
    }
}

function Draw-Line($char = "="){
    $char * ($(get-host).UI.RawUI.BufferSize.Width - 1)
}
