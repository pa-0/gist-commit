#Require -Version 4.0

[hashtable] $headers = $null

function Add-VstsAuthorization {
    [CmdletBinding()]
    param (
        [Parameter(Position=0)]
        [ValidateNotNullOrEmpty()]
        [string] $Token
    )

    if (-not $Token -and (Test-Path "$PSScriptRoot\pat.txt")) {
        Write-Verbose "Reading personal access token from '$PSScriptRoot\pat.txt'"
        $Token = Get-Content "$PSScriptRoot\pat.txt"
    }

    if (-not $Token) {
        throw 'Personal access token is required to log in.'
    }

    $buffer = [Text.Encoding]::ASCII.GetBytes(":$Token")
    $token = [Convert]::ToBase64String($buffer)

    $script:headers = @{'Authorization' = "Basic $token"}
}

function Test-VstsAuthorization {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch] $Fail
    )

    $result = $script:headers.Authorization -ne $null

    # Attempt to automatically log in.
    if (-not $result -and (Test-Path "$PSScriptRoot\pat.txt")) {
        Write-Verbose 'Attempting to automatically log in from stored personal access token'

        Add-VstsAuthorization
        $result = $script:headers.Authorization -ne $null
    }

    if ($Fail) {
        if (-not $result) {
            throw 'User not authorized. Pass authentication token to Add-VstsAuthorization'
        }
    } else {
        $result
    }
}

New-Variable -Name VstsDebugOutputPreference -Value $false -Description 'Whether to save the raw JSON response to a temporary file.'

function Invoke-VstsMethod {
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $Uri,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Method = 'GET'
    )

    if ($VstsDebugOutputPreference) {
        $path = [System.IO.Path]::GetTempFileName()
        $path = [System.IO.Path]::ChangeExtension($path, '.json')

        $PSBoundParameters.Add('OutFile', $path)
        Write-Warning "Writing output to: $path"
    }

    Invoke-RestMethod -Headers $script:headers -ContentType 'application/json' -UseBasicParsing @PSBoundParameters

    if ($PSBoundParameters.ContainsKey('OutFile')) {
        Get-Content -Path $path | ConvertFrom-Json
    }
}

function Remove-VstsAuthorization {
    [CmdletBinding()]
    param ()

    $script:headers = $null
}

