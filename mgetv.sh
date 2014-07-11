#!/bin/bash

debug=false

[ "$debug" == "true" ] && set -x

#ipaddr=`echo $SSH_CLIENT | sed "s/ .*//"`
#proxy="--socks5 $ipaddr:7070"
proxy=

function getv() {
	local key=$1
	local retry=5
	local hours=10
	#local ipaddr=gaovideo.com
	local ipaddr=199.195.197.140
	local conf=config_"$key".txt
	local file=
	local link=

	local url="http://$ipaddr/media/player/cpconfig.php?vkey=$key"
	local exp="s/^[ \t]*<file>\(http:\/\/.*\/flv\/[0-9]*\.mp4\)<\/file>.*$/\1/p"

	cmd="curl $proxy \"$url\""

	while [ $hours -gt 0 ]; do
		date +%c
		echo $cmd
		while [ $retry -gt 0 ]; do
			rm -f $conf
			eval $cmd > $conf
			#file=`cat $conf | sed -n -e "$exp"`
			file=`sed -ne "$exp" $conf`
			if [ -n "$file" ]; then
				echo url: $file
				break
			else
				echo no url found...
			fi
			grep -q "<file>[ \t]*</file>" $conf
			[ $? -eq 0 ] && break
			((retry--))
			sleep 15
		done
		if [ -n "$file" ]; then
			curl $proxy -O $file
			break;
		fi
		link=`sed -ne "s/^[ \t]*<link>\(http:\/\/.*\/video\/[0-9]\+\)<\/link>.*$/\1/p" $conf`
		curl -Is $link > link_head.txt
		err_type=`sed -ne "s/^Location:.*\/needtoken\/\([^\/]\+\)\/[0-9]\+$/\1/p" link_head.txt`
		if [ "$err_type" == "reach_limit" ]; then
			echo "reach limit, waiting for an hour and try it again..."
		elif [ "$err_type" == "long_video" ]; then
			echo "the video is too long, ignored..."
			break
		else
			echo "unknown error type, ignore"
		fi
		((hours--))
		sleep 3600
	done

	#[ -z "$file" ] && echo "cannot get video $key address, ignored"
	rm -f $conf
	#[ -z "$file" ] && return
	#curl $proxy -O $file
}

while [ $# -ge 1 ]
do
	getv $1
	shift
done

