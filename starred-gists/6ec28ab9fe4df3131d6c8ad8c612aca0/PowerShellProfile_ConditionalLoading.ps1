function Get-KeyState([uint16]$keyCode)
{
  $signature = '[DllImport("user32.dll")]public static extern short GetKeyState(int nVirtKey);'
  $type = Add-Type -MemberDefinition $signature -Name User32 -Namespace GetKeyState -PassThru
  return [bool]($type::GetKeyState($keyCode) -band 0x80)
}
$VK_SHIFT = 0x10
function OutputStatus($message){
    try {
        [Console]::SetCursorPosition(0,0)
        Write-Host $message.PadRight([Console]::BufferWidth)
    }
    catch [System.IO.IOException] {
        ## IO Exception when unable to set position
    }
}
$messages = @()

OutputStatus "Loading posh-git"
# Load posh-git example profile
if(Test-Path Function:\Prompt) {Rename-Item Function:\Prompt PrePoshGitPrompt -Force}
. 'C:\tools\poshgit\dahlbyk-posh-git-7acc70b\profile.example.ps1'
Rename-Item Function:\Prompt PoshGitPrompt -Force
function Prompt() {if(Test-Path Function:\PrePoshGitPrompt){++$global:poshScope; New-Item function:\script:Write-host -value "param([object] `$object, `$backgroundColor, `$foregroundColor, [switch] `$nonewline) " -Force | Out-Null;$private:p = PrePoshGitPrompt; if(--$global:poshScope -eq 0) {Remove-Item function:\Write-Host -Force}}PoshGitPrompt}

OutputStatus "Loading Show-Ast"
Import-Module C:\source\_libsetc\ShowPSAst\Show-Ast.psm1

OutputStatus "Loading posh-HumpCompletion"
Import-Module posh-HumpCompletion

OutputStatus "Loading posh-docker"
Import-Module posh-docker


if ((-not (Get-KeyState($VK_SHIFT))) `
	-or (Get-Process -id  $pid).ProcessName -eq "Microsoft.PowerShell.EditorServices.Host"){ # skip if in VS Code!
    OutputStatus "Skipping loading Azure PS profile"
    $messages += "Skipped loading Azure PS profile"
} else {
    OutputStatus "Loading Azure PS profile"
    Select-AzureRmProfile -Path C:\Users\Stuart\OneDrive\AzureRmProfile.json | out-null
}

OutputStatus "Done"
Write-Host $messages
Write-Host ""