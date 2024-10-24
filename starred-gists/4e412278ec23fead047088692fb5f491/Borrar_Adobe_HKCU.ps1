# Writing Current User registry keys in SCCM as System
# https://tdemeul.bunnybesties.org/2022/04/writing-current-user-registry-keys-in.html

# Modificado 27/06/2022 para UPC (Entorno GET)
# Modificado 27/10/2022 para "atacar" únicamente a todos los usuarios (Borrar Adobe)

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('\.reg$')]
    [string]$RegFile
)

function Write-Registry {
    param($RegFileContents)
    $tempFile = '{0}{1:yyyyMMddHHmmssff}.reg' -f [IO.Path]::GetTempPath(), (Get-Date)
    $RegFileContents | Out-File -FilePath $tempFile
    Write-Host ('Writing registry from file {0}' -f $tempFile)
    try { $p = Start-Process -FilePath C:\Windows\regedit.exe -ArgumentList "/s $tempFile" -PassThru -Wait } catch { }
    if ($null -ne $p) { $exitCode = $p.ExitCode } else { $exitCode = 0 }
    if ($exitCode -ne 0) {
        Write-Warning 'There was an error merging the reg file'
    } else {
        Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
    }
}

if (-not (Test-Path -Path $RegFile)) {
    Write-Warning "RegFile $RegFile doesn't exist. Operation aborted"
} else {

        Write-Host ('Reading the registry file {0}' -f $RegFile)
        $registryData = Get-Content -Path $RegFile -ReadCount 0

            Write-Host "Writing to every user's registry"
            $res = C:\Windows\system32\reg.exe query HKEY_USERS
            $res -notmatch 'S-1-5-18|S-1-5-19|S-1-5-20|DEFAULT|Classes' | ForEach-Object {
                if ($_ -ne '') {
                    $sid = $_ -replace 'HKEY_USERS\\'
                    $RegFileContents = $registryData -replace 'HKEY_CURRENT_USER', "HKEY_USERS\$sid"
                    Write-Host "- $sid"
                    Write-Registry -RegFileContents $RegFileContents
                }
            }

}
