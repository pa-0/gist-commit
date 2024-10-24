@echo off
:Main <Username> [Destination=CD]
call :DownloadGists %1 %2 "%CD%"
exit /b
:: TODO Support duplicate file names.
:: Current pagination limit set to 1000
:DownloadGists <Username> <Destination> ~UI/IO
PowerShell -NoProfile -ExecutionPolicy RemoteSigned -Command "$c = New-Object System.Net.WebClient; $c.Headers.Add('user-agent', 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2;)'); $c.DownloadString('https://api.github.com/users/%~1/gists?per_page=1000').Split(',') | ForEach { $_.Split('{') | ForEach { $_.Split('}') | ForEach { If ($_.Contains('filename')) { Write-Host ($f = $_.Split([char]0x0022)[3].Replace(([char]0x0022).ToString(), '')) } ElseIf ($_.Contains('raw_url')) { $c.DownloadFile($_.Split([char]0x0022)[3].Replace(([char]0x0022).ToString(), ''), '%~2\' + $f) } } } };"
exit /b