[CmdletBinding(DefaultParameterSetName = "PreDown")]
param (
    [Parameter(ParameterSetName = "Setup")]
    [switch]
    $Setup,
    [Parameter(ParameterSetName = "Setup")]
    [switch]
    $RestartWGService,
    # WireGuard Interface
    [Parameter(Position = 0)]
    [string]
    $WireGuardInterfaceName = $env:WIREGUARD_TUNNEL_NAME,
    # Post Up Switch
    [Parameter(ParameterSetName = "PostUp")]
    [switch]
    $PostUp,
    # Post Up Switch
    [Parameter(ParameterSetName = "PreDown")]
    [switch]
    $PreDown,
    # No Default Route
    [Parameter(ParameterSetName = "PostUp")]
    [Parameter(ParameterSetName = "PreDown")]
    [switch]
    $NoDefaultRoute,
    # Use Route One
    [Parameter(ParameterSetName = "PostUp")]
    [Parameter(ParameterSetName = "PreDown")]
    [switch]
    $RouteOne
)
$InformationPreference = "Continue"

# $ErrorActionPreference = "SilentlyContinue"
function Invoke-WireGuardExternalRoutingSetup {
    [CmdletBinding()]
    param (
        # Restart the Wireguard service if demanded
        [Parameter()]
        [switch]
        $RestartWGService
    )
    
    begin {
        
    }
    
    process {
        if ($PSCmdlet.ShouldContinue("DangerousScriptExecution", "Activating")) {
            
            $ActivateDangerousScriptExecutionSplat = @{
                Path = "hklm:\Software\WireGuard"
                Name = "DangerousScriptExecution"
                PropertyType = 'DWord'
                Value = 1
                ErrorAction = 'SilentlyContinue'
            }

            New-ItemProperty @ActivateDangerousScriptExecutionSplat

            if ($RestartWGService) {
                Write-Information "Restarting the Wireguard Service"
                Get-Service WireGuardManager | Restart-Service -Verbose
            }
            else {
                Write-Warning "You have to restart the wireguard service to apply the registry change"
            }
        }
    }
    
    end {
        
    }
}

if ($Setup) {
    Invoke-WireGuardExternalRoutingSetup -RestartWGService:$RestartWGService
} else {
    $WireGuardInterface = Get-NetAdapter -Name $WireGuardInterfaceName
}

if (-not $NoDefaultRoute) {
    
    $DefaultNetRouteSplat = @{
        InterfaceAlias    = $WireGuardInterface.InterfaceAlias
        DestinationPrefix = "0.0.0.0/0"
        RouteMetric       = 35
        Confirm           = $false
    }
    Write-Information -MessageData "Taking care of Default Route"
    switch ($PSCmdlet.ParameterSetName) {
        "PostUp" { New-NetRoute @DefaultNetRouteSplat | Out-Null }
        "PreDown" { Remove-NetRoute @DefaultNetRouteSplat | Out-Null }
        Default {}
    }
    

}

if ($RouteOne) {
    $RouteOneSplat = @{
        InterfaceAlias    = $WireGuardInterface.InterfaceAlias
        DestinationPrefix = "192.168.0.0/24"
        Confirm           = $false
    }
    Write-Information -MessageData "Taking care of Route One"
    switch ($PSCmdlet.ParameterSetName) {
        "PostUp" { New-NetRoute @RouteOneSplat | Out-Null }
        "PreDown" { Remove-NetRoute @RouteOneSplat | Out-Null }
        Default {}
    }
}

# Bonus DNS Snippet
# Set to $true to enable
$SetupDNS = $false
if ($SetupDNS){

    $setDnsClientServerAddressSplat = @{
        InterfaceAlias = $WireGuardInterface.InterfaceAlias
    }
    Write-Information -MessageData "Taking care of DNS"
    switch ($PSCmdlet.ParameterSetName) {
        "PostUp" { 
            Set-DnsClientServerAddress @setDnsClientServerAddressSplat -ServerAddresses "192.168.0.1"
        }
        "PreDown" { 
            Set-DnsClientServerAddress @setDnsClientServerAddressSplat -ResetServerAddresses
        }
        Default {}
    }
}