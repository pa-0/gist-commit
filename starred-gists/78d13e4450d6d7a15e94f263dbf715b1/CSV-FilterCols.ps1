Function CSV-FilterCols() {
    param (
        [Parameter(Mandatory=$true)][String]$InCsv,
        [Parameter(Mandatory=$true)][String[]]$ColNameRegex,
        [Switch]$NoGlobal=$false,
        [String]$CsvDelimiter=";",
        [String]$OutCsv=""
    )

    If (!(Test-Path $InCsv)) {
        Write-Error "File $InCsv not found!"
        Return
    } 

    $rawdata = Import-Csv $InCsv

    # Store result of Import-Csv in a Global variable, just in case we want to do something with it, too
    If (! $NoGlobal) { $Global:rawdata = $rawdata }

    $colnames = $rawdata[0] | Get-Member -MemberType NoteProperty | ForEach { $_.Name }

    $cols = New-Object -TypeName System.Collections.Generic.List[String]
    $cols.Add($colnames[0])

    foreach ($r in $ColNameRegex) {
        # Need to cast return of @() to String[] so AddRange won't puke
        $cols.AddRange([String[]]@($colnames -match $r))
    }

    $cols.Sort()
    $cols = $cols.ToArray() | Get-Unique

    $filtdata = $rawdata | select $cols

    If ($OutCsv -eq "") {
        $filtdata
    }
    Else {
        $filtdata | Export-Csv $OutCsv -NoTypeInformation -Delimiter $CsvDelimiter
    }

}
