$userProfileItem = get-item $PROFILE
$userProfileDirectory = $userProfileItem.Directory
$pathToProfileScript = "https://gist.githubusercontent.com/jimbromley-avanade/a6c77b78b1ae263dd5f533812ed6a433/raw/Microsoft.PowerShell_profile.ps1"
$webScriptName = "web-profile.ps1"
$webClient = New-Object System.Net.WebClient
$scriptContents = ""
$webClientError = 0
$loadedFromFile = 0
try
{
    Write-Output "Getting web profile script..."
    $scriptContents = $webClient.DownloadString($pathToProfileScript)
}
catch [System.Exception]
{
    Write-Output "Error getting web profile script..."
    $webClientError = 1
}

if ($webClientError -eq 0)
{
    Write-Output "Caching web profile script..."
    New-Item -Path $userProfileDirectory -Name $webScriptName -ItemType "file" -Value $scriptContents -Force
} else {
    $webScriptFullPath = Join-Path -Path $userProfileDirectory -ChildPath $webScriptName
    if (Test-Path $webScriptFullPath -PathType Leaf)
    {
        Write-Output "Getting cached web profile script..."
        $scriptContents = Get-Content -Path $webScriptFullPath -Raw
        $loadedFromFile = 1
    } else {
        Write-Error "Cached web profile script not found. Profile not loaded."
    }
}

if ($webClientError -eq 0 || $loadedFromFile -eq 1)
{
    Write-Output "Executing web profile script..."
    Invoke-Expression $scriptContents
}