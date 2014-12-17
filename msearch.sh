#!/bin/bash

#proxy="-e http_proxy=http://jiangu:Bag%400305@10.10.40.10:80"

[ $# -lt 1 ] && exit

list_mode=1
down_flag=0

while [ $# -ge 2 ]; do
    if [ "$1" == "-l" ]; then
        list_mode=0
    elif [ "$1" == "-d" ]; then
        down_flag=1
    elif [ "$1" == "-x" ]; then
        proxy="--no-proxy"
    else
        break;
    fi
	shift
done

key=$1
ipaddr=199.195.197.140
query_url="http://$ipaddr/search?search_type=videos&search_query="
query_result=result_$key.html
keylist=list_$key.txt

function OkFile()
{
    [ $# -ne 1 ] && return 0

    local fil=$1
    [ -z "$fil" ] && return 0
    [ ! -f $fil ] && return 0
    [ `stat -c %s $fil` -eq 0 ] && return 0

    return 1
}

OkFile $query_result
[ $? -eq 0 ] && wget $proxy -O $query_result "$query_url$key"

OkFile $keylist
if [ $? -eq 0 ]; then
    OkFile $query_result
    if [ $? -eq 1 ]; then
        sed -ne '/^ *<div class="video_box">/{n;s/.*<a [^>]*\/\([0-9a-f]\+\)\/.*<img[^>]*\/\([0-9]\+\)\/[^ ]* \+title="\([^"]\+\)".*/\1\n\2\n\3/;h;:a;n;/<div class="box_left">/!ba;:z;n;/[0-9:]\+/!bz;s/ *\([0-9:]\+\).*/ \1/;H;g;s/\(.\+\)\n\(.\+\)\n\(.\+\)\n\(.\+\)/\1\t\2  \t\4   \t\3/p}' $query_result > $keylist
    fi
fi

OkFile $keylist
[ $? -eq 0 ] && exit

[ $list_mode -eq 1 ] && tac $keylist

if [ $down_flag -eq 1 ]; then
	list=`cut -d' ' -f1 $keylist | tac`
	./mgetv.sh $list
fi
