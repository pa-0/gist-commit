function Invoke-AutoCurl {
    <# .SYNOPSIS
    cURL wrapper to auto resume downloads #>
    [Alias('autocurl')]
    Param(
        [Parameter(Mandatory)]
        [Uri]$URL
    )

    do {
        curl -LOC - $URL
    } while ($LASTEXITCODE -in 18, 56)
}
