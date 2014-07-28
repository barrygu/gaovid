#!/bin/bash

numbs=(`sort -gr $1`)
base_url="http://199.195.197.140/videos?page="
pg_file=
target=desc.txt

function get_vpage()
{
	pg_file=page_$1.txt
	[ -f "$pg_file" ] || wget -qO $pg_file "$base_url$1"
}

npp=31
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
	
	printf "\nChecking: $vnum\n"
	while true; do
		(( loop_count++ ))
		pg_nums=(`sed -ne "s/.*\/videos\/tmb[0-9]*\/\([0-9]\+\)\/.*/\1/p" $pg_file`)
		npp=${#pg_nums[@]}
		[ $npp -eq 0 ] && exit

		#if [ $vnum -le ${pg_nums[0]} -a $vnum -ge ${pg_nums[(($npp-1))]} ]; then
		if (( $vnum <= ${pg_nums[0]} && $vnum >= ${pg_nums[(($npp-1))]} )); then
			echo "Found vnum($vnum) in page $pg_cur"
			title=$(sed -ne "/\/$vnum\//"'s/^.*title="\([^"]\+\)" .*/\1/p' $pg_file)
			if [ -z "$title" ]; then
				title="Unknown"
				echo "vnum($vnum) is lost"
			fi
			printf "%d --> %s\r\n" $vnum "$title" >> $target
			break
		#elif [ $vnum -lt ${pg_nums[(($npp-1))]} ]; then
		elif (( $vnum < ${pg_nums[(($npp-1))]} )); then
			foot=${pg_nums[0]}
		#elif [ $vnum -gt ${pg_nums[0]} ]; then
		elif (( $vnum > ${pg_nums[0]} )); then
			foot=${pg_nums[(($npp-1))]}
		fi

		#echo last_step: $last_step
		if [ $bounds -eq 0 ]; then
			#step=`expr \( $foot - $vnum \) / $npp`
			step=$(( ( foot - vnum ) / npp ))
			#if [ $(( last_step + step )) -eq 0 ]; then
			if (( last_step + step == 0 )); then
				bounds=1
			fi
		fi
		
		if [ $bounds -eq 1 ]; then
			step=0
			#[ $vnum -gt ${pg_nums[0]} ] && step=-1
			(( $vnum > ${pg_nums[0]} )) && step=-1
			#[ $vnum -lt ${pg_nums[(($npp-1))]} ] && step=1
			(( $vnum < ${pg_nums[(($npp-1))]} )) && step=1
			#if [ $(( last_step + step )) -eq 0 ]; then
			if (( last_step + step == 0 )); then
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
		if (( pg_cur > pg_last )); then 
			(( last_step = pg_last - ( pg_cur - last_step ) ))
			pg_cur=$pg_last
		fi

		get_vpage $pg_cur
	done
	echo "Loop count is $loop_count"
done
