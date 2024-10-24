[windows_update_toggle.bat](https://pastebin.com/gNsLEWJe) _v10.1 **final**_  
~ one script to rule them all!  
~ block build upgrades and/or automatic updates without breawking Store downloads and Defender protection updates  
~ there is a lot of focus on Defender updates working independently, unlike any other updates "management" solution  
~ ifeo safe blocking with no destructive changes of ownership, deleting files, removing tasks, or over-blocking  
~ toggle everything from the Desktop right-click context menu!  
but wait, there is more:  
~ hide/unhide/install update lists with counter at the Desktop right-click context menu!  

_Previous update toggle batch suite scripts have been overwritten on pastebin, but will still be available here:_  
[windows_update_reboot_toggle.bat](https://pastebin.com/fZ361Yw2) __to be updated!__  
~ just removes the update reboot protected scheduled task  
[windows_update_notifications_toggle.bat](https://pastebin.com/4tPPDWtc)    
~ just blocks updates from notifying and rebooting, everything else working  
[windows_update_installs_toggle.bat](https://pastebin.com/gNsLEWJe)  
~ blocks all updates from installing, with Store and Defender protection updates working  
[windows_update_downloads_toggle.bat](https://pastebin.com/EcLB14hg)  
~ blocks all updates from even downloading, at the expense of breaking Defender protection updates (so getting an alternative AV is advised)  
[windows_update_service_toggle.bat](https://pastebin.com/cK8y4YEX)  
~ blocks wuauserv from even checking, at the expense of breaking both Store downloads and Defender protection updates (so getting an alternative AV is advised)  

_Added DefenderUpdate 4-hours scheduled task to all scripts - counter disabling automatic updates side effect_

>You can just run the respective script and forget about it, since it will add a convenient Desktop right-click context menu entry to toggle it further, with current status written right next to it. [Preview](https://i.imgur.com/06bIiWf.gifv)

_It's a given user has the responsibility to check for updates manually / re-enable automatic updates at a later time, so please don't spam about how this might be a bad idea in your view. This is about having a choice as a power user (that Microsoft has taken away) for fringe cases where automated forced update fails in a loop / incompatibility arises / simply user choice to not update at the moment._  

>Other batch scripts:  

[SpeculationControl.bat](https://pastebin.com/EABZnej8)  
~ Convenient batch wrapper around the official powershell script to advise about cpu vulnerabilities  

[esd_to_wim.bat](https://pastebin.com/WdUv5UVj)  
~ Windows Update ESD to WIM Setup [x86 or x64] - to be used with [Microsoft Products.xml links](https://download.microsoft.com/download/F/1/2/F12AE2F0-B1CC-4A83-9529-C3D43F171C62/Products_RS4_04_20_2018.xml)

[MediaCreationTool.bat](https://pastebin.com/bBw0Avc4)  
~ Get an iso / usb with ANY 1607 - 1809 build via official MediaCreationTool.exe

[MediaCreationTool_RS4.bat](https://pastebin.com/du4Td2AU)  
~ Get an iso / usb with 1803 rtm build via official MediaCreationTool.exe

[windows_x_bloat_subscribe_toggle.bat](https://pastebin.com/AVwLJpQm)  
~ Just a prevention, won't uninstall existing items
~ v3.0 applies for current user but also for new users created after running the script!

[windows_x_pro_update_policy](https://pastebin.com/8jNA2K3v)  
~ Pro: Set to notify before download and prevent driver installs  

[disable_gamebarpresencewriter.bat](https://pastebin.com/8wU6Bd2j)  
~ This won't disable the Win + G GameBar. Use Settings to do that. Might prevent some game stutters.  

[FreeStandbyMemory.bat](https://pastebin.com/Kj36ug5h) __v8 final!__  
~ Will set a schedule every `5` minutes and will clear standby memory if free physical memory is under `512MB` (can adjust)