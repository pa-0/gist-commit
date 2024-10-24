function Get-GitHubActionType {
    $scanner.Scan("\w+")
}

function Get-GitHubActionTypeName {
    $scanner.Skip($WHITESPACE)
    $null = $scanner.Scan($QUOTE)
    $scanner.ScanUntil("(?=$QUOTE)")
}

function Get-GitHubActionKVP {
    param($block)
                
    foreach ($line in $block.split("`r`n").where({$_.length -gt 0})) {
        $innerScanner = New-PSStringScanner $line
        do {
            $key = $innerScanner.Scan("\w+")
                
            if($innerScanner.Check('='+$WHITESPACE+$QUOTE)) {
                $null = $innerScanner.Scan('=')
                $innerScanner.Skip($WHITESPACE)
                $null = $innerScanner.Scan($QUOTE)
                $value = $innerScanner.ScanUntil("(?=$QUOTE)")
                $null = $innerScanner.Scan($QUOTE)
            } else {
                $null = $innerScanner.Scan('=')
                $innerScanner.Skip($WHITESPACE)
                $null = $innerScanner.Scan($LEFTBRACKET)
                $value = Invoke-Expression $innerScanner.ScanUntil("(?=$RIGHTBRACKET)")
                $null = $innerScanner.Scan($RIGHTBRACKET)
            }
            if ($key) {
                [PSCustomObject][Ordered]@{key = $key; value = $value}
            }
        } until ($innerScanner.EoS())
    }
}

function Get-GitHubActionBlock {
    $null = $scanner.Scan("\{")
    Get-GitHubActionKVP $scanner.ScanUntil("(?=\})")
    $null = $scanner.Scan("\}")
}

function Import-GitHubAction {
    param(
        [Parameter(Mandatory)]
        $Path
    )

    $target = Get-Content -Path $Path -Raw

    $QUOTE = '"'
    $WHITESPACE = '\s+'
    $LEFTBRACKET = '\['
    $RIGHTBRACKET = '\]'

    $scanner = New-PSStringScanner $target

    do {
        [PSCustomObject][Ordered]@{
            Type  = Get-GitHubActionType
            Name  = Get-GitHubActionTypeName
            Block = Get-GitHubActionBlock
        }
    } until ($scanner.EoS())
}