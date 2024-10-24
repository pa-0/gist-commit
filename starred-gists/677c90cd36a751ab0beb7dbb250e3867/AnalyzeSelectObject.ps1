using namespace System.Management.Automation.Language

param([string]$Path)

$Path = Resolve-Path $Path | % Path

function AnalyzeSelectObjectUsage
{
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$FullName)

    process {
        $err = $null
        $tokens = $null
        $ast = [Parser]::ParseFile($FullName, [ref]$tokens, [ref]$err)

        $selectObjectCommands = $ast.FindAll({ $n = $args[0]; $n -is [CommandAst] -and $n.GetCommandName() -eq 'Select-Object'}, $true)
        if ($selectObjectCommands.Count -eq 0)
        {
            # The string 'Select-Object' was in the script, but not used as a command name.
            return [pscustomobject]@{UsesSelectObject = $false; FileName = $FullName; NeedManualInspection = $false; BreakingCase = $false; Line = -1 }
        }

        foreach ($selectObjectCommand in $selectObjectCommands)
        {
            $binding = [StaticParameterBinder]::BindCommand($selectObjectCommand, $true)
            if ($binding.BindingExceptions.Count -gt 0)
            {
                # Parameters were ambiguous, and the static parameter binder failed
                # (possibly because of too many positional arguments), so we need to manually inspect it
                [pscustomobject]@{UsesSelectObject = $true; FileName = $FullName; NeedManualInspection = $true; BreakingCase = $false; Line = $selectObjectCommand.Extent.StartLineNumber }
                continue
            }

            $hasProperty = $binding.BoundParameters.ContainsKey("Property")
            $hasExcludeProperty = $binding.BoundParameters.ContainsKey("ExcludeProperty")
            $hasExpandProperty = $binding.BoundParameters.ContainsKey("ExpandProperty")

            if (!$hasProperty -and $hasExcludeProperty -and $hasExpandProperty)
            {
                [pscustomobject]@{UsesSelectObject = $true; FileName = $FullName; NeedManualInspection = $false; BreakingCase = $true; Line = $selectObjectCommand.Extent.StartLineNumber }
            }
            else
            {
                [pscustomobject]@{UsesSelectObject = $true; FileName = $FullName; NeedManualInspection = $false; BreakingCase = $false; Line = $selectObjectCommand.Extent.StartLineNumber }
            }
        }
    }
}

dir $Path | AnalyzeSelectObjectUsage


<#
## in PS console, run the following to search 'Select-Object' in GitHub and download all relevant .ps1 files
Import-Module .\SearchGitHub.psm1 -Force
Search-GitHubCode Select-Object $cred -Extension ps1 -Verbose | Save-RelevantFile -DirectoryPath F:\temp\selectobject-dir-ps1 -Verbose
Search-GitHubCode Select-Object $cred -Extension psm1 -Verbose | Save-RelevantFile -DirectoryPath F:\temp\selectobject-dir-psm1 -Verbose

## Only the first 1000 results are available for each search. So I got:
## 571 unique .ps1 files downloaded at F:\temp\selectobject-dir-ps1
## 503 unique .psm1 files downloaded at F:\temp\selectobject-dir-psm1

## Analyze .ps1 files
$results_ps1 = .\AnalyzeSelectObject.ps1 -Path .\selectobject-dir-ps1\
$results_psm1 = .\AnalyzeSelectObject.ps1 -Path .\selectobject-dir-psm1\

## 1317 instances of Select-Object from 571 unique .ps1 files
## 2059 instances of Select-Object from 503 unique .psm1 files
PS:90> $results_ps1.Count
1317
PS:91> $results_psm1.Count
2059
PS:92> $results = $results_ps1 + $results_psm1

## FIND 2 usages like 'Select-Object -ExcludeProperty value -ExpandProperty value'
PS:96> $results | ? BreakingCase

UsesSelectObject     : True
FileName             : F:\temp\selectobject-dir-psm1\ECSNamespace.psm1
NeedManualInspection : False
BreakingCase         : True
Line                 : 48

UsesSelectObject     : True
FileName             : F:\temp\selectobject-dir-psm1\ECSvdc.psm1
NeedManualInspection : False
BreakingCase         : True
Line                 : 158

## 1 file need to be manually inspected, and no breaking usage in it
PS:99> $results | ? NeedManualInspection

UsesSelectObject     : True
FileName             : F:\temp\selectobject-dir-ps1\TraverseFSintoCSV.ps1
NeedManualInspection : True
BreakingCase         : False
Line                 : 3

## 31 files have 'Select-Object' commented out
PS:105> $results | ? UsesSelectObject -EQ $false | measure

Count    : 31
Average  :
Sum      :
Maximum  :
Minimum  :
Property :

## Manually check all of them, and found no breaking usage in them
$results | ? UsesSelectObject -EQ $false | % { Start-Process -FilePath (which gvim) -ArgumentList ($_.FileName) -Wait }
#>

