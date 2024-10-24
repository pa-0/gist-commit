function Invoke-Speak {
    param($msg)

    Add-Type -AssemblyName System.Speech
    $speaker = New-Object System.Speech.Synthesis.SpeechSynthesizer
    
    $speaker.Speak($msg)
}

function getmessage {
    param(
        [Parameter(Mandatory)]
        $data,
        [ValidateSet('Value', 'Type', 'All')]
        $p = 'Value'
    )
    
    if ($p -eq 'Value') {
        'value is, ' + $data
    }
    elseif ($p -eq 'Type') {
        'base type is,' + $data.Gettype().Basetype + ', and name is,' + $data.Gettype().Name
    }
    else {
        'value is, ' + $data + '.'
        'base type is,' + $data.Gettype().Basetype + ', and name is,' + $data.Gettype().Name        
    }
}

$sb = {
    param(
        [ValidateSet('Value', 'Type', 'All')]
        $p = 'Value'
    )
        
    Invoke-Speak (getmessage $this $p)
}

$targetTypes = $(
    'system.int32'
    'system.double'
    'system.array'
    'system.string'    
    'System.Management.Automation.PSCustomObject'
) 

foreach ($targetType in $targetTypes) {
    Update-TypeData -TypeName $targetType -MemberType ScriptMethod -MemberName Speak -Force -Value $sb
}