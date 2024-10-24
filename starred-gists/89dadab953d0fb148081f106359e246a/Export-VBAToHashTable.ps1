function Export-VBAToHashTable {

    param($fileName)

    $inFunction=$false
    $h=@{}

    switch -regex (Get-Content $fileName) {
        "^function"  {
            $inFunction=$true
            $functionName = $_.split(' ')[1].split('(')[0]
            $h.$functionName=@($_)
        }

        "^end function"  {
            $h.$functionName+=$_        
            $inFunction=$false  
        }

        default {
            if($inFunction) {
                $h.$functionName+=$_                    
            }
        }
    }

    $h
}