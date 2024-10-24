# WSL2 - Network Fix.  
# Gist - https://gist.github.com/machuu/7663aa653828d81efbc2aaad6e3b1431
$CiscoAdapter = Get-NetAdapter | Where-Object {$_.InterfaceDescription -Match "Cisco AnyConnect"}
if($CiscoAdapter.Status -eq "Up"){
    $CiscoMetric = ($CiscoAdapter | Get-NetIPInterface).InterfaceMetric
    $WSLAdapter = Get-NetAdapter | Where-Object {$_.Name -match "WSL"}
    $WSLAdapterMetric = ($WSLAdapter | Get-NetIPInterface).InterfaceMetric

    Write-Host "Getting Cisco Network Adapter"
    write-host "Adapter Name: $($CiscoAdapter.InterfaceDescription) Metric: $CiscoMetric"

    Write-Host "Getting WSL Network Adapter"
    write-host "Adapter Name: $($WSLAdapter.Name) Metric: $WSLAdapterMetric"

    write-host "Setting Interface metric"
    $CiscoAdapter | Set-NetIPInterface -InterfaceMetric 6000
    $WSLAdapter | Set-NetIPInterface -InterfaceMetric 1

    $CiscoAdapter = Get-NetAdapter | Where-Object {$_.InterfaceDescription -Match "Cisco AnyConnect"}
    $CiscoMetric = ($CiscoAdapter | Get-NetIPInterface).InterfaceMetric
    $WSLAdapter = Get-NetAdapter | Where-Object {$_.Name -match "WSL"}
    $WSLAdapterMetric = ($WSLAdapter | Get-NetIPInterface).InterfaceMetric
    Write-Host "Getting Cisco Network Adapter"
    write-host "Adapter Name: $($CiscoAdapter.InterfaceDescription) Metric: $CiscoMetric"

    Write-Host "Getting WSL Network Adapter"
    write-host "Adapter Name: $($WSLAdapter.Name) Metric: $WSLAdapterMetric"
    
}else{
    Write-Host "Not setting anything."
}


# $high = ([System.IO.Path]::GetFullPath([System.IO.Path]::GetDirectoryName($PROFILE) + "/UpdateAnyConnectInterfaceMetricHigh.ps1"))
# $low = ([System.IO.Path]::GetFullPath([System.IO.Path]::GetDirectoryName($PROFILE) + "/UpdateAnyConnectInterfaceMetricLow.ps1"))

# function disable-wsl-inet { Write-Host "Domain resources are then visible again but wsl will have no dns."; Start-Process pwsh.exe -NoNewWindow -ArgumentList "-file $high"}

# function enable-wsl-inet { Write-Host "Beware that domain resources will be invisible until you run disable-wsl-inet again."; Start-Process pwsh.exe -NoNewWindow -ArgumentList "-file $low" }