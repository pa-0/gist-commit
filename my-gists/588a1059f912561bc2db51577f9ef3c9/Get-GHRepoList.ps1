Set-StrictMode -Version Latest

function Get-GHRepoList {
    <# .SYNOPSIS
    Gets a list of repositories of a GitHub user. #>
    Param(
        # User to enumerate
        [string]$User,
        # Page size to request
        [int]$Size = 100
    )

    $page = 0
    $count = (Invoke-RestMethod -Uri ('https://api.github.com/users/{0:s}' -f $User)).public_repos
    Write-Verbose ('Total repos for user {0:s} is {1:d}.' -f $User, $count)
    do {
        $page++
        Write-Verbose ('Retrieving page {0:d} of {1:d} results.' -f $page, $Size)
        (Invoke-RestMethod -Uri ('https://api.github.com/users/{0:s}/repos?page={1:d}&per_page={2:d}' -f $User, $page, $Size)).html_url
        Start-Sleep -Seconds 1
    } while ($page * $size -lt $count)
    Write-Verbose ('Stopped at batch size {0:d}' -f ($page * $size))
}
