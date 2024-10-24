
Param (
    [switch]$Sort
)

. ".\helpers.ps1"
. ".\ellipsis.ps1"

workflow Process-InWorkflow {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)] [PSObject[]]$InputObject,
        [parameter(Mandatory=$true)] [ScriptBlock]$ScriptBlock,
        [int]$ThrottleLimit = 8,
        $AdditionalArguments
        )
    $location = Get-Location
    $ProgressPreference="SilentlyContinue"
    ForEach -Parallel -ThrottleLimit $ThrottleLimit ($item in $Input)
    {
        InlineScript {
            # InlineScript runs in different environment, but I need at least working directory to be the same.
            Set-Location $Using:location
            # In some cases arguments passed as strings (Remoting, Jobs, InlineScripts).
            # There is no way to deal with it other than to recreate ScriptBlock from string.
            $sb2 = [ScriptBlock]::Create($Using:ScriptBlock);
            Invoke-Command -ScriptBlock $sb2 -ArgumentList $Using:item,$Using:AdditionalArguments
        }
    }
    $progressPreference = 'Continue'
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
    Process-InWorkflow -ThrottleLimit $numberOfCores `
                       -AdditionalArguments $ExtObject `
                       -ScriptBlock ${function:Optimize-File} |
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
