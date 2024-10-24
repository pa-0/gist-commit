function Get-Giphy {
    param(
        $q = 'clippy',
        [Switch]$Raw
    )
    
    $r = irm "https://api.giphy.com/v1/gifs/search?api_key=$($giphyKey)&q=$($q)&limit=25&offset=0&rating=g&lang=en"
    $t = ($r.data | get-random).images.downsized_medium.url
    
    if ($Raw) {
        return $t
    }
    
    "![]($t)" | Out-Display -MimeType 'text/markdown'
}
