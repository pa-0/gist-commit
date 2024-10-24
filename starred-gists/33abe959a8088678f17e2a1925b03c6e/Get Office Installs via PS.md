# ​Get Office Installs via PS

```powershell
Get-ItemProperty HKLM:\Software\Microsoft\Office\*\Registration\* | Select-Object ProductName

Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "Microsoft Office*"} | Select-Object Name, Version

Get-ItemProperty HKLM:\Software\Microsoft\Office\*\Registration\* | Select-Object ProductName

Get-ChildItem -Path "C:\Program Files\Microsoft Office*" | Select-Object Name, LastWriteTime

$officeInstalls = Get-ItemProperty HKLM:\Software\Microsoft\Office\*\Registration\*
$installedProducts = @()

foreach ($officeInstall in $officeInstalls) {
  $installPath = $officeInstall.InstallPath + "Office"
  $productName = $officeInstall.ProductName
  if (Test-Path -Path $installPath) {
    $installedProducts += New-Object PSObject -Property @{
      Name = $productName
      InstallPath = $installPath
    }
  }
}

$installedProducts

```
