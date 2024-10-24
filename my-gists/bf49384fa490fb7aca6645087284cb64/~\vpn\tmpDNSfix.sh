#!/bin/bash
#/etc/resolv.conf
#resolvconf -u
#exit 0

cat << EOF > resolv.conf
domain home.gateway
search home.gateway
EOF
./update-resolv-conf $@ 2>/dev/null | \
	grep -P 'DNS (\d{1,3}\.){3}\d{1,3}$' | \
	grep -oP '(\d{1,3}\.){3}\d{1,3}$' | \
	xargs -I {} echo nameserver {} \
	>> resolv.conf
mv resolv.conf /etc
#echo nameserver 8.8.8.8 >> /etc/resolv.conf
