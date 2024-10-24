:: Fonte original: https://www.youtube.com/watch?v=Rb4-Ff55-YI
::
:: Modified to not close the CMD window at the end
:: If open from explorer still closes, if open from prompt it doesn't
::
:: Disabled options 1, 2 and 3 (insurance against idiots)
::
:: tavinus @ 17/12/2020
::
:: v0.0.4


@echo off
cls

:: deactivate, black is default
:: color 80

:menu
cls

echo.
echo %date%
echo.
echo Computer: %computername%        User: %username%
echo.
echo ^+---------------------------------------------^+
echo ^|    TASK MENU                                ^|
echo ^+---------------------------------------------^+
echo ^| 1. Empty the Recycle Bin                    ^|
echo ^| 2. Perform Backup                           ^|
echo ^| 3. Scan local disk                          ^|
echo ^| 4. Control Panel                            ^|
echo ^| 5. Exit                                     ^|
echo ^+---------------------------------------------^+
echo.

set /p option= Choose an option: 

if %option% equ 1 goto option1
if %option% equ 2 goto option2
if %option% equ 3 goto option3
if %option% equ 4 goto option4
if %option% equ 5 goto end
if %option% GEQ 6 goto operror

:option1
cls
:: disabled, remove '::' to reactivate
::rd /S /Q c:\$Recycle.bin
echo ^+---------------------------------------------^+
echo ^|    Empty Recycle Bin                        ^|
echo ^+---------------------------------------------^+
pause
goto menu

:option2
cls
:: desativado, remova :: para reativar
::xcopy /T /C C:\Users\emers\Documents\*.* C:\Users\emers\Desktop
echo ^+---------------------------------------------^+
echo ^|    Complete Backup                          ^|
echo ^+---------------------------------------------^+
pause
goto menu

:option3
cls
echo ^+---------------------------------------------^+
echo ^|    Disk Scan                                ^|
echo ^+---------------------------------------------^+
:: disabled remove '::' to activate it
::chkdsk c:
pause
goto menu

:option4
cls
echo ^+---------------------------------------------^+
echo ^|    Open the Control Panel                   ^|
echo ^+---------------------------------------------^+
control.exe
pause
goto menu

:operror
echo ^+---------------------------------------------^+
echo ^| Invalid Selection! Try another menu option. ^|
echo ^+---------------------------------------------^+
pause
goto menu

:end
cls
:: If 'exit' is selected, script will close the terminal / prompt 
:: Even if run from an already-open window
:: exit