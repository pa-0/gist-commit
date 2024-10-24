# Clears the Visual Studio Code User Data caches

# Backup your Visual Studio Code user folder before running!

# === Start Edit
$userdataFolder = "C:\Portable Software\PortableApps\PortableApps\Visual Studio Code\data\user-data"
# === End Edit

$cacheFolder = $userdataFolder + "\Cache"
$cachedDataFolder = $userdataFolder + "\CachedData"
$cachedExtensionVSIXsFolder = $userdataFolder + "\CachedExtensionVSIXs"

# Checks if Visual Studio Code is active
if(Get-Process "Code" -ErrorAction SilentlyContinue)
{
    Write-Host "Please close Visual Studio Code first. Code.exe is running."
    exit
}

if((Test-Path $cacheFolder) -eq $false -or `
(Test-Path $cachedDataFolder) -eq $false -or `
(Test-Path $cachedExtensionVSIXsFolder) -eq $false)
{
    Write-Host "Please check the following paths exist."
    Write-Host "$cacheFolder"
    Write-Host "$cachedDataFolder"
    Write-Host "$cachedExtensionVSIXsFolder"
    exit
}

# Gets the files lists
$cacheFolderFiles = gci $cacheFolder -Recurse
$cachedDataFolder = gci $cachedDataFolder -Recurse
$cachedExtensionVSIXsFiles = gci $cachedExtensionVSIXsFolder -Recurse

# Combines many lists to one
$filesToRemove = $cacheFolderFiles + `
$cachedDataFolder + $cachedExtensionVSIXsFiles

# Loops through final list deleting files and subfolders
foreach($item in $filesToRemove)
{
    $path = $item.FullName
    Write-Host "Deleting: $path" 
    Remove-Item -LiteralPath $path -ErrorAction SilentlyContinue
}