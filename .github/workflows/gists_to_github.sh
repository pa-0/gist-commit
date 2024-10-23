#!/bin/bash
OLDIFS="$IFS" # keep a backup here

data="$(curl -L -H "Accept: application/vnd.github+json" -H "Authorization: Bearer ${{secrets.API_TOKEN}}" -H "X-GitHub-Api-Version: 2022-11-28" 'https://api.github.com/users/pa-0/gists')"

IFS=$' ' # parsing the string
urls="$(echo "$data" | jq -r .[].files | jq -r .[].raw_url)"
descriptions="$(echo "$data" | jq -r .[].description)"
nb_comments="$(echo "$data" | jq -r .[].comments)"
comments_urls="$(echo "$data" | jq -r .[].comments_url)"

IFS=$'\n' # parsing the array
urls=($urls)
descriptions=($descriptions)
nb_comments=($nb_comments)
comments_urls=($comments_urls)

index=0

for url in "${urls[@]}"
do
	gist="$(curl -s $url)"

	filename="$(echo $url | cut -f8 -d /)" # parse url to get filename

	subfolder="$filename"
	mkdir "$subfolder" 2>/dev/null # create directory for each gist

	readme="$subfolder/README.md"

	echo "${descriptions[index]}" > "$readme" # write gist description
	echo -e "---------------\n" >> "$readme"
	echo -n "### " >> "$readme" # url will be h3 in markdown
	echo "$data" | jq -r .["$index"].html_url >> "$readme" # write url to gist.github.com
	echo "$gist" > "$subfolder"/"$filename" # write code
	if [ "${nb_comments[index]}" -ne 0 ]
	then
	    comment="$(curl -s ${comments_urls[index]})"
	    comment_body="$(echo $comment | jq -r .[].body)"
	    echo -e "---------------\n\n" >> "$readme"
	    echo "$comment_body" >> "$readme" # write comments in README if there are any
	fi

	echo -e "\e[033m" "$filename" : "\e[32m" DONE "\e[0m\n"
	let "index+=1"
done
IFS="$OLDIFS"
