param($data=1..50)

$xl = New-Object -ComObject Excel.Application
$xlProcess = Get-Process excel
$wf = $xl.WorksheetFunction

$data = $data|iex

New-Object PSObject -Property @{
    Median = $wf.Median($data)
    StDev  = $wf.StDev($data)
    Var    = $wf.Var($data)
} | ConvertTo-Html

$xlProcess.kill()