#!/bin/bash

REPOS="https://api.github.com/users/szepeviktor/repos"
TARGET="/home/viktor/github/"

Link_next() {
    # Link header / value / explode at commas / next URL
    grep "  Link:" "$HEADERS" \
        | cut -d" " -f4- \
        | sed 's/, /\n/g' \
        | sed -n 's/<\(.\+\)>; rel="next"/\1/p'
}

Git_clone() {
    local URL="$1"
    local REPO="$(basename "$URL")"

    REPO="${REPO%.git}"
    if [ -d "$REPO" ]; then
        git --git-dir="${REPO}/.git/" pull --quiet
    else
        git clone --quiet --no-checkout "$URL"
    fi
}

HEADERS="$(tempfile)"
JSON="$(tempfile)"

cd "$TARGET" || exit 1

while :; do
    wget -q -S -O "$JSON" "$REPOS" 2> "$HEADERS"
    # list JSON / fork and clone URL / source repos with URL / clone URL / URL
    cat "$JSON" \
        | grep '^\s\+"\(fork\|clone_url\)":\s\+' \
        | grep -A 1 '"fork": false,' \
        | grep '"clone_url":' \
        | cut -d'"' -f4 \
        | while read REPO_URL; do
            Git_clone "$REPO_URL"
        done

    REPOS="$(Link_next)"
    [ -z "$REPOS" ] && break
done

rm "$HEADERS" "$JSON"
