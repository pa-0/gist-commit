function Convert-FileSize {

    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [int64] $FileSize
    )

    switch ($FileSize) {
        { $_ -lt 1KB } { '{0:#,##0} B' -f $FileSize; Break }
        { $_ -lt 1MB } { '{0:#,##0.###} KB' -f ($FileSize / 1KB); Break }
        { $_ -lt 1GB } { '{0:#,##0.###} MB' -f ($FileSize / 1MB); Break }
        { $_ -lt 1TB } { '{0:#,##0.###} GB' -f ($FileSize / 1GB); Break }
        { $_ -lt 1PB } { '{0:#,##0.###} TB' -f ($FileSize / 1TB); Break }
        default        { '{0:#,##0.###} PB' -f ($FileSize / 1PB) }
    }
}