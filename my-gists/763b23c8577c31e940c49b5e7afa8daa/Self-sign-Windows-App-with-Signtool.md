# Self Sign a Windows Desktop Application with SignTool
Requires PowerShell to be installed on your PC. Will require installing the signtool which is part of Windows SDK.
There are 4 major steps.

## Step 1) Get your Microsoft Developer Publisher Id
Go to <a href="https://partner.microsoft.com/en-us/dashboard/apps-and-games/overview">partner.microsoft.com/en-us/dashboard/apps-and-games</a> > Select your app > click Product Identity > Copy the Package/Identity/Publisher value.<br>
It should be formatted something like CN=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX replacing the Xs with hexadecimal characters.

## Step 2) Create a self signed certificate
Use the New-SelfSignedCertificate PowerShell cmdlet.<br>
Reference: <a href="https://learn.microsoft.com/en-us/windows/msix/package/create-certificate-package-signing#use-new-selfsignedcertificate-to-create-a-certificate">learn.microsoft.com/en-us/windows/msix/package/create-certificate-package-signing#use-new-selfsignedcertificate-to-create-a-certificate</a>

### Sub-Steps:
1. Open PowerShell as administrator: Search: Windows PowerShell > Right-click Windows PowerShell > Run as Administrator
2. Run the New-SelfSignedCertificate PowerShell cmdlet to create the self signed certificate.
  - The "Subject" in the certificate must match the "Publisher" section in your app's manifest.
  - Friendly name can be whatever you want. Example: mySelfSignedCert.
  - The certificate will be added to the local certificate store, as specified in the "-CertStoreLocation" parameter. The result of the command will also produce the certificate's thumbprint.
  - `New-SelfSignedCertificate -Type Custom -Subject "<publisher ID>" -KeyUsage DigitalSignature -FriendlyName "<Your friendly name goes here>" -CertStoreLocation "Cert:\CurrentUser\My" -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}")`

