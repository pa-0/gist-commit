if ($PROFILE.EndsWith('Microsoft.Powershell_profile.ps1', [System.StringComparison]::CurrentCultureIgnoreCase)) {
	if ($PROFILE.IndexOf("OneDrive", [System.StringComparison]::CurrentCultureIgnoreCase) -ge 0) {
		$gistlocation = Join-Path $PSScriptRoot 'Microsoft.Powershell_profile.ps1'
		Write-Output $gistlocation
		Set-Content -Path $PROFILE -Value ". $gistlocation"
		$theme = Join-Path $PSScriptRoot 'powerline.omp.json'
		Copy-Item $theme ($PROFILE | Split-Path -Resolve) -Force
	}
	else {
    	$currentFile = Join-Path $PSScriptRoot Microsoft.Powershell_profile.ps1
    	New-Item -ItemType SymbolicLink -Path $PROFILE -Value $currentFile
    }
}
