$file = "<YOUR HTML FILE>"

$guid=[guid]::NewGuid()
switch -File $file -Regex  {
    '<script src="(.*)"' {
        $oldValue = $Matches[1]
        $newValue = $oldValue + "?v=$($guid)"
        $_.Replace($oldValue,$newValue)            
    }
            
    '<img.+?src="(.+?)".+?/?>' {
        $oldValue = $Matches[1]
        $newValue = $oldValue + "?v=$($guid)"                
        $_.Replace($oldValue,$newValue)                
    }

    '<link' {
        $s=$_
        $start=$s.IndexOf('href="')
        $end=$s.IndexOf('"', $start+6)
        $oldValue=$s.Substring($start+6,$end-$start-6)
        $newValue = $oldValue + "?v=$($guid)"                
        $_.Replace($oldValue,$newValue)
    }

    default {$_}
}