#!/bin/bash

#ipaddr=`echo $SSH_CLIENT | sed "s/ .*//"`
#proxy="--socks5 $ipaddr:7070"
proxy="-x http://jiangu:Bag%400305@10.10.40.10:80"
#proxy="-x http://jiangu:Bag%400305@172.16.2.17:8080"
#proxy="-x http://jiangu:Bag%400305@10.80.60.19:8080"
# use Proxy varible while reach the limitation
Proxy=
check_fail_type=0

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
			for (( retry = 5; retry > 0; retry-- ))
			do
				curl -O $proxy $file
				[ $? -eq 0 ] && break
				sleep 120
			done
			break;
		fi
        if [ $check_fail_type -eq 0 ]; then
            break
        else
            link=`sed -ne "s/^[ \t]*<link>\(http:\/\/.*\/video\/[0-9]\+\)<\/link>.*$/\1/p" $conf`
            curl -Is $proxy $link > link_head.txt
            err_type=`sed -ne "s/^Location:.*\/needtoken\/\([^\/]\+\)\/[0-9]\+$/\1/p" link_head.txt`
            if [ "$err_type" == "reach_limit" ]; then
                if [ -z "$proxy" -a -n "$Proxy" ]; then
                    echo "try using proxy to get config"
                    continue
                fi
                echo "reach limit, waiting for an hour and try it again..."
            elif [ "$err_type" == "long_video" ]; then
                echo "the video is too long, ignored..."
                break
            elif [ "$err_type" == "hd_video" ]; then
                echo "hd_video, no permission, ignored..."
                break
            else
                grep -q "^Location:.*\/video_missing$" link_head.txt
                if [ $? -eq 0 ]; then
                    echo "Missing video..."
                    break
                fi
                echo "unknown error type, ignore"
            fi
            ((hours--))
            sleep 3600
        fi
	done

	rm -f $conf link_head.txt
}

while [ $# -ge 1 ]
do
	if [ $1 == "-x" ]; then
		shift
		proxy=
		continue
	elif [ $1 == "-c" ]; then
		shift
		check_fail_type=1
		continue
	elif [ $1 == "-p" ]; then
		shift
		if [ $# -ge 1 ]; then
			proxy=$1
			shift
		fi
		continue
	fi
	key=$1
	[ "${key:0:4}" == "http" ] && key=`echo $key | sed -ne "s/http:\/\/.*\/video\/\([0-9a-f]\+\)\/.*/\1/p"`
	getv $key
	shift
done

