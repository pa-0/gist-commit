$result = New-DiGraph {
    $r|%{
       add-edge ('"' + $_.sourcenode + '"') ('"'+$_.targetnode+'"') "dependsOn"
    }       
}

$result | & "C:\Program Files (x86)\Graphviz2.38\bin\dot.exe" -Tpng -o $pwd\test.png
ii $pwd\test.png