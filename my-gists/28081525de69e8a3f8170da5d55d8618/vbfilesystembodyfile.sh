#!/bin/bash
#Simple script for VirtuaBox filesystem bodyfile creation
# Usage: vbfilesystembodyfile.sh <VM name>

disk=`echo $( sudo VBoxManage showvminfo $1|grep "vdi\|vmdk"|head -n 1|cut -d ":" -f 2|cut -d "(" -f 1)|xargs`
VBoxManage clonemedium $disk ./$1.raw --format=raw
offset=$(mmls $1.raw -a | grep `mmls $1.raw -a | grep "000:" |  cut -d " " -f 9 | sort -r | head -1` | cut -d " " -f 6 | bc)
fls -o $offset  -r -m / $1.raw > $1.bodyfile
rm $1.raw
