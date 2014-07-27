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
}

npp=31
pg_cur=1
get_vpage $pg_cur
rm -f $target

for vnum in ${numbs[@]}; do

	step=0
	step_m=0
	last_step=0
	bounds=0
	
	printf "\nChecking: $vnum\n"
	while true; do
		pg_nums=(`sed -ne "s/.*\/videos\/tmb[0-9]*\/\([0-9]\+\)\/.*/\1/p" $pg_file`)
		npp=${#pg_nums[@]}
		[ $npp -eq 0 ] && exit

		if [ $vnum -le ${pg_nums[0]} -a $vnum -ge ${pg_nums[(($npp-1))]} ]; then
			echo "Found vnum($vnum) in page $pg_cur"
			title=$(sed -ne "/\/$vnum\//"'s/^.*title="\([^"]\+\)" .*/\1/p' $pg_file)
			[ -z "$title" ] && title="Unknown"
			printf "%d --> %s\r\n" $vnum "$title" >> $target
			break
		elif [ $vnum -lt ${pg_nums[(($npp-1))]} ]; then
			step_m=${pg_nums[0]}
		elif [ $vnum -gt ${pg_nums[0]} ]; then
			step_m=${pg_nums[(($npp-1))]}
		fi

		#echo last_step: $last_step
		if [ $bounds -eq 0 ]; then
			step=`expr \( $step_m - $vnum \) / $npp`
			if [ $(( last_step + step )) -eq 0 ]; then
				bounds=1
			fi
		fi
		
		if [ $bounds -eq 1 ]; then
			step=0
			[ $vnum -gt ${pg_nums[0]} ] && step=-1
			[ $vnum -lt ${pg_nums[(($npp-1))]} ] && step=1
			if [ $(( last_step + step )) -eq 0 ]; then
				echo "Cannot find title of $vnum, last page is $pg_cur"
				printf "%d --> %s\r\n" $vnum "Unknown~" >> $target
				break
			fi
		fi

		if [ $step -eq 0 ]; then
			echo "Cannot find title of $vnum, last page is $pg_cur"
			printf "%d --> %s\r\n" $vnum "Unknown~" >> $target
			break
		fi

		let pg_cur+=$step
		last_step=$step

		get_vpage $pg_cur
	done
done
