#!/bin/sh

lines=$(cat 00index.txt | wc -l)

list=( "[playlist]" "NumberOfEntries=${lines}" )
index=0
while read -d $'\n' line; do
    (( index++ ))
    list+=( "File${index}=${line%% *}" "Title${index}=${line#* }" )
done < 00index.txt
printf "%s\n" "${list[@]}" > 01index.pls
