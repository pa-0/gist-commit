$parts = @()
$max=0

foreach($file in (dir c:\temp -r)) {    
    $parts += ,$file.FullName.split("\")
    $count = $parts[-1].Count 
    if($count -gt $max) {$max=$count}
}

$data = foreach ($part in $parts) {
    $h=[ordered]@{}
    for ($i = 0; $i -lt $max; $i++) { 
        $h["PropertyName$($i)"]=''
    }

    $count = $part.Count 
    for ($i = 0; $i -lt $count; $i++) {
        $h["PropertyName$($i)"]=$part[$i]
    }

    [pscustomobject]$h
}


$xlfile = "$env:TEMP\parts.xlsx"
rm $xlfile -ErrorAction SilentlyContinue

Export-Excel -InputObject $data -Path $xlfile -AutoSize -Show