$data = ConvertFrom-Csv @'
Name,Score,Grade
Ahmed,76
Bassam,91
Amira,42
Nadia,83
Joseph,36
Mary,45
Ashraf,81
Amal,56
Ben,62
Jack,79
John,45
Michael,81
Jennifer,78
'@

$lookup = ConvertFrom-Csv @"
Score,Lower,Grade
0-49,0,Fail
50-64,50,Pass
65-74,65,Good
75-84,75,Very Good
85-100,85,Excellent
"@

$xlfile = "$psscriptroot\grades.xlsx"
Remove-Item $xlfile -ErrorAction SilentlyContinue

$data  | Export-Excel $xlfile -StartRow 4 -StartColumn 2 -AutoSize
$excel = $lookup | Export-Excel $xlfile -StartRow 4 -StartColumn 6 -AutoSize -PassThru

Set-ExcelRange -Worksheet $excel.Sheet1 -Range "D5:D17" -Formula '=VLOOKUP(C5,$G$5:$H$9,2)' -Width 15

$b = 'Medium'
$borderParam = @{
    BorderTop    = $b
    BorderLeft   = $b
    BorderBottom = $b
    BorderRight  = $b
}

Set-ExcelRange -Worksheet $excel.Sheet1 -Range "F4:H9" @borderParam

Close-ExcelPackage $excel -Show
