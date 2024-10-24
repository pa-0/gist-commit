#!/bin/bash
DIR=`dirname $(readlink -f "$0")`

CONFIG="$DIR/openvpn/$1.ovpn"
ADDR=(`grep -P '^remote (\d{1,3}\.){3}\d{1,3} \d{2,5}$' "$CONFIG"`)
PROTO=(`grep -P '^proto (udp|tcp)' "$CONFIG"`)

sudo "$DIR/preup.sh" "${ADDR[1]}" "${ADDR[2]}" "${PROTO[1]}" 'eth0'

cd `dirname "$CONFIG"`
trap "sudo $DIR/predown.sh 'eth0'" SIGINT
sudo openvpn \
	--config "$CONFIG" \
	--auth-user-pass "$DIR/auth" \
	--up "$DIR/postup.sh 'eth0' 'tun0'" \
	--down "$DIR/predown.sh 'eth0'" \
	--script-security 2 \
|| sudo "$DIR/predown.sh 'eth0'"