function Get-VstsProject {
    [CmdletBinding(SupportsPaging=$true)]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $Organization,

        [Parameter(Position=1, ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $ProjectName,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Version = '4.1'
    )

    Test-VstsAuthorization -Fail

    $url = if ($ProjectName) {
        "https://dev.azure.com/$Organization/_apis/projects/${ProjectName}?api-version=$Version"
    } else {
        "https://dev.azure.com/$Organization/_apis/projects?api-version=$Version"
    }

    $accuracy = 1.0
    if ($PSCmdlet.PagingParameters.First -lt [uint64]::MaxValue) {
        $accuracy = 0.0
        $url += '&$top=' + $PSCmdlet.PagingParameters.First
    }

    if ($PSCmdlet.PagingParameters.Skip) {
        $accuracy = 0.0
        $url += '&$skip=' + $PSCmdlet.PagingParameters.Skip
    }

    $result = Invoke-VstsMethod -Uri $url

    if ($PSCmdlet.PagingParameters.IncludeTotalCount) {
        $PSCmdlet.PagingParameters.NewTotalCount($result.count, $accuracy)
    }

    $value = if ($ProjectName) {
        $result
    } else {
        $result.value
    }

    if ($value) {
        $value `
            | Add-Member -MemberType NoteProperty -Name 'organization' -Value $Organization -PassThru `
            | Add-Member -MemberType AliasProperty -Name 'projectName' -Value 'name' -PassThru
    }
}

function Get-VstsRelease {
    [CmdletBinding(SupportsPaging=$true)]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $Organization,

        [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $ProjectName,

        [Parameter(Position=2)]
        [ValidateNotNullOrEmpty()]
        [string] $ReleaseId,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $ReleaseDefinitionId,

        [Parameter()]
        [string] $SourceBranch,

        [Parameter()]
        [ValidateSet('Abandoned', 'Active', 'Draft')]
        [string] $Status,

        [Parameter()]
        [ValidateSet('Approvals', 'Artifacts', 'Environments', 'ManualInterventions', 'None', 'Tags', 'Variables')]
        [string[]] $Expand = 'None',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Version = '4.1-preview.6'
    )

    Test-VstsAuthorization -Fail

    $url = if ($ReleaseId) {
        "https://vsrm.dev.azure.com/$Organization/$ProjectName/_apis/release/releases/${ReleaseId}?api-version=$Version"
    } else {
        "https://vsrm.dev.azure.com/$Organization/$ProjectName/_apis/release/releases?api-version=$Version"
    }

    if ($ReleaseDefinitionId) {
        $url += "&definitionId=$ReleaseDefinitionId"
    }

    if ($SourceBranch) {
        $url += "&sourceBranchFilter=$SourceBranch"
    }

    if ($Status) {
        $url += '&statusFilter=' + ($Status -join ',')
    }

    if ($Expand -ne 'None') {
        $url += '&$expand=' + ($Expand -join ',')
    }

    $accuracy = 1.0
    if ($PSCmdlet.PagingParameters.First) {
        $accuracy = 0.0
        $url += '&$top=' + $PSCmdlet.PagingParameters.First
    }

    $result = Invoke-VstsMethod -Uri $url

    if ($PSCmdlet.PagingParameters.IncludeTotalCount) {
        $PSCmdlet.PagingParameters.NewTotalCount($result.count, $accuracy)
    }

    $value = if ($ReleaseId) {
        $result
    } else {
        $result.value
    }

    if ($value) {
        $value `
            | Add-Member -MemberType NoteProperty -Name 'organization' -Value $Organization -PassThru `
            | Add-Member -MemberType NoteProperty -Name 'projectName' -Value $ProjectName -PassThru `
            | Add-Member -MemberType ScriptProperty -Name 'releaseDefinitionId' -Value {$this.releaseDefinition.id} -PassThru `
            | Add-Member -MemberType AliasProperty -Name 'releaseId' -Value 'id' -PassThru
    }
}

function Get-VstsReleaseDefinition {
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $Organization,

        [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $ProjectName,

        [Parameter(Position=2)]
        [ValidateNotNullOrEmpty()]
        [string] $ReleaseDefinitionId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Version = '4.1-preview.3'
    )

    Test-VstsAuthorization -Fail

    $url = if ($ReleaseDefinitionId) {
        "https://vsrm.dev.azure.com/$Organization/$ProjectName/_apis/release/definitions/${ReleaseDefinitionId}?api-version=$Version"
    } else {
        "https://vsrm.dev.azure.com/$Organization/$ProjectName/_apis/release/definitions?api-version=$Version"
    }

    $result = Invoke-VstsMethod -Uri $url

    $value = if ($ReleaseDefinitionId) {
        $result
    } else {
        $result.value
    }

    if ($value) {
        $value `
            | Add-Member -MemberType NoteProperty -Name 'organization' -Value $Organization -PassThru `
            | Add-Member -MemberType NoteProperty -Name 'projectName' -Value $ProjectName -PassThru `
            | Add-Member -MemberType AliasProperty -Name 'releaseDefinitionId' -Value 'id' -PassThru
    }
}

function Get-VstsRepository {
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $Organization,

        [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $ProjectName,

        [Parameter(Position=2)]
        [string] $RepositoryId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Version = '4.1'
    )

    Test-VstsAuthorization -Fail

    $url = if ($RepositoryId) {
        "https://dev.azure.com/$Organization/$ProjectName/_apis/git/repositories/${RepositoryId}?api-version=$Version"
    } else {
        "https://dev.azure.com/$Organization/$ProjectName/_apis/git/repositories?api-version=$Version"
    }

    $result = Invoke-VstsMethod -Uri $url

    $value = if ($RepositoryId) {
        $result
    } else {
        $result.value
    }

    if ($value) {
        $value `
            | Add-Member -MemberType NoteProperty -Name 'organization' -Value $Organization -PassThru `
            | Add-Member -MemberType NoteProperty -Name 'projectName' -Value $ProjectName -PassThru `
            | Add-Member -MemberType AliasProperty -Name 'repositoryId' -Value 'id' -PassThru
    }
}

function Get-VstsBuild {
    [CmdletBinding(DefaultParameterSetName='BuildDefinition', SupportsPaging=$true)]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $Organization,

        [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $ProjectName,

        [Parameter(ParameterSetName='Build', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='BuildDefinition', Position=2, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateRange(0, [int]::MaxValue)]
        [int[]] $BuildDefinitionId,

        [Parameter(ParameterSetName='Build', Mandatory=$true, Position=2, ValueFromPipelineByPropertyName=$true)]
        [ValidateRange(0, [int]::MaxValue)]
        [int] $BuildId,

        [Parameter(ParameterSetName='BuildDefinition')]
        [ValidatePattern('^\w+(.\w)*@\w+(.\w+)+$')]
        [string] $RequestedFor,

        [Parameter(ParameterSetName='BuildDefinition')]
        [datetime] $MinTime,

        [Parameter(ParameterSetName='BuildDefinition')]
        [datetime] $MaxTime,

        [Parameter(ParameterSetName='BuildDefinition')]
        [ValidateSet('All', 'Manual', 'IndividualCI', 'BatchedCI', 'Schedule', 'UserCreated', 'ValidateShelveset', 'CheckInShelveset', 'Triggered', 'BuildCompletion', 'PullRequest')]
        [string] $Reason,

        [Parameter(ParameterSetName='BuildDefinition')]
        [ValidateSet('Succeeded', 'PartiallySucceeded', 'Failed', 'Canceled')]
        [string] $Result,

        [Parameter(ParameterSetName='BuildDefinition')]
        [ValidateSet('All', 'InProgress', 'Completed', 'Cancelling', 'Postponed', 'NotStarted')]
        [string] $Status,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]] $Property,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Version = '4.1'
    )

    begin {
        Test-VstsAuthorization -Fail

        $projects = New-Object -TypeName 'System.Collections.Generic.Dictionary[string, [System.Collections.Generic.HashSet[string]]]'
    }

    process {
        $url = "https://dev.azure.com/$Organization/$ProjectName/_apis/build/builds"

        if ($PSCmdlet.ParameterSetName -eq 'BuildDefinition') {
            if (-not $projects.ContainsKey($url)) {
                $value = New-Object -TypeName 'System.Collections.Generic.HashSet[string]' -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
                $projects.Add($url, $value)
            }

            foreach ($definitionId in $BuildDefinitionId) {
                $null = $projects[$url].Add($definitionId)
            }
        } else {
            $url += "/${BuildId}?api-version=$Version"

            $value = Invoke-VstsMethod -Uri $url

            if ($value) {
                $value `
                    | Add-Member -MemberType NoteProperty -Name 'organization' -Value $Organization -PassThru `
                    | Add-Member -MemberType NoteProperty -Name 'projectName' -Value $ProjectName -PassThru `
                    | Add-Member -MemberType ScriptProperty -Name 'buildDefinitionId' -Value {$this.definition.id} -PassThru `
                    | Add-Member -MemberType AliasProperty -Name 'buildId' -Value 'id' -PassThru
            }
        }
    }

    end {
        foreach ($url in $projects.Keys) {
            $key = $url
            $url += "?api-version=$Version"

            if ($projects[$key].Count) {
                $url += '&definitions=' + ($projects[$key] -join ',')
            }

            if ($RequestedFor) {
                $url += "&requestedFor=$RequestedFor"
            }

            if ($MinFinishTime) {
                $url += '&minTime=' + $MinTime.ToUniversalTime().ToString('o')
            }

            if ($MaxFinishTime) {
                $url += '&maxTime=' + $MaxTime.ToUniversalTime().ToString('o');
            }

            if ($Reason) {
                $url += "&reasonFilter=$Reason"
            }

            if ($Result) {
                $url += "&resultFilter=$Result"
            }

            if ($Status) {
                $url += "&statusFilter=$Status"
            }

            if ($Property) {
                $url += '&propertyFilters=' + ($Property -join ',')
            }

            $accuracy = 1.0
            if ($PSCmdlet.PagingParameters.First) {
                $accuracy = 0.0
                $url += '&$top=' + $PSCmdlet.PagingParameters.First
            }

            $response = Invoke-VstsMethod -Uri $url

            if ($PSCmdlet.PagingParameters.IncludeTotalCount) {
                $PSCmdlet.PagingParameters.NewTotalCount($response.count, $accuracy)
            }

            if ($response.value) {
                $response.value `
                    | Add-Member -MemberType NoteProperty -Name 'organization' -Value $Organization -PassThru `
                    | Add-Member -MemberType NoteProperty -Name 'projectName' -Value $ProjectName -PassThru `
                    | Add-Member -MemberType ScriptProperty -Name 'buildDefinitionId' -Value {$this.definition.id} -PassThru `
                    | Add-Member -MemberType AliasProperty -Name 'buildId' -Value 'id' -PassThru
            }
        }
    }
}

