function Get-WinCertificateHash {
<#
.SYNOPSIS

Calculates the SHA256 hash of the WIN_CERTIFICATE structure of an Authenticode-signed PE file

.DESCRIPTION

Get-WinCertificateHash calculates the SHA256 hash of the WIN_CERTIFICATE structure of an Authenticode-signed PE file. I wrote this function to attempt to identify the exact file that the BadRabbit signature was stolen from.

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.PARAMETER FilePath

Specifies the path of the file that will have its WIN_CERTIFICATE hash calculated (assuming its an Authenticode-signed PE).

.EXAMPLE

ls .\BadRabbit\301b905eb98d8d6bb559c04bbda26628a942b2c4107c07a02e8f753bdcfe347c | Get-WinCertificateHash

Calculate the WIN_CERTIFICATE hash of one of the BadRabbit dropped files: https://www.virustotal.com/#/file/301b905eb98d8d6bb559c04bbda26628a942b2c4107c07a02e8f753bdcfe347c/details

.EXAMPLE

ls 'C:\Program Files (x86)\Sysinternals Suite\*' -Include '*.dll', '*.exe', '*.sys' -Recurse | ? { (Get-WinCertificateHash -FilePath $_.FullName) -eq '481976F3E74419DCA3181B8BD2529EE13A311D2721A2A05E48DF259FAB5315F6' }

Attempts to find a BadRabbit Authenticode hash match within the "Sysinternals Suite" directory.

.INPUTS

System.IO.FileInfo

Accepts the input from Get-ChildItem.

.OUTPUTS

String

Outputs the SHA256 hash of the WIN_CERTIFICATE structure of an Authenticode signed PE file.
#>

    [CmdletBinding()]
    [OutputType([String])]
    param (
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [String[]]
        [ValidateNotNullOrEmpty()]
        [Alias('FullName')]
        $FilePath
    )

    BEGIN {
        Add-Type -TypeDefinition @'
            using System;
            using System.Runtime.InteropServices;
            using Microsoft.Win32.SafeHandles;

            namespace Crypto {
                public class NativeMethods {
                    [DllImport("msvcrt.dll")]
                    public static extern IntPtr memset(IntPtr dest, uint src, uint count);
                    [DllImport("Imagehlp.dll", CharSet = CharSet.Auto, SetLastError = true)]
		            public static extern bool ImageGetCertificateData(SafeFileHandle FileHandle, int CertificateIndex, [Out] IntPtr CertificateHeader, ref uint RequiredLength);
                }
            }
'@
    }

    PROCESS {
        foreach ($IndividualFile in $FilePath) {
            $FileFullPath = (Resolve-Path $IndividualFile).Path
            $SigInfo = Get-AuthenticodeSignature -FilePath $FileFullPath -ErrorAction SilentlyContinue

            if ($SigInfo -and ($SigInfo.SignatureType -eq 'Authenticode')) {
                Write-Verbose "Is Authenticode signed: $FileFullPath"
                $File = [IO.File]::OpenRead($FileFullPath)

                if ($File) {
                    $ZeroPtr = [IntPtr]::Zero
                    $WIN_CERTIFICATE_Length = [UInt32] 0
                    $Result = [Crypto.NativeMethods]::ImageGetCertificateData($File.SafeFileHandle, 0, $ZeroPtr, [Ref] $WIN_CERTIFICATE_Length);$LastError = [Runtime.InteropServices.Marshal]::GetLastWin32Error()

                    if (($LastError -ne 122) -or ($WIN_CERTIFICATE_Length -eq 0)) {
                        # 122 = The data area passed to a system call is too small
                        $File.Close()
                        throw "An unknown error occured in ImageGetCertificateData: $FileFullPath. Error message $([ComponentModel.Win32Exception] $LastError)"
                        return
                    }

                    $HeaderPtr = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($WIN_CERTIFICATE_Length)
                    $null = [Crypto.NativeMethods]::memset($HeaderPtr, 0, $WIN_CERTIFICATE_Length)
                    $Result = [Crypto.NativeMethods]::ImageGetCertificateData($File.SafeFileHandle, 0, $HeaderPtr, [Ref] $WIN_CERTIFICATE_Length);$LastError = [Runtime.InteropServices.Marshal]::GetLastWin32Error()

                    if ($Result -eq $False) {
                        [System.Runtime.InteropServices.Marshal]::FreeHGlobal($HeaderPtr)
                        $File.Close()
                        throw "Unable to obtain WIN_CERTIFICATE from: $FileFullPath. Error message: $([ComponentModel.Win32Exception] $LastError)"
                        return
                    }

                    $WIN_CERTIFICATE_Length = [System.Runtime.InteropServices.Marshal]::ReadInt32($HeaderPtr)
            
                    Write-Verbose "WIN_CERTIFICATE Langth: 0x$($WIN_CERTIFICATE_Length.ToString('X8'))"
            
                    $WIN_CERTIFICATE_Bytes = New-Object Byte[]($WIN_CERTIFICATE_Length)

                    [System.Runtime.InteropServices.Marshal]::Copy($HeaderPtr, $WIN_CERTIFICATE_Bytes, 0, $WIN_CERTIFICATE_Length)
        
                    $Hasher = [Security.Cryptography.SHA256CryptoServiceProvider]::Create()
                    $HashBytes = $Hasher.ComputeHash($WIN_CERTIFICATE_Bytes)

                    ($HashBytes | % { '{0:X2}' -f $_ }) -join ''

                    [System.Runtime.InteropServices.Marshal]::FreeHGlobal($HeaderPtr)
                    $File.Close()
                }
            } else {
                Write-Verbose "Not Authenticode signed: $FileFullPath"
            }
        }
    }
}