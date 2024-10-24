## ** PuttyPortable Linker didn't work for me - below is a replacement technique **

Now recompiling winscpportable launcher:

## Changes to WinSCPPortableU.nsi

1) Add to ;=== Include

!include StrRep.nsh

(You may need to copy the StrRep.nsh to the appropriate plugin directory of nsis)

2) comment out line that restores putty as default external application

		;WriteINIStr "$SETTINGSDIRECTORY\winscp.ini" "Configuration\Interface" "PuttyPath" "$1"
		
3) Compile this
4) Launch winSCP and change exeternal application choice to

(Browse to) PortableApps\KiTTYPortable\KiTTYPortable.exe -cmd "cd ""!/""" !U@!@

The important part is documented on the winscp site about adding the '-cmd "cd ""!/""" !U@!@' to the end