@echo off
net session >nul 2>&1
if %errorLevel% == 0 (
powershell -Command "Add-Type -AssemblyName PresentationFramework; if((gsv wslservice).StartType -eq 'Automatic') { $choice = [System.Windows.MessageBox]::Show('Disable WSL and Restart?', 'Version Choice', 'OKCancel', 'Information', 'Cancel');if ($choice -eq 'OK') {Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\WslService -Name Start -Value 0x00000004; Restart-Computer}} else { $choice = [System.Windows.MessageBox]::Show('Enable WSL and Restart?', 'Version Choice', 'OKCancel', 'Information', 'Cancel');if ($choice -eq 'OK') {Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\WslService -Name Start -Value 0x00000002; Restart-Computer}};"
) else (
  echo "Right-Click Bat File And Run As Administrator."
)

pause

:: 0x00000000 = Boot
:: 0x00000001 = System
:: 0x00000002 = Automatic
:: 0x00000003 = Manual
:: 0x00000004 = Disabled