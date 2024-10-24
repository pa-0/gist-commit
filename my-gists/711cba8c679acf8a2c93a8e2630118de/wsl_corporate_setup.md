# WSL corporate setup
A short guide on how to access the interwebz through a corporate proxy from Ubuntu running on WSL.

## Prerequisites
* Windows 10 (Version 1909 Build 18363.1379+)
* WSL v2
* Ubuntu 20.04

If you have not installed WSL/Ubuntu yet, make sure to run the [required PowerShell snippets](https://docs.microsoft.com/en-us/windows/wsl/install) in an elevated (Run as Administrator) console.

## Usage

### Fix DNS servers
1. Open PowerShell, run `Get-DnsClientServerAddress -AddressFamily IPv4 | Select-Object -ExpandProperty ServerAddresses` and take note of the output
1. Inside WSL, remove the symlink of */etc/resolv.conf* via `sudo unlink /etc/resolv.conf`
1. Open *resolv.conf* via `sudo vim /etc/resolv.conf` and paste the PowerShell output into the file, putting `nameserver` in front of every record, i.e. `nameserver 192.168.178.1`
1. Create *wsl.conf* via `sudo vim /etc/wsl.conf` and insert the following snippet:
	```
   	[network]
   	generateResolvConf = false
   	```
1. Return to PowerShell, shutdown WSL via ``wsl --shutdown`` and proceed with a rebooted WSL session

### Configure coprorate certificatess
1. Extract corprorate certificates from your favourite browser
2. Make sure certificates are in PEM format and contain the *.crt* suffix - if they do not, use [openssl](https://www.openssl.org/docs/manmaster/man1/openssl.html) to convert them
3. Copy certificates to */usr/local/share/ca-certificates* and run `sudo update-ca-certificates`
4. *Optional*: If using Python you need to point the *REQUESTS_CA_BUNDLE* environment variable to *ca-certificates.crt*. One way to accomplish this is to edit */etc/environment* via `sudo vim /etc/environment` and add the following line: `REQUESTS_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"`

That's it :boom: - have yourself a drink :tropical_drink: and relax :relaxed:

## Limitations
* For now, you need to manually update nameservers in */etc/resolve.conf* if you change networks. There exist a [shell script](https://gist.github.com/matthiassb/9c8162d2564777a70e3ae3cbee7d2e95) to sync DNS settings, which I have not tested yet.

## Resources
* [Install WSL v2 on Windows](https://docs.microsoft.com/en-us/windows/wsl/install)
