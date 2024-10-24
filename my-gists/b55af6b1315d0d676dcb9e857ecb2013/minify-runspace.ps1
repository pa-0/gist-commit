
Param (
    [switch]$Sort
)

. ".\helpers.ps1"
. ".\ellipsis.ps1"

function Process-InRunspaces {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)] [PSObject[]]$InputObject,
        [parameter(Mandatory=$true)] [ScriptBlock]$ScriptBlock,
        [int]$MaxThreads = 8,
        $SleepTimer = 10,
        $AdditionalArguments
        )
    $location = Get-Location
    $rsPool = [RunspaceFactory]::CreateRunspacePool(1,$MaxThreads)
    $rsPool.Open()
    $RunspaceCollection = @()
    ForEach ($item in $Input) {
        $Powershell = [PowerShell]::Create()
        $Powershell.AddCommand("Set-Location").AddArgument($location) | Out-Null
        $Powershell.AddScript($ScriptBlock) | Out-Null
        $Powershell.AddArgument($item) | Out-Null
        ForEach ($arg in $AdditionalArguments) {
            $Powershell.AddArgument($arg) | Out-Null
        }
        $Powershell.RunspacePool = $rsPool
        $Runspace = $PowerShell.BeginInvoke()
        [Collections.Arraylist]$RunspaceCollection += [PSCustomObject]@{
            Runspace = $Runspace;
            PowerShell = $PowerShell
        }
    }
    While ($RunspaceCollection) {
        Foreach ($Runspace in $RunspaceCollection.ToArray()) {
            If ($Runspace.Runspace.IsCompleted) {
                $result = $Runspace.PowerShell.EndInvoke($Runspace.Runspace)
                $result # just to make it clear that we output result here
                
                $Runspace.PowerShell.Dispose()
                $RunspaceCollection.Remove($Runspace)
            }
        }
        Start-Sleep -Milliseconds $SleepTimer
    }
}

$jpegExtensions = ".jpg", ".jpeg"
$pngExtensions = ,".png"
$textExtensions = ".css", ".htm", ".html", ".js", ".json", ".svg", ".xml"
$allExtensions = $jpegExtensions + $pngExtensions + $textExtensions
$ExtObject = [PSCustomObject]@{
    JpegExtensions=$jpegExtensions;
    PngExtensions=$pngExtensions;
    TextExtensions=$textExtensions
}

function Optimize-File($InputFile, $ExtObject) {
    $path = $InputFile.FullName
    $ext = $InputFile.Extension
    $fromSize = $InputFile.length
    if( $ext -in $ExtObject.JpegExtensions )
    {
        & jpegtran.exe -copy none -optimize -progressive -outfile "$path" "$path"
    }
    if( $ext -in $ExtObject.PngExtensions )
    {
        & optipng.exe -quiet -o3 -clobber "$path"
    }
    if( $ext -in $ExtObject.TextExtensions )
    {
        & minify.exe --html-keep-whitespace -o "$path" "$path"
    }
    $toSize = (Get-Item $path).length
    return [PSCustomObject]@{
        Name=$InputFile.Name;
        From=$fromSize;
        To=$toSize;
        Path=($InputFile.FullName | Resolve-Path -Relative);
        Folder=($InputFile.Directory | Resolve-Path -Relative);
        Ext=$ext
        }
}

$numberOfCores = (Get-WmiObject -class Win32_processor).NumberOfLogicalProcessors

$colW = 12
$firstColW = $(get-host).UI.RawUI.BufferSize.Width - 1 - ($colW+1)*4

$allFiles = Get-ChildItem -Path .\public -Recurse -File | Where Extension -in $allExtensions
$numberOfFiles = $allFiles.Count

if($Sort) {
    $allFiles = $allFiles | Sort-Object -Property length -Descending
}

$allFiles |
    Process-InRunspaces -MaxThreads $numberOfCores `
                        -ScriptBlock ${function:Optimize-File} `
                        -AdditionalArguments $ExtObject |
    Show-Progress -Activity "Minifying files" -TotalItems $numberOfFiles |
    tee -Variable results |
    Format-Table -Property @{ Label="Path"; Width=$firstColW; `
                              Expression={Format-Ellipsis $_.Path $firstColW} },
                           @{ Label="From"; Width=$colW; Expression={$_.From} },
                           @{ Label="To"; Width=$colW; Expression={$_.To} },
                           @{ Label="Saved"; Alignment="Right"; Width=$colW; `
                              Expression={"{0}" -f ($_.From - $_.To)} },
                           @{ Label="Percentage"; Alignment="Right"; Width=$colW; `
                              Expression={"{0:P1}" -f ($_.To/$_.From)} }

Draw-Line
""
"   Totals"

$results |
    Group-Object { $_.Ext } |
    Select-Object -Property Count,
                            @{ Name = "Extension"; Expression = {$_.Name} },
                            @{ Name = "From"; `
                               Expression = {($_.Group | Measure-Object -Property From -Sum).Sum} },
                            @{ Name = "To"; `
                               Expression = {($_.Group | Measure-Object -Property To -Sum).Sum} } |
    Format-Table -Property @{ Label="Extension"; Width=$firstColW-$colW-1;
                              Expression={$_.Extension} },
                           @{ Label="Count"; Width=$colW; Expression={$_.Count} },
                           @{ Label="From"; Width=$colW; Expression={$_.From} },
                           @{ Label="To"; Width=$colW; Expression={$_.To} },
                           @{ Label="Saved"; Alignment="Right"; Width=$colW; `
                              Expression={"{0}" -f ($_.From - $_.To)} },
                           @{ Label="Percentage"; Alignment="Right"; Width=$colW; `
                              Expression={"{0:P1}" -f ($_.To/$_.From)} }
