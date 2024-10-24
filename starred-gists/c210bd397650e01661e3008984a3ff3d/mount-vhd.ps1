param([switch]$Elevated)

function Test-Admin {
  $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) 
    {
        # tried to elevate, did not work, aborting
    } 
    else {
        Start-Process pwsh.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
}

exit
}

'running with full privileges'
$ErrorActionPreference = "Stop"

Write-Output "Montando VHD...."
$disk_number =  (Mount-VHD -Path .\projects.vhdx -PassThru | Get-Disk).Number
Write-Output "VHD montada com sucesso"
Write-Output "Montando disco no WSL"
wsl --mount \\.\PHYSICALDRIVE$disk_number
Write-Output "Disco montado no WSL"

