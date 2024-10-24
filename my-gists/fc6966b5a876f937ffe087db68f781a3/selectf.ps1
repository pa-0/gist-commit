Import-Module PSStringScanner

function selectf {

    $ss = New-PSStringScanner ($args -join ' ')
    $select = $ss.scanUntil("(?=from )")
    $null=$ss.scan("from ")
    
    if($ss.check(" where ")) {
        $targetPath = $ss.scanuntil("(?=where )")
        $null=$ss.scan("where ")
        
        $whereVar = $ss.scanuntil("(?==~ )")
        $null=$ss.scan("=~ ")
        $whereValue = $ss.scan(".*")
    } else {
        $targetPath = $ss.scan(".*")
    }
    
    $cmd = "dir {0} | select {1}" -f $targetPath, $select

    if($whereVar) {
        $cmd += ' | where {{ $_.{0} -match {1} }}' -f $whereVar, $whereValue
    }
  
    $cmd | iex
}

#selectf "name,ext*,length from 'C:\temp'"
selectf "name,ext*,length from 'C:\temp' where extension =~ 'png$'" # use a regex