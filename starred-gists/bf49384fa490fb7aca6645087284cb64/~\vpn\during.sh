#!/bin/bash
DIR=`dirname $(readlink -f "$0")`
int=$1

echo Allowing incomming...
echo ...SSH
sudo ufw allow in on $int to any port      22 proto tcp >/dev/null
echo ...NetBIOS, SMB, LLMNR
sudo ufw allow in on $int to any port 137,138 proto udp >/dev/null
sudo ufw allow in on $int to any port 137,139 proto tcp >/dev/null
sudo ufw allow in on $int to any port     445 proto tcp >/dev/null
sudo ufw allow in on $int to any port    5355 proto udp >/dev/null
sudo ufw allow in on $int to any port    5355 proto tcp >/dev/null
echo ...SOCKS, RDP
sudo ufw allow in on $int to any port    8080 proto tcp >/dev/null
sudo ufw allow in on $int to any port    3389 proto tcp >/dev/null
#echo ...deluge
#sudo ufw allow in on $int to any port   58846 proto tcp > /dev/null
##this is set to 4000 anyway
echo connexions and nothing else in on real
sudo ufw deny in on $int >/dev/null

sudo cp "$DIR/resolv.conf" /etc/
