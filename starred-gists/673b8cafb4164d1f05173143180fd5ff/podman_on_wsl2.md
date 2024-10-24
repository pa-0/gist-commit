# Install Podman on Windows Subsystem for Linux 2 (WSL2)
This guide allows a safe and rootless installation of [Podman](https://podman.io/) on [WSL2](https://docs.microsoft.com/en-us/windows/wsl/).
Head over the hyperlinks to discover more about these two wonderful technologies!

This guide assumes that Debian 11 "bullseye" is installed as WSL2 base OS. To do it, simply open your Windows Powershell console under Admin rights and run
```
PS> wsl install -d Debian
```
After installation, please check that you are under the latest Debian. If not, please [upgrade it](https://www.cyberciti.biz/faq/update-upgrade-debian-10-to-debian-11-bullseye/).

Now, open a Debian terminal window and execute the following commands:
```
# sudo apt update
# sudo apt install -y podman
```

To test out if Podman was installed successfully, execute `podman info`. Notice an error like the following one:
```log
ERRO[0000] unable to write system event: "write unixgram @00002->/run/systemd/journal/socket: sendmsg: no such file or directory"
```

To fix it and make sure that Podman works without issues in WSL2, just execute the following commands:
```
$ mkdir -p $HOME/.config/containers/
$ cp /usr/share/containers/containers.conf $HOME/.config/containers/
```

Now, please edit `$HOME/.config/containers/containers.conf` with a text editor and ensure the following lines are set correctly:
```
cgroup_manager = "cgroupfs"
events_logger = "file"
```

To test out changes, execute `podman info` again. The error is now gone! Podman is now ready to be used for rootless containers!

## Sources
* [Podman Installation](https://podman.io/getting-started/installation)
* [How to run Podman on Windows with WSL2](https://www.redhat.com/sysadmin/podman-windows-wsl2)