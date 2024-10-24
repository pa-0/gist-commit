bash -c (@'
	sudo umount /mnt/wsl/sneak
	sudo cryptsetup luksClose sneak
'@ -replace '\r','')
Start-Process 'wsl' ('--unmount') -Verb RunAs