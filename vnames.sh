#!/bin/bash

numbs=(`sort -gr $1`)
#echo numbs: ${numbs[@]}
base_url="http://199.195.197.140/videos?page="
#grep -A 1 video_box videos | sed -ne "s/.*\/videos\/tmb\/\([0-9]\+\)\/.*/\1/p"
pg_file=
target=desc.txt

function get_vpage()
{
	pg_file=page_$1.txt
	[ -f "$pg_file" ] || wget -O $pg_file "$base_url$1"
	#[ -f "$pg_file" ] || cp videos.txt $pg_file
}

npp=31
pg_cur=1
get_vpage $pg_cur
rm -f $target

for vnum in ${numbs[@]}; do
	printf "\nChecking: $vnum\n"
	while true; do
		pg_nums=(`sed -ne "s/.*\/videos\/tmb\/\([0-9]\+\)\/.*/\1/p" $pg_file`)
		if [ $vnum -le ${pg_nums[0]} -a $vnum -ge ${pg_nums[$(($npp-1))]} ]; then
			echo in current page
			title=$(sed -ne "/\/$vnum\//"'s/^.*title="\([^"]\+\)" .*/\1/p' $pg_file)
			[ -z "$title" ] && title="Unknown"
			printf "%d --> %s\n" $vnum "$title" >> $target
			break
		elif [ $vnum -lt ${pg_nums[$(($npp-1))]} ]; then
			pgn=`expr \( ${pg_nums[0]} - $vnum \) / $npp`
			let pg_cur+=$pgn
		elif [ $vnum -gt ${pg_nums[0]} ]; then
			pgn=`expr \( $vnum - ${pg_nums[$(($npp-1))]} \) / $npp`
			let pg_cur-=$pgn
		fi
		get_vpage $pg_cur
	done
done
