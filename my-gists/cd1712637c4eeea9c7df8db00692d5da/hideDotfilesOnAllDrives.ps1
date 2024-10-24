workflow hideDotfilesOnAllDrives {  
    function hide($mask) {
        $sw = [Diagnostics.Stopwatch]::StartNew()
    
        ATTRIB +H /s /d $mask
        
        $sw.Stop()
        echo "$mask - $($sw.Elapsed.TotalSeconds)s"
    }
    
    foreach -parallel ($d in get-psdrive -p "FileSystem" | select root) {
        hide("$($d.root).*")
    }
}

hideDotfilesOnAllDrives