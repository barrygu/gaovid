#!/bin/bash

[ $# -lt 1 ] && exit
list_mode=0
if [ $# -eq 2 -a "$1" == "-l" ]; then
	list_mode=1
	shift
fi
key=$1
ipaddr=199.195.197.140
query_url="http://$ipaddr/search?search_type=videos&search_query="
query_result=$key"_results.html"
keylist=$key"_lists.txt"

[ -f $query_result ] || wget -O $query_result "$query_url$key"
#[ -f $keylist ] || sed -ne '/href="\/video[^>]\+><img/s/.*\/video\/\([0-9a-f]\+\)\/.*title="\([^"]\+\)".*/\1 \2/p' $query_result > $keylist
[ -f $keylist ] || sed -ne 's/.*\/video\/\([0-9a-f]\+\)\/[^>]*><img.*\/tmb[0-9]*\/\([0-9]\+\)\/.*title="\([^"]\+\)".*/\1 \2 \3/p' $query_result > $keylist

if [ $list_mode -eq 1 ]; then
	tac $keylist
else
	list=`cut -d' ' -f1 $keylist | tac`
	./mgetv.sh $list
fi