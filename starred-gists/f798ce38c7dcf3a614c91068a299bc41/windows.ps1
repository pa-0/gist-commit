winget install Microsoft.VisualStudio.Enterprise
winget install Microsoft.VisualStudioCode
winget install Microsoft.WindowsTerminalPreview
winget install Microsoft.PowerToys
winget install Git.Git
winget install Apple.iTunes
winget install ditto.ditto
winget install RandyRants.SharpKeys
winget install ScooterSoftware.BeyondCompare4
winget install GitHub.cli

Set-ExecutionPolicy RemoteSigned
mkdir -force ~/source/repos/
cd ~/source/repos/
git clone https://github.com/regisf/virtualenvwrapper-powershell.git
cd virtualenvwrapper-powershell
./Install.ps1
cd ~
# https://github.com/microsoft/WSL/issues/4784#issuecomment-675702244

Start-Process powershell -Verb runas
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
cd ~
Invoke-WebRequest https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi -OutFile wsl.msi

# This exit is needed to refresh environment
exit

cd ~/source/repos
git clone https://github.com/microsoft/vcpkg
.\vcpkg\bootstrap-vcpkg.bat

Install-Module DockerCompletion -Scope CurrentUser
Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser
Install-Module git-aliases -Scope CurrentUser -AllowClobber
Install-Module -Name PSFzf -Scope CurrentUser
# https://stackoverflow.com/a/1802183
Install-Module Pscx -Scope CurrentUser -AllowClobber

start-process "https://auth.juliacomputing.com/downloadjuliapro/juliapro/1541/JuliaPro_v1.5.4-1_build-329.exe"