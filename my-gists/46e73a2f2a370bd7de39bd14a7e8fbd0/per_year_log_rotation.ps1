#region Logging

# Start Logging
$LogFilePath = "$($env:TEMP)\$([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)).log"
# Log file rotation per-year
if ((Test-Path -Path $LogFilePath -PathType Container) -ne $null) {
	if ((Get-ChildItem -Path $LogFilePath).LastWriteTime.Year -ne (Get-Date).Year) {
		Move-Item -Path $LogFilePath -Destination "$LogFilePath.bak" -Force -ErrorAction SilentlyContinue | Out-Null
	}
}

function Add-ToLog {
	[CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName="None")]
	PARAM(
	    [string]
		$Message
	)	
	Add-Content -Path $LogFilePath -Value "$(Get-Date -format 'yyyy-MM-dd hh:mm:ss')$(' ' * 3)$($Message)"
}
#endregion
