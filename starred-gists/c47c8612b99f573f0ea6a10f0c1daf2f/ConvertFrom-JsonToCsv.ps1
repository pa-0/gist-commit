function ConvertFrom-JsonToCsv {
    param(
        [Parameter(ValueFromPipeline)]
        $json        
    )

    Process {
        ($json | ConvertFrom-Json) | ConvertTo-Csv -NoTypeInformation
    }
}

'[{"Column 1": "1-1","Column 2": "1-2","Column 3": "1-3","Column 4": "1-4"},{"Column 1": "2-1","Column 2": "2-2","Column 3": "2-3","Column 4": "2-4"},{"Column 1": "3-1","Column 2": "3-2","Column 3": "3-3","Column 4": "3-4"},{"Column 1": 4,"Column 2": 5,"Column 3": 6,"Column 4": 7}]' | 
    ConvertFrom-JsonToCsv 