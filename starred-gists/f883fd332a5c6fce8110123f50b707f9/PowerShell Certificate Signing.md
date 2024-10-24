# PowerShell Code Signing

This is to try and document the behaviour around PowerShell code signing.

## Setup

The following code can be used to set up this scenario.
This must be run as an administrator in Windows PowerShell.

_Note: PowerShell uses implicit remoting for the `New-SelfSignedCertificate` which breaks the constains serialization. You must run this on Windows PowerShell._

```powershell
$testPrefix = 'SelfSignedTest'
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
$caRoot = New-SelfSignedCertificate @caParams -Subject "CN=$testPrefix-Root"
$caIntermediate = New-SelfSignedCertificate @caParams -Subject "CN=$testPrefix-Intermediate" -Signer $caRoot

$certParams = @{
    CertStoreLocation = 'Cert:\CurrentUser\My'
    KeyUsage = 'DigitalSignature'
    TextExtension = @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}")
    Type = 'Custom'
}
$certSigned = New-SelfSignedCertificate @certParams -Subject "CN=$testPrefix-Signed" -Signer $caIntermediate
$certSelfSigned = New-SelfSignedCertificate @certParams -Subject "CN=$testPrefix-SelfSigned"

$null = $caRoot | Export-PfxCertificate -Password $certPassword -FilePath 'root.pfx'
$caRoot | Remove-Item

$null = $caIntermediate | Export-PfxCertificate -Password $certPassword -FilePath 'intermediate.pfx'
$caIntermediate | Remove-Item

$null = $certSigned | Export-PfxCertificate -Password $certPassword -FilePath 'signed.pfx'
$certSigned | Remove-Item

$null = $certSelfSigned | Export-PfxCertificate -Password $certPassword -FilePath 'self_signed.pfx'
$certSelfSigned | Remove-Item

$scriptContent = 'echo "hello world"'
Set-Content -Path ps_ca_signed.ps1 -Value $scriptContent
Set-Content -Path ps_self_signed.ps1 -Value $scriptContent
Set-Content -Path ps_unsigned.ps1 -Value $scriptContent

$null = Set-AuthenticodeSignature -Certificate $certSigned -FilePath ps_ca_signed.ps1
$null = Set-AuthenticodeSignature -Certificate $certSelfSigned -FilePath ps_self_signed.ps1

Set-ExecutionPolicy -ExecutionPolicy AllSigned -Scope Process -Force

# Make sure the policy is in place (this should fail)
.\ps_unsigned.ps1
```

## Scenarios

In the same PowerShell session as above you can run the following scenarios

