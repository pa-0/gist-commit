@echo off

:: Script para relizar el 'offline servicing' de 'install.wim'
:: v1.3 13/09/2018 by inLabFIB
:: Basado en el tweet de Ari Saastamoinen: https://twitter.com/AriSaastamoinen/status/1010870453148311552

:: Referencias:
:: https://execmgr.net/2018/06/07/windows-10-image-maintenance/
:: https://miketerrill.net/2018/06/23/optimizing-win10-os-upgrade-wim-sizes/
:: https://www.osdeploy.com/osmedia/quick-start.html

setlocal

if "%1"=="" goto instrucciones
if "%2"=="" goto instrucciones

pushd %~pd0

:: Variables globales

set dism="c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\DISM\dism.exe"
set imagex="c:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\DISM\imagex.exe"
set win10dir=%1
set workdir=%2
set win10iso=%win10dir%\0-ISO\SW_DVD5_Win_Pro_Ent_Edu_N_10_1803_64BIT_Spanish_-2_MLF_X21-79657.iso
set win10dvd=%win10dir%\1-DVD
set ssudir=%win10dir%\2-SSU
set cudir=%win10dir%\3-CU
set flashdir=%win10dir%\4-Flash
set lpdir=%win10dir%\5-LP
set foddir=%win10dir%\6-FOD
set logsdir=%win10dir%\7-Logs
set wimdir=%win10dir%\8-WIMs

:: Variables funcionamiento para:
:: - Agregar Language Packs
:: - Quitar APPX según lista Keep/Remove
:: - Eliminar feature SMBv1
:: - Agregar feature .NET 3.5
:: - Agregar actualizaciones (SSU/CU)
:: - Deshabilitar OneDrive
:: - Deshabilitar Cortana
:: - Rebase de la imagen WIM (va ligado a si se ha hecho o no .NET 3.5)

set do_add_lp=1
set do_remove_appx=1
set do_remove_feature_smbv1=1
set do_add_feature_dotnet35=0
set do_add_updates=1
set do_disable_onedrive=1
set do_disable_cortana=1
set do_disable_consumer=1
set do_rebase=0

:: Comprobaciones iniciales

if not exist %win10dir% (
	echo Can't find %win10dir% !
	goto final
)

if not exist %workdir% (
	echo Can't find %workdir% !
	goto final
)
if not exist %dism% (
	echo You need to install Windows 10 ADK Deployment Tools !
	goto final
)

if not exist %imagex% (
	echo You need to install Windows 10 ADK Deployment Tools !
	goto final
)

if not exist "%win10iso%" (
	echo Windows 10 ISO file not found !
	goto final
)

if not exist "%win10dvd%" (
	echo Creando directorio %win10dvd% ...
	mkdir "%win10dvd%"
)

if not exist "%logsdir%" (
	echo Creando directorio %logsdir% ...
	mkdir "%logsdir%"
)

if not exist "%wimdir%" (
	echo Creando directorio %wimdir% ...
	mkdir "%wimdir%"
)

:: ################################################################################
:: PRINT INFO
:: ################################################################################

