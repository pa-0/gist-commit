@set @version=3.1 /*&echo off&title Windows X Bloat Subscribe Toggle
call :check_status
echo.
echo      ---------------------------------------------------------------------
echo     :                Windows X Bloat Subscribe Toggle v3.1                :
echo     :---------------------------------------------------------------------:
echo     :  Only a prevention, won't uninstall existing items for your account :
echo     :  But new users get a clean LTSB-like menu with no 3rd party items.  :
echo     :       Usually prevents bloat being reinstalled after upgrades       :
echo     :              Run this script again to subscribe on/off              :
echo     :                                                                     :
echo     :                       Before: %STATUS%%__%                          :
echo     :                                                                     :
echo     : Press Alt+F4 to cancel                    Always run latest version :
echo      ---------------------------------------------------------------------
echo                                                         RED = unsubscribed
:: Init
if %1.==. timeout /t 10 &call wscript /e:JScript "%~f0" shiftrunas &exit &rem : no arguments, run setup elevated
if %1.==shift. shift &shift &rem : if loaded by WScript, shift args to prevent loop and restore %0

:: Main
if "%STATUS%"=="UNSUBSCRIBED" ( set "RV=0x1" &set "RVD=0x0" ) else set "RV=0x0" &set "RVD=0x1"

reg load HKU\NewUsers "C:\Users\Default\NTUSER.DAT" >nul && set "NewUsers=HKU\NewUsers" || set "NewUsers="
:: Manage Content Delivery (SubscribedContent) Bloat
set "cdm=Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
for %%u in (HKCU %NewUsers%) do (
 reg add "%%u\%cdm%" /v FeatureManagementEnabled /t REG_DWORD /d %RV% /f                          &rem Feature Management generic
 reg add "%%u\%cdm%" /v ContentDeliveryAllowed /t REG_DWORD /d %RV% /f                            &rem Content Delivery generic
 reg add "%%u\%cdm%" /v OemPreInstalledAppsEnabled /t REG_DWORD /d %RV% /f                        &rem OEM Preinstalled Apps
 reg add "%%u\%cdm%" /v PreInstalledAppsEnabled /t REG_DWORD /d %RV% /f                           &rem Preinstalled Apps
 reg add "%%u\%cdm%" /v PreInstalledAppsEverEnabled /t REG_DWORD /d %RV% /f                       &rem Preinstalled Apps
 reg add "%%u\%cdm%" /v RotatingLockScreenEnabled /t REG_DWORD /d %RV% /f                         &rem Lock Screen Ads
 reg add "%%u\%cdm%" /v RotatingLockScreenOverlayEnabled /t REG_DWORD /d %RV% /f                  &rem Lock Screen Tips
 reg add "%%u\%cdm%" /v SilentInstalledAppsEnabled /t REG_DWORD /d %RV% /f                        &rem Suggested Apps
 reg add "%%u\%cdm%" /v SoftLandingEnabled /t REG_DWORD /d %RV% /f                                &rem Tips about Windows
 reg add "%%u\%cdm%" /v SubscribedContentEnabled /t REG_DWORD /d %RV% /f                          &rem Suggested Apps generic
 reg add "%%u\%cdm%" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d %RV% /f                      &rem Settings Suggestions
 reg add "%%u\%cdm%" /v SubscribedContent-202914Enabled /t REG_DWORD /d %RV% /f                   &rem Windows Spotlight
 reg add "%%u\%cdm%" /v SubscribedContent-280810Enabled /t REG_DWORD /d %RV% /f                   &rem SyncProviders - OneDrive
 reg add "%%u\%cdm%" /v SubscribedContent-280811Enabled /t REG_DWORD /d %RV% /f                   &rem OneDrive
 reg add "%%u\%cdm%" /v SubscribedContent-280813Enabled /t REG_DWORD /d %RV% /f                   &rem Windows Ink - StokedOnIt
 reg add "%%u\%cdm%" /v SubscribedContent-280815Enabled /t REG_DWORD /d %RV% /f                   &rem Share - Facebook Instagram
 reg add "%%u\%cdm%" /v SubscribedContent-310091Enabled /t REG_DWORD /d %RV% /f                   &rem Feature management?
 reg add "%%u\%cdm%" /v SubscribedContent-310092Enabled /t REG_DWORD /d %RV% /f                   &rem Feature management?
 reg add "%%u\%cdm%" /v SubscribedContent-310093Enabled /t REG_DWORD /d %RV% /f                   &rem Windows Welcome Experience
 reg add "%%u\%cdm%" /v SubscribedContent-314559Enabled /t REG_DWORD /d %RV% /f                   &rem BingWeather
 reg add "%%u\%cdm%" /v SubscribedContent-314559Enabled /t REG_DWORD /d %RV% /f                   &rem Candy Crush
 reg add "%%u\%cdm%" /v SubscribedContent-314563Enabled /t REG_DWORD /d %RV% /f                   &rem MyPeople - Suggested Apps
 reg add "%%u\%cdm%" /v SubscribedContent-338380Enabled /t REG_DWORD /d %RV% /f                   &rem Feature management?
 reg add "%%u\%cdm%" /v SubscribedContent-338381Enabled /t REG_DWORD /d %RV% /f                   &rem Windows Maps
 reg add "%%u\%cdm%" /v SubscribedContent-338387Enabled /t REG_DWORD /d %RV% /f                   &rem Lock screen - Hotspot
 reg add "%%u\%cdm%" /v SubscribedContent-338388Enabled /t REG_DWORD /d %RV% /f                   &rem Startmenu - App Suggestions
 reg add "%%u\%cdm%" /v SubscribedContent-338389Enabled /t REG_DWORD /d %RV% /f                   &rem Cortana - Using Windows tips
 reg add "%%u\%cdm%" /v SubscribedContent-338393Enabled /t REG_DWORD /d %RV% /f                   &rem Settings - Microsoft Links
 reg add "%%u\%cdm%" /v SubscribedContent-353698Enabled /t REG_DWORD /d %RV% /f                   &rem Timeline - Suggestions
) >nul 2>nul
:: Discover other subscriptions and add them too
for %%u in (HKCU %NewUsers%) do for /f %%s in ('reg query "HKCU\%cdm%\Subscriptions"') do (
 reg add "%%u\%cdm%" /v SubscribedContent-%%~nxsEnabled /t REG_DWORD /d %RV% /f
) >nul 2>nul
:: Discover suggested apps
for %%u in (HKCU %NewUsers%) do for /f %%s in ('reg query "HKCU\%cdm%\SuggestedApps" 2^>nul ^|find "REG_D" 2^>nul') do (
 reg add "%%u\%cdm%\SuggestedApps" /v %%s /t REG_DWORD /d %RV% /f
) >nul 2>nul
:: Manage background run for ContentDelivery
set "backgracc=Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
for %%u in (HKCU %NewUsers%) do (
 reg add "%%u\%backgracc%\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy" /v Disabled /t REG_DWORD /d %RVD% /f
) >nul 2>nul
:: Manage Windows Ink suggestions
set "ink=Software\Microsoft\Windows\CurrentVersion\PenWorkspace"
for %%u in (HKCU %NewUsers%) do (
 reg add "%%u\%ink%" /v PenWorkspaceAppSuggestionsEnabled /t REG_DWORD /d %RV% /f
) >nul 2>nul
:: Manage Sync Providers (OneDrive) notifications
set "sync=Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
for %%u in (HKCU %NewUsers%) do (
 reg add "%%u\%sync%" /v ShowSyncProviderNotifications /t REG_DWORD /d %RV% /f
) >nul 2>nul
:: Manage Generic Cloud features aka bloat
set "cloud=Software\Policies\Microsoft\Windows\CloudContent"
for %%u in (HKLM) do (
 reg add "%%u\%cloud%" /v DisableWindowsConsumerFeatures /t REG_DWORD /d %RVD% /f
 reg add "%%u\%cloud%" /v DisableSoftLanding /t REG_DWORD /d %RVD% /f
) >nul 2>nul
:: Done!
reg unload HKU\NewUsers >nul
call :check_status
echo.
echo --------------------------
echo  After : %STATUS%
echo --------------------------
echo.
pause
exit

::---------------------------------------------------------------------------------------------------------------------------------
:: Utility functions
::---------------------------------------------------------------------------------------------------------------------------------
:check_status
set "bloatkey=HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
call :reg_query "%bloatkey%" "ContentDeliveryAllowed" BLOAT_SUBSCRIBE
if "[%BLOAT_SUBSCRIBE%]"=="[0x0]" ( set "STATUS=UNSUBSCRIBED" & color 0c) else set "STATUS=   DEFAULT  " & color 0b
set "__=" &exit/b

:reg_query %1:KeyName %2:ValueName %3:OutputVariable %4:other_options[example: "/reg:32"]
setlocal & for /f "skip=2 delims=" %%s in ('reg query "%~1" /v "%~2" /z %4 2^>nul') do set "rq=%%s" & call set "rv=%%rq:*)    =%%"
endlocal & set "%~3=%rv%" & exit/b                              ||:i AveYo - Usage:" call :reg_query "HKCU\MyKey" "MyValue" MyVar "

:Ask_to_reload_with_admin_rights [required] */
function ShiftRunAs(f0){WSH.CreateObject('Shell.Application').ShellExecute('cmd','/c call "'+f0+'" shift "'+f0+'"','','runas',1);}
if (WSH.Arguments.length>=1 && WSH.Arguments(0)=="shiftrunas") ShiftRunAs(WSH.ScriptFullName);
//