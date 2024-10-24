Get-WmiObject Win32_DiskDrive #list available disks
Select-String cheat # powershell equivalent of grep
wsl --mount <DiskPath> --bare #make disk available to wsl2
$(ls dir/*.ext) # pass all files in dir as argument to cli-tools

# forwards traffic from port 2222 on host to sshd port 22 on wsl client
netsh interface portproxy add v4tov4 listenport=2222 listenaddress=0.0.0.0 connectport=22 connectaddress=localhost 

netsh interface portproxy dump # shows configured port proxies
netsh interface portproxy delete v4tov4 listenport=2222 listenaddress=0.0.0.0 # deletes configured port proxies
netsh advfirewall firewall add rule name="WSL SSH" dir=in action=allow protocol=TCP localport=2222 # opens port for remote access
ssh user@192.168.0.1 -oPort=2222 # connects to your wsl machine

Set-PSReadLineOption -EditMode Vi # vim keybindings in powershell
Get-NetTCPConnection -State Listen,Established| 
Select-Object LocalHost,LocalPort,RemoteHost,RemotePort,
@{'Name' = 'Process';'Expression'={(Get-Process -Id $_.OwningProcess).Path}} # Listening and  Established connections with full process Path
cd \\wsl$\kali-linux # go to directory of wsl distro

kali run vi /mnt/c/Users/<user>/<file> # Edit file in powershell with vi in kali wsl

# Powershell in Linux
# In /etc/ssh/sshd_config:
# Subsystem       powershell /usr/bin/pwsh --sshs -NoLogo -NoProfile
New-PSSession -hostname <IP address> -username <username> # In PS on Windows
Enter-PSSession <Sessionnumber> # Enter Session
Stop-Process -Id <ProcessId> # Close Session
Invoke-Command -Session(Get-PSSession <Sessionnumber>) -ScriptBlock { uname -a } # Remote Command

Expand-Archive <drive>\<path>\<file>.zip -DestinationPath <drive>\<path>\<directory> # unzip 
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container_name_or_id #get IP address of container