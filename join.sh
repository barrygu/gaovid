#!/bin/bash

ff_path=/cygdrive/d/Utils/ffmpeg-20141017-git-bbd8c85-win64-shared/bin
fn_input=input_files.txt
fn_out=

echo total input files is $#
[ -f $fn_input ] && rm -f $fn_input
touch $fn_input
while [ $# -ge 1 ]
do
	f=$1
	fn_out=$fn_out${f%.mp4}
	[ $# -ne 1 ] && fn_out=$fn_out"-"
	printf "file $f\n" >> $fn_input
	shift
done
$ff_path/ffmpeg -f concat -i $fn_input -c copy $fn_out.mp4
rm -f $fn_input
