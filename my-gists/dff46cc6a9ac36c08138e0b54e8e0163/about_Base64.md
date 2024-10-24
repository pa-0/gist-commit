# about `Base64`

## Contents

- [Original (Forked) Script(`.ps1`)](https://gist.github.com/pa-0/dff46cc6a9ac36c08138e0b54e8e0163#file-convert_binary_file_to_base64-ps1)
- [A More Efficient Base64 Conversion Approach](https://gist.github.com/pa-0/dff46cc6a9ac36c08138e0b54e8e0163#file-a-more-efficient-base64-conversion-in-pwsh-md)
- [Better Base64-Encode/Decode(`.ps1`)](https://gist.github.com/pa-0/dff46cc6a9ac36c08138e0b54e8e0163#file-better-b64encode_decode-ps1)

## Notes

_(**Source**: https://stackoverflow.com/questions/42592518/encode-decode-exe-into-base64)_

###  Troubleshooting: Binary not recognized by Windows?

The problem was most likely caused by use of:

1.  `Get-Content` <ins>without</ins> the `-Raw` flag which splits the file into an array of lines thus destroying the code
2.  `Text.Encoding` which interprets the binary code as text thus destroying the code
3.  `Out-File` which  is for text data, not binary code

The correct approach is to use `[IO.File]:`

[`ReadAllBytes`](https://msdn.microsoft.com/en-us/library/system.io.file.readallbytes\(v=vs.110\).aspx) to encode:

```powershell
$base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($FileName))
```

and 

[`WriteAllBytes`](https://msdn.microsoft.com/en-us/library/system.io.file.writeallbytes\(v=vs.110\).aspx) to decode:

```powershell
[IO.File]::WriteAllBytes($FileName, [Convert]::FromBase64String($base64string))
```

<br/>

> [!Note]
> 
>- `$base64String` as referenced above is converted to plain ASCII text at which point it is safe to use the standard text-based commands / `Out-File`


Putting it together in PowerShell Script (written for a full-circle conversion):

```powershell
$FileName    = "C:\src\originalbin.dll"
$base64string = "C:\Src\binasbase64.txt"
$regenerated  = "C:\src\regenerated.dll"

# binary to text
[IO.File]::WriteAllBytes($base64string,[char[]][Convert]::ToBase64String([IO.File]::ReadAllBytes($FileName)))

# text back to binary
[IO.File]::WriteAllBytes($regenerated, [Convert]::FromBase64String([char[]][IO.File]::ReadAllBytes($base64string)))
```

### Command Prompt Alternative (No PowerShell Necessary)

Windows comes with `certutil.exe` (a tool to manipulate certificates) which can base64 encode and decode files.

```bash
certutil -encode source.exe b64output.txt
certutil -decode b64.txt output.exe
```

<br/>

>[!Important]
>- If the base64-encoded text is created by `certutil`,
>it will be wrapped by the following header/footer:
>   ```
>   
>   -----BEGIN CERTIFICATE-----
>   
>     < Base64-Encoded File >
>
>   ------END CERTIFICATE------
>   
>   ```
>

After removing these lines the PowerShell command above will decode it. `Certutil` ignores them so it will decode its own output or the PowerShell output.