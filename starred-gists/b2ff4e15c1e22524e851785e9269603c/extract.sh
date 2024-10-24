#!/bin/bash

# Default extraction target CWD
exdir="."


_unzip() {
	unzip "$1" -d "$exdir"
}


while [ -n "$1" ]; do
case "$1" in

"-h")
	echo "Usage:  unpack [-D dir] [files]
   -D dir   Set output directory
   files    Files to extract/decompress"
	exit 0
	;;
"-D")
	shift
	# ignore checks
	# [ -d "$1" -a -w "$1" ] && exdir="$1"
	# `readlink' important when $exdir compared with `pwd'
	exdir="`readlink -f \"$1\"`"
	;;
-*)
	# switches
	;;
*)
	break
	;;
esac
shift
done

while [ -n "$1" ]; do

bfn="${1##*/}"		# base file name
fn="${bfn%.*}"		# without extension
exfn="${exdir}/${fn}"	# base file in output dir
lcbfn=`echo "${1##*/}" | tr "[:upper:]" "[:lower:]"`;	# lower case base file name
apn=`readlink -f "$1"`	# absolute path name


case "$lcbfn" in
*.tar)
	tar -C "$exdir" -xvf "$1";;
*.tgz|*.tar.gz|*.dsl)
	tar -C "$exdir" -xvzf "$1";;
*.tbz2|*.tar.bz2|*.tbz)
	tar -C "$exdir" -xvjf "$1";;
*.tar.z|*.taz)
	tar -C "$exdir" -xvZf "$1";;
*.z)
	if [ "`pwd`" = "$exdir" ]; then
		uncompress "$1"
	else
		uncompress -c "$1" > "${exfn}"
	fi;;
*.gz)
	if [ "`pwd`" = "$exdir" ]; then
		gunzip -dv "$1"
	else
		gunzip -dcv "$1" > "${exfn}"
	fi;;
*.bz2)
	if [ "`pwd`" = "$exdir" ]; then
		bunzip2 -dv "$1"
	else
		bunzip2 -dcv "$1" > "${exfn}"
	fi;;
*.arj)
	arj e "$1" "$exdir";;
*.lzh|*.lha)
	lha -xvw="$exdir" "$1";;
*.rar)
	unrar x "$1" "$exdir";;
*.zip|*.wsz|*.xpi)
	_unzip "$1";;
*.odt|*.ods)
	_unzip "$1";;
*.docx|*.pptx|*.xlsx)
	_unzip "$1";;
*.jar)
	if [ -x "`which jar`" ]; then
		jar -xvf "$1"
	else
		_unzip "$1"
	fi;;
*.zoo)
	if cd "$exdir"; then
		zoo x "$apn"
		cd -
	fi;;
*.deb)
	dpkg -X "$1" "$exdir";;
*.rpm)
	if cd "$exdir"; then
		rpm2cpio "$apn" | cpio -vid
		cd -
	fi;;
*.7z)
	7zr x -o"$exdir" "$1";;
*.cab|*.msi)
	cabextract -d "$exdir" "$1";;
*.ace)
	if cd "$exdir"; then
		unace e "$apn"
		cd -
	fi;;
*.ha)
	if cd "$exdir"; then
		ha xa "$apn"
		cd -
	fi;;
*.alz)
	unalz -d "$exdir" "$1";;
*.arc|*.ark)
	if cd "$exdir"; then
		nomarch "$apn"
		cd -
	fi;;
#*.uha
#	dosemu uharcd.exe x -t"$exdir" "$1";;
#*.dar
#	true;;
*.a|*.ar)
	ar xo "$1";;
*.iso)
	exdir="$exdir" unpack-iso "$1";;
thumbs.db|ehthumbs.db|thumbcache_*.db)
	vinetto -o "$exdir" "$1";;
*)
	mime="`file -i "$1"`"
	case "$mime" in
	"application/x-zip")
		_unzip "$1";;
	*)
		echo "unpack: Unknown compression type." >&2
		file -k "$1" >&2;;
	esac;;
esac
shift

done

exit $?