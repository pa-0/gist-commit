systemctl start bluetooth  #start bluetooth ... 
systemctl status bluetooth #power on ...
bluetoothctl               #scan on <cr> connect <cr> restart browser/app ... 
systemctl list-unit-files --state enabled #enabled services, neat short and colorful  
systemctl restart iwd.service #wlan not ready before systemd-networkd sometimes  
script -fq /dev/null -c 'journalctl -f -p 4 -b' #failed at boot, color
xrandr --output DP-1 --mode 1920x1080 --rate 30.00 --above LVDS-1 #stop flickering of external monitor  
sudo systemctl restart lxdm #restrart xserver
cat /sys/kernel/debug/dri/0/pstate #use pstate from cat ... 
echo 0f > /sys/kernel/debug/dri/0/pstate #to boost graphic ...   
dmesg --human #system message buffer, color, less
du -hs * | sort -rh | head -5 #biggest files 
du -Sh | sort -rh | head -5 #biggest files, with subdirs  
find -type f -exec du -Sh {} + | sort -rh | head -n 5 #biggest files including subdirs
sudo ip addr flush dev wlan0 #when starting dhclient -> RTNETLINK answers: File exists  
hold ModKey + right click #resize "save as" dialoge in dwm
ctrl-shift-v #paste from firefox textfield to terminal  
sysctl -a #get or set kernel parameters at runtime
file #filetype 
ls -ldeo /Users/spartan/.ssh #show acl permissions  
chmod -a# 0 /Users/spartan/.ssh #remove strange acls   
ls -lO #list extended attributes  
xattr #display and manipulate extended attributes   
sudo gem update --system #update ruby gem  
diff -rq folder1 folder2 #compare files in two directories  
find . -path ./misc -prune -o -name '*.txt' -print #exclude directories in find (don't add the trailing slash to the directory)  
whatis  #short descriptions of system commands, words
apropos  #short descriptions of system commands, strings  
man -k   #short descriptions of system commands, strings 
whereis #locate programs
which #locate a program file in the user's path  
ls *.txt #secure deletion ...
rm !$ # ... 
dpkg-query -W -f='${Status} ${Version}\n' ... #check if package is installed or not   
cat /etc/issue #show linux distro
lsb_release -a #show linux distro
debconf-show #show configuration

ps -p $$ #display current shell name
lsblk #list partition inside WSL
bpf_probe_read() #protects Linux from arbitrary memory 
BPF_PROG_LOAD #verify and load a BPF program 