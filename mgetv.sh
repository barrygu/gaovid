#!/bin/sh

ipaddr=`echo $SSH_CLIENT | awk '{print $1}'`
proxy="--socks5 $ipaddr:7070"

function getv() {
	local key=$1
	local count=0

	local url="http://gaovideo.com/media/player/jwconfig.php?vkey=$key"
	local ref="http://gaovideo.com/video/$key/"
	local exp="s/^\s*<file>\(http:\/\/.*\/flv\/$key.mp4\)<\/file>.*$/\1/p"

	cmd="curl $proxy \"$url\" -e \"$ref\""
	echo $cmd

	while [ $count -lt 10 ]; do
   		#echo curl "$url" -e "$ref"
   		#file=`curl "$url" -e "$ref" | sed -n -e "$expr"`
   		#contents=`eval $cmd`
   		#echo $contents
   		file=`eval $cmd | sed -n -e "$exp"`
		#file=`cat $contents | sed -n -e "$exp"`
   		echo $file
   		[ -n "$file" ] && break
   		((count++))
   		sleep 30
   		#break
	done

	[ -z "$file" ] && return
	count=0
	while [ $count -lt 10 ]; do
		[ -f "$file" ] && rm -f $file
		#wget -b "$file"
		curl $proxy -O $file
		[ $? -eq 0 ] && break
		((count++))
		sleep 30
	done
}

#echo param count: $#
while [ $# -ge 1 ]
do
#	echo param: $1
	getv $1
	shift
done

