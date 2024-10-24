function ConvertTo-MarkdownTable {
    param($targetData)

    $names = $targetData[0].psobject.Properties.name     

    $all = @()
    1..$names.count | foreach {
        if($_ -eq $names.count) {
            $all += '|'
        } else {
            $all += '|---'
        }
    }

    $result = foreach($record in $targetData) {
        $inner=@()
        foreach($name in $names) {        
            $inner+=$record.$name
        }        
        '|' + ($inner -join '|') + '|' + "`n"
    }
    
@"
$('|' + ($names -join '|') + '|')
$($all)
$($result)
"@ | ConvertFrom-Markdown | % html | Get-HtmlContent | Out-Display
}