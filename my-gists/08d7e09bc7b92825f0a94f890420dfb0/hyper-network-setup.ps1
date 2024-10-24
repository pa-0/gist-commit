$switchName = "VM-Internal-Switch"
$ipAddressString = "10.100.100.1"
$prefixLength = 24
$netNatName = "VM-NAT-Network"

Write-Output "Creating new VM Switch"
if ($null -eq (Get-VMSwitch -Name $switchName -ErrorAction SilentlyContinue)) {
  New-VMSwitch -Name $switchName -SwitchType Internal
}

$netAdapter = Get-NetAdapter -Name "vEthernet ($switchName)"

Write-Output "Assigning IP Address"
$ipAddressParams = @{
  IPAddress = $ipAddressString
  PrefixLength = $prefixLength
  InterfaceIndex = $netAdapter.InterfaceIndex
}
New-NetIPAddress @ipAddressParams -ErrorAction SilentlyContinue

$netNat = Get-NetNat -Name $netNatName -ErrorAction SilentlyContinue
if ($null -eq $netNat) {
  New-NetNat -Name $netNatName -InternalIPInterfaceAddressPrefix "$ipAddressString/$prefixLength"
}