#!/bin/sh

key=$1
count=0

#GET http://c30.ydporn.com:81/flv/74a9d60767f20a9980de88b0d6b9e790/51613df4/flv/20457.mp4?start=0&id=main&client=FLASH%20WIN%2011,6,602,180&version=4.5.230&width=630 HTTP/1.1
#GET http://c30.ydporn.com:81/flv/74a9d60767f20a9980de88b0d6b9e790/51613df4/flv/20457.mp4?start=454.931&id=main&client=FLASH%20WIN%2011,6,602,180&version=4.5.230&width=630 HTTP/1.1
url="http://gaovideo.com/media/player/jwconfig.php?vkey=$key"
ref="http://gaovideo.com/video/$key/"
expr="s/^\s*<file>\(http:\/\/.*\/flv\/$key.mp4\)<\/file>.*$/\1/p"
#proxy="--socks5 192.168.1.123:7070"
proxy=
ipaddr=`echo $SSH_CLIENT | awk '{print $1}'`
proxy="--socks5 $ipaddr:7070"

cmd="curl $proxy \"$url\" -e \"$ref\""
echo $cmd
while [ $count -lt 10 ]; do
   #echo curl "$url" -e "$ref"
   #file=`curl "$url" -e "$ref" | sed -n -e "$expr"`
   #contents=`eval $cmd`
   #echo $contents
   file=`eval $cmd | sed -n -e "$expr"`
   #file=`cat $contents | sed -n -e "$expr"`
   echo $file
   [ -n "$file" ] && break;
   ((count++))
   sleep 5
   #break
done

[ -z "$file" ] && exit
#wget -b "$file"
curl $proxy -O $file
