@echo off &Title 'Close Handles' context menu to unlock files or folders by AveYo v2019.09.27
:: changelog: fix dl; add /accepteula; check S-1-5-19 for admin; ask for admin rights to catch system handles; auto-hide window

:: add_remove whenever script is run again
reg query "HKCU\Software\Classes\Directory\shell\CloseHandles" /v MuiVerb >nul 2>nul && (
 reg delete HKCU\Software\Classes\Directory\shell\CloseHandles /f >nul 2>nul
 reg delete HKCU\Software\Classes\Drive\shell\CloseHandles /f >nul 2>nul
 reg delete HKCU\Software\Classes\*\shell\CloseHandles /f >nul 2>nul
 color 0c &echo. &echo  REMOVED! Run script again to add 'Close Handles' context menu
 timeout /t -1 &color 0f &title %COMSPEC% &exit/b
)

:: check if handle tool exists and if not warn about needing admin rights to install it
set "URL=https://download.sysinternals.com/files/Handle.zip"
pushd %TEMP%
if not exist "%WINDIR%\handle.exe" (set "DOWNLOAD=1") else goto has_handle
reg query HKU\S-1-5-19 >nul 2>nul || (
 color 0e
 echo.
 echo  PERMISSION DENIED! Right-click %~nx0 ^& Run as administrator
 echo  or manually download and unzip %URL%
 echo  then copy handle.exe to %WINDIR%
 echo.
)

:: try to download handle tool from sysinternals (microsoft)
pushd %TEMP%
for /f "tokens=3 delims=. " %%i in ('bitsadmin.exe /create /download Handle.zip') do set "JOB=%%i"
call bitsadmin /transfer %%JOB%% /download /priority foreground %%URL%% "%TEMP%\handle.zip" >nul 2>nul
call bitsadmin /complete %%JOB%% >nul 2>nul
set "PS_DOWNLOAD=[Net.ServicePointManager]::SecurityProtocol='tls12,tls11,tls';(new-object System.Net.WebClient).DownloadFile"
if not exist handle.zip powershell -nop -c "%PS_DOWNLOAD%('%URL%','handle.zip')"
if not exist handle.zip certutil -URLCache -split -f "%URL%" >nul 2>nul             &REM naked Windows 7 workaround
set "PS_UNZIP=$s=new-object -com shell.application;foreach($i in $s.NameSpace($zip).items()){$s.Namespace($dir).copyhere($i)}"
if exist handle.zip powershell -nop -c "$dir='%TEMP%'; $zip='%TEMP%\handle.zip'; %PS_UNZIP%"
timeout /t 3 /nobreak >nul
copy /y handle.exe "%WINDIR%\" 2>nul
:has_handle

:: command to run
set "s1=echo ''[ CLOSE HANDLES BY AVEYO ]''; $s=''%%1'';if(([IO.FileInfo]$s).Mode -notmatch ''d''){$s=($s -split ''\\'')[-1]};"
set "s2=$o=New-Object Collections.ArrayList; handle.exe /accepteula -a -u $s| foreach {if ($_ -match ''pid: "
set "s3=(?<P>\d*)\s.*\s(?<H>[\da-z]*):\s*(?<F>[\\a-z]:\\.*)''){$m=''''|select ''O'',''P'',''H'',''F''; $m.P=$matches[''P'']; "
set "s4=$m.H=$matches[''H'']; $m.F=$matches[''F'']; $m.O=$_.Substring(0, $_.lastIndexOf($m.H)); $o.Add($m) | Out-Null} };"
set "s5=$o | Out-GridView -Title ''Close handles'' -PassThru | foreach{handle.exe /accepteula -p $_.P -c $_.H -y}"
set "snipp=powershell -w hidden -c start powershell -ArgumentList '-c %s1% %s2% %s3% %s4% %s5%' -verb RunAs -windowstyle hidden"

:: generate context menu
(
reg add HKCU\Software\Classes\Directory\shell\CloseHandles /v MuiVerb /d "Close Handles" /f
reg add HKCU\Software\Classes\Directory\shell\CloseHandles /v HasLUAShield /d "" /f
reg add HKCU\Software\Classes\Directory\shell\CloseHandles\command /ve /d "%snipp%" /f
reg add HKCU\Software\Classes\Drive\shell\CloseHandles /v MuiVerb /d "Close Handles" /f
reg add HKCU\Software\Classes\Drive\shell\CloseHandles /v HasLUAShield /d "" /f
reg add HKCU\Software\Classes\Drive\shell\CloseHandles\command /ve /d "%snipp%" /f
reg add HKCU\Software\Classes\*\shell\CloseHandles /v MuiVerb /d "Close Handles" /f
reg add HKCU\Software\Classes\*\shell\CloseHandles /v HasLUAShield /d "" /f
reg add HKCU\Software\Classes\*\shell\CloseHandles\command /ve /d "%snipp%" /f
) >nul

:: done
echo.
echo  ADDED! Run "%~nx0" again to remove 'Close Handles' context menu
timeout /t -1
exit/b
