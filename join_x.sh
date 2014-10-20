#!/bin/bash

ff_path=/cygdrive/d/Utils/ffmpeg-20141017-git-bbd8c85-win64-shared/bin
fn_in=
fn_out=

echo total input files is $#
for z in $@
do
	f=${z%.mp4}
	[ -n "$fn_out" ] && fn_out=$fn_out"-"
	fn_out=$fn_out$f
	[ -n "$fn_in" ] && fn_in=$fn_in"|"
	fn_in=$fn_in$f.ts
	$ff_path/ffmpeg -i $f.mp4 -vcodec copy -acodec copy -vbsf h264_mp4toannexb $f.ts
done
$ff_path/ffmpeg -i "concat:$fn_in" -c copy -absf aac_adtstoasc $fn_out.mp4
for z in $@
do
	rm -f ${z%.mp4}.ts
done
