function fdom {
    param([datetime]$date=(get-date))

    Get-Date("{0}/1/{1}" -f $date.Month, $date.Year)
}

function ldom {
    param([datetime]$date=(get-date))
    
    (Get-Date("{0}/1/{1}" -f $date.AddMonths(1).Month, $date.Year)).AddDays(-1)
}
