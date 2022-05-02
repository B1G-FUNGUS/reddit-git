#!/bin/bash

subname=${1/\//_}_$(date +"%Y-%m-%d_%H%M%S")
mkdir $subname
cd $subname

subjson="https://www.reddit.com/r/$1/.json?limit=$2"

tempfile=Reddit-Git_$(date +"%Y-%m-%d_%H%M%S")
tempfile2=$tempfile\2
wget $subjson -O $tempfile

jq . $tempfile > $tempfile2

sed -n '/"url_overridden_by_dest":/ p' $tempfile2 > $tempfile

sed 's/\s*"url_overridden_by_dest": "\(https:.*\)",/\1/' $tempfile > $tempfile2

images="$(sed -n '/https:\/\/i/ p' $tempfile2)"
videos="$(sed -n '/https:\/\/v/ p' $tempfile2)"

wget $images
yt-dlp $videos

rm $tempfile $tempfile2
