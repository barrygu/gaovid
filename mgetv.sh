#!/bin/bash

ipaddr=`echo $SSH_CLIENT | sed "s/ .*//"`
#proxy="--socks5 $ipaddr:7070"
proxy=

function getv() {
	local key=$1
	local retry=10

	local url="http://gaovideo.com/media/player/jwconfig.php?vkey=$key"
	local ref="http://gaovideo.com/video/$key/"
	local exp="s/^\s*<file>\(http:\/\/.*\/flv\/$key.mp4\)<\/file>.*$/\1/p"

	cmd="curl $proxy \"$url\" -e \"$ref\""
	echo $cmd

	while [ $retry -gt 0 ]; do
		file=`eval $cmd | sed -n -e "$exp"`
		echo $file
		[ -n "$file" ] && break;
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

