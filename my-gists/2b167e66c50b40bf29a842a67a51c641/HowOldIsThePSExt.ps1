((Invoke-WebRequest https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell).allelements | 
    Where {$_.class -eq 'vss-extension'}).outerText | ConvertFrom-Json | % {
        [PSCustomObject][Ordered]@{
            Name=$_.displayName
            Version=$_.versions.version
            Lastupdated=get-date($_.versions.lastupdated)
            DaysOld=((get-date)-(get-date($_.versions.lastupdated))).Totaldays.tostring("N")
        }
    }