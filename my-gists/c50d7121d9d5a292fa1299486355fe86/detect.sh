#!/bin/sh
IFS=$'\t\n\r'
available=(`cat available.txt`)
#echo The number of available packages: ${#available[@]}
if [ ${#available[@]} -eq 0 ]; then
	echo No available package is detedted.
	echo You may failed to download package list from PortableApps.com.
	exit -1
fi

installed=(`cat installed.txt`)
#echo The number of installed packages: ${#installed[@]}
if [ ${#installed[@]} -eq 0 ]; then
	echo No installed package is detedted.
	echo You may have given wrong ROOT.
	exit -1
fi

for i in ${installed[@]}
do
	controlled=0
	for a in ${available[@]}
	do
		if [ ${a} = ${i} ]
		then
			controlled=1
			break
		fi
	done
	if [ ${controlled} -eq 0 ]
	then
		echo ${i}
	fi
done

