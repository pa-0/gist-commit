Notes on configuring [ArchWSL](https://github.com/yuk7/ArchWSL) on WSL2.

## Basic setup

Edit `%UserProfile%\.wslconfig`:

```ini
[wsl2]
swap=0
localhostForwarding=true
nestedVirtualization=true
```

Edit `/etc/wsl.conf`:

```ini
[user]
default=root

[network]
generateHosts = true
generateResolvConf = true

[interop]
enabled = true
appendWindowsPath = false
```

Install basic packages:

```
~# pacman -Syu
~# pacman -S base-devel git
```

Add non-priviliged user:

```
~# useradd USERNAME
~# passwd USERNAME
~# mkdir ~USERNAME && chown USERNAME:USERNAME ~USERNAME && chmod 0755 ~USERNAME
~# gpasswd -a USERNAME wheel
~# $EDITOR /etc/sudoers
```

Install yay:

```
~$ git clone https://aur.archlinux.org/yay.git
~$ cd yay
~$ makepkg -si
```

## Workaround with systemd

See [wsl2-hacks](https://github.com/shayne/wsl2-hacks), replace the root login shell with script:

```shell
#!/bin/bash
UNAME="USERNAME"

UUID=$(id -u "${UNAME}")
UGID=$(id -g "${UNAME}")
UHOME=$(getent passwd "${UNAME}" | cut -d: -f6)
USHELL=$(getent passwd "${UNAME}" | cut -d: -f7)

if [[ -p /dev/stdin || "${BASH_ARGC}" > 0 && "${BASH_ARGV[1]}" != "-c" ]]; then
    USHELL=/bin/bash
fi

if [[ "${PWD}" = "/root" ]]; then
    cd "${UHOME}"
fi

# get pid of systemd
SYSTEMD_PID=$(pgrep -xo systemd)

# if we're already in the systemd environment
if [[ "${SYSTEMD_PID}" -eq "1" ]]; then
    exec "${USHELL}" "$@"
fi

# start systemd if not started
/usr/sbin/daemonize -l "${HOME}/.systemd.lock" /usr/bin/unshare -fp --mount-proc /lib/systemd/systemd --system-unit=basic.target 2>/dev/null
# wait for systemd to start
while [[ "${SYSTEMD_PID}" = "" ]]; do
    sleep 0.05
    SYSTEMD_PID=$(pgrep -xo systemd)
done

# enter systemd namespace
exec /usr/bin/nsenter -t "${SYSTEMD_PID}" -m -p --wd="${PWD}" /sbin/runuser -s "${USHELL}" "${UNAME}" -- "${@}"
```

Replace `USERNAME` with your own username, and runs `yay -S daemonize` before moving onto the next step.

It requires to change the login shell of root (using `chsh root`) to this script,
which would setup the namespace and launch systemd as a pseudo init process (pid 1),
then switch to the login shell of your non-priviliged user.

To ensure that systemd would start when Windows host machine login,
simply add a job `C:\Windows\System32\wsl.exe -d Arch -u root -- exit` to Windows Task Scheduler.

## Optimize memory usage

WSL2 runs on a specialize Hyper-V instance, using a customized Linux 4.x kernel provided by Microsoft.

Similar to the vanilla kernel, page caches of that customized kernel would increse gradually when the
available memory is considered to be sufficient.
The behaviour may lead to insane memory usage of the Vmmem process if WSL2 runs for a long time.

To workaround this issue, just setup a systemd timer to intervally drop unnecessary caches.

Edit `/usr/bin/wslfree` and `chmod +x /usr/bin/wslfree`:

```shell
#!/bin/bash

echo 3 > /proc/sys/vm/drop_caches
```

Edit `/usr/lib/systemd/system/wslfree.service`:

```ini
[Unit]
Description = Free WSL2 kernel caches

[Service]
Type = oneshot
ExecStart = /usr/bin/wslfree

[Install]
WantedBy = multi-user.target
```

Edit `/usr/lib/systemd/system/wslfree.timer`:

```ini
[Unit]
Description = Timer to free WSL2 kernel caches

[Timer]
OnBootSec=1h
OnUnitActiveSec=1h

[Install]
WantedBy = timers.target
```

Install the timer using `sudo systemctl enable wslfree.timer`.

## Optimize hard disk usage

WSL2 use virtual hard disk images (.vhdx file) to store the root filesystem of Linux distros.

Vhdx do not preallocate space by default,
it allocates space when needed instead and keep the redundant chunks until you compact it manually.

See [the discussion](https://github.com/microsoft/WSL/issues/4699) and
[a related powershell script](https://github.com/mikemaccana/compact-wsl2-disk), try this script:

```powershell
$ErrorActionPreference = "Stop"

$files = @()
cd $env:LOCALAPPDATA\Packages
get-childitem -recurse -filter "ext4.vhdx" -ErrorAction SilentlyContinue | foreach-object {
  $files += ${PSItem}
}

if ( $files.count -gt 1 ) {
  throw "We found too many files in $env:LOCALAPPDATA\Packages"
}

if ( $files.count -eq 0 ) {
  throw "We could not find a file called ext4.vhdx in $env:LOCALAPPDATA\Packages"
}

$disk = $files[0].FullName

write-output " - Successfully found VHDX file $disk"
write-output " - Shutting down WSL2"

wsl -e sudo fstrim /
wsl --shutdown
write-output " - Compacting disk (starting diskpart)"

optimize-vhd -Path $disk -Mode full

write-output ""
write-output "Success. Compacted $disk."
```

It relies on the `optimize-vhd` cmd-let, which requires Hyper-V installed on Windows.

## Probe Windows host machine IP

WSL2 automatically forwards port bindings on 0.0.0.0 or loopback device to Windows since build 18945.
However, services on Windows could not be conveniently accessed in WSL2 until now, since the IP address is dynamic.

The following python script appends a record of `windows` to `/etc/hosts`, which makes things easier.
Edit `/usr/bin/wslhosts` and `chmod +x`:

```python
#!/usr/bin/env python

import os
import re
from functools import reduce

HOST_MACHINE_NAME = 'windows'
HOST_MACHINE_IP_FILE = '/run/host_machine.ip'

IP_PATTERN = re.compile(r'inet\s+(?P<ip>\d+(\.\d+){3})/(?P<bits>\d+)');

def getHostMAchineIpAddr():
    for line in os.popen('/usr/bin/ip -4 addr show eth0'):
        match = IP_PATTERN.search(line)
        if (match):
            local_ip = reduce(lambda x, y: x * 256 + y, map(int, match.group('ip').split('.')))
            subnet_bits = int(match.group('bits'))
            subnet_mask = ((1 << subnet_bits) - 1) << (32 - subnet_bits)
            host_ip = (local_ip & subnet_mask) + 1
            return '.'.join(map(str, [255 & (host_ip >> (8 * (3 - i))) for i in range(4)]))

if (__name__ == '__main__'):
    with open('/etc/hosts', 'a') as hosts, open(HOST_MACHINE_IP_FILE, 'w') as ip_file:
        hosts.write('\n')
        hosts.write('# generated by wslhosts\n')
        host_machine_ip_addr = getHostMAchineIpAddr()
        if host_machine_ip_addr:
            hosts.write('%s %s\n' % (host_machine_ip_addr, HOST_MACHINE_NAME))
            ip_file.write(host_machine_ip_addr)
```

Edit `/usr/lib/systemd/system/wslhosts.service`:

```ini
[Unit]
Description = Probe and record IPv4 address of WSL2 host machine

[Service]
Type = oneshot
ExecStart = /usr/bin/wslhosts

[Install]
WantedBy = multi-user.target
```

Install the service using `sudo systemctl enable wslhosts.service`.
