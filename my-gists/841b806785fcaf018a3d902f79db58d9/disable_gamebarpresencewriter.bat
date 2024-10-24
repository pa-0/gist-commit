@echo off &title Disable GamebarPresenceWriter - proper method
reg query "HKEY_USERS\S-1-5-20\Environment" /v TEMP >nul 2>nul || goto need_admin_rights

call :check_status
echo.
echo      ---------------------------------------------------------------------
echo     :                 Disable GamebarPresenceWriter v3.1                  :
echo     :---------------------------------------------------------------------:
echo     :  Runs even if Windows DVR is disabled, and can cause game stutters  :
echo     :   This won't disable the Win + G GameBar. Use Settings to do that   :
echo     :             Just run this script again to toggle on/off             :
echo     :                                                                     :
echo     :                          Currently: %STATUS%%_%                     :
echo     :                                                                     :
echo     : Press Alt+F4 to cancel                    Always run latest version :
echo      ---------------------------------------------------------------------
echo.
timeout /t 10 &echo.
set "acikey=Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter"  
set "reg64=HKLM\SOFTWARE" &set "reg32=HKLM\SOFTWARE\WOW6432Node"
:: Use reg_takeownership snippet to unprotect GamebarPresenceWriter registry key
reg delete "%reg64%\%acikey%" /v "ActivationType" /f >nul 2>nul || call :reg_takeownership "%reg64%\%acikey%" "Administrators"
reg delete "%reg32%\%acikey%" /v "ActivationType" /f >nul 2>nul || call :reg_takeownership "%reg32%\%acikey%" "Administrators"
:: Toggle GamebarPresenceWriter activatable class id in the registry
if "%STATUS%"=="OFF" ( set "ActivationType=0x1" ) else set "ActivationType=0x0"
reg add "%reg64%\%acikey%" /v "ActivationType" /t REG_DWORD /d %ActivationType% /f >nul 2>nul
reg add "%reg32%\%acikey%" /v "ActivationType" /t REG_DWORD /d %ActivationType% /f >nul 2>nul  
call :check_status
echo ActivationType = %ActivationType%   
echo.

:: Done!
echo ------------------------------
if "%STATUS%"=="OFF" ( color 0c &echo  GamebarPresenceWriter now: OFF ) else color 0b &echo  GamebarPresenceWriter now: ON! 
echo ------------------------------
echo.
pause
exit

::----------------------------------------------------------------------------------------------------------------------------------
:: Utility functions
::----------------------------------------------------------------------------------------------------------------------------------
:check_status
set "acikey=Microsoft\WindowsRuntime\ActivatableClassId\Windows.Gaming.GameBar.PresenceServer.Internal.PresenceWriter"  
call :reg_query "HKLM\SOFTWARE\%acikey%" "ActivationType" ActivationType
if "[%ActivationType%]"=="[0x0]" ( set "STATUS=OFF" ) else set "STATUS=ON!"
set "_=        " &if "%STATUS%"=="OFF" ( color 0c ) else color 0b
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
setlocal &for /l %%# in (10,1,22) do call set "ps_RegTakeOwnership=%%ps_RegTakeOwnership%%%%s%%#:'=\"%%"                          
powershell.exe -c " $regkey='%~1';$user='%~2';$recursive='%~3'; %ps_RegTakeOwnership%;"
exit/b                                                    AveYo: call :reg_takeownership "HKLM\MyKey" "NT Service\TrustedInstaller"

:reg_query %1:KeyName %2:ValueName %3:OutputVariable %4:other_options[example: "/t REG_DWORD"]
setlocal & for /f "skip=2 delims=" %%s in ('reg query "%~1" /v "%~2" /z 2^>nul') do set "rq=%%s" & call set "rv=%%rq:*)    =%%"
endlocal & set "%~3=%rv%" & exit/b                                              AveYo: call :reg_query "HKCU\MyKey" "MyValue" MyVar

:need_admin_rights
color 0c&echo. &echo  PERMISSION DENIED! Right-click %~nx0 ^& Run as administrator &timeout /t 60 &color 0f&title %COMSPEC% &exit/b
::end