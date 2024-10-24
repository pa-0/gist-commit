<#
  pwsh - PowerShell Core v6+; $PROFILE = ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
#>
    

Import-Module posh-git

Set-Alias -Name notepad -Value "$env:USERPROFILE\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd"
Set-Alias -Name edit -Value "$env:USERPROFILE\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd"

<#
Set-Alias -Name ssl-vpn -Value "C:\Program Files (x86)\VMware\SSL VPN-Plus Client\SVPClient.exe"
#>

$env:Path += ";C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE" 
$env:Path += ";C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE" 

function edit-hosts
{
    code C:\Windows\system32\drivers\etc\hosts
}

function edit-profile
{ 
    code $PROFILE
}

function git-fetch
{ 
    git fetch
}

function git-pull
{ 
    git fetch
    git pull
}

function git-push
{ 
    git fetch
    git push
}

function git-sync
{ 
    git fetch
    git pull
    git push
}

function git-cleanup
{
	[CmdletBinding()]
	param (
		[Parameter()]
		[String]
		$Branch
    )
	
	git push origin $Branch --delete
	git branch -D $Branch
}

function netonly
{ 
	[CmdletBinding()]
	param (
		[Parameter()]
		[String]
		$Domain,
		[Parameter()]
		[String]
		$Cmd
    )
	try {
		Set-Item "env:netonlydomain" $Domain
		runas /netonly /noprofile /user:$Domain\$env:UserName $Cmd
		Start-Sleep -Seconds 5
	}
	finally {
		Set-Item "env:netonlydomain" $null	
	}
}

function Test-IsAdmin {
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal -ArgumentList $identity
        return $principal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )
    } catch {
        throw "Failed to determine if the current user has elevated privileges. The error was: '{0}'." -f $_
    }

    <#
        .SYNOPSIS
            Checks if the current Powershell instance is running with elevated privileges or not.
        .EXAMPLE
            PS C:\> Test-IsAdmin
        .OUTPUTS
            System.Boolean
                True if the current Powershell is elevated, false if not.
    #>
}