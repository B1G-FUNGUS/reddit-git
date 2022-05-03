#!/bin/bash

command -v wget || (echo -e "\e[0;33;1mwget not installed!";  exit 1)
command -v yt-dlp && video="yt-dlp" ||
	command -v youtube-dl && video="youtube-dl" ||
	video="wget"

while getopts 'dbt:s:v:g:' option
do
	case $option in
		# Download
		d)
			echo not implimented
			;;
		# Barebones download
		b)
			echo not implimented
			;;
		# Tags
		t)
			echo not implimented
			;;
		# Sort
		s)
			echo not implimented
			;;
		# Video downloader
		v)
			echo not implimented
			;;
		# General downloader
		g)
			echo not implimented
			;;
		# Date format
		f)
			dformat="$OPTARG"
			;;
		# Number
		n)
			number="$OPTARG"
			;;
			
	esac
done

[ -v dformat ] || dformat="%Y-%m-%d_%H%M%S"
[ -v number ] || number="25"

dirname=$1_$(date +"$dformat")

mkdir $dirname
cd $dirname

link="https://www.reddit.com/r/$1/.json?limit=$number"
wget $link -O tempfile

echo '<html> 
<style> 
	img, iframe { 
		width: 50%; 
		margin-left: 10%;
	} 
	p, h1 {
		margin-left: 10%;
		margin-right: 20%;
	}
</style>' > site.html

for num in $(seq 0 $(($number-1)))
do
	echo "<h1> $(jq -r .data.children[$num].data.title tempfile) </h1>" >> site.html
	echo "<p> $(jq -r .data.children[$num].data.selftext tempfile) </p>" >> site.html
	content="$(jq .data.children[$num].data.url_overridden_by_dest tempfile)"
	letter="$(echo $content | cut -c 10)"
	if [ "$letter" == "v" ]
	then
		vid="$(echo $content | cut -d / -f 4)"
		echo "<video control>
<source src=\"https://v.redd.it/$vid/DASH_480.mp4\">
<source src\"https://v.redd.it/$vid/DASH_audio.mp4\">
</video>" >> site.html
	elif [ "$letter" == "i" ]
	then
		echo "<img src=$content>" >> site.html
	fi
done

echo '</html>' >> site.html
