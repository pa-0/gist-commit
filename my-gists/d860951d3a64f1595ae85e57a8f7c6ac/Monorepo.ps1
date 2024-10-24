function New-Monorepo
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, Position=0)]
        [string] $Path
    )

    Process
    {
        pushd (Resolve-Path $Path)

        Get-ChildItem -Force |
        ? { $_.PsIsContainer -eq $true -and $_.Name -ne ".git" } |
        `
        Get-ChildItem -Recurse -Force |
        ? { $_.PsIsContainer -eq $true -and $_.Name -eq ".git" } |
        % { git config --local --add allRepos.repo $_.parent.FullName }

        git config --local alias.monorepo "for-each-repo --config=allRepos.repo"

        popd
    }
}

function Save-BranchState
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, Position=0)]
        [string] $Monorepo,

        [Parameter(Mandatory, Position=1)]
        [string] $OutFile
    )

    Process
    {
        pushd (Resolve-Path $Monorepo)

        $Repos = git monorepo rev-parse --show-toplevel | % { Resolve-Path -Relative $_ }
        $Branches = git monorepo rev-parse --abbrev-ref HEAD

        [System.Linq.Enumerable]::Zip([string[]]$Repos, [string[]]$Branches, [Func[string, string, object]] {
            param($a, $b)
            [PsCustomObject]@{
                Repo = $a
                Branch = $b
            }
        }) |
        ConvertTo-Csv -NoTypeInformation |
        Out-File $OutFile -Encoding ascii -Force

        popd
    }
}

function Import-BranchState
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, Position=0)]
        [string] $Monorepo,

        [Parameter(Mandatory, Position=1)]
        [string] $InFile
    )

    Process
    {
        pushd (Resolve-Path $Monorepo)

        Get-Content -Encoding ascii (Resolve-Path $InFile) |
        ConvertFrom-Csv |
        % { 
            git -C $_.Repo fetch
            git -C $_.Repo checkout $_.Branch
        }

        popd
    }
}
