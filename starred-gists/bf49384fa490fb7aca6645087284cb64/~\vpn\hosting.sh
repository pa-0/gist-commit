mapfile -t ip < <(ip a show wlp3s0 | sed -E -e '/inet/!d' -e 's#^.*inet\s+([0-9.]+)/([0-9]+)\s.*$#\1\n\2#')
sudo ufw allow from "${ip[0]}/${ip[1]}" to ${ip[0]}
