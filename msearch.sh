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
timelist=timl_$key.txt

doit=0
if [ -f $query_result ]; then
    if [ `stat -c %s $query_result` -eq 0 ]; then
        rm -f $query_result
        doit=1
    fi
else
    doit=1
fi
[ $doit -eq 1 ] && wget $proxy -O $query_result "$query_url$key"

if [ ! -f $keylist -o `stat -c %s $keylist` -eq 0 ]; then
    if [ -f $query_result -a `stat -c %s $query_result` -ne 0 ]; then
        sed -ne 's/.*\/video\/\([0-9a-f]\+\)\/[^>]*><img.*\/tmb[0-9]*\/\([0-9]\+\)\/.*title="\([^"]\+\)".*/\1 \2 \3/p' $query_result > $keylist
    fi
fi

[ ! -f $keylist -o `stat -c %s $keylist` -eq 0 ] && exit

rm -f $timelist
touch $timelist
for id in `cut -f 1 -d\  $keylist`; do
    sed -n -e "/\/video\/$id\//,/box_right/!d;s/<[^>]\+>//;s/[ \ t]\+//" -e '/[0-9][0-9]:[0-9][0-9]/p' $query_result >> $keylist.tim
done
paste $keylist $keylist.tim > $timelist
rm -f $keylist.tim

[ $list_mode -eq 1 ] && tac $timelist

if [ $down_flag -eq 1 ]; then
	list=`cut -d' ' -f1 $keylist | tac`
	./mgetv.sh $list
fi
