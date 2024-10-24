# DISCLAIMER
This tutorial assumes that you have already created the VM and installed Windows 10 on the VM. I am not responsible for any maneuvers or wrong executions of commands that may cause any problems in your Proxmox server or VMS or anything else. The intention of this document is to help anyone experiencing error code 43 and also document it for my own personal use.

## Setup the VM config

see the file: https://gist.github.com/felipemarques/bc0990b60aac19153e09f0c591b696f2#file-999-conf

## Update grub
Follow the file here in this gist: /etc/default/grub

```
update-grub && update-initramfs -u -k all && proxmox-boot-tool refresh
```

## Update /etc/modules

```
nano /etc/modules
```

## Update/create /etc/modprobe.d/kvm.conf

```
nano /etc/modprobe.d/kvm.conf
```

## Update your other files as in this docs:
- dont forget to check every file.

## THE MAIN
For me, I needed to patch the rom bios of the GTX 770.
Here I will describe with images how I could solve the error Code 43.

![image](https://gist.github.com/assets/2640656/7113212a-a55b-43d1-a558-d249aa4a0401)
![image](https://gist.github.com/assets/2640656/a9d0cbd3-62d0-430c-80c7-667da0f3705f)
![image](https://gist.github.com/assets/2640656/e876b122-174d-4b6d-a828-f3129c2fa021)
![image](https://gist.github.com/assets/2640656/b7ed7a17-e2f7-4f9c-8f23-b4e669a321ad)
![image](https://gist.github.com/assets/2640656/3e0fc824-61ab-4201-b5fd-246053cb8019)
![image](https://gist.github.com/assets/2640656/09d7c09f-f50b-4acc-82e4-0a6790bf38ab)
![image](https://gist.github.com/assets/2640656/c596086b-7dab-4b62-8d65-5eb4d69494fa)
![image](https://gist.github.com/assets/2640656/57577975-1aed-44c0-a27c-71d52503d5c4)
![image](https://gist.github.com/assets/2640656/7b93582a-e9b9-462b-b5a4-1bc5bdde8110)
![image](https://gist.github.com/assets/2640656/c9f01254-dfae-4d28-9be7-980d32673259)
![image](https://gist.github.com/assets/2640656/3a7cf197-b159-45bf-97c7-ee26140da247)


## Sources:

- https://pve.proxmox.com/wiki/PCI_Passthrough
- https://pve.proxmox.com/pve-docs/pve-admin-guide.html#qm_pci_passthrough
- https://www.reddit.com/r/homelab/comments/b5xpua/the_ultimate_beginners_guide_to_gpu_passthrough/
- https://forum.proxmox.com/threads/gpu-passthrough-not-working.126537/
- https://www.reddit.com/r/Proxmox/comments/lcnn5w/proxmox_pcie_passthrough_in_2_minutes/