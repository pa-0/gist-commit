msiexec.exe /x "wsl_update_x64.msi" /q
dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /remove /norestart
dism.exe /online /disable-feature /featurename:VirtualMachinePlatform /remove /norestart
