$xlfile = "$env:TEMP\PSreports.xlsx"
Remove-Item $xlfile -ErrorAction SilentlyContinue

# Get-Process
$ecd = New-ExcelChartDefinition -XRange "A3:A7" -YRange "C3:C7" -Row 30 -Column 1 -Title "Report Process`nTotal Handles" -NoLegend
Get-Process | Select -First 5 |
    Export-Excel $xlfile -AutoSize -StartRow 2 -TableName ReportProcess -ExcelChartDefinition $ecd

# Get-Service
Get-Service | Select -First 5 |
    Export-Excel $xlfile -AutoSize -StartRow 11 -TableName ReportService

# Directory Listing
$excel = Get-ChildItem $env:HOMEPATH\Documents\WindowsPowerShell |
    Select PSDRive, PSIsC*, FullName, *time* |
    Export-Excel $xlfile -AutoSize -StartRow 20 -TableName ReportFiles -PassThru

# Get the sheet named Sheet1
$ws = $excel.Workbook.Worksheets['Sheet1']

# Create a hashtable with a few properties
# that you'll splat on Set-Format
$xlParams = @{WorkSheet=$ws;Bold=$true;FontSize=18}

# Create the headings in the Excel worksheet
Set-Format -Range A1  -Value "Report Process" @xlParams -AutoSize
Set-Format -Range A10 -Value "Report Service" @xlParams 
Set-Format -Range A19 -Value "Report Files"   @xlParams 

# Close and Save the changes to the Excel file
# Launch the Excel file using the -Show switch
Close-ExcelPackage $excel -Show