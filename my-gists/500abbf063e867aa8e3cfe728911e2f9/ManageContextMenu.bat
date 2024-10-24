@echo off

set "reg_wildcard=HKEY_CLASSES_ROOT\*\shell\"
set "reg_desktop_bg=HKEY_CLASSES_ROOT\DesktopBackground\Shell\"
set "reg_dir_bg=HKEY_CLASSES_ROOT\Directory\Background\shell\"
set "reg_folder=HKEY_CLASSES_ROOT\Folder\shell\"

set "reg1=Add File to Quick Access Popup menu"
set "reg2=Add File to Quick Access Popup menu Express"
set "reg3=Show Quick Access Popup menu"
set "reg4=Show Quick Access Popup Alternative menu"
set "reg5=Add Folder to Quick Access Popup menu"
set "reg6=Add Folder to Quick Access Popup menu Express"

set "sep=========================="

echo Welcome to Quick Access Popup Context Menu Manager!
echo %sep%
echo 1) Install QAP context menu items
echo 2) Uninstall QAP context menu items
echo %sep%

choice /C 12 /M "Enter your choice:"

if errorlevel 2 goto uninstall
if errorlevel 1 goto install
goto end

:install
echo Installed QAP context menu items

set "icon=%~dp0QuickAccessPopup.exe"
set "msn=%~dp0QAPmessenger.exe"

call :regadd "%reg_wildcard%" "%reg1%" "AddFile" 0 0
call :regadd "%reg_wildcard%" "%reg2%" "AddFileXpress" 1 0

call :regadd "%reg_folder%" "%reg5%" "AddFolder" 0 0
call :regadd "%reg_folder%" "%reg6%" "AddFolderXpress" 1 0

call :regadd "%reg_desktop_bg%" "%reg3%" "ShowMenuLaunch" 0 2
call :regadd "%reg_desktop_bg%" "%reg4%" "ShowMenuAlternative" 1 2

call :regadd "%reg_dir_bg%" "%reg3%" "ShowMenuNavigate" 0 2
call :regadd "%reg_dir_bg%" "%reg4%" "ShowMenuAlternative" 1 2

call :regadd "%reg_dir_bg%" "%reg5%" "AddFolder" 0 1
call :regadd "%reg_dir_bg%" "%reg6%" "AddFolderXpress" 1 1

echo Installed QAP context menu items
goto end

:uninstall
reg delete "%reg_wildcard%%reg1%" /f
reg delete "%reg_wildcard%%reg2%" /f
reg delete "%reg_folder%%reg5%" /f
reg delete "%reg_folder%%reg6%" /f
reg delete "%reg_desktop_bg%%reg3%" /f
reg delete "%reg_desktop_bg%%reg4%" /f
reg delete "%reg_dir_bg%%reg3%" /f
reg delete "%reg_dir_bg%%reg4%" /f
reg delete "%reg_dir_bg%%reg5%" /f
reg delete "%reg_dir_bg%%reg6%" /f

echo Uninstalled QAP context menu items
goto end

:end
echo %sep%
echo Program will now exit
pause
exit /B 0

:regadd
set "fullpath=%~1%~2"
reg add "%fullpath%" /ve /d "%~2" /f
reg add "%fullpath%" /v "Icon" /d "%icon%" /f
if %4==1 reg add "%fullpath%" /v "Extended" /d "" /f

set "param=%%1"
if %5==1 set "param=%%V"
if %5==2 set "param="
reg add "%fullpath%\command" /ve /d "%msn% %3 %param%" /f

exit /B 0
