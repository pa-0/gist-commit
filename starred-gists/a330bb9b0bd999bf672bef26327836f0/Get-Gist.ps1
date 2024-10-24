# https://github.com/dfinke/Posh-Gist

# Get-Gist
# Copy of the Gist-Functions, with focus on Get-Gist
# You need a GitHub account to post a gist, this does not support anonymous posts.

# Remember that the param statement should be the first one in a PowerShell script.
param(
    [Parameter(Mandatory)]
    [string]$User,
    [string]$FileName
)    



function Get-GistAuthHeader {

    if(!$Global:GitHubCred) { $Global:GitHubCred = Get-Credential ''}

    $authInfo = "{0}:{1}" -f $Global:GitHubCred.UserName, $Global:GitHubCred.GetNetworkCredential().Password
    $authInfo = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($authInfo))

    @{
        'Authorization' = 'Basic ' + $authInfo
        'Content-Type' = 'application/json'
    }
}



function Get-GistContent {
    param(
    	[Parameter(ValueFromPipelineByPropertyName)]
    	[string]$RawUrl,

        [Parameter()]
        [switch]$SendToISE
    )
    
    Begin   { $Header = Get-GistAuthHeader }

    Process {
        $gistContent = Invoke-RestMethod -Uri $RawUrl -Headers $Header

        if($SendToISE) {
            $newISETab = $psISE.CurrentPowerShellTab.Files.Add()
            $newISETab.Editor.Text = $gistContent
            $newISETab.Editor.SetCaretPosition(1,1)
        }

        else {
            Write-Output $gistContent
        }
    }
}



function Remove-Gist {
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$GistID
    )

    Begin { $Header = Get-GistAuthHeader }
    Process { Invoke-RestMethod -Method 'Delete' -Uri "https://api.github.com/gists/$($GistID)" -Headers $Header }
}



function Send-Gist {
    param([string]$Path, [string]$Description)

    if($Path) {
        if (Test-Path -Path $Path) {
            $fileName = Split-Path -Path $Path -Leaf
            $contents = Get-Content -Path $Path -Raw
        }
        
        else {
            Write-Warning "$($Path) not found"
            break
        }
    }

    else {
        if($psISE) {
            $fileName = Split-Path -Leaf $psISE.CurrentFile.FullPath

            if($psISE.CurrentFile.Editor.SelectedText) {
                $contents = $psISE.CurrentFile.Editor.SelectedText
            }

            else {
                $contents = $psISE.CurrentFile.Editor.Text
            }
        }

        else {
            Write-Warning 'Using this function without the Path parameter only works in PowerShell ISE'
            break
        }
    }

    if($Description) {
        $gistDescription = $Description
    }
    
    else {
        $gistDescription = "Description for $($fileName)"
    }

    $gist = @{
      'description' = $gistDescription
      'public' = $true
      'files' = @{
        "$($fileName)" = @{
          'content' = "$($contents)"
        }
      }
    }

    $Header = Get-GistAuthHeader 
 
    $BaseUri = $Uri = 'https://api.github.com/gists'    
    $Method  = 'POST'
 
    $targetGist = Get-Gist $Global:GitHubCred.UserName $fileName
    if($targetGist) {
 
        $r = [System.Windows.MessageBox]::Show('Gist already exists. Do you want to overwrite?', 'Confirmation', 'YesNo', 'Question')
        
        if($r -eq 'no') {return}

        $Uri = $BaseUri + "/$($targetGist.GistID)" 
        $Method = 'Patch'
    }

    $resp = Invoke-RestMethod -Uri $Uri -Method $Method -Headers $Header -Body ($gist | ConvertTo-Json)

    Start-Process $resp.'html_url'
}



function Test-Gist {
    param(
        [Parameter(Mandatory)]        
        [string]$FileName
    )    

    Get-GistAuthHeader | Out-Null    
    (Get-Gist $Global:cred.UserName $FileName) -ne $null
}



$(ForEach($gist in (Invoke-RestMethod -Headers (Get-GistAuthHeader) -Uri "https://api.github.com/users/$($User)/gists")) {

    $GetFileName = {($gist.files| Get-Member -MemberType NoteProperty).Name}
    [PSCustomObject]@{            
        FileName = &$GetFileName
        Url      = $gist.url
        RawUrl   = ($gist.files).(&$GetFileName).raw_url
        GistID   = Split-Path -Leaf $gist.url
    }
}) | Where-Object {$_.FileName -match $FileName}
