$sb = {
    
    $node = "node.exe"
    if(!(Get-Command $node -ErrorAction SilentlyContinue)) {
        throw "Could not find $node"
    }

    $psISE.CurrentFile.Save()
    & $node $psISE.CurrentFile.FullPath
}

$psISE.CurrentPowerShellTab.AddOnsMenu.Submenus.Add("Invoke Node", $sb, "CTRL+F6")