function Get-VstsBuildDefinition {
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $Organization,

        [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $ProjectName,

        [Parameter(Position=2, ValueFromPipelineByPropertyName=$true)]
        [ValidateRange(0, [int]::MaxValue)]
        [int] $BuildDefinitionId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string] $RepositoryId,

        [Parameter()]
        [switch] $IncludeLatesetBuilds,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]] $Property,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Version = '4.1'
    )

    Test-VstsAuthorization -Fail

    $url = if ($BuildDefinitionId) {
        "https://dev.azure.com/$Organization/$ProjectName/_apis/build/definitions/${BuildDefinitionId}?api-version=$Version"
    } else {
        "https://dev.azure.com/$Organization/$ProjectName/_apis/build/definitions?api-version=$Version"
    }

    if ($Name) {
        $url += "&name=$Name"
    }

    if ($RepositoryId) {
        $url += "&repositoryId=$RepositoryId&repositoryType=git"
    }

    if ($IncludeLatesetBuilds) {
        $url += "&includeLatestBuilds=true"
    }

    if ($Property) {
        $url += '&propertyFilters=' + ($Property -join ',')
    }

    $result = Invoke-VstsMethod -Uri $url

    $value = if ($BuildDefinitionId) {
        $result
    } else {
        $result.value
    }

    if ($value) {
        $value `
            | Add-Member -MemberType NoteProperty -Name 'organization' -Value $Organization -PassThru `
            | Add-Member -MemberType NoteProperty -Name 'projectName' -Value $ProjectName -PassThru `
            | Add-Member -MemberType AliasProperty -Name 'buildDefinitionId' -Value 'id' -PassThru
    }
}

function Get-VstsBuildTimeline {
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $Organization,

        [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $ProjectName,

        [Parameter(Position=2, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateRange(0, [int]::MaxValue)]
        [int] $BuildId,

        [Parameter(Position=3)]
        [ValidateNotNullOrEmpty()]
        [string] $BuildTimelineId,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Version = '4.1'
    )

    Test-VstsAuthorization -Fail

    $url = if ($BuildTimelineId) {
        "https://dev.azure.com/$Organization/$ProjectName/_apis/build/builds/$BuildId/timeline/${BuildTimelineId}?api-version=$Version"
    } else {
        "https://dev.azure.com/$Organization/$ProjectName/_apis/build/builds/$BuildId/timeline?api-version=$Version"
    }

    $result = Invoke-VstsMethod -Uri $url

    $value = if ($BuildTimelineId) {
        $result
    } else {
        $result.records
    }

    if ($value) {
        $BuildTimelineId = $result.id

        $value `
            | Add-Member -MemberType NoteProperty -Name 'organization' -Value $Organization -PassThru `
            | Add-Member -MemberType NoteProperty -Name 'projectName' -Value $ProjectName -PassThru `
            | Add-Member -MemberType NoteProperty -Name 'timelineId' -Value $BuildTimelineId -PassThru
    }
}

