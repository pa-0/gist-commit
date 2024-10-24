# powershell download wsl distros

```powershell
$URL = 'https://aka.ms/wsl-ubuntu-1804'
$Filename = "$(Split-Path $URL -Leaf).appx"
#$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $URL -OutFile $Filename -UseBasicParsing
Invoke-Item $FileName
```
