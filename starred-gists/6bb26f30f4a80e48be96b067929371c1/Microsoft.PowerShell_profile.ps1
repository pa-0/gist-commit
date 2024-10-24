$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile))
{
    Import-Module "$ChocolateyProfile"
}

# Import-Module gsudoModule

function Cake-Build
{
    dotnet tool restore && dotnet cake --verbosity=verbose --publish=true $args
}

function Git-CommitDateVersion
{
    $branch = git rev-parse --abbrev-ref HEAD
    if ($branch -eq "HEAD")
    {
        $branch = git name-rev --name-only --refs=refs/heads/* --no-undefined --always HEAD
    }
    $branchSlug = [System.Text.RegularExpressions.Regex]::Replace($branch.ToLowerInvariant(), "[^0-9a-z-]", "-").Trim('-')

    $defaultBranch = $($args[1] ?? "main")
    $isDefaultBranch = $branch -eq $defaultBranch
    $isReleaseBranch = $isDefaultBranch -or [System.Text.RegularExpressions.Regex]::IsMatch($branch, "^support/")

    $commit = git rev-parse $($args[0] ?? "HEAD")
    $baseCommit = !$isDefaultBranch ? (git merge-base $defaultBranch $commit) : $commit
    $commits = !$isDefaultBranch ? (git rev-list --count --first-parent "$baseCommit..$commit") : 0

    $commitDate = git -c log.showSignature=false show --format="%cI" -s $baseCommit
    $versionDate = [System.DateTimeOffset]::Parse($commitDate, $null, [System.Globalization.DateTimeStyles]::AdjustToUniversal)
    $versionDate = $versionDate.AddSeconds($isReleaseBranch ? $commits : 1)

    $version = $versionDate.ToString("yyMM.dHH.mss")
    $version = [System.Text.RegularExpressions.Regex]::Replace($version, "(?<=\.)0+(?=\d)", "")
    $version = $isReleaseBranch ? "$version+branch.$branchSlug.sha.$commit" : "$version-branch.$branchSlug.$commits+sha.$commit"
    $version
}

function Which-Command($command)
{
    $commandInfo = $command -is [System.Management.Automation.CommandInfo] ? $command : (Get-Command -Name $command -ErrorAction SilentlyContinue)
    if (!$commandInfo)
    {
        Write-Output "$command not found"
        return
    }

    switch ($commandInfo.CommandType)
    {
        "Alias"
        {
            $commandInfo | Format-List CommandType,DisplayName
            Write-Output "=>"
            Which-Command $commandInfo.ReferencedCommand
        }
        "Application"
        {
            $commandInfo | Format-List CommandType,Name,Path,Version,FileVersionInfo
        }
        "Cmdlet"
        {
            $path = @{ Name = "Path"; Expression = { $commandInfo.DLL } }
            $fileVersionInfo = @{ Name = "FileVersionInfo"; Expression = { [System.Diagnostics.FileVersionInfo]::GetVersionInfo($commandInfo.DLL) } }
            $commandInfo | Select-Object *,$path,$fileVersionInfo | Format-List CommandType,Name,Definition,HelpUri,Module,ImplementingType,Path,Version,FileVersionInfo
        }
        "Function"
        {
            $path = @{ Name = "Path"; Expression = { $commandInfo.ScriptBlock.File } }
            $commandInfo | Select-Object *,$path | Format-List CommandType,Name,Definition,Path
        }
        default
        {
            $commandInfo | Format-List *
        }
    }
}

$env:KUBECONFIG = $(Get-ChildItem ~/.kube | Where-Object { !$_.PSIsContainer -and $_.Name -match 'config[^.]*$' } | Sort-Object | Join-String -Separator ';')

New-Alias cake Cake-Build
New-Alias grep 'C:\Program Files\Git\usr\bin\grep.exe'
New-Alias less 'C:\Program Files\Git\usr\bin\less.exe'
New-Alias l ls
New-Alias ll ls
New-Alias msbuild 'C:\Program Files\Microsoft Visual Studio\2022\Preview\MSBuild\Current\Bin\MSBuild.exe'
New-Alias which Which-Command

Set-PSReadLineKeyHandler -Key End -Function AcceptSuggestion
# Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function AcceptNextSuggestionWord
Set-PSReadLineKeyHandler -Key Ctrl+u -Function BackwardKillLine
Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardKillWord
Set-PSReadLineKeyHandler -Key Tab -Function Complete
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Ctrl+k -Function KillLine
Set-PSReadLineKeyHandler -Key Alt+d -Function KillWord

Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -PredictionSource History

Invoke-Expression (&starship init powershell)
