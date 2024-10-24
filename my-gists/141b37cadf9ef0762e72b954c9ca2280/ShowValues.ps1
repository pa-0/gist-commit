$xlfile = "$env:TEMP\datalabels.xlsx"

rm $xlfile -ErrorAction SilentlyContinue

$data = 1..20 | % {
    [PSCustomObject]@{Idx=$_; Amount=Get-Random -Minimum 10 -Maximum 100}
}

$excel = $data | Export-Excel -Path $xlfile -AutoNameRange -PassThru

$chartParams = @{
    Worksheet    = $excel.Workbook.Worksheets["Sheet1"]
    XRange       = "Idx"
    YRange       = "Amount"
    Title        = "The Title" 
    ChartType    = "ColumnClustered"
    SeriesHeader = "The Data" 
}

$chart = Add-ExcelChart @chartParams -PassThru 
$chart.DataLabel.ShowValue = $true

Close-ExcelPackage $excel -Show