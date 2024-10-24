#### @matthiassb commented on Jul 23, 2018 • 
Steps to run (as root)
This init.d script will keep Ubuntu WSL dns config in-sync with windows with a 15 sec lag-time.

>Be warned: If this service is not running and the nameservers in windows userspace changed, then you may lose connectivity in WSL - make sure the daemon is running at all times

```
wget https://gist.github.com/matthiassb/9c8162d2564777a70e3ae3cbee7d2e95/raw/b204a9faa2b4c8d58df283ddc356086333e43408/dns-sync.sh -O /etc/init.d/dns-sync.sh
chmod +x /etc/init.d/dns-sync.sh
unlink /etc/resolv.conf
service dns-sync.sh start
```

Note: WSL does not support service auto-start, when you boot your system you'll need to start the service manually

#### @regisbsb commented on Jul 23, 2018

```
wget https://gist.githubusercontent.com/matthiassb/9c8162d2564777a70e3ae3cbee7d2e95/raw/56640fbb50ec870d2a2f62b1f188081c29d45337/dns-sync.sh -O /etc/init.d/dns-sync.sh
```

#### @matthiassb commented on Jul 23, 2018
Disable Init.d and restore original WSL functionality (as root)
service dns-sync.sh stop
unlink /etc/resolv.conf 
ln -s /run/resolvconf/resolv.conf /etc/resolv.conf

#### @matthiassb commented on Jul 23, 2018
@regisbsb fixed

#### @alexey-krylov commented on Nov 26, 2018 • 
It's possible to autostart this script with bash. Just add this lines to ~/.bashrc:

if service dns-sync.sh status| grep -q 'dns-sync is not running'; then
   sudo service dns-sync.sh start
fi

#### @carm-scaffidi commented on Jan 19, 2019
Thanks for the great tip to get this working!

#### @estebarb commented on Feb 6, 2019
The script enables networking with the outside world (yay!). Unfortunatelly, that script prevents Linux to connect to a local X Server, so I can't use a local xfce :(

#### @matthiassb commented on Feb 25, 2019
@estebarb. Can you elaborate a little more on your configuration/setup? I might be able to update this GIST to support this scenario.

#### @BrianBlaze commented on Jul 4, 2019 • 
Thank you for this... weirdly enough using this I saw in task manager init using a ton of CPU%... I will just stick to manually configuring.

#### @adrianohirata commented on Aug 20, 2019
Weird... everytime the script runs it changes the font used in the WSL console window. Has anyone else seen this?

#### @ghost commented on Sep 25, 2019 • 
Weird... everytime the script runs it changes the font used in the WSL console window. Has anyone else seen this?

This seems to happen when PowerShell, called from bash (maybe other shells, too), in a WSL instance is instructed to redirect its stdout to a file.

#### @sparcs360 commented on Nov 2, 2019
A workaround for the font switching problem is explained here -> https://patrickwu.space/2019/08/03/wsl-powershell-raster-font-problem/

#### @caiowilson commented on Nov 13, 2019
congrats on the solution! I mean, REALLY!

#### @Farix1337 commented on Dec 4, 2019
you rock

#### @faaarmer commented on Apr 16, 2020
Still works fantastically. Thanks!

#### @rroblik commented on May 18, 2020
@matthiassb is this required https://gist.github.com/matthiassb/9c8162d2564777a70e3ae3cbee7d2e95#gistcomment-2769071?
Seems to work without it and give me an error when enabled :)

#### @jan-glx commented on Sep 23, 2020
To prevent yourself from having to type your password every time you open a new shell after putting
```
if service dns-sync.sh status| grep -q 'dns-sync is not running'; then
   sudo service dns-sync.sh start
fi
```
in your ~/.bashrc to start the service automatically as described by @alexey-krylov you can use the following lines to modify allow sudo users to modify the service without a password:
```
echo -e "%sudo   ALL=(ALL) NOPASSWD: /usr/sbin/service dns-sync.sh *\n%sudo   ALL=(ALL) NOPASSWD: /usr/sbin/service dns-sync.sh\n" | sudo tee /etc/sudoers.d/dns-sync
sudo chmod 0440 /etc/sudoers.d/dns-sync
```

#### @AllanMedeiros commented on Oct 5, 2021
This script seems to finally have fixed my DNS issues on Ubuntu 20.04 under WSL2! Thank you!
Not sure why, but when the script is started, my terminal font changes...
image

#### @jan-glx
jan-glx commented on Nov 12, 2021
I needed to change line 22 to $PS -Command 'Get-DnsClientServerAddress -AddressFamily IPv4 -InterfaceIndex $(Get-NetIPInterface -AddressFamily IPv4 | Where-Object ConnectionState -EQ "Connected" | Sort-Object InterfaceMetric | Select-Object -ExpandProperty ifIndex) | Select-Object -ExpandProperty ServerAddresses' > $TEMPFILE to avoid DNS servers from disconnected interfaces showing up first

#### @jarrodhroberson commented on Feb 27, 2023
Does anyone have any updates to this.

I started at the top and tried every thing listed as I went down the list of comments and nothing works.

I still get this, I applied every mod/patch that everyone mentioned all the way down to jan-glx one at a time and nothing changed.

I did wsl --shutdown after every change to make sure it was getting a fresh start and data.

I still get:

```
❯ go mod tidy
go: downloading github.com/spf13/cobra v1.6.1
adotools/cmd imports
        github.com/spf13/cobra: github.com/spf13/cobra@v1.6.1: Get "https://proxy.golang.org/github.com/spf13/cobra/@v/v1.6.1.zip": proxyconnect tcp: dial tcp: lookup my.corp.proxy.com: i/o timeout
```

when I try to do sudo apt update all I get is:

```
Temporary failure resolving 'my.corp.proxy.com'
my.corp.proxy.com is anonymized obviously :-)
```

Anything else anyone can think out would help.

#### @cantti commented on Aug 29, 2023
Now WSL2 supports systemd, so we can run script as a service.

Download script to home directory

```
wget https://gist.github.com/matthiassb/9c8162d2564777a70e3ae3cbee7d2e95/raw/b204a9faa2b4c8d58df283ddc356086333e43408/dns-sync.sh -O ~/dns-sync.sh
chmod +x ~/dns-sync.sh
```

Add these lines to the /etc/wsl.conf if not exists (sudo nano /etc/wsl.conf)

```
[boot]
systemd=true

[network]
generateResolvConf=false
```

Reboot.

Create a unit file

```
sudo touch /etc/systemd/system/dns-sync.service
Edit (sudo nano /etc/systemd/system/dns-sync.service) and fix path to script inside

[Unit]
Description=dns sync

[Service]
ExecStart=PUT_PATH_HERE
Type=forking

[Install]
WantedBy=multi-user.target
```

Reboot

Run service

```
sudo systemctl enable dns-sync.service
sudo systemctl start dns-sync.service
sudo systemctl status dns-sync.service
```

#### @rroblik commented on Aug 31, 2023
@cantti : enabling systemd prevent any .execommand to work, including the powershell command required by the script. That resulted in... an empty /etc/resolv.conf ! ❌

Related interesting thread : https://www.reddit.com/r/bashonubuntuonwindows/comments/11vx61n/wsl2_error_cannot_execute_binary_file_exec_format/

I'm looking for a workaround but for now I have to (re)disable systemd 😭