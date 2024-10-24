$tasks = Get-ScheduledTask | 
    Where-Object { $_.Principal.RunLevel -ne "Limited" -and 
                   $_.Principal.LogonType -ne "ServiceAccount" -and 
                   $_.State -ne "Disabled" -and 
                   $_.Actions[0].CimClass.CimClassName -eq "MSFT_TaskExecAction" }