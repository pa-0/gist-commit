# Get-SystemDriver requires the ConfigCI module on Win10 Enterprise
# This will collect all signer information for all PEs in C:\
# This will take a while!!!
$Signers = Get-SystemDriver -ScanPath C:\ -UserPEs

# Associate the subject name of each certificate to the file/signer info
# so we can correlate the two.
$CertSubjectMapping = $Signers | % {
    $Signer = $_

    $Signer.Signers.Certificates.Subject | % {
        [PSCustomObject] @{
            CertSubject = $_
            Signer = $Signer
        }
    }
}

# Group all signer/file info by its respective certificate subject name
$CertSubjectGrouping = $CertSubjectMapping | Group-Object -Property CertSubject

# Start digging. Display certificate subject names in order of frequency.
# I can guarantee you will be intrigued/concerned by some of the lesser common cert subject names.
$CertSubjectGrouping | Sort Count -Descending | Select Count, Name

# Once you've identified an 'interesting' subject name, see what files were signed with that certificate.
# Example:
<#
$InterestingCert = $CertSubjectGrouping | ? { $_.Name -eq 'CN=Dummy certificate' }
$InterestingCert.Group.Signer

# It turns out that 'CN=Dummy certificate' is in the certificate chain of Google Chrome binaries.
#>