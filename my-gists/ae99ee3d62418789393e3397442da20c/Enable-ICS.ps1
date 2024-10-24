## Restart ICS when specified MAC address not present in ARP cache (DHCP not working)
# 
# Schedule on system startup:
# schtasks /create /SC ONSTART /DELAY 0005:00 /TN RB\TerminalICS /RU SYSTEM /RL HIGHEST /TR "powershell -file c:\temp\Enable-ICS.ps1 >> c:\temp\enable-ics.log"

function global:Enable-ICS
{
Param (
    [String]
    [ValidateSet('status','enable','disable')]
    $state="status"
)
    $m = New-Object -ComObject HNetCfg.HNetShare
    if ($m.EnumEveryConnection -ne $null) {
        #$m.EnumEveryConnection | foreach { $m.NetConnectionProps.Invoke($_) }
    
        # Find interfaces by its network category
        $pubConnName = (Get-NetConnectionProfile | where {$_.NetworkCategory -eq 'Public'}).InterfaceAlias
        $privConnName = (Get-NetConnectionProfile | where {$_.NetworkCategory -in 'Private', 'DomainAuthenticated'}).InterfaceAlias
    
        $pubConn = $m.EnumEveryConnection | where {$m.NetConnectionProps.Invoke($_).Name -eq $pubConnName}
        $privConn = $m.EnumEveryConnection | where {$m.NetConnectionProps.Invoke($_).Name -eq $privConnName}

        $pubConnConf = $m.INetSharingConfigurationForINetConnection.Invoke($pubConn)
        $privConnConf = $m.INetSharingConfigurationForINetConnection.Invoke($privConn)

        switch($state) {
            'enable' {
                $pubConnConf.EnableSharing(1)
                $privConnConf.EnableSharing(0)
                Write-Host "ICS was enabled on $pubConnName as $($m.NetConnectionProps.Invoke($pubConn))"
                Write-Host "ICS was enabled on $privConnName as $($m.NetConnectionProps.Invoke($privConn))"
            }
            'disable' {
                $pubConnConf.DisableSharing()
                $privConnConf.DisableSharing()
                Write-Host "ICS was disabled on all interfaces"
                Write-Host "$pubConnName : $($m.NetConnectionProps.Invoke($pubConn))"
                Write-Host "$privConnName : $($m.NetConnectionProps.Invoke($privConn))"
            }
            'status' {
                $m.NetConnectionProps.Invoke($pubConn)
                $pubConnConf
                $m.NetConnectionProps.Invoke($privConn)
                $privConnConf
            }
            default {
                Write-Warning "Valid operations are: enable | disable | status"
            }
        }
    } else {
        Write-Error "No ICS connection found. Are you admin?"
    }
}

# Find MAC of the terminal device
$try = 0
while ((arp -a -N 192.168.137.1 | where {$_ -like '*54-e1-40-1b-09-fc*'}) -eq $null -and $try++ -lt 3) {
    Write-Warning "Device is not connected, trying to restart ICS..."
    global:Enable-ICS -state disable
    Start-Sleep -Seconds 5
    global:Enable-ICS -state enable
    Start-Sleep -Seconds 20
}
if ($try -eq 3) {
    Write-Error "Device was not found on network after 3 attempts"
} else {
    Write-Information "Device is connected"
    $ip = (arp -a -N 192.168.137.1 | where {$_ -like '*54-e1-40-1b-09-fc*'}).Trim().Split(' ')[0]
    if (Test-Connection $ip -quiet) {
        Write-Information " and responds to ping"
    } else {
        Write-Warning " but not responding to ping"
    }
}