|Scenario|Trusted Roots|Trusted Publishers|Works|
|-|-|-|-|
|[Root in Trusted Root CA](#root-in-trusted-root-ca)|root|-|Yes (prompt to trust¹)|
|[Root in Trusted Publisher](#root-in-trusted-publisher)|-|root|No (untrusted chain)|
|[Root in Trusted Root and Publisher](#root-in-trusted-root-and-publisher)|root|root|Yes (prompt to trust¹)|
|[Intermediate in Trusted Root CA](#intermediate-in-trusted-root-ca)|intermediate|-|No (untrusted chain)|
|[Intermediate in Trusted Publisher](#intermediate-in-trusted-publisher)|-|intermediate|No (untrusted chain)|
|[Intermediate in Trusted Root and Publisher](#intermediate-in-trusted-root-and-publisher)|intermediate|intermediate|No (untrusted chain)|
|[Cert in Trusted Root CA](#cert-in-trusted-root-ca)|cert|-|No (untrusted chain)|
|[Cert in Trusted Publisher](#cert-in-trusted-publisher)|-|cert|No (untrusted chain)|
|[Cert in Trusted Publisher with Trusted Root](#cert-in-trusted-publisher-with-root)|root|cert|Yes|
|[Cert in Trusted Publisher with Trusted Intermediate](#cert-in-trusted-publisher-with-root)|intermediate|cert|No (untrusted chain)|
|[Self Signed Untrusted](#self-signed-untrusted)|-|-|No (untrusted chain)|
|[Self Signed in Trusted Root CA](#self-signed-in-trusted-root-ca)|self_signed|-|Yes (prompt to trust¹)|
|[Self Signed in Trusted Publisher](#self-signed-in-trusted-root-ca)|-|self_signed|No (untrusted chain)|
|[Self Signed in Trusted Root and Publisher](#self-signed-in-trusted-root-and-publisher)|self_signed|self_signed|Yes|

_¹ A will place the cert into `Cert:\CurrentUser\TrustedPublisher` if `A` is selected in the prompt._

If running these scenarios in a new session make sure you set the execution policy and define `$certPassword` again.

### Root in Trusted Root CA

```powershell
$certPath = Import-PfxCertificate -Password $certPassword -CertStoreLocation Cert:\LocalMachine\Root -FilePath root.pfx
try {
    .\ps_ca_signed.ps1
}
finally {
    $certPath | Remove-Item
}
```

```console
Do you want to run software from this untrusted publisher?
File C:\temp\cert\ps_ca_signed.ps1 is published by CN=SelfSignedTest-Signed and is not trusted on your system. Only run
 scripts from trusted publishers.
[V] Never run  [D] Do not run  [R] Run once  [A] Always run  [?] Help (default is "D"):

hello world
```

### Root in Trusted Publisher

```powershell
$certPath = Import-PfxCertificate -Password $certPassword -CertStoreLocation Cert:\LocalMachine\TrustedPublisher -FilePath root.pfx
try {
    .\ps_ca_signed.ps1
}
finally {
    $certPath | Remove-Item
}
```

```console
.\ps_ca_signed.ps1 : File C:\temp\cert\ps_ca_signed.ps1 cannot be loaded. A certificate chain processed, but
terminated in a root certificate which is not trusted by the trust provider.
At line:2 char:5
+     .\ps_ca_signed.ps1
+     ~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : SecurityError: (:) [], PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess
```

### Root in Trusted Root and Publisher

```powershell
$rootPath = Import-PfxCertificate -Password $certPassword -CertStoreLocation Cert:\LocalMachine\Root -FilePath root.pfx
$certPath = Import-PfxCertificate -Password $certPassword -CertStoreLocation Cert:\LocalMachine\TrustedPublisher -FilePath root.pfx
try {
    .\ps_ca_signed.ps1
}
finally {
    $rootPath | Remove-Item
    $certPath | Remove-Item
}
```

```console
Do you want to run software from this untrusted publisher?
File C:\temp\cert\ps_ca_signed.ps1 is published by CN=SelfSignedTest-Signed and is not trusted on your system. Only run
 scripts from trusted publishers.
[V] Never run  [D] Do not run  [R] Run once  [A] Always run  [?] Help (default is "D"):

hello world
```

### Intermediate in Trusted Root CA

```powershell
$certPath = Import-PfxCertificate -Password $certPassword -CertStoreLocation Cert:\LocalMachine\Root -FilePath intermediate.pfx
try {
    .\ps_ca_signed.ps1
}
finally {
    $certPath | Remove-Item
}
```

```console
.\ps_ca_signed.ps1 : File C:\temp\cert\ps_ca_signed.ps1 cannot be loaded. A certificate chain processed, but
terminated in a root certificate which is not trusted by the trust provider.
At line:2 char:5
+     .\ps_ca_signed.ps1
+     ~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : SecurityError: (:) [], PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess
```

### Intermediate in Trusted Publisher

```powershell
$certPath = Import-PfxCertificate -Password $certPassword -CertStoreLocation Cert:\LocalMachine\TrustedPublisher -FilePath intermediate.pfx
try {
    .\ps_ca_signed.ps1
}
finally {
    $certPath | Remove-Item
}
```

```console
.\ps_ca_signed.ps1 : File C:\temp\cert\ps_ca_signed.ps1 cannot be loaded. A certificate chain processed, but
terminated in a root certificate which is not trusted by the trust provider.
At line:2 char:5
+     .\ps_ca_signed.ps1
+     ~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : SecurityError: (:) [], PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess
```

### Intermediate in Trusted Root and Publisher

```powershell
$rootPath = Import-PfxCertificate -Password $certPassword -CertStoreLocation Cert:\LocalMachine\Root -FilePath intermediate.pfx
$certPath = Import-PfxCertificate -Password $certPassword -CertStoreLocation Cert:\LocalMachine\TrustedPublisher -FilePath intermediate.pfx
try {
    .\ps_ca_signed.ps1
}
finally {
    $rootPath | Remove-Item
    $certPath | Remove-Item
}
```

```console
.\ps_ca_signed.ps1 : File C:\temp\cert\ps_ca_signed.ps1 cannot be loaded. A certificate chain processed, but
terminated in a root certificate which is not trusted by the trust provider.
At line:2 char:5
+     .\ps_ca_signed.ps1
+     ~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : SecurityError: (:) [], PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess
```

### Cert in Trusted Root CA

```powershell
$certPath = Import-PfxCertificate -Password $certPassword -CertStoreLocation Cert:\LocalMachine\Root -FilePath signed.pfx
try {
    .\ps_ca_signed.ps1
}
finally {
    $certPath | Remove-Item
}
```

```console
.\ps_ca_signed.ps1 : File C:\temp\cert\ps_ca_signed.ps1 cannot be loaded. A certificate chain processed, but
terminated in a root certificate which is not trusted by the trust provider.
At line:2 char:5
+     .\ps_ca_signed.ps1
+     ~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : SecurityError: (:) [], PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess
```

### Cert in Trusted Publisher

```powershell
$certPath = Import-PfxCertificate -Password $certPassword -CertStoreLocation Cert:\LocalMachine\TrustedPublisher -FilePath signed.pfx
try {
    .\ps_ca_signed.ps1
}
finally {
    $certPath | Remove-Item
}
```

```console
.\ps_ca_signed.ps1 : File C:\temp\cert\ps_ca_signed.ps1 cannot be loaded. A certificate chain processed, but
terminated in a root certificate which is not trusted by the trust provider.
At line:2 char:5
+     .\ps_ca_signed.ps1
+     ~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : SecurityError: (:) [], PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess
```

### Cert in Trusted Publisher with Trusted Root

```powershell
$rootPath = Import-PfxCertificate -Password $certPassword -CertStoreLocation Cert:\LocalMachine\Root -FilePath root.pfx
$certPath = Import-PfxCertificate -Password $certPassword -CertStoreLocation Cert:\LocalMachine\TrustedPublisher -FilePath signed.pfx
try {
    .\ps_ca_signed.ps1
}
finally {
    $rootPath | Remove-Item
    $certPath | Remove-Item
}
```

```console
hello world
```

### Cert in Trusted Publisher with Trusted Intermediate

```powershell
$rootPath = Import-PfxCertificate -Password $certPassword -CertStoreLocation Cert:\LocalMachine\Root -FilePath intermediate.pfx
$certPath = Import-PfxCertificate -Password $certPassword -CertStoreLocation Cert:\LocalMachine\TrustedPublisher -FilePath signed.pfx
try {
    .\ps_ca_signed.ps1
}
finally {
    $rootPath | Remove-Item
    $certPath | Remove-Item
}
```

```console
.\ps_ca_signed.ps1 : File C:\temp\cert\ps_ca_signed.ps1 cannot be loaded. A certificate chain processed, but
terminated in a root certificate which is not trusted by the trust provider.
At line:2 char:5
+     .\ps_ca_signed.ps1
+     ~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : SecurityError: (:) [], PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess
```

### Self Signed Untrusted

```powershell
.\ps_self_signed.ps1
```

```console
.\ps_self_signed.ps1 : File C:\temp\cert\ps_self_signed.ps1 cannot be loaded. A certificate chain processed, but
terminated in a root certificate which is not trusted by the trust provider.
At line:1 char:1
+ .\ps_self_signed.ps1
+ ~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : SecurityError: (:) [], PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess
```

### Self Signed in Trusted Root CA

```powershell
$certPath = Import-PfxCertificate -Password $certPassword -CertStoreLocation Cert:\LocalMachine\Root -FilePath self_signed.pfx
try {
    .\ps_self_signed.ps1
}
finally {
    $certPath | Remove-Item
}
```

```console
Do you want to run software from this untrusted publisher?
File C:\temp\cert\ps_self_signed.ps1 is published by CN=SelfSignedTest-SelfSigned and is not trusted on your system.
Only run scripts from trusted publishers.
[V] Never run  [D] Do not run  [R] Run once  [A] Always run  [?] Help (default is "D"):

hello world
```

### Self Signed in Trusted Publisher

```powershell
$certPath = Import-PfxCertificate -Password $certPassword -CertStoreLocation Cert:\LocalMachine\TrustedPublisher -FilePath self_signed.pfx
try {
    .\ps_self_signed.ps1
}
finally {
    $certPath | Remove-Item
}
```

```console
.\ps_self_signed.ps1 : File C:\temp\cert\ps_self_signed.ps1 cannot be loaded. A certificate chain processed, but
terminated in a root certificate which is not trusted by the trust provider.
At line:2 char:5
+     .\ps_self_signed.ps1
+     ~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : SecurityError: (:) [], PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess
```

### Self Signed in Trusted Root and Publisher

```powershell
$rootPath = Import-PfxCertificate -Password $certPassword -CertStoreLocation Cert:\LocalMachine\Root -FilePath self_signed.pfx
$certPath = Import-PfxCertificate -Password $certPassword -CertStoreLocation Cert:\LocalMachine\TrustedPublisher -FilePath self_signed.pfx
try {
    .\ps_self_signed.ps1
}
finally {
    $rootPath | Remove-Item
    $certPath | Remove-Item
}
```

```console
hello world
```

## Summary

In the end to to trust a signed certificate you need to do the following

* The root cert in the chain must be in the `Trusted Root CA` store
    * This must be the root cert in the chain, you cannot just trust any intermediate certs
    * Any intermediate certs must be in the `Intermediate CA` store but that seems to be down automatically when you import the root
* The final cert (the one that signed the script) must be in the `Trusted Publishers` store
    
If the signing cert is not in the `Trusted Publishers` store then PowerShell will prompt with the following:

```console
Do you want to run software from this untrusted publisher?
File C:\temp\cert\ps_ca_signed.ps1 is published by CN=SelfSignedTest-Signed and is not trusted on your system. Only run
 scripts from trusted publishers.
[V] Never run  [D] Do not run  [R] Run once  [A] Always run  [?] Help (default is "D"):
```

Here is what each of the options do

* `[V] Never run`
    * Does not run the script
    * Places the signing cert into `Cert:\CurrentUser\Disallowed` (`Untrusted Certificates\Certificates`)
    * Due to the cert being in the `Disallowed` store subsequence runs will fail without any prompt
    * Errors with the below

```console
.\ps_ca_signed.ps1 : File C:\temp\cert\ps_ca_signed.ps1 cannot be loaded because its operation is blocked by software
restriction policies, such as those created by using Group Policy.
At line:1 char:1
+ .\ps_ca_signed.ps1
+ ~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : SecurityError: (:) [], PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess
```

* `[D] Do not run`
    * Like `V` but does not place the cert into the `Disallowed` store
    * Subsequence runs will continue to prompt for desired action
    * Errors with the below

```console
.\ps_ca_signed.ps1 : File C:\temp\cert\ps_ca_signed.ps1 cannot be loaded because you opted not to run this software
now.
At line:1 char:1
+ .\ps_ca_signed.ps1
+ ~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : SecurityError: (:) [], PSSecurityException
    + FullyQualifiedErrorId : UnauthorizedAccess
```

* `[R] Run once`
    * Runs the script
    * Subsequent runs will continue to prompt for desired action

* `[A] Always run`
    * Runs the script
    * Places the cert into `Cert:\CurrentUser\TrustedPublisher`
    * Subsequence runs will run automatically as the cert is now trusted
