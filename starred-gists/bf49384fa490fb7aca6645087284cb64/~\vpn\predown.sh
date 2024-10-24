#!/bin/bash
DIR=`dirname $(readlink -f "$0")`
int=$1
echo VPN is down

echo Resetting firewall
sudo ufw --force reset  >/dev/null
sudo ufw --force enable >/dev/null

echo Allowing DHCP
sudo ufw allow to any port 53 >/dev/null
sudo ufw allow to any port 67 >/dev/null
sudo ufw allow to any port 68 >/dev/null

echo and nothing else
sudo ufw deny out on $int >/dev/null

"$DIR/during.sh" $int
