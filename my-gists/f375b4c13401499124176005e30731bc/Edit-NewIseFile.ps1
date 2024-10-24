function Edit-NewIseFile {
    param(
        [Parameter(ValueFromPipeline=$true)]
        $Filename,
        [Switch]$AddFunction
    )

    Process {
        $content=""

        if($AddFunction) {
            $content = @"
function $FileName {
    <#
        .Synopsis
            A Quick Description of what the command does
        .Description
            A Detailed Description of what the command does
        .Example
            An example of using the command
    #>
}
"@
        }

        if(!$Filename.EndsWith(".ps1")) {
            $Filename+=".ps1"
        }

        if(-not(Test-Path $Filename)) {
            $content | Set-Content -Encoding Ascii $Filename
        }

        if($Host.Name -eq 'ConsoleHost') {
            ise $Filename
        } else {
            psedit $Filename
        }
    }
}