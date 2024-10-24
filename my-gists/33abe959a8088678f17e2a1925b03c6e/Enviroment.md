# Here we explain how to use PowerShell to read and write environment variables, which exist in the user, process and machine contexts

```PowerShell
$env:ComputerName          # The name of the computer
$env:UserName              # The username of the current user
$env:SystemRoot            # The path to the Windows directory
$env:TEMP                  # The path to the temporary folder
$env:ProgramFiles          # The path to the Program Files directory
$env:UserProfile           # The path to the user's profile directory
$env:Path                  # The system PATH environment variable

$DesktopFolder = Join-Path -Path $env:UserProfile -ChildPath "Desktop"
$DocumentsFolder = Join-Path -Path $env:UserProfile -ChildPath "Documents"

Get-ChildItem Env:

$Env:Path -split ';' | ForEach-Object { Write-Host $_ }

# List Paths
$Env:Path

Get-Item -Path Env:

[Environment]::GetEnvironmentVariable("Path")

# List PowerShell's Paths
$Reg = "Registry::HKLM\System\CurrentControlSet\Control\Session Manager\Environment"
(Get-ItemProperty -Path "$Reg" -Name PATH).Path

# We can read and write environment variables in a variety of ways, but the easiest ways to read an environment variable (ComputerName in this example) are as follows

# option 1
(Get-Item -Path Env:ComputerName).Value

# option 2
$env:ComputerName

# Similarly, we can set environment variables like so:
Set-Item -Path Env:\ComputerName -Value "NewComputerName"
$env:ComputerName = "NewComputerName"

# But both of these methods only set the environment variable for the current process (i.e the current session).  To set it persistently, we can use the .net class to manipulate environment variables.  To read we can do the following:
([System.Environment]::GetFolderPath('MyDocuments'))

# Add more folders as needed...
$Console = Split-Path $Host.Name -Leaf
[System.Environment]::CommandLine

([System.Environment]::GetEnvironmentVariables()).COMPUTERNAME

# We can get variables from the different contexts like so:
[System.Environment]::GetEnvironmentVariable('ComputerName','User')
[System.Environment]::GetEnvironmentVariable('ComputerName','Process')
[System.Environment]::GetEnvironmentVariable('ComputerName','Machine')

# and set environment variables like so:
[System.Environment]::SetEnvironmentVariable('ComputerName','NewComputerName','User')
[System.Environment]::SetEnvironmentVariable('ComputerName','NewComputerName','Process')
[System.Environment]::SetEnvironmentVariable('ComputerName','NewComputerName','Machine')

# Special folders differ per user and platform. You can use this method to look up locations like the LocalAppData and favorites.
[System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ApplicationData)
[System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Favorites)
[System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)

# Another useful method is Is64BitProcess to determine whether the currently running process is 64-bit.
[System.Environment]::Is64BitProcess

# You can also find informationa about the user, like user name.
[System.Environment]::UserName

# Using the System.Environment Class
[System.Environment]::OSVersion

# Using the Win32_OperatingSystem CIM Class
Get-CimInstance Win32_OperatingSystem

# Using the systeminfo executable
systeminfo.exe /fo csv | ConvertFrom-Csv

# Using the Get-ComputerInfo Cmdlet
# NOTE: OsHardwareAbstractionLayer was deprecated in version 21H1
Get-ComputerInfo | Select WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer

<#.SYNOPSIS
    PowerShell function to modify Env:Path in the registry
    .DESCRIPTION
    Includes a parameter to append the Env:Path
    .EXAMPLE
    Add-Path -NewPath "D:\Downloads"
#>
Function Global:Add-Path {
    Param (
    [String]
    $NewPath ="D:\Powershell"
    )

    Begin
    {
    Clear-Host
    } # End of small begin section

    Process
    {
        Clear-Host
        $Reg = "Registry::HKLM\System\CurrentControlSet\Control\Session Manager\Environment"
        $OldPath = (Get-ItemProperty -Path "$Reg" -Name PATH).Path
        $NewPath = $OldPath + ';' + $NewPath
        Set-ItemProperty -Path "$Reg" -Name PATH -Value $NewPath -Confirm
    } #End of Process
}
# This is what you type to call the function.
```
