@(set '(=)||' <# lean and mean cmd / powershell hybrid #> @'

@set /a STEAMWEBHELPER_OFFLINE=0
@set /a USE_NEW_INGAME_OVERLAY=0

:: makes 2 Desktop shortcuts: Steam_min - use with auto-login; Steam_login - use if auto-login is not enabled and dialog is black 
:: after opening Store, leave the page on Discovery Queue menu, then switch to Library and/or enable Small Mode for best idle RAM
@echo off & title steamwebhelper_min || AveYo 2023.08.02
if 1%STEAMWEBHELPER_OFFLINE% gtr 10 (set OFFLINE=--proxy-server=localhost) else (set OFFLINE=--disable-background-networking)
if 1%USE_NEW_INGAME_OVERLAY% gtr 10 (set OVERLAY=) else (set OVERLAY=-vgui)
set ARGS_CEF=--enable-low-end-device-mode --disable-low-res-tiling \"--renderer-process-limit=1\" --aggressive %OFFLINE%
set ARGS_LNK=-cef-disable-gpu -no-dwrite -skipinitialbootstrap -quicklogin -oldtraymenu -silent %OVERLAY%
set ARGS_LNK_MIN=-cef-single-process %ARGS_LNK% 
set ARGS_LNK_LOGIN=-cef-in-process-gpu -userchooser %ARGS_LNK%
for /f "tokens=2*" %%R in ('reg query HKCU\SOFTWARE\Valve\Steam /v SteamPath 2^>nul') do for %%A in ("%%~S") do set "STEAM=%%~fA"
set "CEF32=%STEAM%\bin\cef\cef.win7" & set "CEF64=%STEAM%\bin\cef\cef.win7x64" 
pushd "%STEAM%\bin\cef" & (for /f "delims=" %%A in ('dir steamwebhelper.exe /a:-D /b /s /oD') do set "CEF=%%~dpA") & popd
if not exist "%CEF64%\steamwebhelper.exe" set "CEF64=%CEF:~0,-1%" 
if not exist "%CEF64%\steamwebhelper.exe" if not exist "%CEF32%\steamwebhelper.exe" echo; Steam CEF not found! & pause & exit /b
goto setup 

:changelog
2023.07.13: remove -noshaders
2023.07.17: add --disable-gpu to fix --enable-low-end-device-mode after last steam update
2023.07.24: add Steam_login shortcut to fix black dialog when auto-login is not used - vgui but disables single-process so +100MB
          : disable useless breakpad reporting process, valve does not give a damn about high memory usage issue 
2023.08.02: rip -vgui and 32bit cef, must use old client for it! this script will help both     
          : remove -cef-disable-breakpad as it was generating dumps for no reason
            
:setup
::# elevate with native shell by AveYo
>nul reg add hkcu\software\classes\.Admin\shell\runas\command /f /ve /d "cmd /x /d /r set \"f0=%%2\"& call \"%%2\" %%3"& set _= %*
>nul fltmc|| if "%f0%" neq "%~f0" (cd.>"%temp%\runas.Admin" & start "%~n0" /high "%temp%\runas.Admin" "%~f0" "%_:"=""%" & exit /b)

::# lean xp+ color macros by AveYo:  %<%:af " hello "%>>%  &  %<%:cf " w\"or\"ld "%>%   for single \ / " use .%|%\  .%|%/  \"%|%\"
for /f "delims=:" %%s in ('echo;prompt $h$s$h:^|cmd /d') do set "|=%%s"&set ">>=\..\c nul&set /p s=%%s%%s%%s%%s%%s%%s%%s<nul&popd"
set "<=pushd "%appdata%"&2>nul findstr /c:\ /a" &set ">=%>>%&echo;" &set "|=%|:~0,1%" &set /p s=\<nul>"%appdata%\c"

::# toggle when launched without arguments, else jump to arguments: "install" or "remove"
set CLI=%*& (set IFEO=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options)
if /i "%CLI%"=="" reg query "%IFEO%\steamwebhelper.exe\0" /v Debugger >nul 2>nul && goto remove || goto install
if /i "%~1"=="install" (goto install) else if /i "%~1"=="remove" goto remove

:install
reg add "%IFEO%\steamwebhelper.exe" /f /v UseFilter /d 1 /t reg_dword >nul
reg add "%IFEO%\steamwebhelper.exe\0" /f /v FilterFullPath /d "%CEF64%\steamwebhelper.exe" >nul
reg add "%IFEO%\steamwebhelper.exe\0" /f /v Debugger /d "\"%CEF64%\steamwebhelper_min.exe\" %ARGS_CEF% --ignore=" >nul
reg add "%IFEO%\steamwebhelper.exe\1" /f /v FilterFullPath /d "%CEF32%\steamwebhelper.exe" >nul
reg add "%IFEO%\steamwebhelper.exe\1" /f /v Debugger /d "\"%CEF32%\steamwebhelper_min.exe\" %ARGS_CEF% --ignore=" >nul
reg add "%IFEO%\steamerrorreporter.exe" /f /v UseFilter /d 1 /t reg_dword >nul
reg add "%IFEO%\steamerrorreporter.exe\0" /f /v FilterFullPath /d "%STEAM%\steamerrorreporter.exe" >nul
reg add "%IFEO%\steamerrorreporter.exe\0" /f /v Debugger /d "%SystemRoot%\System32\systray.exe" >nul
reg add "%IFEO%\steamerrorreporter64.exe" /f /v UseFilter /d 1 /t reg_dword >nul
reg add "%IFEO%\steamerrorreporter64.exe\0" /f /v FilterFullPath /d "%STEAM%\steamerrorreporter64.exe" >nul
reg add "%IFEO%\steamerrorreporter64.exe\0" /f /v Debugger /d "%SystemRoot%\System32\systray.exe" >nul
tasklist /fi "imagename eq Steam.exe" | findstr /i Steam.exe >nul && start "s" "%STEAM%\Steam.exe" -shutdown
rd /s /q "%STEAM%\dumps" >nul 2>nul
if not exist "%CEF64%\steamwebhelper_min.exe" mklink /h "%CEF64%\steamwebhelper_min.exe" "%CEF64%\steamwebhelper.exe" >nul
if not exist "%CEF32%\steamwebhelper_min.exe" mklink /h "%CEF32%\steamwebhelper_min.exe" "%CEF32%\steamwebhelper.exe" >nul
set lnk_min1= $l=join-path ([Environment]::GetFolderPath('Desktop')) '\Steam_min.lnk';
set lnk_min2= $s=(new-object -ComObject WScript.Shell).CreateShortcut($l);
set lnk_min3= $s.TargetPath=join-path $env:STEAM '\Steam.exe'; $s.Arguments=$env:ARGS_LNK_MIN; $s.Save();
set lnk_login1= $l=join-path ([Environment]::GetFolderPath('Desktop')) '\Steam_login.lnk';
set lnk_login2= $s=(new-object -ComObject WScript.Shell).CreateShortcut($l);
set lnk_login3= $s.TargetPath=join-path $env:STEAM '\Steam.exe'; $s.Arguments=$env:ARGS_LNK_LOGIN; $s.Save();
powershell -nop -c %lnk_min1% %lnk_min2% %lnk_min3% %lnk_login1% %lnk_login2% %lnk_login3%
echo;
%<%:f0 " steamwebhelper_min 2023.08.02 "%>>% & %<%:2f " INSTALLED "%>>% & %<%:f0 " run again to remove "%>%
if /i "%CLI%"=="" timeout /t 7
exit /b

:remove
reg delete "%IFEO%\steamwebhelper.exe" /f >nul 2>nul
reg delete "%IFEO%\steamerrorreporter.exe" /f >nul 2>nul
reg delete "%IFEO%\steamerrorreporter64.exe" /f >nul 2>nul
del /f /q "%CEF32%\steamwebhelper_min.exe" "%CEF64%\steamwebhelper_min.exe"  >nul 2>nul
echo;
%<%:f0 " steamwebhelper_min 2023.08.02 "%>>% & %<%:df " REMOVED "%>>% & %<%:f0 " run again to install "%>%
if /i "%CLI%"=="" timeout /t 7
exit /b

'@); $0 = "$env:temp\steamwebhelper_min.bat"; ${(=)||} -split "\r?\n" | out-file $0 -encoding default -force; & $0
# press enter
