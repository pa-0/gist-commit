ps -e | awk '/awk/ {next} {if(/ dd/) print "kill -INFO", $1}' | sh #get status of dd (also CTRL-T), or no pgrep (rescue disk)  
# %wheel ALL=(ALL) NOPASSWD: ALL #sudo without password, uncomment ...   
dscl . append /Groups/wheel GroupMembership USERNAME #this in etc/sudoers ... 
vifs #safely edit fstab 
iotop #harddisk I/O  
iostat #I/O for disc and CPU
vm_stat #show mach virtual memory statistics  
sudo killall -info mDNSResponder #retrieve internal state of mDNSResponder (/var/log/system.log starts at ---- BEGIN STATE LOG ----)    
indent #indent and format C program source
otool -L /bin/ls #list dynamicaly linked libraries 
kextunload -b org.virtualbox.kext.VBoxNetAdp #unload driver by bundlename
kextstat #list currently loaded drivers_
ls -d \*/ #list the directories in the current directory
sysctl net.inet.tcp.rfc1323 #TCP window scale option  
nettop  #network monitor
lsof -iP | grep -i "listen" #list listening ports
brew uses --installed #which packages depend on ...  
brew uses --recursive #dependency tree 
brew info $(brew list) |xargs  -0 |  grep -ZB2  Depends\ on  #show packages with dependencies  
brew leaves #packages without dependencies  
brew cleanup #delete old versions
brew install --with-lua vim #vim with lua
ln -s /usr/local/bin/mvim /usr/local/bin/vim #start macvim without gui  
brew install bash #enable autocd in macos ...
echo /usr/local/bin/bash >> /etc/shells # ... 
chsh #change login shell #New shell: /usr/local/bin/bash ...
mysql.server start #start mysql 

xcrun -find #show path of commands inside Xcode
/System/Library/Extensions/TMSafetyNet.kext/Helpers/bypass <cmd> #operate on files in Timemachine
cd /private/var/log/asl #speed up terminal in osx  ...
ls \*.asl # ... 
sudo rm !$ # ...
dscl #add users,... # ...  
hdid #mount and manipulate local and remote .dmg images  
hdiutil attach /Users/*/*.sparsebundle #mount a crypted user profile to /Volumes/*    
hdiutil eject ... # ... 
hdiutil compact ... #shrink after manipulation of files within the bundle ...
lsbom #list bill of materials of .pkg installers    
mdfind #metadata search 
mdfind -onlyin #specify searchdir 
hostinfo #cpu and memory info 
pkgutil --pkgs #list all installed packages (.pkg)  
pkgutil --files PACKAGE #list files installed by package
vpnd #mac os VPN service daemon
dseditgroup #group record manipulation tool
say #text to speech
pbpaste #paste from clipboard
calendar /usr/share/calendar #calendars with events
pmset sleepnow #sleep from commandline 
sips -g pixelWidth -g pixelHeight [image-file] #get picture dimensions    
/Applications/Utilities/Network Utility.app/Contents/Resources/stroke #mac os built-in port scanner 
defaults -currentHost write -globalDomain AppleFontSmoothing -int 2  #font smoothing  
defaults write com.apple.finder AppleShowAllFiles TRUE #show hidden files in finder and timemachine ...  
killall Finder # ... 