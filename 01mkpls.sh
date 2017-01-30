#!/bin/sh

lines=$(wc -l 00index.txt)

printf "[playlist]\nNumberOfEntries=%d\n" > 01index.pls
index=0
while read -d $'\n' line; do
    (( index++ ))
    printf "File%d=%s\nTitle%d=%s\n" $index "${line%% *}" $index "${line#* }"
done < 00index.txt >> 01index.pls
