@echo off

:: https://learn.microsoft.com/en-us/archive/blogs/askds/a-treatise-on-group-policy-troubleshootingnow-with-gpsvc-log-analysis
:: https://learn.microsoft.com/en-us/answers/questions/120736/gpos-not-applied-ad-group-issue.html
:: http://www.sysprosoft.com/policyreporter.shtml

echo GPO Debug Activation:
echo - Adding "GPSvcDebugLevel" registry key...
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Diagnostics" /v "GPSvcDebugLevel" /t REG_DWORD /d 0x00030002 /f > nul

if not exist "%windir%\debug\usermode" (
	echo - Creating %windir%\debug\usermode...
	mkdir "%windir%\debug\usermode"
)

echo - Updating GPO...
gpupdate /force