function Get-VstsPullRequest {
    [CmdletBinding(DefaultParameterSetName='ProjectName')]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $Organization,

        [Parameter(ParameterSetName='ProjectName', Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $ProjectName,

        [Parameter(ParameterSetName='PullRequestId', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $PullRequestId,

        [Parameter(ParameterSetName='ProjectName', ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $RepositoryId,

        [Parameter(ParameterSetName='ProjectName')]
        [ValidateSet('All', 'Active', 'Abandoned', 'Completed')]
        [string] $Status = 'Active',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Version = '4.1'
    )

    Test-VstsAuthorization -Fail

    $url = if ($PullRequestId) {
        "https://dev.azure.com/$Organization/_apis/git/pullrequests/${PullRequestId}?api-version=$Version"
    } elseif ($RepositoryId) {
        "https://dev.azure.com/$Organization/$ProjectName/_apis/git/pullrequests?api-version=$Version"
    } else {
        "https://dev.azure.com/$Organization/$ProjectName/_apis/git/repositories/$RepositoryId/pullrequests?api-version=$Version"
    }

    $result = Invoke-VstsMethod -Uri $url

    $value = if ($PullRequestId) {
        $result
    } else {
        $result.value
    }

    if ($value) {
        $value `
            | Add-Member -MemberType NoteProperty -Name 'organization' -Value $Organization -PassThru `
            | Add-Member -MemberType NoteProperty -Name 'projectName' -Value $ProjectName -PassThru `
            | Add-Member -MemberType ScriptProperty -Name 'repositoryId' -Value {$this.repository.id} -PassThru
    }
}

function Get-VstsWorkItem {
    [CmdletBinding(DefaultParameterSetName='Account')]
    param (
        [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $Organization,

        [Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string] $ProjectName,

        [Parameter(Position=2, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [int[]] $Id,

        [Parameter()]
        [string[]] $Field,

        [Parameter()]
        [datetime] $AsOf,

        [Parameter()]
        [ValidateSet('All', 'Relations', 'None', 'Fields', 'Links')]
        [string] $Expand = 'None',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $Version = '4.1'
    )

    Test-VstsAuthorization -Fail

    $url = if ($Id.Count -eq 1) {
        "https://dev.azure.com/$Organization/$ProjectName/_apis/wit/workitems/${Id}?api-version=$Version"
    } else {
        "https://dev.azure.com/$Organization/$ProjectName/_apis/wit/workitems?ids=$($Id -join ',')&api-version=$Version"
    }

    if ($Field) {
        $url += '&fields=' + ($Field -join ',')
    }

    if ($AsOf) {
        $url += '&asOf=' + $AsOf.ToUniversalTime().ToString('o')
    }

    if ($Expand) {
        $url += '&$expand=' + ($Expand -join ',')
    }

    $result = Invoke-VstsMethod -Uri $url

    $value = if ($Id.Count -eq 1) {
        $result
    } else {
        $result.value
    }

    if ($value) {
        $value `
            | Add-Member -MemberType NoteProperty -Name 'organization' -Value $Organization -PassThru `
            | Add-Member -MemberType NoteProperty -Name 'projectName' -Value $ProjectName -PassThru
    }
}

Export-ModuleMember -Variable VstsDebugOutputPreference -Function *