3. View the certificates in your local store with PowerShell cmd:<br>
```
Set-Location Cert:\CurrentUser\My
Get-ChildItem | Format-Table Subject, FriendlyName, Thumbprint`
```
  - Note: Certificates expire after one year.
  - Copy the Thumbprint value for use in step 4. It will be some long hexadecimal character string.
  - To delete a cert, run: `PS Cert:\CurrentUser\My> Remove-Item -Path Cert:\CurrentUser\My\{thumbprint} -DeleteKey`

4. Export the Self-Signed Certificate
  - Set a password. To make it secure, set it to a variable:
    `ConvertTo-SecureString -String <your password> -Force -AsPlainText `
  - Determine the file path where you want to store the certificte.
  - Then export the certificate with PowerShell (running as Administrator) commands:<br>
`$password = ConvertTo-SecureString -String <Your Password> -Force -AsPlainText`<br>
`Export-PfxCertificate -cert "Cert:\CurrentUser\My\<Certificate Thumbprint>" -FilePath <FilePath>.pfx -Password $password`

- For example, if:
  - My Certificate Thumbprint is: 0123456789ABCDEF
  - My password is "myPassword", 
  - The certificate location is `C:\Users\MyUsername\Documents\myCert\mySelfSignedCert.pfx`
  - Then the command would be:<br>
`$password = ConvertTo-SecureString -String myPassword -Force -AsPlainText`<br>
`Export-PfxCertificate -cert "Cert:\CurrentUser\My\0123456789ABCDEF" -FilePath C:\Users\MyUsername\Documents\myCert\myselfsignedcert.pfx -Password $password`<br>

  - And my self signed digital certificate would be exported to: C:\Users\MyUsername\Documents\myCert\myselfsignedcert.pfx

------------------------------------------------------------
## Step 3) Install the Windows SDK sign tool
Reference: <a href="https://learn.microsoft.com/en-us/windows/win32/seccrypto/signtool">learn.microsoft.com/en-us/windows/win32/seccrypto/signtool</a>

- Download the Windows SDK application installer: 
<a href="https://developer.microsoft.com/en-us/windows/downloads/windows-sdk/">developer.microsoft.com/en-us/windows/downloads/windows-sdk</a>
- Then open the setup file and follow the installation process.
- During the installation process, it will give you the opportunity to choose which features to install. You only really need the "Windows SDK Signing Tools for Desktop Apps" feature so if you want to save disc space, you can deselect the rest.

------------------------------------------------------------
## Step 4) Sign your app installer file
Assume you have a Windows application installer file with a name like myApp.appx.

There are two ways you can sign the app. Using PowerShell commands, or use the third-party SignGUI application. The latter is easier and saves your input so we'll start with that.

------------------------------------------------------------
## Step 4 GUI App option) Sign your app using the SignGUI application
SignGUI is a free GUI tool for digitally signing Microsoft Desktop applications.

Download it from: <a href="briggsoft.com/signgui.htm">https://www.briggsoft.com/signgui.htm</a><br>
For reference there is a Youtube video on how to use it: <a href="https://www.youtube.com/watch?v=zqd80Yp9ZSc&ab_channel=ChrisSpeciale">youtube.com/watch?v=zqd80Yp9ZSc&ab_channel=ChrisSpeciale</a>

Once downloaded, click the installer. You can accept all the defaults.

Once installed you can open the SignGUI app from Windows > Apps or from the Desktop Shortcut.

It will display a form. Fill out the following fields:
- SignTool Location: This is the path to the signtool.exe file.
To get the path, go to File Explorer and search for "signtool.exe" > Right-click the result > Select "Copy as path" > Paste it into the SignTool Location field and remove the quotes.<br>
It may be something like the following:<br>
`C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64\signtool.exe`

- Personal Information Exchange (PFX) file:
Get the path of your self-signed certificate. Something like:
`C:\Users\MyUsername\Documents\myCert\mySelfSignedCert.pfx`
- If you set a password, put it in the Password field (e.g., myPassword).
- Timestamp Service URL: Certificates expire after one year unless they are timestamped. 
For testing the installer you don't need a timestamp so you can leave that blank.
If this was a purchased Code Signing Certificate for distributing your application to outside users, you would need to add the CodeSigning services timestamp URL. The Sectigo timestamp URL for example is: http://timestamp.sectigo.com
- If you added a timestamp URL, check both RFC 3161 server and SHA256 timestamp.
- Program Files to Sign: Click Add button > Find the path to your .appx file > Click Open.
- Signature Placement: Primary
- Signature Hash: SHA256
- Result Message: Normal

Click the Sign Files button.

If successfully signed it should return a message saying "Successfully signed".

Close the SignGUI app. It will ask you to save your changes. For convenience, you can place the file where your .pfx file is. Give it a recongnizable name like selfSignedGui. Then you can just double click that file to open the signGUI app with the saved information.

To confirm the installer file (e.g., myApp.appx) is signed: Right-click the file > select Properties > if signed there will be a Digital Signatures tab > In the tab is your digital signature.

Double click the installer file and it will open the installation program. Click install and it will install it.

To uninstall the app: Windows > Apps > Right-click your app > Uninstall > Double-click your app to uninstall it.

------------------------------------------------------------
## Step 4 Command Line option) Sign your app using the PowerShell command line
Instead of installing and using the signGUI application, you can use the PowerShell command line.

Reference: <a href="https://learn.microsoft.com/en-us/windows/win32/appxpkg/how-to-sign-a-package-using-signtool">learn.microsoft.com/en-us/windows/win32/appxpkg/how-to-sign-a-package-using-signtool</a>

### Add the signtool.exe file to your PC's System Path environment variable:
To check if it is already in your Path, open PowerShell and enter: `signtool`<br>
If it asks for a SignTool parameter then it's installed.<br> 
If it says "command SignTool not found" then it needs to be added to the System Path.

### Sub-Steps:
1. Get the signtool.exe path: open File Explorer > Search for <b>signtool.exe</b> > Right-click the result > Select "Copy as path".<br>
It may be something like the following:<br>
`"C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64\signtool.exe"`

2. Edit the System Environment Path variable: Search: env > Click "Edit the system environment variables" > Advanced tab > Environment Variables button > System variables: select Path > Edit > New (to enter a new path to the Path Environment variable) > Paste the path to the signtool.exe file (remove the surrounding quotes, the filename itself, and the trailing slash)<br>
It may be something like the following:<br>
`C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64`<br>
Then click the OK button.

3. Sign the app. 
- Run the PowerShell (as Administrator) command:
`SignTool sign /fd <Hash Algorithm> /a /f <Path to Certificate>.pfx /p <Your Password> <File path>.appx`
- The hash algorithm used by electron-builder for an appx build is: SHA256
- Put paths in quotes if there are any spaces.
- The actual command could look like:
`SignTool sign /fd SHA256 /a /f C:\Users\UserName\Documents\myCert\myselfsignedcert.pfx /p myPassword "C:\Users\UserName\Documents\myApp.appx"`

- If successful it should return a message that says something like:<br>
Done Adding Additional Store<br>
Successfully signed:<br>
C:\Users\UserName\Documents\myApp.appx

4. Install the Certificate:
- Open File Explorer > Go to your app's appx file > Right-click appx file > Properties > Digital Signatures tab > Select signature from list > click Details button > click View Certificate button > click Install Certificate button - This will open the Certificate Import Wizard
- In the Certificate Import Wizard window: Store Location: select Local Machine > click Next > select Place all certificates in the following store > click Browse button > In the Select Certificate Store pop-up window select: Trusted People then click OK button > click Next > click Finish button > If successful a confirmation dialog should appear: The import was successful.

Now the appx installer is self signed and your Windows Application can be installed and tested on your PC.

To confirm the installer file (e.g., myApp.appx) is signed: Right-click the file > select Properties > if signed there will be a Digital Signatures tab > In the tab is your digital signature.

Double click the installer file and it will open the installation program. Click install and it will install it.

To uninstall the app: Windows > Apps > Right-click your app > Uninstall > Double-click your app to uninstall it.