function psncal {
    <#
        .SYNOPSIS
        Print the calendar vertically i.e. the weekdays will be shown in a column, not in a row

        .EXAMPLE
        psncal
        
        .EXAMPLE
        psncal 1

        .EXAMPLE
        psncal jun

        .EXAMPLE
        psncal january
    #>
    param(
        $Month,
        $Year
    )

    $Months = @{
        1  = "January"
        2  = "February"
        3  = "March"
        4  = "April"
        5  = "May"
        6  = "June"
        7  = "July"
        8  = "August"
        9  = "September"
        10 = "October"
        11 = "November"
        12 = "December"
    }    

    $MonthsToNumber = $(
        [PSCustomObject]@{Month = 'January'; MonthNumber = 1 }
        [PSCustomObject]@{Month = 'February'; MonthNumber = 2 }
        [PSCustomObject]@{Month = 'March'; MonthNumber = 3 }
        [PSCustomObject]@{Month = 'April'; MonthNumber = 4 }
        [PSCustomObject]@{Month = 'May'; MonthNumber = 5 }
        [PSCustomObject]@{Month = 'June'; MonthNumber = 6 }
        [PSCustomObject]@{Month = 'July'; MonthNumber = 7 }
        [PSCustomObject]@{Month = 'August'; MonthNumber = 8 }
        [PSCustomObject]@{Month = 'September'; MonthNumber = 9 }
        [PSCustomObject]@{Month = 'October'; MonthNumber = 10 }
        [PSCustomObject]@{Month = 'November'; MonthNumber = 11 }
        [PSCustomObject]@{Month = 'December'; MonthNumber = 12 }
    )

    if (!$Month) {
        $Month = (Get-Date).Month
    }

    if ($Month -is [string]) {
        $result = $MonthsToNumber | Where-Object { $_.Month -match "^$Month" } 
 
        if ($Month.length -lt 3 -or $result.Count -eq 0) {
            Write-Error "$Month is not a month name"
            return         
        }

        $Month = $result.MonthNumber
    }
    elseif ($Month -lt 1 -or $Month -gt 12) {
        Write-Error "$Month is not a month name or number"
        return         
    }


    if (!$Year) {
        $Year = (Get-Date).Year
    }

    if ($Month -eq 12) {
        $lastDayOfMonth = (Get-Date "1 1 $($Year+1)").AddDays(-1)
    }
    else {
        $lastDayOfMonth = (Get-Date "$($Month+1) 1 $Year").AddDays(-1)
    }
    
    $Map = [Ordered]@{
        "Su" = @()
        "Mo" = @()
        "Tu" = @()
        "We" = @()
        "Th" = @()
        "Fr" = @()
        "Sa" = @()
    }

    1..($lastDayOfMonth.Day) | ForEach-Object {
        $key = (Get-Date "$Month/$_/$Year").DayOfWeek.ToString().SubString(0, 2)

        $Map["$key"] += $_.ToString().PadLeft(2, " ")
    }
    
    "     {0} {1}" -f $Months[$Month], $Year

    $Map.getenumerator() | ForEach-Object {
        
        $t = $_.Value

        $filler = 2 
        if ($t[0] -gt $map.sa[0]) { $filler = 5 }
        
        "{0}{1}{2:2}" -f $_.Key, (' ' * $filler), "$t"
    }
}