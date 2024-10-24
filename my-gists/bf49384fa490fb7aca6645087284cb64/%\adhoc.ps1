#at top of script
if (!
	#current role
	(New-Object Security.Principal.WindowsPrincipal(
		[Security.Principal.WindowsIdentity]::GetCurrent()
	#is admin?
	)).IsInRole(
		[Security.Principal.WindowsBuiltInRole]::Administrator
	)
) {
	#elevate script and exit current non-elevated runtime
	Start-Process `
		-FilePath 'powershell' `
		-ArgumentList (
			#flatten to single array
			'-File', $MyInvocation.MyCommand.Source, $args `
			| %{ $_ }
		) `
		-Verb RunAs
	exit
}

'Host network?'
Pause

netsh interface set   interface     'name="WiFi"' 'admin=disabled'
netsh wlan      set   hostednetwork 'mode=allow'  'ssid=sneaky'    'key=icantthinkofanything'
netsh wlan      start hostednetwork
netsh interface set   interface     'name="WiFi"' 'admin=enabled'

'Forward ports?'
Pause



$sneak = (
	wsl -- ip addr show eth0 `
	| ?{ $_ -match '(?<=inet )[\d.]+' } `
	| %{ $Matches }
)[0]


#$interface = (
#	Get-NetAdapter -Name 'Local Area Connection*'
#).Name
#$box = '192.168.0.1'
#
#$old = @(
#	Get-NetIPAddress -InterfaceAlias $interface `
#	| %{ $_.IPAddress }
#)
#if (!$box) {
#	$box = $old[0]
#}
#else {
#	"Currently '$old', switching to '$box'"
#	if (!($old | ?{ $_ -eq $box })) {
#		New-NetIPAddress `
#			-InterfaceAlias $interface `
#			-IPAddress $box `
#			-PrefixLength 24 `
#		| Out-Null
#	}
#	$old = $old | ?{ $_ -ne $box}
#	if ($old) {
#		Remove-NetIPAddress $old
#	}
#}
#
#$port = '8080'
#&"$PSScriptRoot/tinymapper_wepoll.exe" -l "$($box):$port" -r "$($sneak):$port" -t #-u
##netsh interface portproxy delete v4tov4 "listenport=$port" <#"listenaddress=$box"#>
##netsh interface portproxy add    v4tov4 "listenport=$port" <#"listenaddress=$box"#> "connectport=$port" "connectaddress=$sneak"


Set-VMSwitch -SwitchName 'WSL' -NetAdapterName 'WiFi'
bash -c (@"
	sudo ip addr add 10.0.0.50/24 broadcast 10.0.0.255 dev eth0 label eth0:1
	sudo ip addr del $sneak/20 broadcast 172.24.223.255 dev eth0 label eth0
	sudo route del -net 0.0.0.0/0
	sudo route add -net 0.0.0.0/0 gw 10.0.0.1
"@ -replace '\r','')



'Teardown network?'
Pause

netsh wlan stop hostednetwork
netsh wlan set  hostednetwork 'mode=disallow'

'Done!'
Pause