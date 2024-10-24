$CustomHistoryHandler = {
    param([string]$line)
    $AllowListRegex = @( # Add keywords to match that you want to allow in your history file.
        "Get-TokenFromOutlook"
    ) -join '|'

    $DenyListRegex = @( # Add keywords to match that you don't want in your history file
        "correcthorsebatterystaple"
    ) -join '|'

    switch ($line) {
        { $_ -match $AllowListRegex } { [Microsoft.PowerShell.AddToHistoryOption]::MemoryAndFile }
        { $_ -match $DenyListRegex } { [Microsoft.PowerShell.AddToHistoryOption]::MemoryOnly }
        Default { [Microsoft.PowerShell.PSConsoleReadLine]::GetDefaultAddToHistoryOption($_) } # Default falls back to the default handler function
    }
}
Set-PSReadLineOption -AddToHistoryHandler $CustomHistoryHandler