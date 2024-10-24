function Write-Log {
    Param(
        $Message,
        $Path = "$env:USERPROFILE\log.txt"
    )

    function TS {Get-Date -Format 'hh:mm:ss'}
    "[$(TS)]$Message" | Tee-Object -FilePath $Path -Append | Write-Verbose
}

Write-Log 'Some message'