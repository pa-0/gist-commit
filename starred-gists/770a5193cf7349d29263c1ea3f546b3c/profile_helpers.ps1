#region Custom Function Definitions
Function Test-Administrator {
    $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $AdministratorRole = [Security.Principal.WindowsBuiltInRole] "Administrator"
    ([Security.Principal.WindowsPrincipal]$CurrentUser).IsInRole($AdministratorRole)
}
#endregion

#region Prompt Prep
# Set ENV for elevated status
If (Test-Administrator) {
    $Env:ISELEVATEDSESSION = 'just needs to be set, never displayed'
}

# Overwrite default color output
$host.PrivateData.ErrorForegroundColor = 'DarkMagenta'
$host.PrivateData.WarningForegroundColor = 'Blue'

# Add autocompletion for gh tool
Invoke-Expression -Command $(gh completion -s powershell | Out-String)

# Add autocomplettion for posh-git
Import-Module -Name posh-git
#endregion
