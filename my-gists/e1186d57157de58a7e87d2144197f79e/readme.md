# WireGuard Windows Routing Helper Script

This script is developped in a PowerShell 7 environment.
The script works PowerShell for Windows right now. I might try to be smart about that in the future.

The tunnel configuration is only an example for the Table, [Post|Pre][Up|Down] parameters.
I don't know right now if the peer configuration works. Help for that would be appreciated

## Setting Up WireGuard Dangerous Script Execution

To Setup the registry run the script with the `-Setup` switch in a Administrative PowerShell Console.
Add the `-RestartWGService` switch to restart the Wireguard Service while setting up.

```powershell
.\Invoke-WireGuardRoutingHelper.ps1 -Setup -RestartWGService
```

## Configuring the WireGuard Tunnel

You can use the switch `-NoDefaultRoute` to not add de default route, and the switch `-RouteOne` to add the Route One. You can change the route in the the script.

```text
PostUp = pwsh.exe -File "C:\Invoke-WireGuardRoutingHelper.ps1" -PostUp -NoDefaultRoute -RouteOne
```