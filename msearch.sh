#!/bin/bash

#proxy="-e http_proxy=http://10.10.40.10:80"

[ $# -lt 1 ] && exit

list_mode=1
down_flag=0
multi_page=0
max_pages=99999

while [ $# -ge 2 ]; do
    if [ "$1" == "-l" ]; then
        list_mode=0
    elif [ "$1" == "-d" ]; then
        down_flag=1
    elif [ "$1" == "-x" ]; then
        proxy="--no-proxy"
#    elif [ "$1" == "-m" ]; then
#		multi_page=1
    elif [[ $1 =~ -m[0-9]*$ ]]; then
		multi_page=1
		[ ${#1} -eq 2 ] || max_pages=${1:2}
    else
        break;
    fi
	shift
done

key=$1
page=1
last_page=1
#ipaddr=199.195.197.133
ipaddr=199.195.197.134
#ipaddr=199.195.197.140

function OkFile()
{
    [ $# -ne 1 ] && return 0

    local fil=$1
    [ -z "$fil" ] && return 0
    [ ! -f $fil ] && return 0
    [ `stat -c %s $fil` == "0" ] && return 0

    return 1
}

#
# previous page NO.
# cat $query_result | sed -ne '/pagination/{s/.*page=\([0-9]\+\)[^<]\+&laquo;.*/\1/p;}'
# next page NO.
# cat $query_result | sed -ne '/pagination/{s/.*page=\([0-9]\+\)[^<]\+&raquo;.*/\1/p;}'
#
[ -d Data ] || mkdir Data
while ( true )
do

	last_page=$page
	query_url="http://$ipaddr/search?search_type=videos&search_query=$key&page=$page"
	query_result=Data/result_$key-$page.html
	keylist=Data/list_$key-$page.txt

	OkFile $query_result
	[ $? -eq 0 ] && wget $proxy -O $query_result "$query_url"

	OkFile $keylist
	if [ $? -eq 0 ]; then
		 OkFile $query_result
		 if [ $? -eq 1 ]; then
			  sed -ne '/^ *<div class="video_box">/{n;s/.*<a [^>]*\/\([0-9a-f]\+\)\/.*<img[^>]*\/\([0-9]\+\)\/[^ ]* \+title="\([^"]\+\)".*/\1\n\2\n\3/;h;:a;n;/<div class="box_left">/!ba;:z;n;/[0-9:]\+/!bz;s/ *\([0-9:]\+\).*/ \1/;H;g;s/\(.\+\)\n\(.\+\)\n\(.\+\)\n\(.\+\)/\1\t\2  \t\4   \t\3/p}' $query_result > $keylist
		 fi
	fi

	OkFile $keylist
	if [ $? -eq 0 ]; then
		echo "List fail, stopped."
		rm $keylist
		break
	fi

	if [ $list_mode -eq 1 ]; then
		printf "\n>>> Page: $page <<<\n"
		tac $keylist
	fi

	if [ $down_flag -eq 1 ]; then
		list=`cut -f1 $keylist | tac`
		./mgetv.sh $list
	fi

	if [ $multi_page -eq 1 ]; then
		[ $page -ge $max_pages ] && break
		page=$(cat $query_result | sed -ne '/pagination/{s/.*page=\([0-9]\+\)[^<]\+&raquo;.*/\1/p;}')
		[ -z "$page" ] && break
	else
		break
	fi

done

page=1
fil=list_$key.txt
[ -f $fil ] && rm $fil
while [ $page -le $last_page ]
do
	printf "\n>>> Page: $page <<<\n" >> $fil
	cat Data/list_$key-$page.txt >> $fil
	(( page++ ))
done
