
. ".\helpers.ps1"

$jpegExtensions = ".jpg", ".jpeg"
$pngExtensions = ,".png"
$textExtensions = ".css", ".htm", ".html", ".js", ".json", ".svg", ".xml"
$allExtensions = $jpegExtensions + $pngExtensions + $textExtensions

function Optimize-File([System.IO.FileInfo]$InputFile) {
    $path = $InputFile.FullName
    $ext = $InputFile.Extension
    $fromSize = $InputFile.length
    if( $ext -in $jpegExtensions )
    {
        & jpegtran.exe -copy none -optimize -progressive -outfile "$path" "$path"
    }
    if( $ext -in $pngExtensions )
    {
        & optipng.exe -quiet -o3 -clobber "$path"
    }
    if( $ext -in $textExtensions )
    {
        & minify.exe --html-keep-whitespace -o "$path" "$path"
    }
    $toSize = (Get-Item $path).length
    return [PSCustomObject]@{
        Name=$InputFile.Name;
        From=$fromSize;
        To=$toSize;
        Folder=($InputFile.Directory | Resolve-Path -Relative);
        Ext=$ext
        }
}

$colW = 12
$firstColW = $(get-host).UI.RawUI.BufferSize.Width - 1 - ($colW+1)*4

$allFiles = Get-ChildItem -Path .\public -Recurse -File | Where Extension -in $allExtensions
$numberOfFiles = $allFiles.Count

$allFiles |
    %{ Optimize-File $_ } |
    Show-Progress -Activity "Minifying files" -TotalItems $numberOfFiles |
    tee -Variable results |
    Format-Table -GroupBy Folder `
                 -Property @{ Label="Name"; Width=$firstColW; Expression={$_.Name} },
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
