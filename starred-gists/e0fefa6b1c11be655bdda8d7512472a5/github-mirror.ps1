param(
    [Parameter(Mandatory=$true)]
    [string]$Username,
    [Parameter(Mandatory=$true)]
    [string]$GitHubAccessToken,
    [Parameter(Mandatory=$true)]
    [string]$BackupFolderPath
)

$initialWorkingPath = Convert-Path '.'

# Create the authorisation headers using our access token
$bytes = [System.Text.Encoding]::UTF8.GetBytes("${Username}:${GitHubAccessToken}")
$base64Credentials =[Convert]::ToBase64String($Bytes)

$authorization = "Basic $base64Credentials"

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"

$headers.Add("content-type", "application/json")
$headers.Add("Authorization", $authorization)

# This is the GraphQL query, which gets us the first
# 100 repos belonging to the specified username
$graphql = @"
query { 
    user(login:"$Username") { 
        repositories(first:100) { 
            nodes { name url } 
        } 
    } 
}
"@

# We're going to wrap the GraphQL query in JSON, so 
# we need to escape it accordingly. 

# However, ConvertTo-Json converts newlines to \r\n, 
# which the API endpoints fail to parse... 

# https://developer.github.com/v4/guides/forming-calls/#communicating-with-graphql

# So, first we remove newlines and multiple spaces
$queryJson = $graphql `
    -replace "[\r\n]+", " " `
    -replace "\s{2,}", " "

# The API request body is a JSON wrapper, with a
# 'query' property containing the actual query
$body = '{ "query": ' + (ConvertTo-Json $queryJson) + '}'

function Write-Divider {
    Write-Host "-----------------------------------------"
}     

try {
    $response = Invoke-WebRequest `
        -Uri 'https://api.github.com/graphql' `
        -Method POST `
        -Headers $headers `
        -Body $body

    $responseJson = (ConvertFrom-Json $response)

    $repos = $responseJson.data.user.repositories.nodes

    $repos | ForEach {
        $name = $_.name

        $mirrorPath = "$BackupFolderPath\$name.git"

        # Check if the repository already exists; if it does, 
        # we'll need to call a different git command
        $exists = Test-Path -Path $mirrorPath

        Write-Host ""

        if ($exists) {
            "Updating $name"
            Write-Divider
            cd $mirrorPath
            git remote update
            Write-Divider
        } else {
            "Cloning $name"
            Write-Divider
            cd $BackupFolderPath
            git clone $_.url --mirror
            Write-Divider
        }
    }
} finally {
    # We've been cd'ing about all over the place, 
    # so go back to where we started
    cd $initialWorkingPath
}