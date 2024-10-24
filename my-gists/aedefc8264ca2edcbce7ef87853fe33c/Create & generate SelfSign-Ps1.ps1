# for computers with ExecutionPolicy = AllSigned, adds some helper methods for signing ps1 files in general, and profile files in particular

$selfSignFuncFile = "$([System.IO.Path]::GetDirectoryName($profile.CurrentUserAllHosts))\Scripts\SelfSign-Ps1.ps1";
if (Test-Path -Path $selfSignFuncFile -PathType Leaf) {
    thorw 'the self signing function file already exists';
}
New-Item $selfSignFuncFile;
Set-Content $selfSignFuncFile '    
function SelfSign-Ps1 {
    [CmdletBinding()]
    Param([Parameter(ValueFromPipeline)] $target);
    if ([string]::IsNullOrEmpty($target)) {
        $target = $args[0];
    }
    if ([string]::IsNullOrEmpty($target)) {
        throw ''You must specify a file to sign'';
    }
    if ([System.IO.Path]::GetExtension($target) -ne ''.ps1'') {
        throw ''this function is only valid for ps1 files'';
    }
    if (-not(Test-Path -Path $target -PathType Leaf)) {
        throw "the specified file, $target, does not exist";
    }
    $subject = ''CN=PowerShell Code Signing Cert''
    $cert = Get-ChildItem cert:\CurrentUser\my -codesigning | where { $_.Subject -eq $subject }
    # todo: if it''s not the trusted root delete it
    # if it''s expired, delete from the store as well
    if (-not $cert) {
    $params = @{
        KeySpec = "Signature"
        Subject = $subject
        Type = ''CodeSigning''
        CertStoreLocation = ''cert:\CurrentUser\My''
        HashAlgorithm = ''sha256''
    };
    
    $cert = New-SelfSignedCertificate @params
    
    # taken from a github issue https://github.com/PowerShell/PowerShell/issues/4753
    # thanks anonymous internet man
    Export-Certificate -FilePath exported_cert.cer -Cert $cert
    Import-Certificate -FilePath exported_cert.cer -CertStoreLocation Cert:\CurrentUser\Root
    }
    Set-AuthenticodeSignature $target $cert | select *
}
function SelfSign-Profiles {
    $profiles = 
        $profile.CurrentUserCurrentHost,
        $profile.CurrentUserAllHosts
    $profiles |
        Where-Object { Test-Path -Path $_ -PathType Leaf } |
        ForEach-Object { $_ | SelfSign-Ps1 }
}
'

# sign the signer
$subject = 'CN=PowerShell Code Signing Cert'
$cert = Get-ChildItem cert:\CurrentUser\my -codesigning | where { $_.Subject -eq $subject }
# todo: if it's not the trusted root delete it
# if it's expired, delete from the store as well
if (-not $cert) {
$params = @{
    KeySpec = "Signature"
    Subject = $subject
    Type = 'CodeSigning'
    CertStoreLocation = 'cert:\CurrentUser\My'
    HashAlgorithm = 'sha256'
};
    
$cert = New-SelfSignedCertificate @params
    
# taken from a github issue https://github.com/PowerShell/PowerShell/issues/4753
# thanks anonymous internet man
Export-Certificate -FilePath exported_cert.cer -Cert $cert
Import-Certificate -FilePath exported_cert.cer -CertStoreLocation Cert:\CurrentUser\Root
}
Set-AuthenticodeSignature $selfSignFuncFile $cert | select *