# the powercfg /query SCHEME_CURRENT SUB_VIDEO VIDEOIDLE command specifically queries the power settings for the display idle timeout. This setting determines how long the display will remain on when the system is idle before it turns off

## Querying Other Power Settings

If you want to query different power settings, you need to use different subcategories and settings. Here are a few examples

- **Display Timeout**:

  ```powershell
  powercfg /query SCHEME_CURRENT SUB_VIDEO VIDEOIDLE
  ```

- **Sleep Timeout**:

  ```powershell
  powercfg /query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE
  ```

- **Hard Disk Timeout**:

  ```powershell
  powercfg /query SCHEME_CURRENT SUB_DISK DISKIDLE
  ```

- **Processor Power Management**:

  ```powershell
  powercfg /query SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX
  ```

## Example: Querying Sleep Timeout

Here is an example of how to query and convert the sleep timeout values similarly to how you did with the display timeout:

```powershell
function Get-SleepTimeout {
    [CmdletBinding()]
    param ()

    # Query the active power scheme settings for AC and DC sleep timeouts
    $ACSleepTimeout = powercfg /query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE | Select-String -Pattern 'Power Setting Index' | ForEach-Object { $_.Line -split '\s+' } | Select-Object -Last 1
    $DCSleepTimeout = powercfg /query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE | Select-String -Pattern 'Power Setting Index' | ForEach-Object { $_.Line -split '\s+' } | Select-Object -First 1

    # Convert extracted values to integers
    $ACSleepTimeout = [int]$ACSleepTimeout
    $DCSleepTimeout = [int]$DCSleepTimeout

    # Create a PSCustomObject with the extracted timeouts
    $TimeoutObject = [PSCustomObject]@{
        ACSleepTimeout = $ACSleepTimeout
        DCSleepTimeout = $DCSleepTimeout
    }

    return $TimeoutObject
}

# Example usage
$SleepTimeout = Get-SleepTimeout
Write-Output "ACSleepTimeout: $($SleepTimeout.ACSleepTimeout)"
Write-Output "DCSleepTimeout: $($SleepTimeout.DCSleepTimeout)"
```

This script defines a function `Get-SleepTimeout` that queries the sleep timeouts for both AC and DC power states, converts the values to integers, and returns them as a custom object. You can modify this approach for other power settings by changing the `SUB_*` and setting names in the `powercfg` query command.
