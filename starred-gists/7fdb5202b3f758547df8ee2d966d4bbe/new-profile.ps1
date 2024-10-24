# This should go into the $PROFILE file. Open in code easily with `code $PROFILE` in a powershell terminal.


if (-not (Get-InstalledModule PSReadline -ErrorAction SilentlyContinue)) {
    Install-Module PSReadline -Force -Confirm:$false -Scope CurrentUser -AllowPrerelease
}
if (-not (Get-Module PSReadline)) {
  Import-Module PSReadline -DisableNameChecking -Global -Force
}
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key Ctrl+C -Function Copy
Set-PSReadLineKeyHandler -Key Ctrl+v -Function Paste

Set-PSReadLineKeyHandler -Key Alt+Backspace -Function ShellKillWord
Set-PSReadLineOption -PredictionViewStyle ListView  # As of 2020-11 only supported with editmode windows https://bit.ly/3lMEKN4
Set-PSReadLineOption -PredictionSource History


if ((Get-Command 'starship' -ErrorAction SilentlyContinue).Count -eq 0) {
    Write-Warning "missing starship so setting up for you"
    choco install starship -y
}

Invoke-Expression (@(&starship init powershell --print-full-init) -join "`n")