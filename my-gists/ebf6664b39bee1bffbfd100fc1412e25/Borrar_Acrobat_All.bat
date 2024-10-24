@echo off

echo Matando procesos...
taskkill.exe /f /im "AcroRd32.exe" 2>nul
taskkill.exe /f /im "Acrobat.exe" 2>nul
taskkill.exe /f /im "acrodist.exe" 2>nul

echo Desinstalando programas...
FOR /F "tokens=1 delims=:" %%i IN ('UninstallW.exe /a  ^| FIND /I "Adobe Acrobat Reader"') DO UninstallW.exe /q /w "%%i"
FOR /F "tokens=1 delims=:" %%i IN ('UninstallW.exe /a  ^| FIND /I "Adobe Acrobat"') DO UninstallW.exe /q /w "%%i"
FOR /F "tokens=1 delims=:" %%i IN ('UninstallW.exe /a  ^| FIND /I "Adobe Refresh Manager"') DO UninstallW.exe /q /w "%%i"

echo Borrando servicios...
sc query AdobeARMservice > nul
if "%errorlevel%"=="0" (
	sc stop AdobeARMservice
	sc delete AdobeARMservice
)

sc query AGSService > nul
if "%errorlevel%"=="0" (
	sc stop AGSService
	sc delete AGSService
)

sc query AGMService > nul
if "%errorlevel%"=="0" (
	sc stop AGMService
	sc delete AGMService
)

echo Borrando directorios Adobe...
if exist "C:\Program Files (x86)\Common Files\Adobe" rmdir /s /q "C:\Program Files (x86)\Common Files\Adobe"
if exist "C:\Windows\SysWOW64\config\systemprofile\AppData\Local\Adobe" rmdir /s /q "C:\Windows\SysWOW64\config\systemprofile\AppData\Local\Adobe"
if exist "C:\Windows\System32\config\systemprofile\AppData\Roaming\Adobe" rmdir /s /q "C:\Windows\System32\config\systemprofile\AppData\Roaming\Adobe"

echo Borrando directorios Adobe en C:\Users...
for /f "tokens=*" %%f in ('dir c:\Users /ad /b') do (
	if exist "c:\users\%%f\appdata\local\adobe" rmdir /s /q "c:\users\%%f\appdata\local\adobe"
	if exist "c:\users\%%f\appdata\locallow\adobe" rmdir /s /q "c:\users\%%f\appdata\locallow\adobe"
	if exist "c:\users\%%f\appdata\local\temp\adobe" rmdir /s /q "c:\users\%%f\appdata\local\temp\adobe"
	if exist "c:\users\%%f\appdata\roaming\adobe" rmdir /s /q "c:\users\%%f\appdata\roaming\adobe"
	if exist "c:\users\%%f\appdata\local\temp\acrobat_sbx" rmdir /s /q "c:\users\%%f\appdata\local\temp\acrobat_sbx"
	if exist "c:\users\%%f\appdata\local\temp\acrord32_super_sbx" rmdir /s /q "c:\users\%%f\appdata\local\temp\acrord32_super_sbx"
	if exist "c:\users\%%f\appdata\local\temp\acrord32_sbx" rmdir /s /q "c:\users\%%f\appdata\local\temp\acrord32_sbx"
	if exist "c:\users\%%f\appdata\local\temp\acrord32_super_sbx" rmdir /s /q "c:\users\%%f\appdata\local\temp\acrord32_super_sbx"
)

echo Borrando directorios Adobe en Program Files...
if exist "C:\ProgramData\Adobe" rmdir /s /q "C:\ProgramData\Adobe"
if exist "C:\Program Files (x86)\Adobe" rmdir /s /q "C:\Program Files (x86)\Adobe"
if exist "C:\Program Files\Adobe" rmdir /s /q "C:\Program Files\Adobe"

echo Borrando HKCU...
powershell.exe -ep Bypass .\Borrar_Adobe_HKCU.ps1 Borrar_Adobe_HKCU.reg

echo Borrando HKLM...
reg delete hklm\software\adobe /f 2>NUL
reg delete hklm\software\policies\adobe /f 2>NUL
reg delete hklm\wow6432node\adobe /f 2>NUL

echo Borrando clave Adobe Genuine Service...
reg delete HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\AdobeGenuineService /f 2>NUL
