<#
    .SYNOPSIS
        Convert PowerShell ConsoleHost_history.txt files from the specified Source Directory into a single CSV file.
        Original script to copy the ConsoleHost_history.txt files from Andrew Rathbun and Matt Arbaugh: https://github.com/AndrewRathbun/DFIRPowerShellScripts/blob/main/Move-KAPEConsoleHost_history.ps1
    
    .PARAMETER InputDir
        Specify the folder which contains the ConsoleHost_history.txt file(s). Ideally, the C:\ or C:\Users|Utilisateurs|Usuarios|Benutzer directory in order to grab the file(s) from all users.
    
    .PARAMETER Destination
        Specify the folder where the ConsoleHost_histories.csv file will be placed.
    
    .PARAMETER outputFile
        Specify the output file name (by default Powershell_ConsoleHost_histories.csv).
#>

[CmdletBinding()]
param
(
    [Parameter(Mandatory = $true,
               Position = 1,
               HelpMessage = 'Specify the folder which contains the ConsoleHost_history.txt file(s). Ideally, the C:\ or C:\Users|Utilisateurs|Usuarios|Benutzer directory in order to grab the file(s) from all users.')]
    [String]$InputDir,
    [Parameter(Mandatory = $true,
               Position = 2,
               HelpMessage = 'Specify the folder where the Powershell_ConsoleHost_histories.csv file will be placed.')]
    [String]$Destination,
    [Parameter(Mandatory = $false,
               HelpMessage = 'Specify the output file name (by default Powershell_ConsoleHost_histories.csv).')]
               [String]$outputFile = "Powershell_ConsoleHost_histories.csv"
)

try {
    # Check if $InputDir exists
    if (-not (Test-Path -Path $InputDir -PathType Container)) {
        throw "The directory $InputDir does not exist."
    }
    
    # Create the $Destination path if it does not exist
    if (-not (Test-Path -Path $Destination -PathType Container)) {
        # Create the directory, but do not prompt for confirmation (-Confirm:$false)
        [void] (New-Item -ItemType Directory -Path $Destination -Confirm:$false)
    }
    
    # Regex pattern to extract username from file path
    $usernameRegex = "\\(Users|Utilisateurs|Usuarios|Benutzer)\\(.+?)\\AppData\\"
    
    # Look for ConsoleHost_history.txt files in $InputDir
    $consoleHostHistoryTxt = 'ConsoleHost_history.txt'
    $files = Get-ChildItem -Path $InputDir -Filter $consoleHostHistoryTxt -Recurse -ErrorAction Stop | ForEach-Object{ $_.FullName }
    
    # Check if files were found
    if ($null -eq $files -or $files.Count -eq 0) {
        Write-Host "No $consoleHostHistoryTxt file(s) were found in $InputDir"
    }
    else {
        Write-Host "Found $($files.Count) $consoleHostHistoryTxt file(s) in $InputDir"
    }

    $commandsOutput = New-Object System.Collections.ArrayList
    
    foreach ($file in $files) {
        $fileItem = Get-Item $file

        # Extract username from file path
        $file -match $usernameRegex | Out-Null
        $username = $matches[2]
        
        # Get file content
        $fileContent = Get-Content $file
        
        # Get file size in KB
        $fileSizeKB = [math]::Round($fileItem.Length / 1KB, 2)
        
        # Get row count
        $rowCount = ($fileContent | Measure-Object -Line).Lines
        
        Write-Host "Located $consoleHostHistoryTxt for $username | File size: $fileSizeKB KB | Row count: $rowCount"
        
        $commandIndex = 0
        while ($commandIndex -lt $rowCount) {
            $executionTimestamp = $null
            # The execution timestamp of the last command can be deduced from the last write timestamp of the associated ConsoleHost_history.txt file.
            If (($commandIndex + 1) -eq $rowCount) {
                $executionTimestamp = $fileItem.LastWriteTimeUtc.ToString("yyyy-MM-ddTHH:mm:ssK")
            }
            # If less than the max number of commands have been executed (by default 4096),
            # the execution timestamp of the first command can be deduced as the birth timestamp of the associated ConsoleHost_history.txt file.
            ElseIf ($commandIndex -eq 0 -and $rowCount -lt 4096) {
                $executionTimestamp = $fileItem.CreationTimeUtc.ToString("yyyy-MM-ddTHH:mm:ssK")
            }

            $null = $commandsOutput.Add([PSCustomObject]@{
                User = $username
                CommandIndex = $commandIndex
                Command = $fileContent[$commandIndex]
                ExecutionTimestamp = $executionTimestamp
                File = $file
            })
            
            $commandIndex = $commandIndex + 1
        }

    }

    $commandsOutput | Export-Csv -NoTypeInformation "$Destination\\$outputFile"
}

catch [System.Exception]     {
    # If an error occurred, print error details
    Write-Error "An error occurred while running this script"
    Write-Error "Exception type: $($_.Exception.GetType().FullName)"
    Write-Error "Exception message: $($_.Exception.Message)"
}
