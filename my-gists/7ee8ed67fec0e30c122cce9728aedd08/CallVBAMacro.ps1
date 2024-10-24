$f= "C:\TryPracticalAstronomy\MoonPhase.xls"

$xl = New-Object -ComObject Excel.application
$workbooks=$xl.Workbooks
$wb=$workbooks.Open($f)

$xl.Run("MoonLong",0,0,0,0,0,1,9,2003)

$wb.Close($false)
$null=[System.Runtime.InteropServices.Marshal]::ReleaseComObject($wb)
$wb=$null

$null=[System.Runtime.InteropServices.Marshal]::ReleaseComObject($workbooks)
$workbooks=$null

$xl.Quit()
$null=[System.Runtime.InteropServices.Marshal]::ReleaseComObject($xl)

$xl=$null