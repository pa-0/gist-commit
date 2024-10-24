;*******************************************************
; Want a clear path for learning AHK; Take a look at our AutoHotkey courses.
; They're structured in a way to make learning AHK EASY: https://the-Automator.com/Learn
;*******************************************************

; Create certificate
$cert = New-SelfSignedCertificate -Subject "{CertName}" -CertStoreLocation "cert:\CurrentUser\My" -HashAlgorithm sha256 -type CodeSigning

; Create password
$pwd = ConvertTo-SecureString -String "{123456}" -Force -AsPlainText

; Export Certificate to a file
Export-PfxCertificate -cert $cert -FilePath {CertName}.pfx -Password $pwd

; Sign the executable
signtool.exe sign /f {CertName.pfx /fd sha256 /p 123456 {Program}.exe
