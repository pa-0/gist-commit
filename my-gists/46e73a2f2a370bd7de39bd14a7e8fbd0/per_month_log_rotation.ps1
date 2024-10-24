#region Logging
	$LogFilePath = "$(Split-Path $Script:MyInvocation.MyCommand.Path)\$([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))-$((Get-Date -format MMM).ToUpper()).log"
	
	function Add-ToLog {
		[CmdletBinding(SupportsShouldProcess=$True,DefaultParameterSetName="None")]
		PARAM(
			[string]
			$Message
		)	
		Add-Content -Path $LogFilePath -Value "$(Get-Date -format 'yyyy-MM-dd hh:mm:ss')$(' ' * 3)$($Message)"
	}
	Add-Content -PassThru $LogFilePath -Value ""
#endregion