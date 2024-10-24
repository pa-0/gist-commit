function Get-TimeStamp {
    param(
        [Switch]$Yesterday,
        [Switch]$ToClipboard
    )

    $date = Get-Date
    
    if($Yesterday) {
        $date = $date.AddDays(-1)
    }

    $r=$date.tostring("yyyyMMdd")

    if($ToClipboard) { return $r | clip }
    
    $r
}
