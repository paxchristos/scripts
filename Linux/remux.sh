#!/bin/bash
# Then it transcodes the file to the size I want and removes the temp merged file
handbrakePreset=/mnt/truenas/transcode/Anime-NVENC-1080.plist
clear
for filename in *.mp4
do
    echo "$filename"
    tempname="${filename%.*}"
    mkvmerge -o "$tempname.mkv" "$filename"
    rm "$filename"
done
