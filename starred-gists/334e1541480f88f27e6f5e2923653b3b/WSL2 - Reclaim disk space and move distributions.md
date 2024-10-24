# WSL2 – Reclaim Disk Space
You may notice that your system drive runs out of space when using WSL-Distibutions. So you might ask how to move these stuff
to another hard drive or get some space back from your precious drive. **Warning**: Some commands here might be destructive - I take no responsibilities for any lost data.
Read, understand and then decide to follow instructions or not.

## How to get space back from WSL virtual disks
<https://superuser.com/questions/1606213/how-do-i-get-back-unused-disk-space-from-ubuntu-on-wsl2>

The Problem: WSL will dynamically grow the virtual disk (ext4.vhdx) but
never shrink it to reclaim unused space. (See also
<https://github.com/microsoft/WSL/issues/4699>) - What a bummer huh.

Usually this virtual hard disk is located at:
```%LOCALAPPDATA%\\Packages\\CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc\\LocalState```

Chances are good that you can get a lot of disk space back by using
"[optimize-vhd -Path \<PathToYourVHD\> -Mode
full](https://docs.microsoft.com/en-us/powershell/module/hyper-v/optimize-vhd?view=windowsserver2022-ps#example-1)"
from the PowerShell after [shutting down wsl distributions](https://docs.microsoft.com/en-us/windows/wsl/basic-commands#shutdown).
To do so run the following commands:
```
wsl --shutdown
optimize-vhd -Path <PathToYourVhdxFile> -Mode full
```
In my case some vhdx files took up to 50GB and could be optimized to around 8GB - Not so bad for two commands.

**Note**: The ```optimize-vhd``` command is not available in Home-Editions as mentioned in the Github-Issue above. In this case you can use ```diskpart``` instead (thx to [davidwin](https://github.com/microsoft/WSL/issues/4699#issuecomment-565700099) and [merkuriy](https://github.com/microsoft/WSL/issues/4699#issuecomment-627133168)).
```
wsl --shutdown
diskpart
# open window Diskpart
select vdisk file="C:\WSL-Distros\…\ext4.vhdx"
attach vdisk readonly
compact vdisk
detach vdisk
exit
```

# Move WSL2 distributions to another drive
If you dont want theese distributions on your system drive you can follow the guide at <https://stackoverflow.com/questions/38779801/move-wsl-bash-on-windows-root-filesystem-to-another-hard-drive>. 
In Windows 10 version 1903 (April 2019 Update) or later, you can use the ```wsl.exe``` command line tool to move an entire distribution to another location.
If you have an older version you can follow the instructions from the SO-Link above using ```LxRunOffline```.

## Export the distribution
First you want to create a .tar file with the distribution to move using wsl.exe --export.

Run ```wsl --list --verbose``` to get a list of your installed distributions.
Please note that this command is user dependent - running it as administrator will give different results than you standard user. Now
you can run "[wsl.exe --export \<DistributionName> <Tar-FileName>](https://docs.microsoft.com/en-us/windows/wsl/basic-commands#export-a-distribution-to-a-tar-file)"
command to store the archive to the desired location. For instance, to
export an Ubuntu distribution, you can use:

```wsl --export Ubuntu D:\WSL\Ubuntu\Ubuntu.tar```

Now that you have a backup of your distribution you can unregister it from WSL using "[wsl
--unregister](https://docs.microsoft.com/en-us/windows/wsl/basic-commands#unregister-or-uninstall-a-linux-distribution)"

```wsl --unregister Ubuntu```

**Caution:** Once unregistered, all data, settings, and software
associated with that distribution will be permanently lost. Reinstalling
from the store will install a clean copy of the distribution. Running ```wsl --list``` will reveal that it
is no longer listed.

## Import the distribution into WSL
Now you can import the exported distribution into another folder by using "[wsl.exe \--import \<DistributionName\> \<Folder-To-Install\>
\<Tar-FileName\>](https://docs.microsoft.com/en-us/windows/wsl/basic-commands#import-a-new-distribution)".
For instance, to import the exported Ubuntu, you can use:

```wsl --import Ubuntu D:\WSL\Ubuntu D:\WSL\Ubuntu\Ubuntu.tar```

**Note:** I suggest you the following script that use these commands for moving WSL distros: [https://github.com/pxlrbt/move-wsl](https://github.com/pxlrbt/move-wslT) (thx to
[pixelarbeit](https://stackoverflow.com/users/7329721/pixelarbeit)).

# Docker distributions
Depending on how much you have, Docker images, containers and volumes can pretty easy fill your whole system disk (like any other
distribution). The "docker-desktop-data" distro is used by the "docker-desktop" distro as the backing store for container images etc. In general, you should be able to move the whole thing the same way you
move any WSL-Distribution (export, unregister, import) as described
before.

## How bad is it?
To analyze, how much disk space is used by Docker just run "[docker system df](https://docs.docker.com/engine/reference/commandline/system_df/)" (Add --v to get more information's.)

```docker system df```

## Pruning system, image, containers and volumes
<https://docs.docker.com/config/pruning/>

To clean up as much as possible excluding components that are in use, run this commands: **Note:** Theese are destructive commands:
```
docker system prune --a
docker image prune --a
docker container prune -a
docker volume prune --a
```

## Use .wslconfig to limit resources used by Docker globally
<https://docs.microsoft.com/en-us/windows/wsl/wsl-config#wslconfig>

Create a ```.wslconfig``` file at ```%UserProfile%```. In the textbox below you find an example. 
```
[wsl2]
memory=8GB                  # Limits VM memory in WSL 2 
processors=4                # Makes the WSL 2 VM use 4 virtual processors
localhostForwarding=true    # Boolean specifying if ports bound to wildcard or localhost in the WSL 2 VM should be connectable from the host via localhost:port.
```
You can add more options if
you want (even use a custom Linux kernel). The complete list of options can be found [here](https://docs.microsoft.com/en-us/windows/wsl/wsl-config#configuration-setting-for-wslconfig).
After saving the file, restart the Linux Subsystem Manager by fire up
the following command from an elevated PowerShell:

```Restart-Service LxssManager```
