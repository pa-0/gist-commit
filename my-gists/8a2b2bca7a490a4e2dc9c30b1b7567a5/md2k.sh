#!/usr/bin/env bash 
  
MD=$1 
EPUB="${MD%.*}.epub" 
  
if [ "$#" -ne 1 ]; then 
   echo "Usage: $0 <file name>." 
   exit 1 
 fi 
  
if [ ! -f $MD ]; then 
  echo "[$MD] not found." 
  exit 1  
 fi 
  
pandoc --toc $MD -o $EPUB 
kindlegen $EPUB 
rm $EPUB
