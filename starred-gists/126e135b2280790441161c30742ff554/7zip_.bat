@echo off
set _7ZIP="C:\Program Files\7-Zip\7z.exe"
set OUT_DIR=F:\Book Scan

echo %*

@echo on
for /d %%G in (%*) do %_7ZIP% a -bd -bso0 -bsp0 "F:\Book Scan\_Created_PDF\%%~nxG.zip" %%G
pause
