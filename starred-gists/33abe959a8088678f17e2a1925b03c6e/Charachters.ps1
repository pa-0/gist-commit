# https://symbl.cc/en/


# Heart Symbol (💗)
$heart = [System.Char]::ConvertFromUtf32(0x1F497)
$heartCodePoint = [int][char]$heart
Write-Host "Heart Symbol Code Point: 0x$($heartCodePoint.ToString("X4"))"

# Copyright Symbol (©)
$copyright = [System.Char]0x00A9
$copyrightCodePoint = [int][char]$copyright
Write-Host "Copyright Symbol Code Point: 0x$($copyrightCodePoint.ToString("X4"))"

# En Dash (–)
$endash = [System.Char]0x2013
$endashCodePoint = [int][char]$endash
Write-Host "En Dash Code Point: 0x$($endashCodePoint.ToString("X4"))"
©
