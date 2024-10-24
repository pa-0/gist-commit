function Get-AvailableComObjects {
    $classesCom = ''
    $classes = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SOFTWARE\\Classes').GetSubKeyNames()
    [regex]::Matches($classes, '\w+\.\w+').Value | % {if ([Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SOFTWARE\\Classes\\$_\\CLSID")) {$classesCom += "$_`r`n"}}
    $classesCom.Replace("`r`n",' ').Split(' ') | Select-Object -Unique
}