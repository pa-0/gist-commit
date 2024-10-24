Write-Host "Begin init the system environment...."

# 安装 gsudo
Write-Host "Installing gsudo ...."
winget install "gsudo"
Write-Host "Installing gsudo Successfully"

# 下载 NF 字体，需手动安装
Write-Host "Installing NF font ....."
Start-BitsTransfer -Source "http://cloud.coderthinking.com/s/cbxgYLMzSK8DWdm/download?path=%2FFonts&files=Meslo.zip&downloadStartSecret=kath89x3t2o" -Destination "E:\Meslo.zip"
Expand-Archive -Path "E:\Meslo.zip" -DestinationPath "E:\Meslo"
Write-Host "Installing NF font successfully" 

# 安装 pwsh 主题
Write-Host "Installing oh-my-posh ....."
Install-Module oh-my-posh -Scope CurrentUser -RequiredVersion 6.42.4
Import-Module oh-my-posh
Set-PoshPrompt -Theme gmay
Write-Host "Installing oh-my-posh successfully" 

# 安装 posh-git 主题
Write-Host "Installing posh-git ....."
Install-Module posh-git -Scope CurrentUser
Write-Host "Installing posh-git successfully" 

# 安装 PSReadLine
Write-Host "Installing PSReadLine...."
Install-Module PSReadLine  -RequiredVersion 2.2.0 -Scope CurrentUser
Write-Host "Installing PSReadLine Successfully"

# 安装 windows terminal
Write-Host "Installing Windows Terminal ...."
winget install "Microsoft.WindowsTerminal"
Write-Host "Installing Windows Terminal Successfully"

# 安装 git
Write-Host "Installing git ...."
winget install "Git.Git"
Write-Host "Installing git successfully"

# 安装 vscode
Write-Host "Installing git ...."
winget install vscode
Write-Host "Installing git successfully" 

# 配置 pwsh
Write-Host "Start download custom pwsh config and config ...."
Start-BitsTransfer -Source "https://gist.githubusercontent.com/ChesterZengJian/37a5fb40c8b84d8a9f2bb2c4960763d0/raw/5df2a6cbe5af875ade6220dc9de116b738635ffa/Microsoft.PowerShell_profile.ps1" -Destination "Microsoft.PowerShell_profile.ps1"
if (Test-Path $PROFILE) {
    Copy-Item "$PROFILE" "$PROFILE.bak"
    Copy-Item .\Microsoft.PowerShell_profile.ps1 "$PROFILE"
    Remove-Item .\Microsoft.PowerShell_profile.ps1
}
Write-Host "Start download custom pwsh config and config successfully"

Write-Host "End init the system environment"