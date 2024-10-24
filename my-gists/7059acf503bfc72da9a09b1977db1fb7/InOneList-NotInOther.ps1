$list1 = ConvertFrom-Csv @"
list1
Gigi
Jo
Chin
Phil
Jojo
"@

$list2 = ConvertFrom-Csv @"
list2
Chin
Gigi
Jo
Mindy
Phil
Sioux
Tyrone
"@

$xlfile = "$PSScriptRoot\lists.xlsx"
Remove-Item $xlfile -ErrorAction SilentlyContinue

$wsName = "Unique Values"
$c1 = New-ConditionalText -ConditionalType UniqueValues -Range '$A$2:$C$8' 

$list1 | Export-Excel $xlfile -WorksheetName $wsName
$list2 | Export-Excel $xlfile -WorksheetName $wsName -StartColumn 3 -ConditionalText $c1 -Show