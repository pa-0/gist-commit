@echo off &title .Files.xml listing from directory context-menu by AveYo v1.0
if not exist "%~1" ( goto :setup ) else pushd "%~1\.." &echo "%~1" &set "fn=%~nx1 Files.xml"
del /f/q "%fn%" >nul 2>nul &cd.>"%fn%" 2>nul
if exist "%fn%" ( set "files=%CD%\%fn%" ) else set "files=%USERPROFILE%\Desktop\%fn%"
pushd "%~1"
set "bad=&" &set "escape=&amp;"
>"%files%" echo ^<?xml version="1.0"?^>^<root listing="%~1"^>
for /f "delims=" %%M in ('dir /b') do >>"%files%" call :loop "%%~dpnxM"
>>"%files%" echo ^</root^>
rem start "preview" iexplore "%files%"
exit
:loop
set "fn=%~nx1"
call set "fn=%%fn:%bad%=%escape%%%"
for /f "tokens=1 delims=r-" %%# in ("%~a1") do if /i ".%%#"==".d" (
 echo  ^<dir n="%fn%"^>
 pushd "%~dpnx1"
 for /f "delims=" %%N in ('dir /b') do call :loop "%%~dpnxN"
 popd
 echo  ^</dir^>
) else (
 echo    ^<f n="%fn%"/^>
)
exit/b
:setup
if /i "%~f0"=="%APPDATA%\AveYo\Files_xml.bat" (set "COPY=") else copy /y "%~f0" "%APPDATA%\AveYo\Files_xml.bat"
reg add HKCU\Software\Classes\Directory\shell\Files.xml\command /ve /d "cmd /c call \"%APPDATA%\AveYo\Files_xml.bat\" \"%%1\"" /f
echo Done - right-click any directory and click 'Files.xml' entry!
pause
exit/b
