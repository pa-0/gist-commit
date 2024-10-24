# Save script to temp folder
Save-Script -Name Get-WindowsAutoPilotInfo -Path C:\Windows\Temp
# Install script
Install-Script -Name Get-WindowsAutoPilotInfo
# Run script
Get-WindowsAutoPilotInfo.ps1 -OutputFile C:\Users\%USER%\Desktop\autopilot.csv