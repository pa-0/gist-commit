function add ($a, $b) { 
    $a + $b 
}

function subtract ($a, $b) { 
    $a - $b 
}

$a, $b = 4, 5

&($a -gt $b ? 'subtract' : 'add') $a $b # 9