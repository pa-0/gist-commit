# Backup and restore WSL2 vhdx, avoid 256GB vhdx limit for docker desktop WSL2 native

Review all steps to view the symptom this Gist addresses, customize a workaround to allow for >256GB Docker pulls safely on Windows, then perform a backup and recovery of the result (export and import). Please provide comments on any failures.

#### Determine the expected size of the docker-desktop-data volume 
- Get the base image size + additional + all docker volumes using `docker system df`
- Add raw uncompressed size for alpine (50MB), docker for your version of windows (700MB) and linux (80MB)

`docker system df`

#### Get info for the docker-desktop-data VHD

```powershell
Get-VHD -Path C:\Users\windows-admin\AppData\Local\Docker\wsl\data\ext4.vhdx
```
<pre>
ComputerName            : WINDOWS10PRO
Path                    : C:\Users\windows-admin\AppData\Local\Docker\wsl\data\ext4.vhdx
VhdFormat               : VHDX
VhdType                 : Dynamic
FileSize                : 115GB <in bits>
Size                    : 256GB <in bits>
MinimumSize             :
LogicalSectorSize       : 512
PhysicalSectorSize      : 4096
BlockSize               : 1048576
ParentPath              :
DiskIdentifier          : A9****
FragmentationPercentage : 10
Alignment               : 1
Attached                : False
DiskNumber              :
IsPMEMCompatible        : False
AddressAbstractionType  : None
Number                  :
</pre>

#### Set max size per Windows Hyper-V cmdlet [Resize-HD](https://docs.microsoft.com/en-us/powershell/module/hyper-v/resize-vhd?view=win10-ps)
```powershell
Resize-VHD -Path C:\Users\windows-admin\AppData\Local\Docker\wsl\data\ext4.vhdx -SizeBytes 350GB
# confirm change to Size
Get-VHD -Path C:\Users\windows-admin\AppData\Local\Docker\wsl\data\ext4.vhdx
```
<pre>
...
Size                    : 350GB <in bits>
...
</pre>

#### Restart 

#### Attempt to `docker pull` above 350GB fails at 256GB despite new size specification on dynamic `ext4.vhdx` 

# The work-around to the 256GB implicit .vhdx limit 

This along with regular backups help to protect docker-desktop-data against disk or overload failures. They also mitigate patches to wsl2, dotfile, filesystem chagnes, other configuration gotchas.

#### Quit docker in windows _or_ via

`taskkill /F /IM "Docker Desktop.exe"`

#### Stop the docker service

`net stop com.docker.service`

#### Shutdown wsl

```
wsl --shutdown
```

#### Create a backup of the docker-data virtual disk. `-VHDType Fixed` will set the size to fixed volume the max size of the volume, the `size` attribute returned by `Get-VHD`. Ensure you have enough HD space to proceed, you can use an external volume but it will be slow.

```powershell
# PS>
Convert-VHD -Path C:\Users\windows-admin\AppData\Local\Docker\wsl\data\ext4.vhdx -DestinationPath C:\Users\windows-admin\AppData\Local\Docker\wsl\data\ext4_fixed.vhdx -VHDType Fixed
```

#### Compact the dynamic disk... the size will not change due to [WSL 2 should automatically release disk space back to the host OS #4699](https://github.com/microsoft/WSL/issues/4699)

```powershell
# PS>
Optimize-VHD -Path C:\Users\windows-admin\AppData\Local\Docker\wsl\data\ext4.vhdx 
```

#### Compact the fixed disk... the size will not change

```powershell
# PS>
Optimize-VHD -Path C:\Users\windows-admin\AppData\Local\Docker\wsl\data\ext4_fixed.vhdx 
```

#### Delete the dynamic disk

```powershell
# PS>
Remove-Item -Path C:\Users\windows-admin\AppData\Local\Docker\wsl\data\ext4.vhdx 
```

####  Rename the fixed disk to ext4.vhdx

```powershell
# PS>
Rename-Item -Path C:\Users\windows-admin\AppData\Local\Docker\wsl\data\ext4_fixed.vhdx -NewName ext4.vhdx 
```
#### Start docker and manage disk size up to 350GB.

### Backup via `wsl --export`  
#### Export the docker-desktop the docker-desktop-data wsl distros. This should bring their `.vhdx` with them, and only bring the data from the in-use portion of the volumes.
```sh
wsl --export docker-desktop E:\docker-desktop.tar # 57MB
wsl --export docker-desktop-data E:\docker-desktop-data.tar # 115GB in size of docker contents (not 350GB)
```

#### Optionally compress the distro tars to save filespace and backup elsewhere
```sh
bash # can also use 7zip via windows
tar cvzf docker-desktop.tar.gz docker-desktop.tar # 17MB
tar cvzf docker-desktop-data.tar.gz docker-desktop-data.tar # 13GB takes about 40 minutes
```

####  Import the wsl distros you exported from an earlier Docker install
```bash
# Unregister WSL images (can be from a newer version of Docker Desktop)
wsl --unregister docker-desktop-data
wsl --unregister docker-desktop
# Import backup of old WSL images (can be from an older version of Docker Desktop)
# wsl.exe --import <DistributionName> <InstallLocation> <FileName>
# any <InstallLocation> should work (was `%LOCALAPPDATA%/Docker/wsl/data` before)
wsl --import docker-desktop-data C:\Users\windows-admin\AppData\Local\Docker\wsl\data C:\Users\windows-admin\DockerVHDXs\docker-desktop-data.tar 
wsl --import docker-desktop C:\Users\windows-admin\AppData\Local\Docker\wsl\distro C:\Users\windows-admin\DockerVHDXs\docker-desktop.tar
```

### If you want to use >256GB safely, repeat steps above to expand it to a bigger `Size` 

```sh
Get-VHD -Path C:\Users\windows-admin\AppData\Local\Docker\wsl\data\ext4.vhdx

ComputerName            : WINDOWS10PRO
Path                    : C:\Users\windows-admin\AppData\Local\Docker\wsl\data\ext4.vhdx
VhdFormat               : VHDX
VhdType                 : Dynamic ### 
FileSize                : 229952716800
Size                    : 274877906944 ### 256GB <in bits>
MinimumSize             :
LogicalSectorSize       : 512
PhysicalSectorSize      : 4096
BlockSize               : 1048576
ParentPath              :
DiskIdentifier          : A96*****
FragmentationPercentage : 89
Alignment               : 1
Attached                : True
DiskNumber              :
IsPMEMCompatible        : False
AddressAbstractionType  : None
Number                  :
```

## Move in either direction to restore or backup the image. Convert to larger than 256GB fixed volume to surpass WSL limits.

### Notes
- Opening Docker.exe will restart the docker service and when pre-configured in wsl2 mode will also start wsl
- Pull or run a large amount of stuff without fearing the native wsl2 256GB limit that cannot be reconfigured using the Microsoft method because docker appears to have left docker-desktop-data 'shell-less'
- You can see the `docker-desktop-data` files by exporting and then opening in 7zip
  - It should be possible to pass between Linux and perhaps Mac by modifying volumes stored in overlay2 driver or reusing another driver
- Monitor that you do not broach the >256GB limit you choose, much like you did using WSL1. When reach `<your size in GB above 256GB>`, you may not be able to start or recover your data. There is no built-in altitude warning.
- If you reach the `<your size in GB above 256GB>` limit and cannot start docker, you can attempt to export the docker-desktop-data wsl distro and run it natively with some linux filesystem utilities and hyper-v .vhdx drivers, it may be possible to prune the image manually then remount it.