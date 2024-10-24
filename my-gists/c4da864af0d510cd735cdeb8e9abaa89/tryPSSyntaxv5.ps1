function add ($a, $b) { 
    $a + $b 
}

function subtract ($a, $b) { 
    $a - $b 
}

$a, $b = 4, 5

$fn = if($a -gt $b) {'subtract'} else {'add'}
&$fn $a $b # 9