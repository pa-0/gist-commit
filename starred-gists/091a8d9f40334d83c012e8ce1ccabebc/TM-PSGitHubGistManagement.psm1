using namespace System
using namespace System.IO
using namespace System.Management.Automation


function Get-GistScript {
<#
    .SYNOPSIS
    Downloads the contents of a specified GitHub Gist file.

    .PARAMETER GistUri
    The GitHub Gist URL.

    .PARAMETER FileName
    The file to select from within the Gist.
#>
    [CmdletBinding()]
    [OutputType([Void])]
    param (
        [Parameter(Mandatory)]
        [Validation.ValidateGistUriFormatAttribute()]
        [string]$GistUri,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$FileName
    )

    if ($GistUri -match '/(?<guid>[a-zA-Z0-9]{32})$') {
        $GistUri = "https://api.github.com/gists/$($matches.guid)"
    }
    $gist = Invoke-RestMethod $gistUri -ErrorAction Stop

    return $gist.Files.$FileName.Content
}


function Update-GistScript {
<#
    .SYNOPSIS
    Updates a local script file with the content of a GitHub Gist.

    .DESCRIPTION
    Compares the local script version number to the version in the remote Gist, and updates the local script
    if the Gist version is newer.

    .PARAMETER Path
    Local script file path

    .PARAMETER ScriptPath
    Full path of the local script file (Alias: FullName)

    .OUTPUTS
    Returns a boolean value indicating whether the local Gist script has been updated.
#>
    [CmdletBinding()]
    [OutputType([Boolean])]
    param (
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'FileInfo',
            Position = 0
        )]
        [Validation.ValidatePathExists('File')]
        [FileInfo]$Path,

        [Alias('FullName')]
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ParameterSetName = 'String',
            ValueFromPipelineByPropertyName,
            Position = 0
        )]
        [Validation.ValidatePathExists('File')]
        [string]$ScriptPath
    )

    begin {
        $projectUriRegEx = '\.PROJECTURI\r?\n\s*(?<ProjectUri>https?:.*)'
        $versionRegEx = '\.VERSION\r?\n\s*(?<Version>\d+\.\d+\.\d+)'
        $FilePath = switch ($PSCmdlet.ParameterSetName) {
            'String' { $ScriptPath }
            'FileInfo' { $Path.FullName }
        }
        $FileName = [Path]::GetFileName($FilePath)
    }

    process {
        [string]$BadVerNum = '0.0.0'
        [string]$ScriptContent = [IO.File]::ReadAllText($FilePath)
        [version]$currentVersion = if ($ScriptContent -match $versionRegEx) { $matches.Version } else { $BadVerNum }
        [string]$projectUri = [string]::Empty
        if ($ScriptContent -match $projectUriRegEx) { $projectUri = $matches.ProjectUri.Trim() }

        if ($projectUri -ne [string]::Empty) {
            try {
                $gistScript = Get-GistScript -GistUri $projectUri -FileName $FileName
                [version]$gistVersion = if ($gistScript -match $versionRegEx) { $matches.Version } else { $BadVerNum }

                if ($gistVersion -gt $currentVersion) {
                    Microsoft.PowerShell.Utility\Write-Host (
                        "Updating '$FileName' from v$currentVersion to v$gistVersion."
                    )
                    Set-Content -Path $FilePath -Value $gistScript
                    return $true
                } elseif ($gistVersion -eq $BadVerNum) {
                    Microsoft.PowerShell.Utility\Write-Warning (
                        "Unsuccessful gist version parse. v$gistVersion in '$FilePath' is invalid."
                    )
                } elseif ($gistVersion -lt $currentVersion) {
                    Microsoft.PowerShell.Utility\Write-Host (
                        "Local copy of '$FileName' is v$currentVersion which is newer than the gist (v$gistVersion). " +
                        "Don't forget to update the gist when you're done editing!"
                    )
                }
            } catch {
                Microsoft.PowerShell.Utility\Write-Warning "Failed to update gist. Error: $($_.Exception.Message)"
            }
        } else {
            Microsoft.PowerShell.Utility\Write-Warning (
                "'$FilePath' does not contain the required ProjectUri, or it is in an invalid format."
            )
        }
        return $false
    }
}


function Start-BackgroundGistScriptUpdate {
<#
    .SYNOPSIS
    Starts a background job to update the specified Gist script.

    .DESCRIPTION
    Initiates a background job to update a PowerShell script from the GitHub Gist URL mentioned in the PROJECTURI field
    of the ScriptFileInfo header.

    .PARAMETER LocalScriptPath
    Specifies the path to the local Gist script that needs to be updated.

    .NOTES
    This function requires internet access to reach the gist URL.
#>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.Job])]
    param (
        [Parameter(Mandatory)]
        [Validation.ValidatePathExists('File')]
        [string]$LocalScriptPath
    )

    # Get the file item from the local script path
    $ScriptPath = Get-Item -Path $LocalScriptPath -ErrorAction Stop

    # Create parameters for the job or thread that will be started
    $UpdateGistJobParams = [hashtable]@{
        Name         = "Update Gist Script - $($ScriptPath.Name)"
        ArgumentList = @($ScriptPath.FullName)
        ScriptBlock  = {
            param ($LocalScriptPath)
            . ([ScriptBlock]::Create('using module TM-ValidationUtility'))
            Import-Module -Name TM-PSGitHubGistManagement
            # Call the Update-GistScript function if the local script path is valid
            Update-GistScript -ScriptPath $LocalScriptPath | Out-Null # Ignore the boolean return
        }
    }

    # Create the job or thread depending on the PowerShell edition
    $Job = if ($PSVersionTable.PSEdition -eq 'Desktop') {
        Start-Job @UpdateGistJobParams
    } else {
        Start-ThreadJob @UpdateGistJobParams
    }

    return $Job
}
