for filename in *.mkv
do
    echo $bitrate
    bitrate=$(mediainfo --Inform="General;%OverallBitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
    abitrate=$(mediainfo --Inform="Audio;%BitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
    bitrate=$(($bitrate-$abitrate))
    echo $bitrate
    tempbr=$(($bitrate/4*3))
    echo $tempbr
    tempbr=${tempbr%.*}
    echo $tempbr
done


