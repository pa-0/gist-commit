# Authenticate 
$clientID = 'myGitHubUsername'
# GitHub API Client Secret 
$clientSecret = '21c22a9f0ca888373a3077614d0abcdefghijklmnop'
# Basic Auth
$Bytes = [System.Text.Encoding]::utf8.GetBytes("$($clientID):$($clientSecret)")
$encodedAuth = [Convert]::ToBase64String($Bytes)
# Search based on Description
$search = "Import Script"

$Headers = @{Authorization = "Basic $($encodedAuth)"; Accept = 'application/vnd.github.v3+json'}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$githubURI = "https://api.github.com/user"

$githubBaseURI = "https://api.github.com"
$auth = Invoke-RestMethod -Method Get -Uri $githubURI -Headers $Headers -SessionVariable GITHUB 

if ($auth) {
    # Get my GISTS
    $myGists = Invoke-RestMethod -method Get -Uri "$($githubBaseURI)/users/$($clientID)/gists" -Headers $Headers -WebSession $GITHUB
    $privateGists = $myGists | Select-Object | Where-Object {$_.public -eq $false}
    $privateGists.url
    $script = $privateGists | Select-Object | where-Object {$_.description -eq $search}
    
    if ($script){
       foreach ($file in $script.files){
            $filename = $file | Get-Member  | Where-Object {$_.memberType -eq "NoteProperty"} | select-object Name
            # Get File 
            $fileProps = $file."$($filename.Name)" 
            $rawURL = $fileProps.raw_url
            $fileraw = Invoke-RestMethod -Method Get -Uri $rawURL -WebSession $GITHUB
            $fileraw                     
       }
    }
}
