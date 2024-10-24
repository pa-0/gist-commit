goto="init" /* %~nx0
::----------------------------------------------------------------------------------------------------------------------------------
:about
::----------------------------------------------------------------------------------------------------------------------------------
title Windows X Update Policy
call :check_status
echo.
echo      ---------------------------------------------------------------------
echo     :                 Windows X Update Policy Toggle v2.0                 :
echo     :---------------------------------------------------------------------:
echo     :   Pro: Set to notify before download and prevent driver installs    :
echo     :             Just run this script again to toggle on/off             :
echo     :                                                                     :
echo     :                          Currently: %STATUS%%_%                     :
echo     :                                                                     :
echo     : Press Alt+F4 to cancel                    Always run latest version :
echo      ---------------------------------------------------------------------
echo.
exit/b
::----------------------------------------------------------------------------------------------------------------------------------
:main [ Batch main function ]
::----------------------------------------------------------------------------------------------------------------------------------
call :about &timeout /t 10 &echo.
if "%STATUS%"=="CUSTOM!" ( set "OP=delete" & set "NOP=/f >nul &rem" ) else set "OP=add" & set "NOP="

net stop wuauserv >nul 2>nul

:: Get current user sid with vmic
for /f "usebackq delims= " %%s in (`wmic useraccount where "name='%username%'" get sid ^| find "S-"`) do set "sid=%%s"

:: Settings Accounts Sign-in options: use my sign-in info to automatically finish setting up my device after an update or restart
set "key=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\UserARSO\%sid%"
reg %OP% "%key%" /v "OptOut" %NOP% /t REG_DWORD /d 0x1 /f >nul
if "%STATUS%"=="DEFAULT" reg query "%key%" /v "OptOut" 2>nul

:: Disable Windows Update Delivery Optimization
set "key=HKLM\Software\Policies\Microsoft\Windows\DeliveryOptimization"
echo reg %OP% "%key%" /v "DODownloadMode" %NOP% /t REG_DWORD /d 0x0 /f >nul
if "%STATUS%"=="DEFAULT" reg query "%key%" /v "DODownloadMode" 2>nul

:: Choose how updates are delivered 0=p2p update from MS only, 1=p2p update from PCs on LAN, 3=p2p update from PCs on the internet
set "key=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config"
reg %OP% "%key%" /v "DownloadMode" %NOP% /t REG_DWORD /d 0x0 /f >nul
reg %OP% "%key%" /v "DODownloadMode" %NOP% /t REG_DWORD /d 0x0 /f >nul
if "%STATUS%"=="DEFAULT" reg query "%key%" 2>nul

:: UX and old style update settings - check but don't download, exclude drivers, no metered
if "%STATUS%"=="DEFAULT" call :TakeKeyOwnership "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX" -y
set "key1=HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
set "key2=HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
set "key3=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update"
set keys="%key1%" "%key2%" "%key3%"
:: Enable update management
for %%k in (%keys%) do reg %OP% %%k /v "NoAutoUpdate" %NOP% /t REG_DWORD /d 0x0 /f >nul
:: Enable updates 2=notify before download, 3=download and notify install, 4=download and schedule, 5=fully automatic
for %%k in (%keys%) do reg %OP% %%k /v "AUOptions" %NOP% /t REG_DWORD /d 0x2 /f >nul
:: Enable UX settings
for %%k in (%keys%) do reg %OP% %%k /v "UxOption" %NOP% /t REG_DWORD /d 0x1 /f >nul
for %%k in (%keys%) do reg %OP% %%k /v "IsConvergedUpdateStackEnabled" %NOP% /t REG_DWORD /d 0x1 /f >nul
:: Active Hours enabled 08 - 23
for %%k in (%keys%) do reg %OP% %%k /v "SetActiveHours" %NOP% /t REG_DWORD /d 0x0 /f >nul
for %%k in (%keys%) do reg %OP% %%k /v "ActiveHoursEnd" %NOP% /t REG_DWORD /d 0x17 /f >nul 2>nul
for %%k in (%keys%) do reg %OP% %%k /v "ActiveHoursStart" %NOP% /t REG_DWORD /d 0x8 /f >nul 2>nul
:: Disable Windows Update Power Management from automatically wake up the system to install scheduled updates 
for %%k in (%keys%) do reg %OP% %%k /v "AUPowerManagement" %NOP% /t REG_DWORD /d 0x0 /f >nul 2>nul
:: Do not download over metered connection
for %%k in (%keys%) do reg %OP% %%k /v "AllowAutoWindowsUpdateDownloadOverMeteredNetwork" %NOP% /t REG_DWORD /d 0x0 /f >nul
:: Include recommended updates
for %%k in (%keys%) do reg %OP% %%k /v "IncludeRecommendedUpdates" %NOP% /t REG_DWORD /d 0x1 /f >nul
:: Do not autoinstall minor updates
for %%k in (%keys%) do reg %OP% %%k /v "AutoInstallMinorUpdates" %NOP% /t REG_DWORD /d 0x1 /f >nul
:: Exclude drivers from updates
for %%k in (%keys%) do reg %OP% %%k /v "ExcludeWUDriversInQualityUpdate" %NOP% /t REG_DWORD /d 0x1 /f >nul
:: Hide Creators Update build is non the way add
for %%k in (%keys%) do reg %OP% %%k /v "HideMCTLink" %NOP% /t REG_DWORD /d 0x1 /f >nul
:: Defer updates
for %%k in (%keys%) do reg %OP% %%k /v "DeferFeatureUpdatesPeriodInDays" %NOP% /t REG_DWORD /d 0x0 /f >nul
for %%k in (%keys%) do reg %OP% %%k /v "DeferQualityUpdatesPeriodInDays" %NOP% /t REG_DWORD /d 0x0 /f >nul
for %%k in (%keys%) do reg %OP% %%k /v "DeferUpgrade" %NOP% /t REG_DWORD /d 0x0 /f >nul
:: Check frequency
for %%k in (%keys%) do reg %OP% %%k /v "DetectionFrequency" %NOP% /t REG_DWORD /d 0xa /f >nul
for %%k in (%keys%) do reg %OP% %%k /v "DetectionFrequencyEnabled" %NOP% /t REG_DWORD /d 0x1 /f >nul
:: Schedule install every day 0=every day, 1=Sunday, 2=Monday, 3=Tuesday, 4=Wednesday, 5=Thursday, 6=Friday, 7=Saturday
for %%k in (%keys%) do reg %OP% %%k /v "ScheduledInstallDay" %NOP% /t REG_DWORD /d 0x0 /f >nul
:: Schedule install time 23pm
for %%k in (%keys%) do reg %OP% %%k /v "ScheduledInstallTime" %NOP% /t REG_DWORD /d 0x17 /f >nul
:: Remove shutdown with update options
for %%k in (%keys%) do reg %OP% %%k /v "NoAUAsDefaultShutdownOption" %NOP% /t REG_DWORD /d 0x1 /f >nul
for %%k in (%keys%) do reg %OP% %%k /v "NoAUShutdownOption" %NOP% /t REG_DWORD /d 0x0 /f >nul
:: Don't autoreboot
for %%k in (%keys%) do reg %OP% %%k /v "NoAutoRebootWithLoggedOnUsers" %NOP% /t REG_DWORD /d 0x1 /f >nul
:: Longer reboot notification
for %%k in (%keys%) do reg %OP% %%k /v "RebootRelaunchTimeout" %NOP% /t REG_DWORD /d 0x5a0 /f >nul
for %%k in (%keys%) do reg %OP% %%k /v "RebootRelaunchTimeoutEnabled" %NOP% /t REG_DWORD /d 0x1 /f >nul
:: Reboot warning
for %%k in (%keys%) do reg %OP% %%k /v "RebootWarningTimeout" %NOP% /t REG_DWORD /d 0x5a0 /f >nul
for %%k in (%keys%) do reg %OP% %%k /v "RebootWarningTimeoutEnabled" %NOP% /t REG_DWORD /d 0x1 /f >nul  
:: Longer reschedule wait
for %%k in (%keys%) do reg %OP% %%k /v "RescheduleWaitTime" %NOP% /t REG_DWORD /d 0x14 /f >nul
for %%k in (%keys%) do reg %OP% %%k /v "RescheduleWaitTimeEnabled" %NOP% /t REG_DWORD /d 0x1 /f >nul
:: More restart notifications
for %%k in (%keys%) do reg %OP% %%k /v "RestartNotificationsAllowed" %NOP% /t REG_DWORD /d 0x1 /f >nul
if "%STATUS%"=="DEFAULT" reg query "%key1%" 2>nul

:: Do you want Windows to download driver software 0=never ,1=always, 2=install if not found on my computer
set "key=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching"
reg %OP% "%key%" /v "SearchOrderConfig" %NOP% /t REG_DWORD /d 0x2 /f >nul
if "%STATUS%"=="DEFAULT" reg query "%key%" /v "SearchOrderConfig" 2>nul

:: Disable enhanced manufacturer icons
set "key=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata"
reg %OP% "%key%" /v "PreventDeviceMetadataFromNetwork" %NOP% /t REG_DWORD /d 0x0 /f >nul
if "%STATUS%"=="DEFAULT" reg query "%key%" /v "PreventDeviceMetadataFromNetwork" 2>nul

:: Enable 'Give me updates for other Microsoft products when I update Windows'
set "key=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\7971f918-a847-4430-9279-4a52d1efe18d"
reg %OP% "%key%" /v "RegisteredWithAU" %NOP% /t REG_DWORD /d 0x1 /f >nul
if "%STATUS%"=="DEFAULT" reg query "%key%" /v "RegisteredWithAU" 2>nul

:: Disable Automatic Update of Speech Data
if "%STATUS%"=="DEFAULT" call :TakeKeyOwnership "HKLM\SOFTWARE\Microsoft\Speech_OneCore" -y
set "key=HKLM\SOFTWARE\Microsoft\Speech_OneCore\Preferences"
reg %OP% "%key%\Preferences" /v "ModelDownloadAllowed" %NOP% /t REG_DWORD /d 0x0 /f >nul
if "%STATUS%"=="DEFAULT" reg query "%key%\Preferences" /v "ModelDownloadAllowed" 2>nul

:: Smart multi-homed name resolution - prevent dns timeouts and leaks when using VPN 
set "key1=HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient"
set "key2=HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters"
reg %OP% "%key1%" /v "DisableSmartNameResolution" %NOP% /t REG_DWORD /d 0x1 /f >nul 
reg %OP% "%key2%" /v "DisableParallelAandAAAA" %NOP% /t REG_DWORD /d 0x1 /f >nul
if "%STATUS%"=="DEFAULT" reg query "%key1%" /v "DisableSmartNameResolution" 2>nul
if "%STATUS%"=="DEFAULT" reg query "%key2%" /v "DisableParallelAandAAAA" 2>nul

net start wuauserv >nul 2>nul

echo.
call :check_status

:: Done!
echo ---------------------------------------------------------------------
if "%STATUS%"=="CUSTOM!" ( color 0c &echo  Update Policy now: CUSTOM! ) else color 0b &echo  Update Policy now: DEFAULT 
echo ---------------------------------------------------------------------
echo.
pause
exit

::----------------------------------------------------------------------------------------------------------------------------------
:: Utility functions
::----------------------------------------------------------------------------------------------------------------------------------
:check_status
set "policykey=HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"   
call :reg_query "%policykey%" "AUOptions" UPDATE_POLICY
if "[%UPDATE_POLICY%]"=="[0x2]" ( set "STATUS=CUSTOM!" ) else set "STATUS=DEFAULT"
set "_=    " &if "%STATUS%"=="CUSTOM!" ( color 0c ) else color 0b
exit/b

:TakeKeyOwnership %1:regpath[ex:"HKCU\Console"] %2:_recurse[optional, default:"-n", "-y"] %3:_sid[optional, default:"S-1-5-32-545"]
rem $src=https://stackoverflow.com/questions/12044432/how-do-i-take-ownership-of-a-registry-key-via-powershell snippet-ized by AveYo
set "s10=function TakeKeyOwnership { param($regp, $all, $owner); $recurse=($all -eq '-y'); $RP=($regp -split '\\',2); $key=$RP[1];"
set "s11= switch -regex ($RP[0]) { 'HKLM|HKEY_LOCAL_MACHINE' {$HK='LocalMachine'};'HKCC|HKEY_CURRENT_CONFIG' {$HK='CurrentConfig'};"
set "s12=  'HKCR|HKEY_CLASSES_ROOT' {$HK='ClassesRoot'};'HKU|HKEY_USERS' {$HK='Users'};'HKCU|HKEY_CURRENT_USER' {$HK='CurrentUser'}"
set "s13= }; $rootKey=$HK; if ($owner -eq '') {$owner='S-1-5-32-545'}; [System.Security.Principal.SecurityIdentifier]$sid=$owner;"
set "s14= $import='[DllImport("ntdll.dll")] public static extern int RtlAdjustPrivilege(ulong a, bool b, bool c, ref bool d);';"
set "s15= $ntdll=Add-Type -Member $import -Name NtDll -PassThru; $privileges=@{ SeTakeOwnership=9; SeBackup=17; SeRestore=18 };"
set "s16= foreach ($i in $privileges.Values) { $null=$ntdll::RtlAdjustPrivilege($i, 1, 0, [ref]0) };"
set "s17= function Take-KeyPermissions { param($rootKey, $key, $sid, $recurse, $recurseLevel=0);"
set "s18=  $regKey=[Microsoft.Win32.Registry]::$rootKey.OpenSubKey($key, 'ReadWriteSubTree', 'TakeOwnership');"
set "s19=  $acl=New-Object System.Security.AccessControl.RegistrySecurity; $acl.SetOwner($sid); $regKey.SetAccessControl($acl);"
set "s20=  $acl.SetAccessRuleProtection($false, $false); $regKey.SetAccessControl($acl);"
set "s21=  if ($recurseLevel -eq 0) { $regKey=$regKey.OpenSubKey('', 'ReadWriteSubTree', 'ChangePermissions');"
set "s22=  $rule=New-Object System.Security.AccessControl.RegistryAccessRule($sid,'FullControl','ContainerInherit','None','Allow');"
set "s23=  $acl.ResetAccessRule($rule); $regKey.SetAccessControl($acl) };"
set "s24=  if ($recurse) { foreach($subKey in $regKey.OpenSubKey('').GetSubKeyNames()) {"
set "s25=    Take-KeyPermissions $rootKey ($key+'\'+$subKey) $sid $recurse ($recurseLevel+1) } };" 
set "s26= }; $ErrorActionPreference='Continue'; Take-KeyPermissions $rootKey $key $sid $recurse }" 
for /l %%# in (10,1,26) do call set "ps_TakeKeyOwnership=%%ps_TakeKeyOwnership%%%%s%%#:"=\"%%" 
powershell.exe -c "%ps_TakeKeyOwnership%; try { TakeKeyOwnership '%~1' '%~2' '%~3' } catch {}"
exit/b

:reg_query %1:KeyName %2:ValueName %3:OutputVariable %4:other_options[example: "/reg:32"]
setlocal & for /f "skip=2 delims=" %%s in ('reg query "%~1" /v "%~2" /z %4 2^>nul') do set "rq=%%s" & call set "rv=%%rq:*)    =%%"
endlocal & call set "%~3=%rv%" & exit/b                          ||:i AveYo - Usage:" call :reg_query "HKCU\MyKey" "MyValue" MyVar "

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
