function Update-CodePSExePath {
    $version=$PSVersionTable.PSVersion.Major

    if($version -eq 5) {
        $powerShellExePath = (get-command powershell.exe).Source
    } else {
        $powerShellExePath = (get-command pwsh.exe).Source
    }

    $settingsFile = "$env:APPDATA\Code\User\settings.json"
    $LineNumber   = (Select-String 'powershell.powerShellExePath' $settingsFile).LineNumber
    $fileContent  = Get-Content $settingsFile

    $fileContent[$LineNumber-1] = "`t" + '"powershell.powerShellExePath": "{0}",' -f ($powerShellExePath.Replace("\","\\"))

    $fileContent | Set-Content $settingsFile -Encoding Ascii
}