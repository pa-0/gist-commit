# Assigning Static IP Addresses in WSL2

WSL2 uses Hyper-V for networking. The WSL2 network settings are ephemeral and configured on demand when any WSL2
instance is first started in a Windows session. The configuration is reset on each Windows restart and the IP addresses change each time. The Windows host creates a hidden switch named "WSL" and a network adapter named "WSL" (appears as
"vEthernet (WSL)" in the "Network Connections" panel). The Ubuntu instance creates a corresponding network interface
named "eth0".

Assigning static IP addresses to the network interfaces on the Windows host or the WSL2 Ubuntu instance enables support
for the following scenarios:

- Connect to an Ubuntu instance from the Windows host using a static IP address
- Connect to the Windows host from an Ubuntu instance using a static IP address

This guide assumes [PowerShell 7](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows) and:

| **Variable**                 | **Value**                      |
| ---------------------------- | ------------------------------ |
| WSL distribution             | Ubuntu 20.04                   |
| WSL instance name            | Ubuntu-20.04                   |
| Windows host IP address      | 192.168.2.1                    |
| Ubuntu instance IP address   | 192.168.2.2                    |
| Network subnet (subnet mask) | 192.168.2.0/24 (255.255.255.0) |

> **Note**
> It's best to pick a subnet in the [private address range](https://en.wikipedia.org/wiki/Private_network).

## Manual Steps

Configure connectivity from the Windows host to the Ubuntu instance:

1. Assign the Ubuntu instance IP address to the "eth0" network interface in Ubuntu _(after every restart)_.

    ```shell
    sudo ip address add 192.168.2.2/24 brd + dev eth0
    ```

Configure connectivity from the Ubuntu instance to the Windows host:

2. Add a Windows firewall allow rule _(once only)_.

    The "vEthernet (WSL)" network interface uses the "Public" Windows network profile so all traffic from the Ubuntu
    instance to the host is blocked by default. Allow all inbound traffic from the "vEthernet (WSL)" network interface.

    ```powershell
    # Requires "Run as Administrator"
    New-NetFirewallRule -Name 'WSL' -DisplayName 'WSL' -InterfaceAlias 'vEthernet (WSL)' -Direction Inbound -Action Allow
    ```

    > **Note**
    > Any existing rules blocking inbound traffic for applications on the Windows host will take precedence
    > over this rule, so remove or disable these where required. Such rules can be created automatically by Windows
    > when an application is first run. Windows shows the user a UAC modal asking for permission to create a firewall
    > rule.

3. Assign the Windows host IP address to the "WSL" network interface in Windows _(after every restart)_.

    ```powershell
    # Requires "Run as Administrator"
    New-NetIPAddress -InterfaceAlias 'vEthernet (WSL)' -IPAddress '192.168.2.1' -PrefixLength 24
    ```

## PowerShell Script

All the steps above in a PowerShell script.

```powershell
$WslInstanceName = 'Ubuntu-20.04'
$WindowsHostIPAddress = '192.168.2.1'
$UbuntuInstanceIPAddress = '192.168.2.2'
$SubnetMaskNumberOfBits = 24

$WslFirewallRuleName = 'WSL'
$WslNetworkInterfaceName = 'vEthernet (WSL)'
$UbuntuNetworkInterfaceName = 'eth0'

# Ensure the "vEthernet (WSL)" network adapter has been created by starting WSL.
Write-Host 'Ensure WSL network exists...'
wsl --distribution "$WslInstanceName" /bin/false
Write-Host 'WSL network exists'

# All inbound traffic from Ubuntu through Windows firewall and assign a static IP address to the "vEthernet (WSL)"
# network adapter in Windows.
Write-Host 'Configuring Windows host network...'
Start-Process 'pwsh' -Verb RunAs -Wait -ArgumentList '-ExecutionPolicy Bypass', @"
-Command & {
  Write-Host 'Checking firewall...'
  If (-Not (Get-NetFirewallRule -Name '$WslFirewallRuleName' -ErrorAction SilentlyContinue)) {
    Write-Host 'Configuring firewall...'
    New-NetFirewallRule -Name '$WslFirewallRuleName' -DisplayName '$WslFirewallRuleName' -InterfaceAlias '$WslNetworkInterfaceName' -Direction Inbound -Action Allow
    Write-Host 'Finished configuring firewall'
  }
  Else {
    Write-Host 'Already configured firewall'
  }
 
  Write-Host 'Checking network interface...'
  If (-Not (Get-NetIPAddress -InterfaceAlias '$WslNetworkInterfaceName' -IPAddress '$WindowsHostIPAddress' -PrefixLength $SubnetMaskNumberOfBits  -ErrorAction SilentlyContinue)) {
    Write-Host 'Configuring network interface...'
    New-NetIPAddress -InterfaceAlias '$WslNetworkInterfaceName' -IPAddress '$WindowsHostIPAddress' -PrefixLength $SubnetMaskNumberOfBits
    Write-Host 'Finished configuring network interface'
  }
  Else {
    Write-Host 'Already configured network interface'
  }
}
"@
Write-Host 'Finished configuring Windows host network'

# Assign a static IP address to the "eth0" network interface in Ubuntu.
Write-Host 'Configuring Ubuntu instance network...'
wsl --distribution "$WslInstanceName" --user root /bin/sh -c "if !(ip address show dev $UbuntuNetworkInterfaceName | grep -q $UbuntuInstanceIPAddress/$SubnetMaskNumberOfBits); then ip address add $UbuntuInstanceIPAddress/24 brd + dev $UbuntuNetworkInterfaceName; fi"
Write-Host 'Finished configuring Ubuntu instance network'
```