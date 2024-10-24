# Instalación manual en versiones anteriores a Windows 10 2004
# https://docs.microsoft.com/en-us/windows/wsl/install-manual
#
# - Instalar Feature Microsoft-Windows-Subsystem-Linux
# - Instalar Feature VirtualMachinePlatform
# - Reiniciar el ordenador
# - Instalar Linux Kernel Update (MSI) https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi
# - Fijar WSL2 como versión por defecto

# dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
# dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
# msiexec.exe /i "wsl_update_x64.msi" /q
# wsl.exe --set-default-version 2

# Instalación automática en versiones superiores a Windows 10 2004
# https://docs.microsoft.com/en-us/windows/wsl/install
#
# - Instalar Features + Kernel + Distro
# - Reiniciar el ordenador

wsl.exe --install -d Ubuntu
Get-ChildItem -Path $Env:USERPROFILE -Include Ubuntu*.appx -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item
Get-ChildItem -Path $Env:USERPROFILE -Include Ubuntu*.zip -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item
