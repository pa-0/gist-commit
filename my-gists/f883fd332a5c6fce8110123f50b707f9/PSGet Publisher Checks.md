# PSGet Code Signing

This is to try and document the behaviour around PowerShellGet/PSResourceGet code signing publisher behaviour.

## Setup

The following code can be used to set up this scenario.
This must be run as an administrator in Windows PowerShell.

_Note: PowerShell uses implicit remoting for the `New-SelfSignedCertificate` which breaks the constains serialization. You must run this on Windows PowerShell._

```powershell
$testPrefix = 'SignedTest'
$certPassword = ConvertTo-SecureString -String 'SecurePassword123' -Force -AsPlainText

$enhancedKeyUsage = [Security.Cryptography.OidCollection]::new()
$null = $enhancedKeyUsage.Add('1.3.6.1.5.5.7.3.3')  # Code Signing

$caParams = @{
    Extension = @(
        [Security.Cryptography.X509Certificates.X509BasicConstraintsExtension]::new($true, $false, 0, $true),
        [Security.Cryptography.X509Certificates.X509KeyUsageExtension]::new('KeyCertSign', $false),
        [Security.Cryptography.X509Certificates.X509EnhancedKeyUsageExtension ]::new($enhancedKeyUsage, $false)
    )
    CertStoreLocation = 'Cert:\CurrentUser\My'
    NotAfter = (Get-Date).AddYears(2)
    Type = 'Custom'
}
$caRoot1 = New-SelfSignedCertificate @caParams -Subject "CN=$testPrefix-Root1"
$caRoot2 = New-SelfSignedCertificate @caParams -Subject "CN=$testPrefix-Root2"
$caIntermediate1Root1 = New-SelfSignedCertificate @caParams -Subject "CN=$testPrefix-Root1-Intermediate1" -Signer $caRoot1
$caIntermediate2Root1 = New-SelfSignedCertificate @caParams -Subject "CN=$testPrefix-Root1-Intermediate2" -Signer $caRoot1
$caIntermediate1Root2 = New-SelfSignedCertificate @caParams -Subject "CN=$testPrefix-Root2-Intermediate1" -Signer $caRoot2

$certParams = @{
    CertStoreLocation = 'Cert:\CurrentUser\My'
    KeyUsage = 'DigitalSignature'
    TextExtension = @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}")
    Type = 'Custom'
}
$certSigned1Intermediate1Root1 = New-SelfSignedCertificate @certParams -Subject "CN=$testPrefix-Root1-Intermediate1-Signed" -Signer $caIntermediate1Root1
$certSigned2Intermediate1Root1 = New-SelfSignedCertificate @certParams -Subject "CN=$testPrefix-Root1-Intermediate1-Signed" -Signer $caIntermediate1Root1
$certSigned3Intermediate1Root1 = New-SelfSignedCertificate @certParams -Subject "CN=$testPrefix-Other-Root1-Intermediate1-Signed" -Signer $caIntermediate1Root1
$certSignedIntermediate2Root1 = New-SelfSignedCertificate @certParams -Subject "CN=$testPrefix-Root1-Intermediate2-Signed" -Signer $caIntermediate2Root1
$certSignedIntermediate1Root2 = New-SelfSignedCertificate @certParams -Subject "CN=$testPrefix-Root2-Intermediate1-Signed" -Signer $caIntermediate1Root2

$null = $caRoot1 | Export-PfxCertificate -Password $certPassword -FilePath 'root1.pfx'
$caRoot1 | Remove-Item

$null = $caRoot2 | Export-PfxCertificate -Password $certPassword -FilePath 'root2.pfx'
$caRoot2 | Remove-Item

$null = $caIntermediate1Root1 | Export-PfxCertificate -Password $certPassword -FilePath 'intermediate1-root1.pfx'
$caIntermediate1Root1 | Remove-Item

$null = $caIntermediate1Root2 | Export-PfxCertificate -Password $certPassword -FilePath 'intermediate1-root2.pfx'
$caIntermediate1Root2 | Remove-Item

$null = $caIntermediate2Root1 | Export-PfxCertificate -Password $certPassword -FilePath 'intermediate2-root1.pfx'
$caIntermediate2Root1 | Remove-Item

$null = $certSigned1Intermediate1Root1 | Export-PfxCertificate -Password $certPassword -FilePath 'signed1-intermediate1-root1.pfx'
$certSigned1Intermediate1Root1 | Remove-Item

$null = $certSigned2Intermediate1Root1 | Export-PfxCertificate -Password $certPassword -FilePath 'signed2-intermediate1-root1.pfx'
$certSigned2Intermediate1Root1 | Remove-Item

$null = $certSigned3Intermediate1Root1 | Export-PfxCertificate -Password $certPassword -FilePath 'signed3-intermediate1-root1.pfx'
$certSigned3Intermediate1Root1 | Remove-Item

$null = $certSignedIntermediate2Root1 | Export-PfxCertificate -Password $certPassword -FilePath 'signed-intermediate2-root1.pfx'
$certSignedIntermediate2Root1 | Remove-Item

$null = $certSignedIntermediate1Root2 | Export-PfxCertificate -Password $certPassword -FilePath 'signed-intermediate1-root2.pfx'
$certSignedIntermediate1Root2 | Remove-Item

$rootStore = Get-Item Cert:\LocalMachine\Root
try {
    $rootStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
    $rootStore.Add($caRoot1)
    $rootStore.Add($caRoot2)
}
finally {
    $rootStore.Dispose()
}

$repoParams = @{
    Name = 'SignatureTest'
    SourceLocation = Join-Path $pwd 'Source'
    PublishLocation = Join-Path $pwd 'Publish'
    InstallationPolicy = 'Trusted'
}

if (Test-Path -LiteralPath $repoParams.SourceLocation) {
    Remove-Item -LiteralPath $repoParams.SourceLocation -Recurse -Force
}
New-Item -Path $repoParams.SourceLocation -ItemType Directory | Out-Null

if (Test-Path -LiteralPath $repoParams.PublishLocation) {
    Remove-Item -LiteralPath $repoParams.PublishLocation -Recurse -Force
}
New-Item -Path $repoParams.PublishLocation -ItemType Directory | Out-Null

if (Get-PSRepository -Name $repoParams.Name -ErrorAction SilentlyContinue) {
    Unregister-PSRepository -Name $repoParams.Name
}
Register-PSRepository @repoParams

if (Get-PSResourceRepository -name $repoParams.Name -ErrorAction SilentlyContinue) {
    Unregister-PSResourceRepository -Name $repoParams.Name
}
Register-PSResourceRepository -Name $repoParams.Name -Trusted -Uri $repoParams.SourceLocation

$moduleGuid = [Guid]::NewGuid()
$moduleName = 'SigningTest'
$moduleTemp = Join-Path $pwd $moduleName

@(
    [PSCustomObject]@{
        Scenario = 'Unsigned'
        Certificate = $null
    }
    [PSCustomObject]@{
        Scenario = 'Cert1Intermediate1Root1'
        Certificate = $certSigned1Intermediate1Root1
    }
    [PSCustomObject]@{
        Scenario = 'Cert2Intermediate1Root1'
        Certificate = $certSigned2Intermediate1Root1
    }
    [PSCustomObject]@{
        Scenario = 'Cert3Intermediate1Root1'
        Certificate = $certSigned3Intermediate1Root1
    }
    [PSCustomObject]@{
        Scenario = 'Intermediate2Root1'
        Certificate = $certSignedIntermediate2Root1
    }
    [PSCustomObject]@{
        Scenario = 'Intermediate1Root2'
        Certificate = $certSignedIntermediate1Root2
    }
) | ForEach-Object {
    $info = $_

    '1.0.0', '1.1.0' | ForEach-Object {
        if (Test-Path -LiteralPath $moduleTemp) {
            Remove-Item -LiteralPath $moduleTemp -Recurse -Force
        }
        New-Item -Path $moduleTemp -ItemType Directory | Out-Null

        $moduleManifest = @{
            Path = Join-Path $moduleTemp "$($moduleName).psd1"
            Guid = $moduleGuid
            Author = 'Author'
            Description = $info.Scenario
            RootModule = "$($moduleName).psm1"
            ModuleVersion = $_
            PowerShellVersion = '5.1'
            FunctionsToExport = 'Test-Signing'
        }
        New-ModuleManifest @moduleManifest
        Set-Content -LiteralPath (Join-Path $moduleTemp "$($moduleName).psm1") -Value @"
Function Test-Signing {
    'Scenario: $($info.Scenario), Version: $_'
}

Export-ModuleMember -FunctionsToExport Test-Signing
"@

        if ($info.Certificate) {
            "psd1", "psm1" | ForEach-Object {
                $path = Join-Path $moduleTemp "$moduleName.$_"

                $sigParams = @{
                    Certificate = $info.Certificate
                    FilePath = $path
                    HashAlgorithm = 'SHA256'
                    TimestampServer = 'http://timestamp.digicert.com'
                }
                $null = Set-AuthenticodeSignature @sigParams
            }
        }

        Publish-Module -Path $moduleTemp -Repository $repoParams.Name
        $nupkgPath = Join-Path $repoParams.PublishLocation "$moduleName.$_.nupkg"
        $destPath = Join-Path $pwd "$($info.Scenario)-$_.nupkg"
        Move-Item -LiteralPath $nupkgPath -Destination $destPath -Force
    }
}

Remove-Item -LiteralPath $moduleTemp -Force -Recurse
```

