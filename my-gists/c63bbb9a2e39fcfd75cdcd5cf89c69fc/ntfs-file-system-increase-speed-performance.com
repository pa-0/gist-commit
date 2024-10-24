rem execute as an Administrator

rem based on http://www.windowsdevcenter.com/pub/a/windows/2005/02/08/NTFS_Hacks.html
ram based on https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-2000-server/cc938961(v=technet.10)

rem http://archive.oreilly.com/cs/user/view/cs_msg/95219 (some installers need 8dot3 filenames)
rem disable 8dot3 filenames
ram Warning: Some applications such as incremental backup utilities rely on this update information and do not function correctly without it.
fsutil behavior set disable8dot3 1

rem increase ntfs mtz size
fsutil behavior set mftzone 2

rem disable last access time on all files
fsutil behavior set disablelastaccess 1

echo now you can reboot 