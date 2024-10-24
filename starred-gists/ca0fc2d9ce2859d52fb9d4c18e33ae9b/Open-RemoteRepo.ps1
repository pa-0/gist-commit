<#        
    Use GitHub slugs for repo - ex `Open-RemoteRepo microsoft/vscode`
    Remembers urls for use in tab completion in next invocations    
    Lets you choose between vscode and vscode-insiders
#>
$remoteRepoFileName = "$PSScriptRoot\OpenRemoteRepoUrls.txt"
function Open-RemoteRepo {
    param(
        [Parameter(Mandatory)]
        $Url,
        [ValidateSet('vscode', 'vscode-insiders', 'vscode-exploration')]
        $Edition = 'vscode'
    )

    if (Test-Path $remoteRepoFileName) {
        $savedUrls = @(Get-Content $remoteRepoFileName)
    }
    else {
        $savedUrls = @()
    }

    if ($savedUrls.Where( { $_ -eq $url }).Count -eq 0) {
        $savedUrls += $Url
    }

    $targetUrl = $Url
    if (!$Url.StartsWith('https://github.com/')) {
        $targetUrl = "https://github.com/" + $Url
    }    

    Start-Process "$($Edition)://github.remotehub/open?url=$targetUrl"
    $savedUrls > $remoteRepoFileName    
}

Register-ArgumentCompleter -CommandName Open-RemoteRepo -ParameterName Url -ScriptBlock {
    if (Test-Path $remoteRepoFileName) {
        foreach ($url in @(Get-Content $remoteRepoFileName)) {
            [System.Management.Automation.CompletionResult]::new($url, $url, 'ParameterValue', $url)
        }
    }
}
