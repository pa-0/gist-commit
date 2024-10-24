
Param (
    [switch]$Sort
)

. ".\helpers.ps1"
. ".\ellipsis.ps1"

$jpegExtensions = ".jpg", ".jpeg"
$pngExtensions = ,".png"
$textExtensions = ".css", ".htm", ".html", ".js", ".json", ".svg", ".xml"
$allExtensions = $jpegExtensions + $pngExtensions + $textExtensions

$optimizeFile = {
    $InputFile = $_
    
    $path = $InputFile.FullName
    $ext = $InputFile.Extension
    $fromSize = $InputFile.length
    if( $ext -in $Using:jpegExtensions )
    {
        & jpegtran.exe -copy none -optimize -progressive -outfile "$path" "$path"
    }
    if( $ext -in $Using:pngExtensions )
    {
        & optipng.exe -quiet -o3 -clobber "$path"
    }
    if( $ext -in $Using:textExtensions )
    {
        & minify.exe --html-keep-whitespace -o "$path" "$path"
    }
    $toSize = (Get-Item $path).length
    [PSCustomObject]@{
        Name=$InputFile.Name;
        From=$fromSize;
        To=$toSize;
        Path=($InputFile.FullName | Resolve-Path -Relative);
        Folder=($InputFile.Directory | Resolve-Path -Relative);
        Ext=$ext
        }
}

$numberOfCores = (Get-WmiObject -class Win32_processor).NumberOfLogicalProcessors
$Activity = "Minifying files"

$colW = 12
$firstColW = $(get-host).UI.RawUI.BufferSize.Width - 1 - ($colW+1)*4

$allFiles = Get-ChildItem -Path .\public -Recurse -File | Where Extension -in $allExtensions
$numberOfFiles = $allFiles.Count

if($Sort) {
    $allFiles = $allFiles | Sort-Object -Property length -Descending
}

$allFiles |
    Start-RSJob -ScriptBlock $optimizeFile -Throttle $numberOfCores |
    Wait-RSJob |
    Receive-RSJob |
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
