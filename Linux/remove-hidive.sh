#!/bin/bash
# Merges video and audio track, assumes only 1 season and less than 99 episodes, as well as audio and original file name match
clear
for filename in *.mkv
do
    echo "$filename"
    wordsathome="${filename%.*}"
    mkvmerge --output split-"$filename" --split timestamps:00:00:05.005,01:00:00 "$filename"
    rm split-"$wordsathome"-001.mkv
    rm "$filename"
    mv split-"$wordsathome"-002.mkv "$filename"
done
