#!/bin/bash

debug=true

ipaddr=`echo $SSH_CLIENT | sed "s/ .*//"`
#proxy="--socks5 $ipaddr:7070"
proxy=

function getv() {
	local key=$1
	local retry=10
	#local ipaddr=gaovideo.com
	local ipaddr=199.195.197.140

	#local url="http://gaovideo.com/media/player/jwconfig.php?vkey=$key"
	local url="http://$ipaddr/media/player/cpconfig.php?vkey=$key"
	#local ref="http://gaovideo.com/video/$key/"
	#local exp="s/^\s*<file>\(http:\/\/.*\/flv\/$key.mp4\)<\/file>.*$/\1/p"
	local exp="s/^[ \t]*<file>\(http:\/\/.*\/flv\/[0-9]*\.mp4\)<\/file>.*$/\1/p"

	#cmd="curl $proxy \"$url\" -e \"$ref\""
	cmd="curl $proxy \"$url\""
	echo $cmd

	while [ $retry -gt 0 ]; do
		#file=`eval $cmd | sed -n -e "$exp"`
		`eval $cmd > config.txt`
		cat config.txt
		file=`cat config.txt | sed -n -e "$exp"`
		echo url: $file
		exit
		#[ -n "$file" ] && break;
		[ -n "$file" ] && return;
		#exit
		((retry--))
		sleep 5
	done

	[ -z "$file" ] && return
	curl $proxy -O $file
}

while [ $# -ge 1 ]
do
	getv $1
	shift
done

