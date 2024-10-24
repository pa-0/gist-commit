#!/bin/bash

set -o errexit

screenshot=rich-help-screenshot.png
perspective=01-perspective.png
shadow=02-shadow.png
gradient=03-gradient.png
final=04-final.png

# create perspective view
convert  ${screenshot} -matte -virtual-pixel transparent -distort Perspective '0,0 0,0  987,0 987,70  987,810 987,720  0,810 0,810' ${perspective}

# add shadow to the perspective view
convert  ${perspective} \( +clone -background black -shadow 80x10+5+10 \) +swap -background none -layers merge +repage  ${shadow}

# create a color gradient for the background
convert -size 1027x850 -define gradient:direction=57 'gradient:rgb(54,200,150)-rgb(20,90,160)' ${gradient}

# combine both images
convert -page +0+0 ${gradient} -page +0+0 ${shadow} +page -alpha Set -virtual-pixel transparent -background None -flatten ${final}
