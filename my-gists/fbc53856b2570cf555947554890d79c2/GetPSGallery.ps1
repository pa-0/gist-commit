$result = Find-Module

$data = $result |     
    select @{n="DateCollected";e={(Get-Date).ToString("MM/dd/yyyy")}},    
        Author,
        @{n="YearPublished";e={[int]($_.PublishedDate).Year}},
        @{n="WeekOfYear";e={[int](Get-Date $_.PublishedDate -UFormat %V)}},
        @{n="PublishedDate";e={($_.PublishedDate).ToString("MM/dd/yyyy")}},
        @{n="MonthPublished";e={($_.PublishedDate).Month}},
        @{n="DayPublished";e={($_.PublishedDate).Day}},        
        name, 
        description | sort PublishedDate

$xlFilename = ".\psgallery.xlsx"
rm $xlFilename -Force -ErrorAction Ignore

$data |
    Export-Excel $xlFilename -AutoSize -AutoFilter -Show `
    -IncludePivotChart  -ChartType ColumnStacked `
    -IncludePivotTable -PivotColumns YearPublished `
    -PivotRows MonthPublished  -PivotData YearPublished