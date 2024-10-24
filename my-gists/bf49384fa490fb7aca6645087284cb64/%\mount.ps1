#sudo cryptsetup luksFormat --type luks2 /dev/sdc
#sudo mkfs.btrfs -f /dev/mapper/sneak

Start-Process 'wsl' ('--mount', '\\.\PHYSICALDRIVE1', '--bare') -Verb RunAs
bash -c (@'
	mkdir /mnt/wsl/sneak
	sudo cryptsetup luksOpen /dev/sdc sneak
	sudo mount \
		-o ssd,noatime,space_cache,commit=120,compress \
		/dev/mapper/sneak \
		/mnt/wsl/sneak
'@ -replace '\r','')