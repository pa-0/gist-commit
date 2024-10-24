Function GenerateDSC {

$WindowsFeature = Get-WindowsFeature | Where {$PSItem.installed -and $PSItem.name -match 'net-framework'} | % {

@"

WindowsFeature $($PSItem.name) {
    Ensure = 'Present'
    Name = "$($PSItem.name)"
}

"@

} 


@"
Configuration DotNetFrameWork{
    param(`$TargetMachine)
    Node `$TargetMachine {
            $WindowsFeature
    }
}

"@
}