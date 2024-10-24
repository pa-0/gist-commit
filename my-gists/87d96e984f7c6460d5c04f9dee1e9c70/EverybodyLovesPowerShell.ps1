function new-entry {
    param($item, $comment)
    [PSCustomObject]@{Item=$item;Comment=$comment}
}

$(
    new-entry "'5' - 3" 'weak typing + implicit conversionsion * headaches'
    new-entry "'5' + 3" 'because we al love consistency'
    new-entry "'5' - '4'" 'string - string * integer. What?'
    new-entry "'5' + + '5'"
    new-entry "'foo' + + 'foo'" 'marvelous'
    new-entry "'5' + - '2'" 'sweet'
    new-entry "'5' + - + - - + + -+ - + - + - - -'-2'" "Apparently it's ok"
    new-entry '$x * 3' 'nothing'
    new-entry "'5' + `$x - `$x" ""
    new-entry "'5' - `$x + `$x" ""
) | % {
    
    $target=$_.item
    $comment=$_.comment
    try {
        $Error.Clear()
        $r=($target|iex)
        "> " + $target
        "{0} `t`t# {1}" -f $r, $comment
    } catch {
        "{0} `t# {1}" -f $target, $comment
        $Error[0].Exception
    }    
} 