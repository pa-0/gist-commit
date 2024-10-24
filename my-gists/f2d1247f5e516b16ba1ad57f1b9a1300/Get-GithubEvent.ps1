function Get-GithubEvent {
    
    param($userId,$Password)
    
    function Get-GitHubAuthHeaders {
        
        param($userId,$Password)
        
        $authInfo = "$($userId):$($Password)" 
        $authInfo = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($authInfo))
    
        @{
            "Authorization" = "Basic " + $authInfo
            "Content-Type"  = "application/json"
        }                   
    }

    $Headers = Get-GitHubAuthHeaders $userId $Password
    $Uri     = "https://api.github.com/users/$userId/received_events"

    ForEach($item in (Invoke-RestMethod -Headers $Headers -Uri $Uri )) {
        [PSCustomObject]@{
            Action  = $item.payload.action
            Type    = $item.type
            Who     = $item.actor.login
            Details = $item
        }        
    }
}