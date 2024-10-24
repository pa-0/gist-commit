<#
.Synopsis
    Download GitHub Release File.
.DESCRIPTION
    A utilities tool for download GitHub release.
.PARAMETER Repository
    The relative url of the repository (owner/repo).
.PARAMETER Pattern
    Matching the pattern file name.
.PARAMETER TagName
    The tag name of the release.
.PARAMETER Destination
    The directory to save files.
.PARAMETER Force
    Force existing files.
.EXAMPLE
    .\Download-GitHubRelease.ps1 -Repository "user/repo" -Pattern "filename"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [Alias('r', 'Repo')][string]$Repository,

    [Alias('t', 'Tag')]
    [string]$TagName,

    [Alias('p', 'Value')]
    [string]$Pattern,

    [Alias('d', 'Directory')]
    [string]$Destination,

    [Alias('f')]
    [switch]$Force
)

Set-StrictMode -Off

$script:ErrorActionPreference = 'Stop'
$script:ProgressPreference = 'SilentlyContinue'

if (-not $Destination) {
    $Destination = [System.IO.Directory]::GetCurrentDirectory()
}

if (-not [System.IO.Directory]::Exists($Destination)) {
    [System.IO.Directory]::CreateDirectory($Destination)
}

$release = [System.Uri]::new("https://api.github.com/repos/$Repository/releases").AbsoluteUri

if ($TagName) {
    $url = [System.Uri]::new($release, "tag/$TagName").AbsoluteUri
}
else {
    $url = [System.Uri]::new($release, 'latest').AbsoluteUri
}

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $metadata = Invoke-RestMethod -Uri $url
}
catch {
    # 403: The API rate limit, 404: Page not found
    throw $_.Exception.Message
    # $StatusCode = $_.Exception.Response.StatusCode.value__
    # if ($StatusCode -eq 403) {
    #     "($StatusCode) Please try your request again later."
    # }
    # elseif ($StatusCode -eq 404) {
    #     "($StatusCode) Page not found: https://github.com/$Repository"
    # }
    # else {
    #     "Please check your connection and try again. "
    # }
    # exit $LASTEXITCODE
}

if ($Pattern) {
    $assets = $metadata.assets.Where({ $_.name -match $Pattern })
    if (-not $assets) {
        Write-Host "No package found matching: $Pattern" -Foreground Red
        exit $LASTEXITCODE
    }
}
else {
    $assets = $metadata.assets
}

foreach ($asset in $assets) {
    $packageName = [System.IO.Path]::Combine($Destination, $asset.name)
    $downloadURL = [System.Uri]::new($asset.browser_download_url)
    if ($Force -and [System.IO.File]::Exists($packageName)) {
        [System.IO.File]::Delete($packageName)
    }
    if (-not [System.IO.File]::Exists($packageName)) {
        Write-Host "Downloading $($asset.name) ... " -NoNewline
        [System.Net.WebClient]::new().DownloadFile($downloadURL, $packageName)
        Write-Host 'done'
    }
    else {
        Write-Host "The package already exists: $packageName" -ForegroundColor Yellow
    }
}
