# Method 1: Measure-Command Cmdlet
$elapsedTime = Measure-Command {
    Start-Sleep -Seconds 5  # Example script block with a delay
    Get-Process  # Another example command
}
Write-Host "Measure-Command: Total time elapsed: $($elapsedTime.TotalMinutes) minutes"

# Method 2: Stopwatch Class
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
Start-Sleep -Seconds 5  # Example script block with a delay
$stopwatch.Stop()
Write-Host "Stopwatch: Elapsed time: $($stopwatch.Elapsed.TotalSeconds) seconds"

# Method 3: Date Variables
$start = Get-Date
Start-Sleep -Seconds 5  # Example script block with a delay
$end = Get-Date
$elapsed = $end - $start
Write-Host "Date Variables: Elapsed time: $($elapsed.TotalSeconds) seconds"

# Method 5: Logging (Timestamps)
function Log-TimeStamp
{
    $timestamp = Get-Date -Format "mm:ss"

    Write-Host "[$timestamp] Script execution started."
    # "[$timestamp] Script execution started." | Out-File "script_log.txt" -Append
    Start-Sleep -Seconds 5  # Example script block with a delay
    Write-Host "[$timestamp] Script execution completed."
}
Log-TimeStamp

# Note: Method 4 (Performance Counters) isn't included here as it's more advanced and specific to monitoring system metrics.

# Additional Notes:
# - Method 1 (Measure-Command) directly measures the script block.
# - Method 2 (Stopwatch) manually starts and stops timing.
# - Method 3 (Date Variables) calculates elapsed time using date/time variables.
# - Method 5 (Logging) logs timestamps to a file before and after script execution.

# Feel free to copy and use these examples as needed in your PowerShell scripts.
