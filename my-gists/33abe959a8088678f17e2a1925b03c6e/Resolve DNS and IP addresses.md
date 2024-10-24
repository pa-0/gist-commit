# Resolve DNS and IP addresses with PowerShell

## Name to IP Address (DNS Forward)

```powershell
[system.net.dns]: :GetHostAddresses('graef.io')
[system.net.dns]: :GetHostAddresses('graef.io').IPAddressToString
```

## IP Address to Name (DNS Reverse)

```powershell
[System.Net.Dns]::GetHostbyAddress('85.13.135.42')

HostName              Aliases AddressList
--------              ------- -----------
graef.io {}      {85.13.135.42}

```

```powershell
Resolve-DnsName graef.io

Name      Type   TTL   Section    IPAddress
----      ----   ---   -------    ---------
graef.io  AAAA   72711 Answer     2a01:488:42:1000:50ed:84e8:ff91:1f91
graef.io  A      72711 Answer     80.237.132.232

Resolve-DnsName 80.237.132.232

Name                           Type   TTL   Section    NameHost
----                           ----   ---   -------    --------
232.132.237.80.in-addr.arpa    PTR    32738 Answer     graef.io
```
