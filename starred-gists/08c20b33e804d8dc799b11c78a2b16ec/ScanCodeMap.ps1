# 左Ctrl和CapsLock互换
New-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout" -Name "ScanCode Map" -PropertyType "Binary" -Value 00, 00, 00, 00, 00, 00, 00, 00, 03, 00, 00, 00, 29, 00, 58, 00, 58, 00, 29, 00, 00, 00, 00, 00

# 复原
Remove-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout" -Name "ScanCode Map"