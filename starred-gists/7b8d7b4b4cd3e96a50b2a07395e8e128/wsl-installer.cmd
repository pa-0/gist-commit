@echo off
:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------    
@echo off
title wsl setup Part 1 !


dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart


(
echo @echo off
echo :: BatchGotAdmin
echo :-------------------------------------
echo REM  --> Check for permissions
echo     IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
echo >nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
echo ) ELSE (
echo >nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
echo )
echo 
echo REM --> If error flag set, we do not have admin.
echo if '%errorlevel%' NEQ '0' (
echo     echo Requesting administrative privileges...
echo     goto UACPrompt
echo ) else ( goto gotAdmin )
echo 
echo :UACPrompt
echo     echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo     set params= %*
echo     echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"
echo 
echo     "%temp%\getadmin.vbs"
echo     del "%temp%\getadmin.vbs"
echo     exit /B
echo 
echo :gotAdmin
echo     pushd "%CD%"
echo     CD /D "%~dp0"
echo :--------------------------------------    
echo @echo off
echo title wsl setup part 2 !
echo c
echo powershell Invoke-WebRequest https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -OutFile C:\wsl2-kernel.msi -UseBasicParsing
echo 
echo C:\wsl_update_x64.msi
echo wsl --set-default-version 2
echo powershell Invoke-WebRequest -Uri https://aka.ms/wslubuntu2004 -OutFile C:\distro.appx -UseBasicParsing
echo 
echo powershell Add-AppxPackage .\distro.appx
echo 
echo del "C:\distro.appx"
echo echo Setup Finished, deleting this script.
echo (GoTo^) 2^>Nul ^& Del "%%~f0"
echo 
echo 
)>"C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\wsl-part2.bat"

setlocal
:PROMPT
SET /P REBOOTNOW=Do you want reboot now second script will run after reboot (Y/[N])?
IF /I "%REBOOTNOW%" NEQ "N" GOTO END

shutdown -r


:END
endlocal