## Scenarios

In the same PowerShell session as above you can run the following scenarios

|Scenario|Behaviour|
|-|-|
|[Same Certificate](#same-certificate)|Installs no prompt|no prompt|
|[Same Intermediary](#same-intermediary)|Installs no prompt|
|[Same Intermediary Different Subject](#same-intermediary-different-subject)|2.2.5|Fails, requires `-SkipPublisherCheck`|
|[Same Root](#same-root)|Fails, requires `-SkipPublisherCheck`|
|[Different Root](#different-root)|Fails, requires `-SkipPublisherCheck`|

### Same Certificate

```powershell
Copy-Item -Path Cert1Intermediate1Root1-1.0.0.nupkg -Destination Source/SigningTest.1.0.0.nupkg
Copy-Item -Path Cert1Intermediate1Root1-1.1.0.nupkg -Destination Source/SigningTest.1.1.0.nupkg

Install-Module -Name SigningTest -Repository SignatureTest -RequiredVersion 1.0.0 -Scope CurrentUser
Install-Module -Name SigningTest -Repository SignatureTest -RequiredVersion 1.1.0 -Scope CurrentUser

# Cleanup
$pwshFolder = if ($PSEdition -eq 'Core') { 'PowerShell' } else { 'WindowsPowerShell' }
$modulePath = [System.IO.Path]::Combine(([System.Environment]::GetFolderPath('MyDocuments')), $pwshFolder, 'Modules', 'SigningTest')
Remove-Item -Path Publish/*.nupkg -Force
Remove-Item -LiteralPath $modulePath -Force -Recurse
```

### Same Intermediary

```powershell
Copy-Item -Path Cert1Intermediate1Root1-1.0.0.nupkg -Destination Source/SigningTest.1.0.0.nupkg
Copy-Item -Path Cert2Intermediate1Root1-1.1.0.nupkg -Destination Source/SigningTest.1.1.0.nupkg

Install-Module -Name SigningTest -Repository SignatureTest -RequiredVersion 1.0.0 -Scope CurrentUser
Install-Module -Name SigningTest -Repository SignatureTest -RequiredVersion 1.1.0 -Scope CurrentUser

# Cleanup
$pwshFolder = if ($PSEdition -eq 'Core') { 'PowerShell' } else { 'WindowsPowerShell' }
$modulePath = [System.IO.Path]::Combine(([System.Environment]::GetFolderPath('MyDocuments')), $pwshFolder, 'Modules', 'SigningTest')
Remove-Item -Path Publish/*.nupkg -Force
Remove-Item -LiteralPath $modulePath -Force -Recurse
```

### Same Intermediary different subject

```powershell
Copy-Item -Path Cert1Intermediate1Root1-1.0.0.nupkg -Destination Source/SigningTest.1.0.0.nupkg
Copy-Item -Path Cert3Intermediate1Root1-1.1.0.nupkg -Destination Source/SigningTest.1.1.0.nupkg

Install-Module -Name SigningTest -Repository SignatureTest -RequiredVersion 1.0.0 -Scope CurrentUser
Install-Module -Name SigningTest -Repository SignatureTest -RequiredVersion 1.1.0 -Scope CurrentUser
Install-Module -Name SigningTest -Repository SignatureTest -RequiredVersion 1.1.0 -Scope CurrentUser -SkipPublisherCheck

# Cleanup
$pwshFolder = if ($PSEdition -eq 'Core') { 'PowerShell' } else { 'WindowsPowerShell' }
$modulePath = [System.IO.Path]::Combine(([System.Environment]::GetFolderPath('MyDocuments')), $pwshFolder, 'Modules', 'SigningTest')
Remove-Item -Path Publish/*.nupkg -Force
Remove-Item -LiteralPath $modulePath -Force -Recurse
```

#### PowerShellGet 2.2.5

```
PackageManagement\Install-Package : Authenticode issuer 'CN=SignedTest-Other-Root1-Intermediate1-Signed' of the
new module 'SigningTest' with version '1.1.0' from root certificate authority 'CN=SignedTest-Root1' is not
matching with the authenticode issuer 'CN=SignedTest-Root1-Intermediate1-Signed' of the previously-installed
module 'SigningTest' with version '1.0.0' from root certificate authority 'CN=SignedTest-Root1'. If you still want
to install or update, use -SkipPublisherCheck parameter.
```

### Same Root

```powershell
Copy-Item -Path Intermediate1Root1-1.0.0.nupkg -Destination Source/SigningTest.1.0.0.nupkg
Copy-Item -Path Intermediate2Root1-1.1.0.nupkg -Destination Source/SigningTest.1.1.0.nupkg

Install-Module -Name SigningTest -Repository SignatureTest -RequiredVersion 1.0.0 -Scope CurrentUser
Install-Module -Name SigningTest -Repository SignatureTest -RequiredVersion 1.1.0 -Scope CurrentUser
Install-Module -Name SigningTest -Repository SignatureTest -RequiredVersion 1.1.0 -Scope CurrentUser -SkipPublisherCheck

# Cleanup
$pwshFolder = if ($PSEdition -eq 'Core') { 'PowerShell' } else { 'WindowsPowerShell' }
$modulePath = [System.IO.Path]::Combine(([System.Environment]::GetFolderPath('MyDocuments')), $pwshFolder, 'Modules', 'SigningTest')
Remove-Item -Path Publish/*.nupkg -Force
Remove-Item -LiteralPath $modulePath -Force -Recurse
```

#### PowerShellGet 2.2.5

```
PackageManagement\Install-Package : Authenticode issuer 'CN=SignedTest-Root1-Intermediate2-Signed' of the new
module 'SigningTest' with version '1.1.0' from root certificate authority 'CN=SignedTest-Root1' is not matching
with the authenticode issuer 'CN=SignedTest-Root1-Intermediate1-Signed' of the previously-installed module
'SigningTest' with version '1.0.0' from root certificate authority 'CN=SignedTest-Root1'. If you still want to
install or update, use -SkipPublisherCheck parameter.
```

### Different Root

```powershell
Copy-Item -Path Intermediate1Root1-1.0.0.nupkg -Destination Source/SigningTest.1.0.0.nupkg
Copy-Item -Path Intermediate1Root2-1.1.0.nupkg -Destination Source/SigningTest.1.1.0.nupkg

Install-Module -Name SigningTest -Repository SignatureTest -RequiredVersion 1.0.0 -Scope CurrentUser
Install-Module -Name SigningTest -Repository SignatureTest -RequiredVersion 1.1.0 -Scope CurrentUser
Install-Module -Name SigningTest -Repository SignatureTest -RequiredVersion 1.1.0 -Scope CurrentUser -SkipPublisherCheck

# Cleanup
$pwshFolder = if ($PSEdition -eq 'Core') { 'PowerShell' } else { 'WindowsPowerShell' }
$modulePath = [System.IO.Path]::Combine(([System.Environment]::GetFolderPath('MyDocuments')), $pwshFolder, 'Modules', 'SigningTest')
Remove-Item -Path Publish/*.nupkg -Force
Remove-Item -LiteralPath $modulePath -Force -Recurse
```

#### PowerShellGet 2.2.5

```
PackageManagement\Install-Package : Authenticode issuer 'CN=SignedTest-Root2-Intermediate1-Signed' of the new
module 'SigningTest' with version '1.1.0' from root certificate authority 'CN=SignedTest-Root2' is not matching
with the authenticode issuer 'CN=SignedTest-Root1-Intermediate1-Signed' of the previously-installed module
'SigningTest' with version '1.0.0' from root certificate authority 'CN=SignedTest-Root1'. If you still want to
install or update, use -SkipPublisherCheck parameter.
```
