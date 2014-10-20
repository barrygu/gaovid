#!/bin/bash
#cut/join videos using ffmpeg without quality loss

if [ -z $1 ] || [ -z $2 ]; then
   echo "Usage:$0 c[ut] seconds <File>"
   echo "   eg. $0 c 10 80 example.mp4"
   echo "   eg. $0 c 00:00:10 00:01:20 example.mp4"
   echo "Usage:$0 j[oin] <FileType>"
   echo "   eg. $0 j avi"
   exit
fi

case "$1" in
   c)
      echo "cuttig video..."
      fileName=$(echo $4 | cut -f 1 -d '.')
      fileType=$(echo $4 | cut -f 2 -d '.')
      ffmpeg -i $4 -ss $2 -t $3 -acodec copy -vcodec copy $fileName-$2-$3.$fileType
      ;;
   j)
      echo "joinning videos..."
      rm temp_list.txt      
      for f in ./*.$2; do echo "file '$f'" >> temp_list.txt; done
      printf "file '%s'\n" ./*.$2 > temp_list.txt
      ffmpeg -f concat -i temp_list.txt -c copy output.$2
      rm temp_list.txt
      ;;
   *)
      echo "wrong arguments"
      ;;
esac
exit