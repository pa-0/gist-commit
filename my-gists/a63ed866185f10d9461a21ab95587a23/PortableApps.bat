echo set variable %~n0 of global environment as path to this script without slash on the end
cd /d %~dp0
setx %~n0 %cd%
