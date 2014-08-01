#!/bin/bash

if [ $# -eq 1 -a -f "$1" ]; then
	numbs=(`sort -gr $1`)
elif [ $# -ge 2 ]; then
	if [ "$1" == "-n" ]; then
		shift
		numbs=${@}
	else
		echo "Invalid arguments 1"
		exit
	fi
else
	echo "Invalid arguments 2"
	exit
fi

base_url="http://199.195.197.140/videos?page="
pg_file=
target=desc.txt

function get_vpage()
{
	pg_file=page_$1.txt
	if [ -f "$pg_file" ]; then
		echo "page $1 has already existed"
	else
		echo "getting page $1 from web..."
		wget -qO $pg_file "$base_url$1"
	fi
}

function is_integer() 
{
#	[ "$1" -eq "$1" ] > /dev/null 2>&1
#	return $?
	re='^[0-9]+$'
	if ! [[ "$1" =~ $re ]] ; then
		return 1
	fi
	return 0
}

nItems=31
pg_cur=1
get_vpage $pg_cur
pg_last=`sed -n -e "/pagination/s/.*&nbsp;\(.*\)class.*/\1/" -e 's/.*[0-9]\+">\([0-9]\+\)<.*/\1/p' page_1.txt`
rm -f $target

for vnum in ${numbs[@]}; do

	step=0
	foot=0
	last_step=0
	bounds=0
	loop_count=0

	is_integer $vnum || continue
	printf "\nChecking: $vnum\n"
	while true; do
		(( loop_count++ ))
		pg_nums=(`sed -ne "s/.*\/videos\/tmb[0-9]*\/\([0-9]\+\)\/.*/\1/p" $pg_file`)
		nItems=${#pg_nums[@]}
		[ $nItems -eq 0 ] && exit

		if (( $vnum <= ${pg_nums[0]} && $vnum >= ${pg_nums[(($nItems-1))]} )); then
			echo "Found vnum($vnum) in page $pg_cur"
			title=$(sed -ne "/\/$vnum\//"'s/^.*title="\([^"]\+\)" .*/\1/p' $pg_file)
			if [ -z "$title" ]; then
				title="Deleted"
				echo "vnum($vnum) may be deleted."
			fi
			printf "%d --> %s\r\n" $vnum "$title" >> $target
			break
		elif (( $vnum < ${pg_nums[(($nItems-1))]} )); then
			foot=${pg_nums[0]}
		elif (( $vnum > ${pg_nums[0]} )); then
			foot=${pg_nums[(($nItems-1))]}
		fi

		if [ $bounds -eq 0 ]; then
			(( step = ( foot - vnum ) / nItems ))
			(( step > 1 )) && (( step = step * 2 / 3 ))
			if (( last_step + step == 0 )); then
				bounds=1
			fi
		fi
		
		if [ $bounds -eq 1 ]; then
			if (( $vnum > ${pg_nums[0]} )); then
				step=-1
			elif (( $vnum < ${pg_nums[(($nItems-1))]} )); then
				step=1
			else
				step=0;
			fi

			if (( last_step + step == 0 )); then
				echo "enter bounds again, no page contains $vnum, last checked page is $pg_cur"
				printf "%d --> %s\r\n" $vnum "Not found" >> $target
				break
			fi
		fi

		if [ $step -eq 0 ]; then
			echo "no page contains $vnum, last checked page is $pg_cur"
			printf "%d --> %s\r\n" $vnum "Not found" >> $target
			break
		fi

		let pg_cur+=$step
		last_step=$step
		printf "step is %5d, " $step
		if (( pg_cur > pg_last )); then 
			echo "step is too long, use last page $pg_last to instead $pg_cur."
			(( last_step = pg_last - ( pg_cur - last_step ) ))
			pg_cur=$pg_last
		fi

		get_vpage $pg_cur
	done
	echo "Loop count is $loop_count"
done
