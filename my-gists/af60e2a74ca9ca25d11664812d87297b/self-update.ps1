function New-Thread {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [scriptblock] $Script,

        # Timeout in seconds
        [Parameter()]
        [int] $TimeOut = 60
    )

    $startTime = Get-Date

    $iss = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
    $runspace = [System.Management.Automation.PowerShell]::Create($iss)
    [void]$runspace.AddScript($Script)
    $runspaceHandle = $runspace.BeginInvoke()

    $continue = $true

    while (($continue) -and (-not($runspaceHandle.IsCompleted))) {
        # break free of wait loop if timeout is exceeded
        if ((New-TimeSpan -Start $startTime).TotalSeconds -ge $TimeOut) {
            Write-Verbose 'Timeout exceeded - breaking out of loop'
            $continue = $false
        }
    }

    # receive the output from the script run in the separate thread
    if ($continue) {
        Write-Output $runspace.EndInvoke($runspaceHandle)
    }

    # clean-up
    $runspace.Dispose()
    $runspaceHandle = $null
}

function Check-Update {
    [CmdletBinding()]
    param (
        # Path to 'master' script this script will update from (if needed)
        [Parameter()]
        [string] $UpdatePath,

        [Parameter()]
        [string] $ThisScriptPath = $MyInvocation.PSCommandPath
    )

    # get hash of currently running script
    $thisScriptHash = Get-FileHash -Path $ThisScriptPath

    # get hash of master-script
    $masterScriptHash = Get-FileHash -Path $UpdatePath

    # check if hash between this script and the master script is different
    if ($thisScriptHash.Hash -cne $masterScriptHash.Hash) {
        # update the script from the master script
        Get-Content -Path $UpdatePath -Raw | Set-Content -Path $ThisScriptPath -NoNewline -Force
        Write-Host "Script is updated!"

    }

}

#################################################################################

# Start by checking for updates to the script
# UPDATE THIS PATH TO POINT TO THE MASTER VERSION OF YOUR SCRIPT

Check-Update -UpdatePath C:\tmp\self_updating_script\sentral_location\script.ps1

#################################################################################

# This is the main script-code. This will be launched in a separate thread
# If you want any text returned to the console, remember to use Write-Output!
# Write-Host will not work - as the host in this case will be in the temporary
# runspace that it will run in.

#################################################################################
{
    $scriptVersion = 2
    Write-Output "This is version $scriptVersion of the script"
    #Start-Sleep -Seconds 5

} | New-Thread -Timeout 8 -Verbose