# Install-Module -Name Profiler
# created by: @nohwnd - twitter - Jakub Jareš

$trace = Trace-Script { 
    Get-Process |
        Select-Object -First 5 Company,Name,handles | 
        Export-Excel ./tempProfiler.xlsx 
}

Remove-Item ./tempProfiler.xlsx -ErrorAction SilentlyContinue

###

Remove-Item ./traceData.xlsx -ErrorAction SilentlyContinue

$properties = $(
    'Text'
    'Name'
    'Line'
    @{name = 'DurationInSeconds'; expression = { $_.Duration.TotalSeconds } }
    @{name = 'AverageInSeconds'; expression = { $_.Average.TotalSeconds } }
    @{name = 'SelfDurationInSeconds'; expression = { $_.SelfDuration.TotalSeconds } }
    @{name = 'SelfAverageInSeconds'; expression = { $_.SelfAverage.TotalSeconds } }
    'HitCount'
    'Percent'
)

$HitCountChart = New-ExcelChartDefinition -XRange Name -YRange HitCount -NoLegend -Title 'Hit Count' -Column 10
$DurationInSecondsChart = New-ExcelChartDefinition -XRange Name -YRange DurationInSeconds -NoLegend -Title 'Duration in Seconds' -Row 19 -Column 10 

$xl = $trace.Top50Duration | 
    Select-Object -Property $properties -Skip 1 | 
    Export-Excel ./traceData.xlsx -AutoSize -AutoFilter -AutoNameRange -TableName traceData `
        -ExcelChartDefinition $HitCountChart, $DurationInSecondsChart -PassThru

$ws = $xl.sheet1
Set-ExcelRange -Worksheet $ws -Range 'A:A' -Width 15
Set-ExcelRange -Worksheet $ws -Range DurationInSeconds -NumberFormat "#.####0"
Add-ConditionalFormatting -Worksheet $ws -Address HitCount -DataBarColor Red

Close-ExcelPackage $xl -Show