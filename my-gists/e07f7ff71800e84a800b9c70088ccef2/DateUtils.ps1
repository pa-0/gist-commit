class DateUtils {
    static [datetime] EasterSunday($year) {
        $a = $year % 19
        $b = [math]::Truncate($year/100)
        $c = $year % 100
        $d = [math]::Truncate($b/4)
        $e = $b%4
        $f = [math]::Truncate(($b+8)/25)
        $g = [math]::Truncate(($b-$f+1)/3)
        $h = ((19*$a)+$b-$d-$g+15)%30
        $i = [math]::Truncate($c/4)
        $k = $c%4
        $l = (32+2*($e+$i)-$h-$k)%7
        $m = [math]::Truncate(($a+(11+$h)+(22*$l))/451)
        $n = [math]::Truncate(($h+$l-(7*$m)+114)/31)
        $p = ($h+$l-(7*$m)+114)%31

        return Get-Date("$n/$($p+1)/$year")
    }
}

2013..2020 | %{[DateUtils]::EasterSunday($_)}