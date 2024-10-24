	# Log file rotation (keep last 30 logs)
	foreach ($Item In (Get-ChildItem -Path "$($PSScriptRoot)" -Filter "$([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))_*.log" | Sort LastWriteTime -Descending | Select -Skip 30)) {
		$FullName = $Item.FullName
		try {
			$Item | Remove-Item -Force -ErrorAction SilentlyContinue | Out-Null
			Write-CMTraceEvent "Removed log file. ($($FullName))"
		} catch {
			Write-CMTraceEvent -Message "$($_.Exception.InnerException.Message) ($($FullName))" -Severity Error
		}
	}