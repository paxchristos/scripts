#!/bin/bash
# Merges video and audio track, assumes only 1 season. as well as audio and original file name match
# After merging the different parts it gets rid of the originals
# Then it transcodes the file to the size I want and removes the temp merged file
clear
handbrakePreset=/mnt/media/Anime/transcode/Anime-NVENC-1080.plist
counter=1
for filename in *.mkv
do
    echo "$filename"
    tempname="s01e$counter.mkv"
    mkvmerge --output $tempname "$filename" "$counter".mka
    rm "$filename"
    rm "$counter".mka
    HandBrakeCLI -i $tempname -o "$filename" --preset-import-file "$handbrakePreset"  --preset "Anime-NVENC"
    rm $tempname
    ((counter++))
done
