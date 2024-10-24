#!/bin/bash
set -e
set -x

ARG=$1
[[ -z ${ARG} ]] && exit 1

BASE=$(basename ${ARG})

tmpfile=/tmp/.$$.tmp.html
finally () { rm -f ${tmpfile}  ;}
trap finally INT EXIT
dirimg=/tmp/viewcomics/${BASE}

mkdir -p ${dirimg}
curl -o${tmpfile} ${ARG}

IMAGES=$(egrep -oEi 'img border=.0. src=".([^"]*)"' ${tmpfile}|sed 's/.*src="/http:/;s/"//')

for img in ${IMAGES};do
    bimg=$(basename $img)
    wget -c -O "${dirimg}/${bimg}" -c "${img}"
done

cd $(dirname ${dirimg})
zip ${BASE}.cbz ${BASE}/*.jpg

rm -rf ${BASE}/

echo $(dirname ${dirimg})/${BASE}.cbz
