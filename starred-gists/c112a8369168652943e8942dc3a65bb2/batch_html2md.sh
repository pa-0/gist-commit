#!/bin/bash

# Converts HTML from https://exportmyposts.jazzychad.net/ exports to Markdown

POSTS_DIR=/Users/richard/Desktop/d6y/posts

for file in $POSTS_DIR/*.html
do
	echo $file

	# The filename without the path:
	basefile=`basename $file`

	# Filenames have the form: yyyy-mm-dd-hh:mm:ss-slug.html
	
	# Remove the hh:mm:ss- part
	shortfile=${basefile/[0-9][0-9]:[0-9][0-9]:[0-9][0-9]-}
	
	# Remove the .html part
	withoutext=${shortfile%.html}
	
	# The slug is the part after the date:
	slug=${withoutext:11}

	# The publication date in yyyy-mm-dd format
	pubdatedash=${withoutext:0:10}

	# The publication date in yyyy/mm/dd format
	pubdate=${pubdatedash//-//}

	# The output filename e.g., yyyy-mm-dd-slug.md
	mdfile=${withoutext}.md
	
	# MAGIC!
	pandoc --reference-links -s -f html -t markdown $file > $mdfile.tmp

	# The first line is a comment followed by the title
	mdtitle=`head -1 $mdfile.tmp`
	title=${mdtitle:1}

	# Write meta data to the start of the file
	echo "title: $title" > $mdfile
	echo "date: $pubdate" >> $mdfile
	echo "alias: /$slug" >> $mdfile

	# Append the rest of the markdown without the title (as I don't need it)
	tail +7 $mdfile.tmp >> $mdfile
	rm $mdfile.tmp

done

