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
[ -v number ] || number="100"

dirname=$1_$(date +"$dformat")
mkdir $dirname
cd $dirname

link="https://www.reddit.com/r/$1/.json?limit=$number"
wget $link -O tempfile

[ -f ~/.config/redditgit/style.html] || (
	echo -n Creating style file
	if [ -v $XDG_CONFIG_HOME ]
	then
		install -D style.html "$XDG_CONFIG_HOME/style.html"
		echo "$XDG_CONFIG_HOME/style.html"
	else
		install -D style.html ~/.config/style.html
		echo ~/.config/style.html
	fi )
cp "$XDG_CONFIG_HOME/style.html" site.html || cp ~/.config/style.html site.html

for num in $(seq 0 $(($number-1)))
do
	echo "<h1> $(jq -r .data.children[$num].data.title tempfile) </h1>" >> site.html
	echo "<p> $(jq -r .data.children[$num].data.selftext tempfile) </p>" >> site.html
	content="$(jq -r .data.children[$num].data.url tempfile)"
	domain="$(echo $content | cut -d / -f 3)"
	if [ "$domain" == "v.redd.it" ]
	then
		media="$(jq .data.children[$num].data.media.reddit_video tempfile)"
		echo "<video width=$(echo $media | jq .width) height=$(echo $media | jq .height) controls>
	<source src=$(echo $media | jq .fallback_url | cut -d ? -f 1)\">
	<source src=$(echo $media | jq .fallback_url | cut -d _ -f 1)_audio.mp4\">
</video>" >> site.html
	elif [ "$domain" == "i.redd.it" ]
	then
		echo "<img src=$content>" >> site.html
	fi
done

echo '</html>' >> site.html
