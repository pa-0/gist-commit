#!/bin/bash

URL=$1
DIR=$2

# Download a website
wget --show-progress --recursive --convert-links --page-requisites --no-parent \
--user-agent="User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:32.0) Gecko/20100101 Firefox/32.0" \
−−directory−prefix="$DIR" \
"$URL"

# Remove duplicated header content on each page
for f in **/*.html; do stdbuf -o100M cat <(grep --no-filename -A10000 '</header>' "$f" | tail -n+2) > "$f.htm"; done
rm -f "$DIR"/**/*.html
rename -x **/*.htm

# Convert the downloaded HTML files to a single PDF
htmldoc --verbose --embedfonts --jpeg=80 --webpage -f "Handbrake Manual.pdf" "$DIR"/index.html "$DIR"/**/*.html

