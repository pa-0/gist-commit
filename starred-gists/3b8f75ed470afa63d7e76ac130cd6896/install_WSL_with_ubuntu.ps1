$featurename='Microsoft-Windows-Subsystem-Linux'
$Ubuntu_APK_URL="https://aka.ms/wsl-ubuntu-1804"
$Distro = 'Ubuntu-18.04'
$EXEName = 'ubuntu1804.exe'


function Exit_Wait(){
    if($needRestart){
        Write-Warning 'Please restart computer and run the script again!!!'
    }
    Write-Host -NoNewLine 'Press any key to continue...';
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}


# rerun if not in admin mode
if ( -not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator') ) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -WorkingDirectory $pwd -Verb RunAs
    Exit
}

# get wsl install status
$installstatus=Get-WindowsOptionalFeature -Online -FeatureName $featurename

# enable wsl if need
if($installstatus.State -eq $null) {echo 'Please update windows to at lease win10 1803'; exit}
elseif($installstatus.State -eq 'Disabled'){
    echo 'Enableing WSL...'
    Enable-WindowsOptionalFeature -Online -FeatureName $featurename
    $needRestart = $true
    echo 'Completed'
    Exit_Wait
}else{
    Write-Warning 'WSL Already Enable'
}

#check if ubuntu is already installed
$InstalledWSLDistros = @((Get-ChildItem 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss' -ErrorAction:SilentlyContinue | ForEach-Object { Get-ItemProperty $_.pspath }).DistributionName)

#install ubuntu
if ($InstalledWSLDistros -notcontains $Distro) {
    $WSLDownloadPath = Join-Path $ENV:TEMP "$Distro.zip"
    $InstallPath = Join-Path $ENV:TEMP "$Distro"
    $WSLExe = Join-Path $InstallPath "$EXEName"
    Write-Output "WSL distro $Distro is not found to be installed on this system, attempting to download and install it now..."    

    if (-not (Test-Path $WSLDownloadPath)) {
        Invoke-WebRequest -Uri $Ubuntu_APK_URL -OutFile $WSLDownloadPath -UseBasicParsing
    }
    else {
        Write-Warning "The $Distro zip file appears to already be downloaded."
    }

    Expand-Archive $WSLDownloadPath $InstallPath -Force

    if (Test-Path $WSLExe) {
        Write-Output "Starting $WSLExe"
        Start-Process $WSLExe -wait
    }
    else {
        Write-Warning "  $WSLExe was not found for whatever reason"
    }
}
else {
    Write-Warning "Found $Distro is already installed on this system. Enter it simply by typing bash.exe"
}
#create shortcut for access ubuntu '/' for furture use
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutpath="$DesktopPath/$Distro rootfs.lnk"
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutpath)
$targetPath = "$ENV:TEMP\$Distro\rootfs"
$Shortcut.TargetPath = $targetPath
$Shortcut.Save()
#create shortcut for open ubuntu terminal
$shortcutpath="$DesktopPath/$Distro.lnk"
$Shortcut = $WshShell.CreateShortcut($shortcutpath)
$targetPath = "$ENV:TEMP\$Distro\$EXEName"
$Shortcut.TargetPath = $targetPath
$Shortcut.Save()

#wait for exit
Exit_Wait
