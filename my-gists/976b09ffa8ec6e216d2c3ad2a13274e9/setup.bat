title win11 setup

::------------------windows settings------------------------
echo setting windows settings..

:: show hidden files in explorer
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v Hidden /t REG_DWORD /d 1 /f

:: show file extensions in explorer
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v HideFileExt /t REG_DWORD /d 0 /f

::use old windows right click menu
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f

:: Disable web search in Start Menu
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search /v BingSearchEnabled /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search /v AllowCortana /t REG_DWORD /d 0 /f
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search /v CortanaConsent /t REG_DWORD /d 0 /f

:: Disable P2P Update downlods outside of local network
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v DODownloadMode /t REG_DWORD /d 0 /f

::restart explorer
powershell -c gps 'explorer' ^| stop-process


::------------------------wsl2------------------------------
echo installing wsl..
wsl --install

::-------------------winget installs------------------------
echo installing programs..

winget install -e --id 7zip.7zip
::winget install -e --id RARLab.WinRAR

winget install -e --id Audacity.Audacity

winget install -e --id Canonical.Ubuntu.2004

winget install -e --id Docker.DockerDesktop

winget install -e --id GitHub.GitHubDesktop

winget install -e --id Git.Git

winget install -e --id Google.Chrome

winget install -e --id JetBrains.Toolbox
winget install -e --id JetBrains.Rider
winget install -e --id JetBrains.WebStorm

winget install -e --id Microsoft.VisualStudioCode
winget install -e --id Microsoft.dotnet
winget install -e --id Microsoft.PowerToys
winget install -e --id Microsoft.Teams
winget install -e --id Microsoft.VisualStudio.2022.Enterprise-Preview

winget install -e --id Mozilla.Firefox.DeveloperEdition

winget install -e --id OpenJS.NodeJS.LTS

winget install -e --id SlackTechnologies.Slack

winget install -e --id Spotify.Spotify

winget install -e --id VideoLAN.VLC

echo setup done.
pause