mkdir orig || exit
mv *.conf orig/

DIR=`dirname "$(dirname "$(readlink -f "$0")")"`
int='eno1'

cd orig/
for conf in *.conf
do
	addr=`ag -o '(?<=^Endpoint = ).*' $conf`
	port=`echo $addr | ag -o '(?<=:).*$'`
	addr=`getent hosts $(echo $addr | ag -o '^[^:]+') | cut -d' ' -f1 | head -1`
	cat $conf \
	| sed '0,/^$/ s#^$#PreUp = '$DIR'/preup.sh '$addr' '$port' udp '$int'\nPostUp = '$DIR'/postup.sh '$int' %i\nPreDown = '$DIR'/predown.sh '$int'\n#' \
	| sed 's/^Endpoint = .*/Endpoint = '$addr:$port'/' \
	> `echo "$conf" | sed 's#^.*-#../#'`
done
