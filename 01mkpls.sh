#!/bin/sh

find -name "*.mp4" | \
  gawk '
    BEGIN{
      i=1
    }{
      sub(/^\.\//,"",$0); 
      match($0, /^([0-9]+)[\.\-].*$/, aa); 
      arr[aa[1]]=$0; 
      brr[i]=aa[1]; 
      i++
    } END{
      count=i
      asort(brr);
      print "[playlist]\nNumberOfEntries=" count > "01index.pls"
      while ((getline < "00index.txt") > 0) {
        map[$1]=$2
        for (i=3;i<=NF;i++)
          map[$1]=map[$1]$i
      }
      for(i=count-1;i>0;i--){
        printf "File%d=%s\nTitle%d=%s\n", count-i, arr[brr[i]], count-i, map[arr[brr[i]]] >> "01index.pls"
      }
    }'
