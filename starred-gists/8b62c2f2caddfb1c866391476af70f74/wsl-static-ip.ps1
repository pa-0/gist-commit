# https://netmarble.engineering/wsl2-static-ip-scheduler-settings/

wsl hostname -I
wsl -d Ubuntu-20.04 -u root ip addr add 192.168.254.16/24 broadcast 192.168.50.255 dev eth0 label eth0:1
netsh interface ip add address "vEthernet (WSL)" 192.168.254.100 255.255.255.0