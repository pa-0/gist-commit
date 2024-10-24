function Get-ContentJson {
    <#
        .Synopsis
            Get-ContentJson reads a json file, converts it an returns the object
        .Example
            ls . -recurse *.json | Get-ContentJson
        .Example
            Get-ContentJson (dir . *.json).fullname
    #>
    param(
        [Parameter(ValueFromPipeLineByPropertyName)]
        $FullName
    )

    Process {
        [System.IO.File]::ReadAllText($FullName) | 
            ConvertFrom-Json
    }
}