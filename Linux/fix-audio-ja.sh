#!/bin/bash 
# check file in media info to get tracks and fix as needed
clear
for filename in *.mkv 
do 
    echo "$filename" 
	mkvpropedit "$filename" --edit track:2 --set language=ja
done
