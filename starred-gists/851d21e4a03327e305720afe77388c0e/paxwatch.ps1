Write-Host -fore green '===PAX CHECKER==='
Write-Host -fore green '===This will open a browser to the ticket window if PAX goes on sale==='
$result = $null
do {
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	Write-Host -fore gray "$(Get-Date): Checking ShowClix for PAX"
	$paxEvents = (Invoke-RestMethod -Headers @{'Cache-Control' = 'max-age=0'} 'https://www.showclix.com/rest.api/Partner/48/events').psobject.properties.value |
		Where-Object { $PSItem.event -match 'PAX' -and $PSItem.event -notmatch 'BYOC|Special|Media|Exhibitor' }
	$result = $paxEvents |
		Where-Object {
			[datetime]$PSItem.date_added -ge (Get-Date).AddDays(-1)
		} |
		Foreach-Object listing_url

	if ($result) {
		Write-Host -fore Green '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
		Write-Host -fore Green "***ITS PAX TIME!*** Opening $($result -join ',') in 3 new browser windows or tabs"
		Write-Host -fore Green '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
		[media.soundplayer]::New('C:\Windows\media\Alarm01.wav').PlayLooping()
		$result | ForEach-Object {
			$url = $PSItem
			0..3 | ForEach-Object {
				Start-Process $url
			}
		}
	} else {
		Write-Host -fore Gray 'No Pax For Now :( Checking again in 1 second...'
		Start-Sleep 1
	}
} while (-not $result)