$xlfile='C:\Temp\testHyperlink.xlsx'

$pkg=Open-ExcelPackage $xlfile
$ws=$pkg.Workbook.Worksheets["Sheet1"]
$target = $ws.Cells["A2"]
if($target.Hyperlink) {
    Start-Process $target.Hyperlink.OriginalString
}
Close-ExcelPackage $pkg -NoSave