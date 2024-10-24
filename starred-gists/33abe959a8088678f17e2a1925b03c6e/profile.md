# POWERSHELL PROFILE

```powershell
Windows PowerShell 5.1

Profile Path
Current User - Current Host $Home\[My ]Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
Current User - All Hosts $Home\[My ]Documents\WindowsPowerShell\Profile.ps1
All Users - Current Host $PSHOME\Microsoft.PowerShell_profile.ps1
All Users - All Hosts $PSHOME\Profile.ps1
💡 The $Home variable references the current users home directory while the $PSHOME variable references the installation path of PowerShell.

PowerShell 7.x

Profile Path
Current User - Current Host - Windows $Home\[My ]Documents\Powershell\Microsoft.Powershell_profile.ps1
Current User - Current Host - Linux/macOS ~/.config/powershell/Microsoft.Powershell_profile.ps1
Current User - All Hosts - Windows $Home\[My ]Documents\Powershell\Profile.ps1
Current User - All Hosts - Linux/macOS ~/.config/powershell/profile.ps1
All Users - Current Host - Windows $PSHOME\Microsoft.Powershell_profile.ps1
All Users - Current Host - Linux/macOS /usr/local/microsoft/powershell/7/Microsoft.Powershell_profile.ps1
All Users - All Hosts - Windows $PSHOME\Profile.ps1
All Users - All Hosts - Linux/macOS /usr/local/microsoft/powershell/7/profile.ps1
```
