# WSL2 cheatsheet

## Install WSL2

1. Install Windows Terminal from Microsoft Store
2. Install WSL2 with `wsl --install` in PowerShell as admin

## Format fractured WSL2 volume (vhdx)

1. Open PowerShell as admin
2. `wsl --shutdown`
3. `Optimize-VHD -Path [PATH TO ext4.vhdx] -Mode Full`

Path is usually:
C:\Users\<YOUR USER>\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu\_\*\*\*\LocalState\ext4.vhdx
