#!/bin/bash
# download episodes from readcomics.net take an episode and download it, to download full serie do things like :
#  comics-read-comics-download.com http://www.readcomics.net/red-robin/chapter-{1..26}
# this uses bash/zsh nifty seq expansions it basically converts it to chapter-1 chapter-2 chapter-3 etc..
set -e
#set -x


function dwl() {
    local ARG BASE tmpfile IMAGES dirimg bimg

    ARG=$1
    [[ -z ${ARG} ]] && { echo "error no arg to func specified"; exit 1;}

    [[ $ARG != */full ]] && ARG=${ARG}/full
    BASE=$(echo ${ARG}|sed 's|.*/\([^/]*\)/\([^/]*\)/[^/]*$|\1-\2|')

    tmpfile=/tmp/.$$.tmp.html
    finally () { rm -f ${tmpfile}  ;}
    trap finally INT EXIT
    dirimg=/tmp/readcomics/${BASE}

    mkdir -p ${dirimg}
    curl -o${tmpfile} ${ARG}

    IMAGES=$(grep 'img class="chapter_img"' ${tmpfile}|sed 's/.*src="\([^"]*\)".*/\1/')

    for img in ${IMAGES};do
        bimg=$(basename $img)
        wget -c -O "${dirimg}/${bimg}" -c "${img}"
    done

    cd $(dirname ${dirimg})
    zip ${BASE}.cbz ${BASE}/*.jpg

    rm -rf ${BASE}/

    echo $(dirname ${dirimg})/${BASE}.cbz
}

ALL=$@

[[ -z ${ALL} ]] && { echo "You need some stuff for me bud"; exit 1 ;}

for url in ${ALL};do
   dwl $url
 done