$Script:SearchUrl = "https://api.github.com/search/code?q={0}+in:file+language:powershell+extension:{1}&page={2}&per_page=100";
$Script:BasicAuth = "{0}:{1}"
$Script:Credential = $null

if ($PSEdition -ne "Core") {
    Add-Type -AssemblyName System.Net.Http
}


##
## Create HttpClient instance
##
function New-HttpClient {

    [CmdletBinding()]
    param(
        [Parameter()]
        [pscredential]$Credential
    )

    $httpHandler = [System.Net.Http.HttpClientHandler]::new()
    $httpHandler.AllowAutoRedirect = $true
    $httpHandler.PreAuthenticate = $true
    $httpHandler.UseCookies = $true

    if ($PSEdition -eq "Core") {
        $httpHandler.SslProtocols = "Tls12"
    }
        
    $client = [System.Net.Http.HttpClient]::new($httpHandler, $true)
    $client.DefaultRequestHeaders.UserAgent.ParseAdd("SearchGithub")
    
    if ($Credential) {
        $NetCred = $Credential.GetNetworkCredential()
        $client.DefaultRequestHeaders.Authorization = 
            [System.Net.Http.Headers.AuthenticationHeaderValue]::new("Basic", 
                [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(
                    $NetCred.UserName + ":" + $NetCred.Password)))
    }

    return $client
}


##
## Search GitHub for powershell usage
##
function Search-GitHubCode {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$SearchString,

        [Parameter(Mandatory, Position = 1)]
        [pscredential]$Credential,

        [Parameter(Position = 2)]
        [ValidateRange(1, 10)]
        [int]$MaxPages = 10, # Only the first 1000 search results are available. See https://developer.github.com/v3/search/#about-the-search-api

        [Parameter(Position = 3)]
        [ValidateSet("ps1", "psm1")]
        [string]$Extension = "ps1"
    )

    Begin {
        $Script:Credential = $Credential
        $SearchString = $SearchString -replace "\s+", "+"
        $UrlFormat = $Script:SearchUrl -f $SearchString, $Extension, "{0}"
        $client = New-HttpClient -Credential $Credential
    }

    Process {
        try {
            for ($i = 1; $i -le $MaxPages; $i++) {
                Write-Verbose "[Search-GitHubCode] Retrieving page $i"
                SendRequestAndReadAsJson $client ($UrlFormat -f $i)
                Start-Sleep -Seconds 1
            }
        } finally {
            $client.Dispose()
        }
    }
}


##
## Download and save the relevant files in the search results
##
function Save-RelevantFile {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [psobject]$SearchResult,

        [Parameter(Mandatory)]
        [string]$DirectoryPath
    )

    Begin {
        $targetDir = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($DirectoryPath)
        $scriptsUrlFile = Join-Path $targetDir "scripts-url-file.txt"

        if (Test-Path $targetDir -PathType Leaf) {
            throw "The path '$targetDir' points to an existing file."
        }
        if (-not (Test-Path $targetDir -PathType Container)) {
            New-Item $targetDir -ItemType Directory -Force -ea Stop > $null
        }
        if (Test-Path $scriptsUrlFile) {
            Remove-Item $scriptsUrlFile -Force -ea Stop
        }

        $fileSet = [System.Collections.Generic.HashSet[string]]::new()
        $client = New-HttpClient -Credential $Script:Credential
    }

    Process {
        try {
            $downloadUrls = [System.Collections.Generic.List[string]]::new()
            foreach ($item in $SearchResult.items) {
                if ($fileSet.Contains($item.name)) {
                    continue
                } else {
                    $fileSet.Add($item.name) > $null
                }

                $file = Join-Path $targetDir $item.name
                if (Test-Path $file -PathType Leaf) {
                    Write-Verbose "[Save-RelevantFile][SKIP] $($item.name) already saved."
                    continue
                }

                Write-Verbose "[Save-RelevantFile] name: $($item.name)"
                Write-Verbose "[Save-RelevantFile] url: $($item.url)"

                $json = SendRequestAndReadAsJson $client $item.url
                $downloadUrls.Add($json.download_url)
                SendRequestAndSaveFile $client $json.download_url $file
                Start-Sleep 1
            }
            $downloadUrls | Out-File -FilePath $scriptsUrlFile -Append
        } catch {
            $client.Dispose()
            throw
        }
    }

    End {
        $client.Dispose()
        Write-Host "scripts-url-file.txt: $scriptsUrlFile" -ForegroundColor Green
        Write-Host "Relevant .ps1 files can be found at: $targetDir" -ForegroundColor Green
    }
}


##
## Help function -- request and receive json
##
function SendRequestAndReadAsJson([System.Net.Http.HttpClient]$client, [string]$url) {
    try {
        $response = $client.GetAsync($url).Result.EnsureSuccessStatusCode()
        $content = $response.Content
        $contentType = $content.Headers.ContentType.MediaType
            
        if ($contentType -eq "application/json") {
            ConvertFrom-Json $content.ReadAsStringAsync().Result
        } else {
            throw "Unexpected content: '$contentType'; Request URL: '$url'"
        }
    } catch {
        Write-Host -ForegroundColor Red ("Request URL: '$url'")
        throw
    }
}


##
## Help function -- request and receive file
##
function SendRequestAndSaveFile([System.Net.Http.HttpClient]$client, [string]$url, [string]$file) {
    try {
        $response = $client.GetAsync($url).Result.EnsureSuccessStatusCode()
        $content = $response.Content
        $contentType = $content.Headers.ContentType.MediaType

        if ($contentType -ne "text/plain") {
            throw "Unexpected content: '$contentType'; Request URL: '$url'"
        }

        $fileStream = [System.IO.FileStream]::new($file, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
        $content.CopyToAsync($fileStream).Wait()
    } catch {
        Write-Host -ForegroundColor Red ("Request URL: '$url'")
        throw 
    } finally {
        if ($fileStream -ne $null) {
            $fileStream.Dispose()
        }
    }
}