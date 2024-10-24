DIR=`dirname $(readlink -f "$0")`
sudo rfkill unblock all
#sudo create_ap -c 11 -w 2 --ieee80211ac --ieee80211n wlp3s0 $1 $SSD $PASS
sudo "$DIR/lnxrouter" --ap wlp3s0 $SSD -p $PASS -w 2 -c 11 --no-virt --hostname sneakbox
