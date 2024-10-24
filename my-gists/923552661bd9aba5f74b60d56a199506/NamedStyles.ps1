$data = ConvertFrom-Csv @"
Region,State,Units,Price
West,Texas,927,923.71
North,Tennessee,466,770.67
East,Florida,520,458.68
East,Maine,828,661.24
West,Virginia,465,053.58
North,Missouri,436,235.67
South,Kansas,214,992.47
North,North Dakota,789,640.72
South,Delaware,712,508.55
"@

$xlfilename = './testRange.xlsx'
Remove-Item $xlfilename -ErrorAction SilentlyContinue

$xl = $data | Export-Excel $xlfilename -PassThru

Set-ExcelRange -Worksheet $xl.Sheet1 -Range "F1:F10" -Value "Hello World" -AutoSize

$ws = $xl.Sheet1

$namedStyle = $xl.Workbook.Styles.CreateNamedStyle("visa")
$namedStyle.Style.Fill.PatternType = "Solid"
$namedStyle.Style.Fill.BackgroundColor.SetColor(200, 80, 50, 80)
$namedStyle.Style.font.color.SetColor(200, 225, 50, 225)

$namedStyle = $xl.Workbook.Styles.CreateNamedStyle("mastercard")
$namedStyle.Style.Fill.PatternType = "Solid"
$namedStyle.Style.Fill.BackgroundColor.SetColor("Red")
$namedStyle.Style.font.color.SetColor("Blue")

$ws.Cells["F1:F5"].StyleName = "visa"
$ws.Cells["F6:F10"].StyleName = "mastercard"

Close-ExcelPackage $xl -Show