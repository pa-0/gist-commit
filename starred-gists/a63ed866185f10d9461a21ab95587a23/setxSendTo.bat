:Place this script in %USERPROFILE%\SendTo
cd /d %1
call :wd %cd%
goto end
:wd
echo set variable %~n1 of global environment as path to folder without slash on the end
setx %~n1 %cd%
:end
