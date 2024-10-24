function squeeze {
    param($s)

    $p = $s.IndexOf('  ')

    while ($p -gt -1) {
        $s = $s -replace '  ', ' '
        $p = $s.IndexOf('  ')
    }

    $s
}

function ConvertFrom-ListPackage {
    param(
        [parameter(ValueFromPipeline)]
        $data 
    )

    Process {
        $collectedData += @($data)
    }
    End {
        
        switch ($collectedData) {
            { $_.StartsWith("Project") } { $projectName = $_.split(' ')[1] -replace "'", '' }
            { $_.Trim().StartsWith("Top-level Package") } { 
                $TLPFound = $true
                $TPFound = $false 
            }
            { $_.Trim().StartsWith("Transitive Package") } { 
                $TPFound = $true 
                $TLPFound = $false 
            }
            { $_.Trim().StartsWith(">") } {
                $s = (squeeze $_.Trim()).Split(' ')

                if ($TLPFound) {
                    $type = 'Top-level Package'
                    $null, $pkg, $requested, $resolved = $s
                }
                elseif ($TPFound) {                    
                    $type = 'Transitive Package'
                    $requested = 'n/a'
                    $null, $pkg, $resolved = $s
                }

                [PSCustomObject][Ordered]@{
                    ProjectName = $projectName
                    Type        = $type
                    Package     = $pkg
                    Requested   = $requested
                    Resolved    = $resolved                                        
                }
            }            
        }
    }
}

dotnet list package --include-transitive | ConvertFrom-ListPackage