function Write-Verbose
{
[cmdletbinding()]
Param(
    [string]$Message
)
    # Comment the next line to disable logging to file
    [string]$LogFilePath = "c:\temp\customlog.txt"

    if($LogFilePath)
    {
        Add-Content -Path "$LogFilePath" -Value "$Message$newLine"
    }
    Microsoft.PowerShell.Utility\Write-Verbose -Message $Message
}