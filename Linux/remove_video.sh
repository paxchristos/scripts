#!/bin/bash
# Removes video, keeps audio track, keeps subtitle track 2
clear
typeset -Z2 counter
counter=1
for filename in *.mkv
do
    echo "$filename"
    mkvmerge --output "$counter".mka -D "$filename"
    ((counter++))
done
