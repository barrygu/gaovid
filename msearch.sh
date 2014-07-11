#!/bin/bash

key=$1
ipaddr=199.195.197.140
query_url="http://$ipaddr/search?search_type=videos&search_query="
query_result=$key"_results.html"
keylist=$key"_lists.txt"

[ -f $query_result ] || wget -O $query_result "$query_url$key"
[ -f $keylist ] || grep "href=\"\/video[^>]\+><img" results.html | sed -ne "s/.*\/video\/\([0-9a-f]\+\)\/.*/\1/p" > $keylist
list=`cat $keylist`

#echo $list
./mgetv.sh $list