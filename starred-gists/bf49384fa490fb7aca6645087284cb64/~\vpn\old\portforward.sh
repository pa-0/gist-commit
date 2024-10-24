#USER=`head -1 auth | tail -1`
#PASSWORD=`head -2 auth | tail -1`
#
#LOCAL_IP=`ip addr show tun0|grep -oE "inet *10\.[0-9]+\.[0-9]+\.[0-9]+"|tr -d "a-z :"|tee /tmp/vpn_ip`
#
#if [[ -z "$1" ]]; then
#  CLIENT_ID=`head -n 100 /dev/urandom | md5sum | tr -d " -"`
#  echo $CLIENT_ID
#else
#  CLIENT_ID="$1"
#fi
#
#ADDR='https://www.privateinternetaccess.com/vpninfo/port_forward_assignment'
#
#JSON=`wget -q --post-data="user=$USER&pass=$PASSWORD&client_id=$CLIENT_ID&local_ip=$LOCAL_IP" -O - "$ADDR" | head -1`
#
#echo $JSON




#CLIENT_ID=`head -n 100 /dev/urandom | sha256sum | tr -d " -"`
CLIENT_ID='721c4843a0764cbb0a4072f4a39c3e423f728a4dfe5ab916b21262dadad481db'
curl "http://209.222.18.222:2000/?client_id=$CLIENT_ID" 2>/dev/null | \
	grep -oP '(?<="port":)[0-9]+'
