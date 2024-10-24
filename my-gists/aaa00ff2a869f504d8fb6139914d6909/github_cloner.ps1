# github.com cloner
# Usage: github_cloner.ps1 <ORG_NAME> <github_username> <github_personal_accesstoken>
# E.g.: github_cloner.ps1 SecurityShift markz0r ghp_BzuLHDiU6dfsqwfau0Njxiy
# Personal access tokens: https://github.com/settings/tokens
$ErrorActionPreference = "Stop"
$User = $args[1]
$Token = $args[2]
$orgName = "https://api.github.com/orgs/$args[0]/repos?per_page=100"
$INPUT_FILE=".\github_repos.txt"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($User):$($Token)"))
$Header = @{
    Authorization = "Basic $base64AuthInfo"
}
$Response = Invoke-RestMethod -Uri $orgName -Headers $Header 
$($Response | Select-Object "ssh_url") | Out-File -FilePath $INPUT_FILE

$regex = '^git.*.git'
$i=0
foreach($line in Get-Content .\github_repos.txt) {
    $repo_name = $line.Trim()
    if($repo_name -match $regex){ 
        $repo_folder = $repo_name.SubString(25)
        $repo_folder = $repo_folder.SubString(0,$repo_folder.length -4)
        if (Test-Path -Path $repo_folder)
        {
            Write-Output "$repo_folder EXISTS, pulling instead"
            Write-Output "$i - START: git pull $repo_name"
            Push-Location ".\$repo_folder"
            git pull
            Pop-Location
            Write-Output "$i - END: git pull $repo_name"
        } else {
            Write-Output "NO EXIST, folder: $repo_folder"
            Write-Output "$i - START: git clone $repo_name"
            git clone "$repo_name"
            Write-Output "$i - END: git clone $repo_name"
        }      
        $i++
    }
}