####################################################################################################
####
#### Name: SyncTrayzorPortableUpdate.ps1
####
#### Author: Bernd Bestel (bernd@berrnd.de ; https://berrnd.de)
#### Created: 2015-06-08
#### Version: 1.0.0
####
#### License: The MIT License (MIT)
####
#### Description:
#### Makes updates of a portable installation of SyncTrayzor (https://github.com/canton7/SyncTrayzor) a little bit more convenient...
#### It will:
#### - Automatically detect the path where SyncTrayzor lives from the current running instance
#### - Update the found installation (if the online version is newer than the installed one), while preserving the data directory
####
####################################################################################################


function Begin()
{
    $Host.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size(200, 25)
}

function Finish()
{
    Write-Host
	Write-Host "SyncTrayzor Portable Update done, press any key to exit..."
	$HOST.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
	Exit
}

#Borrowed from http://www.howtogeek.com/tips/how-to-extract-zip-files-using-powershell/
function Expand-ZIPFile($file, $destination)
{
    $shell = New-Object -ComObject Shell.Application
    $zip = $shell.Namespace($file)
    foreach($item in $zip.items())
    {
        $shell.Namespace($destination).CopyHere($item)
    }
}


Begin

#Check if system is x64 or x86
if ([System.IntPtr]::Size -eq 4) { $arch = "x86" } else { $arch = "x64" }
Write-Host "System architecture is $arch"

#Get SyncTrayzor directory from running process
Write-Host "Getting SyncTrayzor path..."
$syncTrayzorExePath = (Get-Process -Name "SyncTrayzor" -ErrorAction SilentlyContinue)
if ([String]::IsNullOrEmpty($syncTrayzorExePath))
{
	Write-Host "SyncTrayzor is not running, canceling"
    Finish
}
$syncTrayzorExePath = $syncTrayzorExePath.Path
$syncTrayzorPath = Split-Path $syncTrayzorExePath -Parent
Write-Host "   Application directory is $syncTrayzorPath"

#Get installed SyncTrayor version
$installedVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($syncTrayzorExePath).FileVersion
$installedVersion = [Version]$installedVersion.SubString(0, $installedVersion.LastIndexOf(".")) #Ignore revision
Write-Host "   Installed version is $installedVersion"

#Get latest release info
Write-Host "Downloading latest release info..."
$webClient = New-Object System.Net.WebClient
$webClient.Headers["User-Agent"] = "SyncTrayzorPortableUpdate.ps1/1.0" #GitHub API needs an User-Agent...
$releaseJson = $webClient.DownloadString("https://api.github.com/repos/canton7/SyncTrayzor/releases/latest")

#Parse latest release info
Write-Host "Parsing latest release info..."
[System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions") | Out-Null
$jsSerializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
$releaseInfo = $jsSerializer.DeserializeObject($releaseJson)
$releaseName = $releaseInfo.name
$releaseAssets = $releaseInfo.assets
$releaseZip = $releaseAssets | Where-Object { $_.name -eq "SyncTrayzorPortable-$arch.zip" }
$releaseZipUrl = $releaseZip.browser_download_url
$onlineVersion = [Version]$releaseInfo.tag_name.Substring(1, $releaseInfo.tag_name.Length - 1)
Write-Host "   Latest release is $releaseName"
Write-Host "   Latest release URL is $releaseZipUrl"

#Compare online version to installed
if ($onlineVersion -le $installedVersion)
{
    Write-Host "Installed version $installedVersion is not newer than the online version $onlineVersion, canceling"
    Finish
}

#Download latest release
Write-Host "Downloading latest release..."
$newGuid = [Guid]::NewGuid()
$releaseZipPath = Join-Path $env:TEMP "SyncTrayzorPortable-$arch-$newGuid.zip"
Write-Host "   Destination is $releaseZipPath"
$webClient.DownloadFile($releaseZipUrl, $releaseZipPath)

#Close SyncTrayzor and Syncthing
Write-Host "Closing (killing) SyncTrayzor and Syncthing..."
Stop-Process -Name "SyncTrayzor"
Stop-Process -Name "syncthing"
Start-Sleep -s 2 #Syncthing sometimes needs some time...

#Backup data directory
Write-Host "Backing up data directory..."
$syncTrayzorDataPath = Join-Path $syncTrayzorPath "data"
$newGuid = [Guid]::NewGuid()
$syncTrayzorDataPathBackup = Join-Path $env:TEMP "SyncTrayzor-data-$newGuid"
Write-Host "   Backup path is $syncTrayzorDataPathBackup"
Move-Item $syncTrayzorDataPath $syncTrayzorDataPathBackup

#Empty app directory
Write-Host "Emptying application directory..."
Remove-Item -Recurse -Force $syncTrayzorPath

#Unzip new release
Write-Host "Unzipping new release..."
$newGuid = [Guid]::NewGuid()
$releaseTempPath = Join-Path $env:TEMP $newGuid
md $releaseTempPath | Out-Null
Expand-ZIPFile -File $releaseZipPath -Destination $releaseTempPath
$syncTrayzorPathTemp = Join-Path $releaseTempPath "SyncTrayzorPortable-$arch"
Move-Item $syncTrayzorPathTemp $syncTrayzorPath
Remove-Item $releaseZipPath
Remove-Item $releaseTempPath

#Restore data directory
Write-Host "Restoring data directory..."
Move-Item $syncTrayzorDataPathBackup $syncTrayzorDataPath

#Start SyncTrayzor
Write-Host "Starting SyncTrayzor..."
cmd /c "echo.>$syncTrayzorExePath:Zone.Identifier" #Unblock-File PowerShell 2.0 workaround
Start-Process -FilePath $syncTrayzorExePath -WorkingDirectory $syncTrayzorPath

Finish