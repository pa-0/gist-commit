rm -rf old/
mkdir old
mv *.ovpn old/

cd orig/
for conf in *.ovpn
do
	name=`ag -o '(?<=^remote )[^ ]+' $conf | head -1`
	ip=`getent hosts echo $name | cut -d' ' -f1 | head -1`
	cat $conf | sed "s/ $name / $ip /" > `echo "$conf" | sed 's#^[^-]*-#../#' | sed 's#1\?\(-ext\)\?\.ovpn$#.ovpn#'`
done
