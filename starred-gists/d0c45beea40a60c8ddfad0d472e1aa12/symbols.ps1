cls

function New-Symbol {
    param($key, $symbol, $description)

    [pscustomobject] @{
        key         = $key
        symbol      = $symbol
        description = $description
    }
}

$(
    New-Symbol "ALT+0153" '™' 'trademark'
    New-Symbol "ALT+0169" '©' 'copyright'
    New-Symbol "ALT+0174" '®' 'registered trademark'
    New-Symbol "ALT+0176" '°' 'degree'
    New-Symbol "ALT+0177" '±' 'plus or minus'
    New-Symbol "ALT+0182" '¶' 'paragraph'
    New-Symbol "ALT+0190" '¾' 'fraction'
    New-Symbol "ALT+0215" '×' 'multiplication'
    New-Symbol "ALT+0162" '¢' 'cent sign'
    New-Symbol "ALT+0161" '¡' 'upside down exclamation point'
    New-Symbol "ALT+0191" '¿' 'upside down question mark'
    New-Symbol "ALT+1" '☺' 'smiley face'
    New-Symbol "ALT+15" '☼' 'sun'
    New-Symbol "ALT+12" '♀' 'female sign'
    New-Symbol "ALT+11" '♂' 'male sign'
    New-Symbol "ALT+6" '♠' 'spade'
    New-Symbol "ALT+5" '♣' 'club'
    New-Symbol "ALT+3" '♥' 'heart'
    New-Symbol "ALT+4" '♦' 'diamond'
    New-Symbol "ALT+13" '♪' 'eighth note'
    New-Symbol "ALT+14" '♫' 'beamed eighth note'
    New-Symbol "ALT+251" '√' 'square root'
    New-Symbol "ALT+24" '↑' 'up arrow'
    New-Symbol "ALT+25" '↓' 'down arrow'
    New-Symbol "ALT+26" '→' 'right arrow'
    New-Symbol "ALT+27" '←' 'left arrow'
    New-Symbol "ALT+18" '↕' 'up/down arrow'
    New-Symbol "ALT+29" '↔' 'left/right arrow'
)