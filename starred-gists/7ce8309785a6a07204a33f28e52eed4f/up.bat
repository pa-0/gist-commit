@echo off

REM Usage: `up <n>`
REM Will run `cd ..` n times
REM Put this file (`up.bat`) somewhere in your PATH

set many=1
if not "%1"=="" set many=%1
for /l %%x in (1, 1, %many%) do cd ..