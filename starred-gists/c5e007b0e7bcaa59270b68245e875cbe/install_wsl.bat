@echo off
echo - This scripts automates process of installing Windows Subsystem for Linux (WSL)

REM Due some limitations, this script has to be can't be executed under PowerShell
Get-ChildItem >nul 2>&1
if %errorLevel% == 0 (
    echo # Swich to CMD
    cmd /c start "" %0
    exit 0
)

set BASH=C:\Windows\System32\bash.exe
if not exist %BASH% call :install_wsl

call :get_linux_user
echo Main Linux user is: %linux_user%

call :fix_wsl
call :install_base_packages

echo -
echo - Done
pause
goto :eof

:check_permissions
    net session >nul 2>&1
    if %errorLevel% == 0 (
        goto :eof
    ) else (
        call :missing_admin
    )
    goto :eof

:get_linux_user
    %BASH% -c "whoami > ./tmpFile" 
    if not %errorLevel% == 0 call :missing_admin
    set /p linux_user= < tmpFile
    del tmpFile
    goto :eof

:install_wsl
    call :check_permissions
    
    echo -- Enable developer mode in Windows
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"
    
    echo -- Install WSL
    powershell -noprofile -command "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux"
    
    echo -- Install Ubuntu
    lxrun /install /y

    echo
    echo - Please Reboot your computer before continue
    set /p in= Do you want to reboot now? (y/n) 
    if "%in%" == "y"  (
        shutdown -r -f -t 10
    )
    exit 0
    
:wsl_start_sudo
    if not "%linux_user%" == "root" (
        echo -- Switch linux user to root
        lxrun /setdefaultuser root
    )
    goto :eof

:wsl_stop_sudo
    if not "%linux_user%" == "root" (
        echo -- Switch linux user to `%linux_user%`
        lxrun /setdefaultuser %linux_user%
    )
    goto :eof

:fix_wsl
    echo -- Fix WSL installation
    call :wsl_start_sudo

    echo -- Fix settings for root user
    call :fix_user_wsl_settings
    
    echo --- Fix sudo command
    %BASH% -c "if cat /etc/hosts | grep `hostname` >> /dev/null ; then echo OK; else echo '127.0.0.1 `hostname`' >> /etc/hosts; fi"
    REM %BASH% -c "echo '127.0.0.1 `hostname`' >> /etc/hosts"

    echo --- Fix D-BUS warnings / errors
    %BASH% -c "if cat /etc/dbus-1/session.conf | grep localhost,port=0 >> /dev/null ; then echo OK; else sed -i 's$<listen>.*</listen>$<listen>tcp:host=localhost,port=0</listen>$' /etc/dbus-1/session.conf && sed -i 's$<auth>EXTERNAL</auth>$<auth>ANONYMOUS</auth>$' /etc/dbus-1/session.conf && sed -i 's$</busconfig>$<allow_anonymous/></busconfig>$' /etc/dbus-1/session.conf; fi"
    REM %BASH% -c "sed -i 's$<listen>.*</listen>$<listen>tcp:host=localhost,port=0</listen>$' /etc/dbus-1/session.conf"
    REM %BASH% -c "sed -i 's$<auth>EXTERNAL</auth>$<auth>ANONYMOUS</auth>$' /etc/dbus-1/session.conf"
    REM %BASH% -c "sed -i 's$</busconfig>$<allow_anonymous/></busconfig>$' /etc/dbus-1/session.conf"

    echo --- Update packages
    %BASH% -c "apt update && apt -y upgrade"
    
    call :wsl_stop_sudo

    if not "%linux_user%" == "root" (
        echo -- Fix settings for main user
        call :fix_user_wsl_settings
    )
    goto :eof
    
    
:fix_user_wsl_settings
    echo --- Fix default language
    %BASH% -c "if cat ~/.bashrc | grep LANG=en_US.utf8 >> /dev/null ; then echo OK; else echo LANG=en_US.utf8 >> ~/.bashrc; fi"
    REM %BASH% -c "echo LANG=en_US.utf8 >> ~/.bashrc"
    echo --- Setup default X display
    %BASH% -c "if cat ~/.bashrc | grep 'export DISPLAY=:0.0' >> /dev/null ; then echo OK; else echo 'export DISPLAY=:0.0' >> ~/.bashrc; fi"
    REM %BASH% -c "echo 'export DISPLAY=:0.0' >> ~/.bashrc"
    goto :eof

:install_base_packages
    echo -- Install base packages
    call :wsl_start_sudo
    %BASH% -c "apt install -y unzip git-core zsh"
    call :wsl_stop_sudo
    goto :eof

:missing_admin
    echo Please run this script as an administrator
    exit 1

