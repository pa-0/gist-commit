[CmdletBinding()]
param (
    [Parameter(ParameterSetName = "SSHURI")]
    [System.Uri]
    $SSHURI,
    # 
    [Parameter(ParameterSetName = "ComputerName", Mandatory)]
    [string]
    $ComputerName,
    # Parameter help description
    [Parameter(ParameterSetName = "ComputerName", Mandatory)]
    [string]
    $UserName,
    # Allows to run in loop until a disk matching this name is found, or until a count of Sata Disks is found
    [Parameter(ParameterSetName = "SSHURI")]
    [Parameter(ParameterSetName = "ComputerName")]
    [string]
    $WaitFor
)
$InformationPreference = "Continue"

$SSHConnectionIP = switch ($PSCmdlet.ParameterSetName) {
    "SSHURI" { 
        if ($SSHURI.UserInfo -notmatch "(.*):(.*)" -and -not [string]::IsNullOrEmpty($SSHURI.Host)) {
            "{0}@{1}" -f $SSHURI.UserInfo, $SSHURI.Host
        }
        elseif ($SSHURI.OriginalString -match "(.*)@(.*)" -and [string]::IsNullOrEmpty($SSHURI.Host)) {
            "{0}@{1}" -f $Matches[1], $Matches[2]
        }
        elseif ($SSHURI.UserInfo -match "(.*):(.*)") {
            "{0}@{1}" -f $SSHURI.UserInfo.Split(':')[0], $SSHURI.Host
        }
    }
    "ComputerName" { "{0}@{1}" -f $UserName, $ComputerName }
    Default {}
}

# Change the default behavior of CTRL-C so that the script can intercept and use it versus just terminating the script.
[Console]::TreatControlCAsInput = $True
# Sleep for 1 second and then flush the key buffer so any previously pressed keys are discarded and the loop can monitor for the use of
#   CTRL-C. The sleep command ensures the buffer flushes correctly.
$InformationPreference = "Continue"
Write-Information "Starting Script."
Start-Sleep -Seconds 1
$Host.UI.RawUI.FlushInputBuffer()
$keeplooping = $true
# Continue to loop while there are pending or currently executing jobs.
# -or $disks.blockdevices.name -notcontains 'sdj'
$loopCount = 0
While ($keeplooping) {
    $loopCount++;
    Write-Progress -Activity $("Loop #{0}" -f $loopCount) -PercentComplete -1 -Status "Loop Start" -Id 1
    Start-Sleep -Milliseconds 200

    # If a key was pressed during the loop execution, check to see if it was CTRL-C (aka "3"), and if so exit the script after clearing
    #   out any running jobs and setting CTRL-C back to normal.
    If ($Host.UI.RawUI.KeyAvailable -and ($Key = $Host.UI.RawUI.ReadKey("AllowCtrlC,NoEcho,IncludeKeyUp"))) {
        If ([Int]$Key.Character -eq 3) {

            Write-Warning "CTRL-C was used - Stopping."
            [Console]::TreatControlCAsInput = $False
            $keeplooping = $false
        }
        # Flush the key buffer again for the next loop.
        $Host.UI.RawUI.FlushInputBuffer()
    }

    if ($keeplooping) {

        Write-Progress -Activity $("Loop #{0}" -f $loopCount) -PercentComplete -1 -Status "SSH to TrueNAS" -Id 1
        
        $Global:disks = $disks = Invoke-Expression -Command "ssh $SSHConnectionIP lsblk -O --json" | ConvertFrom-Json

        $FoundCount = $disks.blockdevices.Where({ $_.Name -match 'sd' }).Count
        Start-Sleep -Milliseconds 800
        
        $writeProgressSplat = @{
            Activity        = $("Loop #{0}" -f $loopCount)
            PercentComplete = '-1'
            Status          = $("{0} SATA block devices were found" -f $disks.blockdevices.Where({ $_.Name -match 'sd' }).Count)
            Id              = 1
        }
        Write-Progress @writeProgressSplat

        Start-Sleep -Milliseconds 800

        if ($PSBoundParameters.Keys -contains 'WaitFor') {
            Write-Debug "Hit WaitFor Block"
            $WaitForCount = 0
            if ([int]::TryParse($WaitFor, [ref]$WaitForCount)) {
                Write-Debug "Hit WaitFor Count"
                if ($FoundCount -lt $WaitForCount) {
                    $writeProgressSplat = @{
                        Activity        = $("Loop #{0}" -f $loopCount)
                        PercentComplete = '-1'
                        Status          = $("Found {0} Sata Drives, not {1}. Sleeping for 15 seconds" -f $FoundCount, $WaitForCount)
                        Id              = 1
                    }
                    Write-Progress @writeProgressSplat
                    Start-Sleep -Milliseconds 800
                    $keeplooping = $true
                } else {
                    $keeplooping = $False
                }
            }
            elseif ($WaitFor -match "sd") {
                Write-Debug "Hit WaitFor Match"
                if ($disks.blockdevices.Where({ $_.Name -match $WaitFor }).Count -lt 1) {
                    $writeProgressSplat = @{
                        Activity        = $("Loop #{0}" -f $loopCount)
                        PercentComplete = '-1'
                        Status          = $("{0} Not Found. Sleeping 15 seconds" -f $WaitFor )
                        Id              = 1
                    }
                    Write-Progress @writeProgressSplat
                    Start-Sleep -Milliseconds 800
                    $keeplooping = $true
                }
                else {
                    $keeplooping = $False
                }
            }
            if ($keeplooping) {
                Start-Sleep -Seconds 15
            }
        }
        else {
            Write-Progress -Activity $("Loop #{0}" -f $loopCount) -PercentComplete 100 -Status "Completed" -Id 1
            $Global:disks = $disks
            $keeplooping = $false
        }
    }
    # Perform other work here such as process pending jobs or process out current jobs.
}
$Global:disks | Select-Object -ExpandProperty blockdevices | Format-Table -AutoSize -Property name, model, size, rota, serial