To enable **Windows Subsystem for Linux (WSL)**, the correct command would be:
```powershell
.\Dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux
```

For **Virtual Machine Platform**, use:
```powershell
.\Dism.exe /online /enable-feature /featurename:VirtualMachinePlatform
```

And for **Hyper-V**, the command is:
```powershell
.\Dism.exe /online /enable-feature /featurename:Microsoft-Hyper-V -All
```

Remember to run PowerShell as an administrator to perform these operations.