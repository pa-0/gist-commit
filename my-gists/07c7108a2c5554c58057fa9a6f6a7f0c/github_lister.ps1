# github.com lister
# Usage: github_lister.ps1 <ORG_NAME> <github_username> <github_personal_accesstoken>
# E.g.: github_lister.ps1 SecurityShift markz0r ghp_BzuLHDiU6dfsqwfau0Njxiy
# Personal access tokens: https://github.com/settings/tokens
$ErrorActionPreference = "Stop"
$User = $args[1]
$Token = $args[2]
$orgName = "https://api.github.com/orgs/$args[0]/repos?per_page=100"
$OUTPUT_FILE=".\github_repos.txt"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($User):$($Token)"))
$Header = @{
    Authorization = "Basic $base64AuthInfo"
}
$allRepos = @()
$page=0
#keep getting repos until the count comes back zero 
do 
{    
   $page += 1    
   $params = @{'Uri' = ('{0}/repos?page={1}&per_page=100' -f
                        $orgName, $page )
               'Headers' = $Header
               'Method'      = 'GET'
               'ContentType' = 'application/json'}
   $repos = Invoke-RestMethod @params
   $allRepos += $repos
   $repoCount = $repos.Count
} while($repoCount -gt 0)
#now you have an array of all the repos in your org
foreach ( $repo in $allRepos )
{
   #iterate over the Repos and do what you need
   $repoName = $repo.name    
   $repoVisibility = $repo.visibility    
   $repoArchived = $repo.archived
   $repo_ssh_url = $repo.ssh_url
   Write-Output "$repoName - $repoVisibility - $repoArchived"
   Add-Content -Path $OUTPUT_FILE -Value "$repo_ssh_url"
}