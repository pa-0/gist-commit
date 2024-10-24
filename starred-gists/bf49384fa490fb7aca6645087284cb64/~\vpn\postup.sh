#!/bin/bash
DIR=`dirname $(readlink -f "$0")`
int=$1
tun=$2
echo VPN is up

"$DIR/during.sh" $int

echo Allowing incomming...
echo ...55800 to 55899 port
sudo ufw allow in on $tun from any to any port 55800:55899 proto tcp >/dev/null
echo ...443 port
sudo ufw allow in on $tun from any to any port 443 proto tcp >/dev/null
echo connexions and nothing else on VPN
sudo ufw deny in on $tun >/dev/null

sed -i --follow-symlinks "s/^external: .*$/external: $tun/" "$DIR/danted.conf"
sudo service danted restart
