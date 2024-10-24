# greatest common divisor
function Get-GCD {    
    param(        
        [int]$a, 
        [int]$b
    )

    $r = [ordered]@{a = $a; b = $b }

    while ($a -ne 0) {
        $a, $b = ($b % $a), $a
    }

    $r.gcd = $b
    
    [PSCustomObject]$r
}