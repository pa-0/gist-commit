cd /d %~dp0
call :wd %cd%
goto end
:wd
echo set variable %~n1 of global environment as path to this script without slash on the end
setx %~n1 %cd%
:end
