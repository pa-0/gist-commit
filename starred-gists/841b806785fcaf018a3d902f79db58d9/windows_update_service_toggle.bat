goto="init" /* %~nx0
:: unified v9 final builds: Notifications = low block, Installs = medium block, Downloads = high block, Service = full block 
:: v9.1: add a DefenderUpdate 4-hours scheduled task (if automatic updates are disabled, Defender can fail updating on it's own) 
:: v9.2: switch wuauserv to own process for more reliable on-demand start 
::----------------------------------------------------------------------------------------------------------------------------------
:about                                            Consider using the much safer and convenient windows_update_toggle.bat instead!
::----------------------------------------------------------------------------------------------------------------------------------
title Windows Update Toggle
call :check_status
echo.
echo      ---------------------------------------------------------------------
echo     :                 Windows Update Service Toggle v9.2                  :
echo     :---------------------------------------------------------------------:
echo     :              Block wuauserv from even checking [Full]               :
echo     :  Store and Defender protection updates don't work - get another AV  :
echo     :        Use Desktop right-click context menu entry to toggle         :
echo     :                                                                     :
echo     :                          Currently: %STATUS%%_%                     :
echo     :                                                                     :
echo     : Press Alt+F4 to cancel                    Always run latest version :
echo      ---------------------------------------------------------------------
echo      Installs and Notifications only builds available: https://git.io/vx2et
echo.
exit/b
:: What could go wrong: nothing - simply run the script again to undo. Windows Update troubleshooter can do the rest  
::----------------------------------------------------------------------------------------------------------------------------------
:main [ Batch main function ]
::----------------------------------------------------------------------------------------------------------------------------------
set "build=Service" &set "xnotify=" &set "xerr=" &set "xupd=" &set "xopt=" &color 07 &call :about &timeout /t 10
:: notification blocking
set "xnotify=%xnotify% MusNotification MusNotifyIcon"                 || Tasks\Microsoft\Windows\UpdateOrchestrator       ESSENTIAL!  
set "xnotify=%xnotify% UpdateNotificationMgr UNPUXLauncher UNPUXHost" || Tasks\Microsoft\Windows\UNP
set "xnotify=%xnotify% Windows10UpgraderApp DWTRIG20 DW20 GWX"        || Windows10Upgrade
:: error reporting blocking
set "xerr=%xerr% wermgr WerFault WerFaultSecure DWWIN"                || Tasks\Microsoft\Windows\Windows Error Reporting
:: diag - optional blocking of diagnostics / telemetry
rem set "xopt=%xopt% compattelrunner"                                 || Tasks\Microsoft\Windows\Application Experience
rem set "xopt=%xopt% dstokenclean appidtel"                           || Tasks\Microsoft\Windows\ApplicationData
rem set "xopt=%xopt% wsqmcons"                                        || Tasks\Microsoft\Windows\Customer Experience Improvement Prg
rem set "xopt=%xopt% dusmtask"                                        || Tasks\Microsoft\Windows\DUSM
rem set "xopt=%xopt% dmclient"                                        || Tasks\Microsoft\Windows\Feedback\Siuf
rem set "xopt=%xopt% DataUsageLiveTileTask"                           || Tasks\{SID}\DataSenseLiveTileTask
rem set "xopt=%xopt% DiagnosticsHub.StandardCollector.Service"        || System32\DiagSvcs
rem set "xopt=%xopt% HxTsr"                                           || WindowsApps\microsoft.windowscommunicationsapps
:: other - optional blocking of other tools
rem set "xopt=%xopt% PilotshubApp"                                    || WindowsApps\Microsoft.WindowsFeedbackHub_
rem set "xopt=%xopt% SpeechModelDownload SpeechRuntime"               || Tasks\Microsoft\Windows\Speech                  RECOMMENDED
rem set "xopt=%xopt% LocationNotificationWindows WindowsActionDialog" || Tasks\Microsoft\Windows\Location
rem set "xopt=%xopt% DFDWiz disksnapshot"                             || Tasks\Microsoft\Windows\DiskFootprint
::----------------------------------------------------------------------------------------------------------------------------------
:: all_entries - used to cleanup orphaned / commented entries between script versions
set e1=TiWorker UsoClient wuauclt wusa WaaSMedic SIHClient WindowsUpdateBox GetCurrentRollback WinREBootApp64 WinREBootApp32
set e2=MusNotification MusNotifyIcon UpdateNotificationMgr UNPUXLauncher UNPUXHost Windows10UpgraderApp DWTRIG20 DW20 GWX wuapihost
set e3=wermgr WerFault WerFaultSecure DWWIN compattelrunner dstokenclean appidtel wsqmcons dusmtask dmclient DataUsageLiveTileTask
set e4=DiagnosticsHub.StandardCollector.Service HxTsr PilotshubApp SpeechModelDownload SpeechRuntime LocationNotificationWindows
set e5=WindowsActionDialog DFDWiz disksnapshot TrustedInstaller
set all_entries=%e1% %e2% %e3% %e4% %e5% & set exe=%xnotify% %xerr% %xupd% %xopt%
:: Cleanup orphaned / commented items between script versions
echo.
for %%C in (%all_entries%) do call :cleanup_orphaned %%C
echo.
:: Toggle execution via IFEO
set/a "bl=0" & set/a "unbl=0" & set "REGISTRY_MISMATCH=echo [REGISTRY MISMATCH CORRECTED] & echo."
for %%a in (%exe%) do call :ToggleExecution "%ifeo%\%%a.exe"
if %bl% gtr 0 if %unbl% gtr 0 %REGISTRY_MISMATCH% & for %%a in (%exe%) do call :ToggleExecution "%ifeo%\%%a.exe" forced
echo.
call :check_status
:: Block wuauserv via clever sc method - survives update troubleshooter
if "%STATUS%"=="OFF" ( set "wuauserv=svchost.exe" ) else set "wuauserv=svchost.exe -k netsvcs"   
net stop wuauserv /y &sc config wuauserv binPath= "%%systemroot%%\system32\%wuauserv%" type= own>nul 2>nul
echo.
:: Generate WindowsUpdate.cmd script to update manually
pushd "%systemroot%" & set wu=WindowsUpdate.cmd
 >%wu% echo/goto="init" /*
>>%wu% echo/:main Windows Update %build% Toggle - Desktop right-click menu entry [ https://git.io/vx2et ]
>>%wu% echo/set "ifeo=HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"
>>%wu% echo/reg query "%%ifeo%%\MusNotification.exe" /v Debugger 1^>nul 2^>nul ^&^& set "STATUS=OFF" ^|^| set "STATUS=ON!"
>>%wu% echo/set "dmy=%%systemroot%%\System32\systray.exe" ^&set "exe=%exe%"
>>%wu% echo/if "%%STATUS%%"=="OFF" for %%%%a in ^(%%exe%%^) do reg delete "%%ifeo%%\%%%%a.exe" /v "Debugger" /f ^>nul 2^>nul
>>%wu% echo/if "%%STATUS%%"=="ON!" for %%%%a in ^(%%exe%%^) do reg add "%%ifeo%%\%%%%a.exe" /v "Debugger" /d "%%dmy%%" /f ^>nul
>>%wu% echo/if "%%STATUS%%"=="ON!" for %%%%a in ^(%%exe%%^) do taskkill /IM %%%%a.exe /t /f ^>nul 2^>nul
>>%wu% echo/net stop wuauserv /y ^>nul 2^>nul ^&timeout /t 2 ^>nul
>>%wu% echo/if "%%STATUS%%"=="OFF" ^( set "wuauserv=svchost.exe -k netsvcs" ^) else set "wuauserv=svchost.exe"   
>>%wu% echo/sc config wuauserv binPath= "%%%%systemroot%%%%\system32\%%wuauserv%%" type= own^>nul 2^>nul ^&timeout /t 2 ^>nul
>>%wu% echo/if "%%STATUS%%"=="OFF" net start wuauserv ^&timeout /t 2 ^>nul
>>%wu% echo/reg query "%%ifeo%%\MusNotification.exe" /v Debugger 1^>nul 2^>nul ^&^& set "STATUS=OFF" ^|^| set "STATUS=ON!"
>>%wu% echo/set "key=HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsUpdate"
>>%wu% echo/reg add "%%key%%" /v "MUIVerb" /d "Windows Update %build% : %%STATUS%%" /f ^>nul 2^>nul
>>%wu% echo/echo. ^&echo  Windows Update %build% now: %%STATUS%%
>>%wu% echo/schtasks /Run /TN DefenderUpdate ^>nul 2^>nul
>>%wu% echo/timeout /t 6 ^>nul ^& exit
>>%wu% echo/:"init"
>>%wu% echo/@echo off ^&title Windows Update ^&mode 80,4 ^&color 1f ^&setlocal ^&if "%%1"=="init" shift ^&shift ^&goto :main
>>%wu% echo/reg query "HKEY_USERS\S-1-5-20\Environment" /v temp 1^>nul 2^>nul ^&^& goto :main ^|^| echo. ^&echo  Requesting rights..
>>%wu% echo/call cscript /nologo /e:JScript "%%~f0" get_rights "%%1" ^& exit *^/
>>%wu% echo/function get_rights^(fn^) { var console_init_shift='/c start "init" "'+fn+'"'+' init '+fn+' '+WSH.Arguments^(1^);
>>%wu% echo/  WSH.CreateObject^("Shell.Application"^).ShellExecute^('cmd.exe',console_init_shift,"","runas",1^); }
>>%wu% echo/if ^(WSH.Arguments.length^>=1 ^&^& WSH.Arguments^(0^)=="get_rights"^) get_rights^(WSH.ScriptFullName^);
takeown /f %wu% >nul 2>nul &icacls %wu% /grant %username%:F >nul 2>nul 
if "%STATUS%"=="ON!" del /f /q %wu%  >nul 2>nul
:: Add Desktop right-click entry [Windows Update] to update manually 
set "key=HKEY_CLASSES_ROOT\DesktopBackground\Shell\WindowsUpdate"
reg delete "%key%" /f >nul 2>nul
reg add "%key%" /v "MUIVerb" /d "Windows Update %build% : OFF" /f >nul 2>nul
reg add "%key%" /v "Icon" /d "appwiz.cpl,5" /f >nul 2>nul 
reg add "%key%" /v "Position" /d "Bottom" /f >nul 2>nul
reg add "%key%\command" /ve /d "%systemroot%\WindowsUpdate.cmd" >nul 2>nul  
if "%STATUS%"=="ON!" reg delete "%key%" /f >nul 2>nul
:: Add a DefenderUpdate scheduled task every 4-hours
set "defu=cmd.exe /c pushd \"%%ProgramFiles%%\Windows Defender\""
set "defu=%defu% & MpCmdRun.exe -removedefinitions -dynamicsignatures"
set "defu=%defu% & MpCmdRun.exe -SignatureUpdate"
schtasks /Delete /TN DefenderUpdate /f >nul 2>nul
if "%STATUS%"=="OFF" schtasks /Create /RU "System" /sc MINUTE /MO 240 /TN DefenderUpdate /TR "%defu%" /ST "12:00:00" /NP >nul 2>nul
if "%STATUS%"=="OFF" schtasks /Run /TN DefenderUpdate >nul 2>nul

:: Done!
echo ---------------------------------------------------------------------
if "%STATUS%"=="OFF" ( color 0c &echo  Windows Update %build% now: OFF ) else color 0b &echo  Windows Update %build% now: ON!
if "%STATUS%"=="OFF" ( echo  Use Desktop right-click menu to toggle.. ) else echo  Desktop right-click menu removed..
echo ---------------------------------------------------------------------
echo.
pause
exit

::----------------------------------------------------------------------------------------------------------------------------------
:: Utility functions
::----------------------------------------------------------------------------------------------------------------------------------
:check_status
set "ifeo=HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options"  
reg query "%ifeo%\MusNotification.exe" /v Debugger 1>nul 2>nul && set "STATUS=OFF" || set "STATUS=ON!"
set "_=        " &if "%STATUS%"=="OFF" ( color 0c ) else color 0b
exit/b

:cleanup_orphaned %1:[entry to check, used internally] %2:[anytext=silent]
call set "orphaned=%%exe:%1=%%" & set "okey="%ifeo%\%1.exe""
if /i "%orphaned%"=="%exe%" reg delete %okey% /v "Debugger" /f >nul 2>nul & if /i ".%2"=="." echo %1 not selected.. 
exit/b

:ToggleExecution %1:[regpath] %2:[optional "forced"]
set "dummy=%windir%\System32\systray.exe" & rem allow dummy process creation to limit errors
if "%STATUS%_%2"=="OFF_forced" reg delete "%~1" /v "Debugger" /f >nul 2>nul & exit/b
if "%STATUS%_%2"=="ON!_forced" reg add "%~1" /v Debugger /d "%dummy%" /f >nul 2>nul & exit/b
reg query "%~1" /v Debugger 1>nul 2>nul && set "isBlocked=1" || set "isBlocked="
if defined isBlocked reg delete "%~1" /v "Debugger" /f >nul 2>nul & set/a "unbl+=1" & echo %~n1 un-blocked! & exit/b 
reg add "%~1" /v Debugger /d "%dummy%" /f >nul 2>nul & set/a "bl+=1" & echo %~n1 blocked! & taskkill /IM %~n1 /t /f >nul 2>nul
exit/b

::----------------------------------------------------------------------------------------------------------------------------------
:"init" [ Batch entry function ]
::----------------------------------------------------------------------------------------------------------------------------------
@echo off & cls & setlocal & if "%1"=="init" shift &shift & goto :main &rem Admin self-restart flag found, jump to main
reg query "HKEY_USERS\S-1-5-20\Environment" /v temp 1>nul 2>nul && goto :main || call :about 0c & echo  Requesting admin rights..
call cscript /nologo /e:JScript "%~f0" get_rights "%1" & exit
::----------------------------------------------------------------------------------------------------------------------------------
*/ // [ JScript functions ] all batch lines above are treated as a /* js comment */ in cscript
function get_rights(fn) { var console_init_shift='/c start "init" "'+fn+'"'+' init '+fn+' '+WSH.Arguments(1);
  WSH.CreateObject("Shell.Application").ShellExecute('cmd.exe',console_init_shift,"","runas",1); }
if (WSH.Arguments.length>=1 && WSH.Arguments(0)=="get_rights") get_rights(WSH.ScriptFullName);
//