$url="http://www.manning.com/jones2/"

(Invoke-WebRequest $url).links | where onclick -match 'free' | foreach {
    [PSCustomObject] @{
        innerHTML = $_.innerHTML
        FullHref = $url+$_.href
        href = $_.href
        url = $url
    } 
} | ForEach {
    $outFile = "c:\temp\$($_.href)"
    "Downloading $($_.InnerHtml) -> $($outFile)"
    
    Invoke-WebRequest $_.FullHref -OutFile $outFile
}