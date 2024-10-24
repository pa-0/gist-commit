@echo off &title Windows Update Reboot Toggle
reg query "HKEY_USERS\S-1-5-20\Environment" /v TEMP >nul 2>nul || goto need_admin_rights

set "updatetasks=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\Microsoft\Windows\UpdateOrchestrator"
call :check_status "%updatetasks%\Reboot"
echo.
echo      ---------------------------------------------------------------------
echo     :                  Windows Update Reboot Toggle v4.7                  :
echo     :---------------------------------------------------------------------:
echo     : Prevent protected reboot and wake to run tasks without disabling WU :
echo     :           Just run this script again to toggle tasks on/off         :
echo     :                                                                     :
echo     :                          Currently: %STATUS%%_%                     :
echo     :                                                                     :
echo     : Press Alt+F4 to cancel                                Green is good :
echo      ---------------------------------------------------------------------
echo       All-around Windows Update Toggle available at https://git.io/vx2et
echo.
timeout /t 10 &echo.

:: Disable WakeToRun for all tasks
set "p1=try{ Get-ScheduledTask | foreach{ if ($_.Settings.WakeToRun -eq $true){ Set-ScheduledTask"
set "p2= -TaskName $_.TaskName -TaskPath  $_.TaskPath -Settings (New-ScheduledTaskSettingsSet -WakeToRun:$false)} } }catch{}"
powershell -noprofile -c "%p1% %p2%" >nul 2>nul

:: Use Reg_TakeOwnership snippet to unprotect UpdateOrchestrator task cache registry keys
reg add "%updatetasks%\Reboot" /v checkrights /d 1 /f >nul 2>nul || call :reg_takeownership "%updatetasks%" Administrators rcsv
reg delete "%updatetasks%\Reboot" /v checkrights /f >nul 2>nul
:: Toggle Reboot task
call :toggle_task "%updatetasks%\Reboot"
:: Toggle Schedule Retry Scan task
call :toggle_task "%updatetasks%\Schedule Retry Scan"
:: Update status
call :check_status "%updatetasks%\Reboot"
echo.

:: Done!
echo -------------------------------------
echo  Windows Update Reboot Tasks now: %STATUS%
echo -------------------------------------
echo.
pause
exit

::----------------------------------------------------------------------------------------------------------------------------------
:: Utility functions
::----------------------------------------------------------------------------------------------------------------------------------
:check_status %1:TaskCache entry in registry
reg query "%~1" /v "Id_OFF" >nul 2>nul && set "STATUS=OFF" || set "STATUS=ON!"
set "_=        " &if "%STATUS%"=="OFF" ( color 0a ) else color 0c
exit/b

:toggle_task %1:TaskCache entry in registry
reg query "%~1" /v "Id_OFF" >nul 2>nul && set "isOFF=1" || set "isOFF="
reg query "%~1" /v "Id" >nul 2>nul && set "isOFF=" || set "isOFF=1"
if defined isOFF ( call :reg_query "%~1" "Id_OFF" ID_BACKUP ) else call :reg_query "%~1" "Id" ID_BACKUP
if defined isOFF ( reg delete "%~1" /v "Id_OFF" /f &reg add "%~1" /v "Id" /d %ID_BACKUP% /f )
if not defined isOFF ( reg delete "%~1" /v "Id" /f &reg add "%~1" /v "Id_OFF" /d %ID_BACKUP% /f )
exit/b

:reg_takeownership %1:regkey[ex:"HKCU\Console"] %2:_user[optional, default:"Administrators"] %3:_recursive[optional, default:""]
set "s10=$dll0='[DllImport(''ntdll.dll'')]public static extern int RtlAdjustPrivilege(ulong a,bool b,bool c,ref bool d);'; $ntdll="
set "s11=Add-Type -Member $dll0 -Name NtDll -PassThru; foreach($i in @(9,17,18)){$null=$ntdll::RtlAdjustPrivilege($i,1,0,[ref]0)};"
set "s12=function Reg_TakeOwnership { param($hive, $key, $own, $inherit=$false);"
set "s13= $reg=[Microsoft.Win32.Registry]::$hive.OpenSubKey($key,'ReadWriteSubTree','TakeOwnership');"
set "s14= $acl=New-Object System.Security.AccessControl.RegistrySecurity; $acl.SetOwner($own); $reg.SetAccessControl($acl);"
set "s15= $acl.SetAccessRuleProtection($false,$false);$reg.SetAccessControl($acl);"
set "s16= $reg=$reg.OpenSubKey('','ReadWriteSubTree','ChangePermissions'); if($inherit){"
set "s17= $rule=New-Object System.Security.AccessControl.RegistryAccessRule($own,'FullControl','ContainerInherit','None','Allow');"
set "s18= $acl.ResetAccessRule($rule);$reg.SetAccessControl($acl);} }; $rk=$regkey -split '\\\\',2; $key=$rk[1];"
set "s19=switch -regex ($rk[0]) { '[mM]'{$HK='LocalMachine'};'[uU]'{$HK='CurrentUser'}; default {$HK='ClassesRoot'}; }; $HK; $key;"
set "s20=if($user -eq ''){$user='Administrators'}; [System.Security.Principal.NTAccount]$owner=$user; $rcsv=($recursive -ne '');"
set "s21=Reg_TakeOwnership $HK $key $owner $true; if($rcsv){$r=[Microsoft.Win32.Registry]::$HK.OpenSubKey($key);"
set "s22=foreach($sk in $r.GetSubKeyNames()){$sk; try{ Reg_TakeOwnership $HK $($key+'\\'+$sk) $owner }catch{} }} "
setlocal & for /l %%# in (10,1,22) do call set "ps_RegTakeOwnership=%%ps_RegTakeOwnership%%%%s%%#:'=\"%%"
powershell.exe -c " $regkey='%~1';$user='%~2';$recursive='%~3'; %ps_RegTakeOwnership%;"
endlocal & exit/b                                         AveYo: call :reg_takeownership "HKLM\MyKey" "NT Service\TrustedInstaller"

:reg_query %1:KeyName %2:ValueName %3:OutputVariable %4:other_options[example: "/t REG_DWORD"]
setlocal & for /f "skip=2 delims=" %%s in ('reg query "%~1" /v "%~2" /z 2^>nul') do set "rq=%%s" & call set "rv=%%rq:*)    =%%"
endlocal & set "%~3=%rv%" & exit/b                                              AveYo: call :reg_query "HKCU\MyKey" "MyValue" MyVar

:need_admin_rights
color 0e&echo. &echo  PERMISSION DENIED! Right-click %~nx0 ^& Run as administrator &timeout /t 60 &color 0f&title %COMSPEC% &exit/b
::end