echo [42m[[[ CONFIGURATION ]]][0m
echo.
echo - Win10 = %win10dir%
echo - Temp  = %workdir%
echo - ISO   = %win10iso%
echo - DVD   = %win10dvd%
echo - SSU   = %ssudir%
echo - CU    = %cudir%
echo - Flash = %flashdir%
echo - LP    = %lpdir%
echo - FOD   = %foddir%
echo - Logs  = %logsdir%
echo - WIMs  = %wimdir%

:: ################################################################################
:: MOUNT ISO FILE AND MOUNT 'install.wim' FROM INTO 'mount\windows' DIRECTORY
:: ################################################################################

:: Clean log files

del "%logsdir%\*.log" >nul 2>&1
del "%logsdir%\*.log.bak" >nul 2>&1

:: Mount Windows 10 ISO

echo.
echo [45m[[[ MOUNTING ]]][0m

powershell.exe -ep bypass "Mount-DiskImage ""%win10iso%"""
FOR /F "tokens=*" %%I IN ('powershell.exe -ep bypass "(Get-DiskImage """%win10iso%""" | Get-Volume).DriveLetter"') DO set isodrive=%%I:
set wim=%isodrive%\sources\install.wim

:: Check for install.wim

if not exist %wim% (
	echo Something went wrong when mounting %win10iso%, install.wim not found !
	goto dismount
)

:: Getting WIM image information

%dism% /get-imageinfo /imagefile:%wim%

:: Export index 3 (Enterprise) to temporary WIM

%dism% /export-image /sourceimagefile:%wim% /sourceindex:3 /destinationimagefile:%wimdir%\install_tmp.wim

:: Mount temporary WIM in temporary folders

if not exist %workdir%\mount\windows mkdir %workdir%\mount\windows
%dism% /mount-image /imagefile:%wimdir%\install_tmp.wim /index:1 /mountdir:%workdir%\mount\windows

:: ################################################################################
:: LANGUAGE PACKS
:: ################################################################################

if not defined do_add_lp goto :skip_lp
if not "%do_add_lp%"=="1" goto :skip_lp

echo.
echo [45m[[[ LANGUAGE PACKS ]]][0m

:: Adding LP (en-us, fr-fr) and LIP (ca-es)
:: Adding FoD (Basic, OCR, etc.) for these languages
:: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/add-language-packs-to-windows
:: https://msdn.microsoft.com/es-es/library/windows/hardware/dn898429(v=vs.85).aspx (dependencias)

%dism% /add-package /image:%workdir%\mount\windows /packagepath:"%lpdir%\Microsoft-Windows-Client-Language-Pack_x64_en-us.cab" /logpath:%logsdir%\offline_languages_en.log
%dism% /add-package /image:%workdir%\mount\windows /packagepath:"%foddir%\Microsoft-Windows-LanguageFeatures-Basic-en-us-Package~31bf3856ad364e35~amd64~~.cab" /logpath:%logsdir%\offline_languages_en.log
REM %dism% /add-package /image:%workdir%\mount\windows /packagepath:"%foddir%\Microsoft-Windows-LanguageFeatures-OCR-en-us-Package~31bf3856ad364e35~amd64~~.cab" /logpath:%logsdir%\offline_languages_en.log
REM %dism% /add-package /image:%workdir%\mount\windows /packagepath:"%foddir%\Microsoft-Windows-LanguageFeatures-Handwriting-en-us-Package~31bf3856ad364e35~amd64~~.cab" /logpath:%logsdir%\offline_languages_en.log
REM %dism% /add-package /image:%workdir%\mount\windows /packagepath:"%foddir%\Microsoft-Windows-LanguageFeatures-TextToSpeech-en-us-Package~31bf3856ad364e35~amd64~~.cab" /logpath:%logsdir%\offline_languages_en.log
REM %dism% /add-package /image:%workdir%\mount\windows /packagepath:"%foddir%\Microsoft-Windows-LanguageFeatures-Speech-en-us-Package~31bf3856ad364e35~amd64~~.cab" /logpath:%logsdir%\offline_languages_en.log

%dism% /add-package /image:%workdir%\mount\windows /packagepath:"%lpdir%\Microsoft-Windows-Client-Language-Pack_x64_fr-fr.cab" /logpath:%logsdir%\offline_languages_fr.log
%dism% /add-package /image:%workdir%\mount\windows /packagepath:"%foddir%\Microsoft-Windows-LanguageFeatures-Basic-fr-fr-Package~31bf3856ad364e35~amd64~~.cab" /logpath:%logsdir%\offline_languages_fr.log
REM %dism% /add-package /image:%workdir%\mount\windows /packagepath:"%foddir%\Microsoft-Windows-LanguageFeatures-OCR-fr-fr-Package~31bf3856ad364e35~amd64~~.cab" /logpath:%logsdir%\offline_languages_fr.log
REM %dism% /add-package /image:%workdir%\mount\windows /packagepath:"%foddir%\Microsoft-Windows-LanguageFeatures-Handwriting-fr-fr-Package~31bf3856ad364e35~amd64~~.cab" /logpath:%logsdir%\offline_languages_fr.log
REM %dism% /add-package /image:%workdir%\mount\windows /packagepath:"%foddir%\Microsoft-Windows-LanguageFeatures-TextToSpeech-fr-fr-Package~31bf3856ad364e35~amd64~~.cab" /logpath:%logsdir%\offline_languages_fr.log
REM %dism% /add-package /image:%workdir%\mount\windows /packagepath:"%foddir%\Microsoft-Windows-LanguageFeatures-Speech-fr-fr-Package~31bf3856ad364e35~amd64~~.cab" /logpath:%logsdir%\offline_languages_fr.log

%dism% /add-package /image:%workdir%\mount\windows /packagepath:"%lpdir%\Microsoft-Windows-Client-Language-Interface-Pack_x64_ca-es.cab" /logpath:%logsdir%\offline_languages_ca.log
%dism% /add-package /image:%workdir%\mount\windows /packagepath:"%foddir%\Microsoft-Windows-LanguageFeatures-Basic-ca-es-Package~31bf3856ad364e35~amd64~~.cab" /logpath:%logsdir%\offline_languages_ca.log
REM %dism% /add-package /image:%workdir%\mount\windows /packagepath:"%foddir%\Microsoft-Windows-LanguageFeatures-Handwriting-ca-es-Package~31bf3856ad364e35~amd64~~.cab" /logpath:%logsdir%\offline_languages_ca.log
REM %dism% /add-package /image:%workdir%\mount\windows /packagepath:"%foddir%\Microsoft-Windows-LanguageFeatures-TextToSpeech-ca-es-Package~31bf3856ad364e35~amd64~~.cab" /logpath:%logsdir%\offline_languages_ca.log

:: Getting capabilities

echo.
echo [45m[[[ CAPABILITIES ]]][0m

%dism% /image:%workdir%\mount\windows /get-capabilities

:skip_lp

:: ################################################################################
:: REMOVAL OF PROVISIONED APPX PACKAGES
:: ################################################################################

if not defined do_remove_appx goto :skip_appx
if not "%do_remove_appx%"=="1" goto :skip_appx

echo.
echo [45m[[[ REMOVAL APPX ]]][0m

:: Removing Appx Packages using blacklist file using this format: [Keep|Remove] [PackageName]
:: For example:
:: Keep    Microsoft.MicrosoftStickyNotes_2.0.13.0_neutral_~_8wekyb3d8bbwe
:: Remove  Microsoft.MSPaint_3.1803.5027.0_neutral_~_8wekyb3d8bbwe
:: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-app-package--appx-or-appxbundle--servicing-command-line-options

:: %dism% /image:%workdir%\mount\windows /Get-ProvisionedAppxPackages > output.txt
:: type output.txt | find /i "packagename" > Packages1803.txt
:: Edit Packages1803.txt to Keep or Remove ;-)

if exist %win10dir%\Packages1803.txt (
	for /f "tokens=1,2" %%p in ('type %win10dir%\Packages1803.txt') do (
		if /i "%%p"=="Remove" (
			%dism% /image:%workdir%\mount\windows /remove-provisionedappxpackage /packagename:%%q /logpath:%logsdir%\offline_appxpackages.log
		)
	)
)

:skip_appx

:: ################################################################################
:: DISABLE FEATURE SMBv1
:: ################################################################################

if not defined do_remove_feature_smbv1 goto :skip_feature_smbv1
if not "%do_remove_feature_smbv1%"=="1" goto :skip_feature_smbv1

echo.
echo [45m[[[ DISABLE SMBv1 ]]][0m

:: Disabling SMBv1 (not necessary in 1803)

%dism% /image:%workdir%\mount\windows /disable-feature /featurename:smb1protocol /logpath:%logsdir%\offline_features.log

:skip_feature_smbv1

:: ################################################################################
:: ENABLE FEATURE .NET3
:: ################################################################################

if not defined do_add_feature_dotnet35 goto :skip_feature_dotnet3
if not "%do_add_feature_dotnet35%"=="1" goto :skip_feature_dotnet3

echo.
echo [45m[[[ ENABLE .NET3 ]]][0m

:: Adding .NET3

if exist %isodrive%\sources\sxs (
	%dism% /image:%workdir%\mount\windows /enable-feature /featurename:netfx3 /all /limitaccess /source:%isodrive%\sources\sxs /logpath:%logsdir%\offline_features.log
)

:skip_feature_dotnet3

:: ################################################################################
:: COPY DVD
:: ################################################################################

if not exist %win10dvd% mkdir %win10dvd%
robocopy %isodrive%\ %win10dvd% /mir

:: ################################################################################
:: LANGUAGE SETTINGS
:: ################################################################################

if not defined do_add_lp goto :skip_lp_settings
if not "%do_add_lp%"=="1" goto :skip_lp_settings

echo.
echo [45m[[[ LANGUAGE SETTINGS ]]][0m

:: Default language (not used because 'install.wim' is es-es)
:: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-languages-and-international-servicing-command-line-options
:: Language/Region 	Primary input profile (language and keyboard pair)
:: Catalan - Catalan 	ca-ES: Spanish (0403:0000040a)
:: %dism% /image:%workdir%\mount\windows /set-skuintldefaults:es-es /logpath:%logsdir%\offline_languages.log

%dism% /image:%workdir%\mount\windows /set-allintl:es-es /logpath:%logsdir%\offline_languages.log

:: Get information about international configuration and languages

%dism% /get-intl /image:%workdir%\mount\windows

:: Generating 'lang.ini' used for 'In-Place upgrades'

attrib -r %win10dvd%\sources\lang.ini
%dism% /gen-langini /image:%workdir%\mount\windows /distribution:%win10dvd%

:skip_lp_settings

:: ################################################################################
:: INSTALL SSU + CU + FLASH
:: ################################################################################

if not defined do_add_updates goto :skip_updates
if not "%do_add_updates%"=="1" goto :skip_updates

echo.
echo [45m[[[ UPDATES ]]][0m

:: Adding latest SSU (Servicing Stack Update)
:: Catalog -> 2018-06 windows 10 1803 x64 (https://www.catalog.update.microsoft.com)

for %%i in ("%ssudir%\*.msu") do %dism% /add-package /image:%workdir%\mount\windows /packagepath:"%%i" /logpath:%logsdir%\offline_updates_ssu.log

:: Adding latest CU (Cumulative Update) and Flash
:: Catalog -> 2018-06 windows 10 1803 x64 (https://www.catalog.update.microsoft.com)

for %%i in ("%cudir%\*.msu") do %dism% /add-package /image:%workdir%\mount\windows /packagepath:"%%i" /logpath:%logsdir%\offline_updates_cu.log
for %%i in ("%flashdir%\*.msu") do %dism% /add-package /image:%workdir%\mount\windows /packagepath:"%%i" /logpath:%logsdir%\offline_updates_flash.log

:skip_updates

:: ################################################################################
:: DISABLE ONEDRIVE SETUP
:: ################################################################################

if not defined do_disable_onedrive goto :skip_onedrive
if not "%do_disable_onedrive%"=="1" goto :skip_onedrive

echo.
echo [45m[[[ ONEDRIVE]]][0m

reg load hklm\wim %workdir%\mount\windows\Users\Default\NTUSER.DAT
reg delete "hklm\wim\software\microsoft\windows\currentversion\run" /v "OneDriveSetup" /f
reg unload hklm\wim

reg load hklm\wim %workdir%\mount\windows\Windows\System32\config\SOFTWARE
reg add "hklm\wim\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v System.IsPinnedToNameSpaceTree /t REG_DWORD /d 0 /f
reg unload hklm\wim

:skip_onedrive

:: ################################################################################
:: DISABLE CORTANA
:: ################################################################################

if not defined do_disable_cortana goto :skip_cortana
if not "%do_disable_cortana%"=="1" goto :skip_cortana

echo.
echo [45m[[[ CORTANA ]]][0m

reg load hklm\wim %workdir%\mount\windows\Windows\System32\config\SOFTWARE
reg add "hklm\wim\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f
reg unload hklm\wim

:skip_cortana

:: ################################################################################
:: DISABLE CONSUMER APPS
:: ################################################################################

if not defined do_disable_consumer goto :skip_consumer
if not "%do_disable_consumer%"=="1" goto :skip_consumer

echo.
echo [45m[[[ CONSUMER ]]][0m

reg load hklm\wim %workdir%\mount\windows\Windows\System32\config\SOFTWARE
reg add "hklm\wim\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f
reg add "hklm\wim\Policies\Microsoft\WindowsStore" /v AutoDownload /t REG_DWORD /d 2 /f
reg add "hklm\wim\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" /v AutoDownload /t REG_DWORD /d 2 /f
reg unload hklm\wim

:skip_consumer

:: ################################################################################
:: WINRE SERVICING
:: ################################################################################

if not defined do_add_updates goto :skip_winre
if not "%do_add_updates%"=="1" goto :skip_winre

echo.
echo [45m[[[ WINRE SERVICING ]]][0m

:: Servicing WinRE
:: https://github.com/DeploymentResearch/DRFiles/blob/master/Scripts/Create-W10RefImageViaDISM.ps1

if not exist %workdir%\mount\winre  mkdir %workdir%\mount\winre
%dism% /mount-image /imagefile:%workdir%\mount\windows\windows\system32\recovery\winre.wim /index:1 /mountdir:%workdir%\mount\winre
for %%i in ("%ssudir%\*.msu") do %dism% /add-package /image:%workdir%\mount\winre /packagepath:"%%i" /logpath:%logsdir%\offline_updates_winre_ssu.log
for %%i in ("%cudir%\*.msu") do %dism% /add-package /image:%workdir%\mount\winre /packagepath:"%%i" /logpath:%logsdir%\offline_updates_winre_cu.log
%dism% /unmount-image /mountdir:%workdir%\mount\winre /commit /logpath:%logsdir%\offline_commit_winre.log

:skip_winre

:: ################################################################################
:: RESETBASE
:: ################################################################################

if not defined do_rebase goto :skip_rebase
if not "%do_rebase%"=="1" goto :skip_rebase

echo.
echo [45m[[[ RESET BASE ]]][0m

:: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/shrink-your-image-size

%dism% /image:%workdir%\mount\windows /cleanup-image /startcomponentcleanup /resetbase /logpath:%logsdir%\offline_cleaning.log

:skip_rebase

:: ################################################################################
:: DISMOUNT AND COMMIT
:: ################################################################################

echo.
echo [45m[[[ COMMIT ]]][0m

:: Dismount temporary folders and apply changes to temporary WIM (/discard si no se quieren aplicar)

%dism% /unmount-image /mountdir:%workdir%\mount\windows /commit /logpath:%logsdir%\offline_commit.log

:: Deleting temporary folders

rmdir %workdir%\mount\winre
rmdir %workdir%\mount\windows

:: ################################################################################
:: ADDING INFO FILE
:: ################################################################################

echo.
echo [45m[[[ DESCRIPTION ]]][0m

%imagex% /info %wimdir%\install_tmp.wim 1 "Windows 10 Enterprise 1803 x64" "Win10 Ent 1803 x64 con LPs en-us, fr-fr, ca-es. Creada el %date:~0,2%-%date:~3,2%-%date:~6,4%"

:: ################################################################################
:: EXPORTING FINAL WIM IMAGE
:: ################################################################################

echo.
echo [45m[[[ FINAL EXPORT ]]][0m

del "%wimdir%\install_lp.wim" >nul 2>&1
%dism% /export-image /sourceimagefile:%wimdir%\install_tmp.wim /sourceindex:1 /destinationimagefile:%wimdir%\install_lp.wim /logpath:%logsdir%\offline_export.log
del "%wimdir%\install_tmp.wim" >nul 2>&1

:: ################################################################################
:: BOOT SERVICING
:: ################################################################################

if not defined do_add_updates goto :skip_boot
if not "%do_add_updates%"=="1" goto :skip_boot

echo.
echo [45m[[[ BOOT SERVICING ]]][0m

if not exist %workdir%\mount\boot mkdir %workdir%\mount\boot
xcopy /y %isodrive%\sources\boot.wim %wimdir%
attrib -r %wimdir%\boot.wim
%dism% /mount-image /imagefile:%wimdir%\boot.wim /index:2 /mountdir:%workdir%\mount\boot
for %%i in ("%ssudir%\*.msu") do %dism% /add-package /image:%workdir%\mount\boot /packagepath:"%%i" /logpath:%logsdir%\offline_updates_boot_ssu.log
for %%i in ("%cudir%\*.msu") do %dism% /add-package /image:%workdir%\mount\boot /packagepath:"%%i" /logpath:%logsdir%\offline_updates_boot_cu.log
%dism% /unmount-image /mountdir:%workdir%\mount\boot /commit /logpath:%logsdir%\offline_commit_boot.log

rmdir %workdir%\mount\boot

:skip_boot

rmdir %workdir%\mount

:: ################################################################################
:: DISMOUNT ISO FILE
:: ################################################################################

:dismount

powershell.exe -ep bypass "Dismount-DiskImage ""%win10iso%"""

:: ################################################################################
:: UPDATE DVD
:: ################################################################################

if exist %win10dvd%\sources (
	echo.
	echo [45m[[[ DVD UPDATE ]]][0m

	if exist %wimdir%\install_lp.wim (
		attrib -r %win10dvd%\sources\install.wim
		copy /y %wimdir%\install_lp.wim %win10dvd%\sources\install.wim
	)
	if exist %wimdir%\boot.wim (
		attrib -r %win10dvd%\sources\boot.wim
		copy /y %wimdir%\boot.wim %win10dvd%\sources\boot.wim
	)
	attrib +r %win10dvd%\sources\boot.wim
	attrib +r %win10dvd%\sources\install.wim
)

goto final

:: ################################################################################
:: INSTRUCCIONES
:: ################################################################################

:instrucciones

echo %~nx0 {path_to_win10_folder} {path_to_working_folder}
echo.
echo Ej: %~nx0 G:\CAMPUS\ISOs\Win10\1803 D:\TEMP\WIMLatest1803
echo.

:final

popd

endlocal
