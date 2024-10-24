#!/bin/bash
addr=$1
port=$2
proto=$3
int=$4

echo Resetting firewall
sudo ufw --force reset  > /dev/null
sudo ufw --force enable > /dev/null

echo Allowing outbound...
echo ...VPN $addr:$port/$proto
sudo ufw allow out on $int to $addr port $port proto $proto >/dev/null
echo connexions and nothing else on real
sudo ufw deny out on $int >/dev/null
