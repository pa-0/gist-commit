@echo off
if _%1_==_payload_  goto :payload

:getadmin
    echo %~nx0: elevating self
    set vbs=%temp%\getadmin.vbs
    echo Set UAC = CreateObject^("Shell.Application"^)                >> "%vbs%"
    echo UAC.ShellExecute "%~s0", "payload %~sdp0 %*", "", "runas", 1 >> "%vbs%"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
goto :eof

:payload

::ADD TO HOSTS::   

SETLOCAL
SET "HOSTS=%WinDir%\System32\drivers\etc\hosts"
SET "TEMP_HOSTS=%TEMP%\%RANDOM%__hosts"
SET "WSL_IP=%TEMP%\%RANDOM%__docker_ip"
findstr /v /i "app.phoenix api.phoenix app.gate" %WINDIR%\system32\drivers\etc\hosts > %TEMP_HOSTS%
wsl ip addr show eth0 | grep -oP 'inet\s+\K\d+(\.\d+){3}' > %WSL_IP%
set /p WSLIP=<%WSL_IP%
echo %WSLIP% app.phoenix >> %TEMP_HOSTS% 
echo %WSLIP% api.phoenix >> %TEMP_HOSTS% 
echo %WSLIP% app.gate >> %TEMP_HOSTS% 
COPY /b/v/y "%TEMP_HOSTS%" "%HOSTS%"



::END OF YOUR CODE::

echo %WSLIP% assigned

pause