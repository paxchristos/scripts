#!/bin/bash
# Merges video and audio track, assumes only 1 season and less than 99 episodes, as well as audio and original file name match
clear
typeset -Z2 counter
counter=1
for filename in *.mkv
do
    echo "$filename"
    tempname="s01e$counter.mkv"
    mkvmerge --output "$tempname" "$filename" "$counter".mka
    rm "$counter".mka "$filename"
    mv "$tempname" "$filename"
    ((counter++))
done
