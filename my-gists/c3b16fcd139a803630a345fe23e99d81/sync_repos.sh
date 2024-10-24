#!/bin/bash
temp=`basename $0`
TMPFILE=`mktemp /tmp/${temp}.XXXXXX` || exit 1

API_CALL="/user/repos?type=owner+fork=true"

function rest_call {
    curl -u skarlso:$GIT_TOKEN -s $1 >> $TMPFILE
}

last_page=`curl -u skarlso:$GIT_TOKEN -s -I "https://api.github.com$API_CALL" | grep '^Link:' | sed -e 's/^Link:.*page=//g' -e 's/>.*$//g'`

if [ -z "$last_page" ]; then
    rest_call "https://api.github.com$API_CALL"
else
    for p in `seq 1 $last_page`; do
        rest_call "https://api.github.com$API_CALL?page=$p"
    done
fi

cat $TMPFILE