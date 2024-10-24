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
    do {
        $page++
        (Invoke-RestMethod -Uri ('https://api.github.com/users/{0:s}/repos?page={1:d}&per_page={2:d}' -f $User, $page, $Size)).html_url
        Start-Sleep -Seconds 1
    } while ($page * $size -lt $count)
}