#!/bin/bash
# Automated transcoding to h265 for any (current) file type
clear
hdh=1080
hdw=1920
shdh=720
shdw=1280
hdbr=4000
shdbr=2000
sdbr=1000
maxfhdbr=5334
maxhdbr=2667
maxsdbr=1334
HEVC=HEVC
counter=1
encoder=nvenc_h265
for filename in *.mkv
do
    bitrate=0
    tempname=$counter.mkv
    temp1=$(mediainfo --Inform="General;%OverallBitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
    temp2=$(mediainfo --Inform="Video;%BitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
    if [[ $temp1 -ge $temp2 ]]
    then
    bitrate=$temp1
    else
    bitrate=$temp2
    fi
    format=$(mediainfo --Inform="Video;%Format%" "$filename")
    vert=$(mediainfo --Inform="Video;%Height%" "$filename")
    hort=$(mediainfo --Inform="Video;%Width%" "$filename")
    tempbr=$(($bitrate/4*3))
    tempbr=${tempbr%.*}
    echo "MKV Found"
    if [[ $format = $HEVC ]]
    then
        echo "HEVC Codec"
        if  [[ $vert -eq $hdh ]] || [[ $hort -eq $hdw ]]
        then
        echo "1080p Resolution"
            if [[ $bitrate -gt $maxfhdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $hdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        elif [[ $vert -eq $shdh ]] || [[ $hort -eq $shdw ]]
        then
        echo "720p Resolution"
            if [[ $bitrate -gt $maxhdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $shdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        else
        echo "SD"
            if [[ $bitrate -gt $maxsdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $sdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        fi
    else
    echo "Not HEVC"
        if  [[ $vert -eq $hdh ]] || [[ $hort -eq $hdw ]]
        then
        echo "1080p Resolution"
            if [[ $bitrate -gt $maxfhdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $hdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        elif [[ $vert -eq $shdh ]] || [[ $hort -eq $shdw ]]
        then
        echo "720p Resolution"
            if [[ $bitrate -gt $maxhdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $shdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        else
        echo "SD"
            if [[ $bitrate -gt $maxsdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $sdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        fi
    fi
done

for filename in *.mp4
do
    tempname="${filename%.*}".mkv
    bitrate=0
    temp1=$(mediainfo --Inform="General;%OverallBitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
    temp2=$(mediainfo --Inform="Video;%BitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
    if [[ $temp1 -ge $temp2 ]]
    then
        bitrate=$temp1
    else
        bitrate=$temp2
    fi
    format=$(mediainfo --Inform="Video;%Format%" "$filename")
    vert=$(mediainfo --Inform="Video;%Height%" "$filename")
    hort=$(mediainfo --Inform="Video;%Width%" "$filename")
    tempbr=$(($bitrate/4*3))
    tempbr=${tempbr%.*}
    echo "MP4 Found"
    if [[ $format = $HEVC ]]
    then
        echo "HEVC Codec"
        if  [[ $vert -eq $hdh ]] || [[ $hort -eq $hdw ]]
        then
        echo "1080p Resolution"
            if [[ $bitrate -gt $maxfhdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $hdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        elif [[ $vert -eq $shdh ]] || [[ $hort -eq $shdw ]]
        then
        echo "720p Resolution"
            if [[ $bitrate -gt $maxhdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $shdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        else
        echo "SD"
            if [[ $bitrate -gt $maxsdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $sdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        fi
    else
    echo "Not HEVC"
        if  [[ $vert -eq $hdh ]] || [[ $hort -eq $hdw ]]
        then
        echo "1080p Resolution"
            if [[ $bitrate -gt $maxfhdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $hdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        elif [[ $vert -eq $shdh ]] || [[ $hort -eq $shdw ]]
        then
        echo "720p Resolution"
            if [[ $bitrate -gt $maxhdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $shdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        else
        echo "SD"
            if [[ $bitrate -gt $maxsdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $sdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        fi
    fi
done

for filename in *.avi
do
    echo "AVI Found"
    tempname="${filename%.*}".mkv
    bitrate=0
    temp1=$(mediainfo --Inform="General;%OverallBitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
    temp2=$(mediainfo --Inform="Video;%BitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
    if [[ $temp1 -ge $temp2 ]]
    then
        bitrate=$temp1
    else
        bitrate=$temp2
    fi
    format=$(mediainfo --Inform="Video;%Format%" "$filename")
    vert=$(mediainfo --Inform="Video;%Height%" "$filename")
    hort=$(mediainfo --Inform="Video;%Width%" "$filename")
    tempbr=$(($bitrate/4*3))
    tempbr=${tempbr%.*}
    if  [[ $vert -eq $hdh ]] || [[ $hort -eq $hdw ]]
        then
        echo "1080p Resolution"
            if [[ $bitrate -gt $maxfhdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $hdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        elif [[ $vert -eq $shdh ]] || [[ $hort -eq $shdw ]]
        then
        echo "720p Resolution"
            if [[ $bitrate -gt $maxhdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $shdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        else
        echo "SD"
            if [[ $bitrate -gt $maxsdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $sdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        fi
done


for filename in *.divx
do
    echo "DIVX Found"
    tempname="${filename%.*}".mkv
    bitrate=0
    temp1=$(mediainfo --Inform="General;%OverallBitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
    temp2=$(mediainfo --Inform="Video;%BitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
    if [[ $temp1 -ge $temp2 ]]
    then
        bitrate=$temp1
    else
        bitrate=$temp2
    fi
    format=$(mediainfo --Inform="Video;%Format%" "$filename")
    vert=$(mediainfo --Inform="Video;%Height%" "$filename")
    hort=$(mediainfo --Inform="Video;%Width%" "$filename")
    tempbr=$(($bitrate/4*3))
    tempbr=${tempbr%.*}
    if  [[ $vert -eq $hdh ]] || [[ $hort -eq $hdw ]]
        then
        echo "1080p Resolution"
            if [[ $bitrate -gt $maxfhdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $hdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        elif [[ $vert -eq $shdh ]] || [[ $hort -eq $shdw ]]
        then
        echo "720p Resolution"
            if [[ $bitrate -gt $maxhdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $shdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        else
        echo "SD"
            if [[ $bitrate -gt $maxsdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $sdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        fi
done

for filename in *.mpg
do
    echo "MPG Found"
    tempname="${filename%.*}".mkv
    bitrate=0
    temp1=$(mediainfo --Inform="General;%OverallBitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
    temp2=$(mediainfo --Inform="Video;%BitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
    if [[ $temp1 -ge $temp2 ]]
    then
        bitrate=$temp1
    else
        bitrate=$temp2
    fi
    format=$(mediainfo --Inform="Video;%Format%" "$filename")
    vert=$(mediainfo --Inform="Video;%Height%" "$filename")
    hort=$(mediainfo --Inform="Video;%Width%" "$filename")
    tempbr=$(($bitrate/4*3))
    tempbr=${tempbr%.*}
    if  [[ $vert -eq $hdh ]] || [[ $hort -eq $hdw ]]
        then
        echo "1080p Resolution"
            if [[ $bitrate -gt $maxfhdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $hdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        elif [[ $vert -eq $shdh ]] || [[ $hort -eq $shdw ]]
        then
        echo "720p Resolution"
            if [[ $bitrate -gt $maxhdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $shdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        else
        echo "SD"
            if [[ $bitrate -gt $maxsdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $sdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        fi
done

for filename in *.m4v
do
    echo "M4V Found"
    tempname="${filename%.*}".mkv
    bitrate=0
    temp1=$(mediainfo --Inform="General;%OverallBitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
    temp2=$(mediainfo --Inform="Video;%BitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
    if [[ $temp1 -ge $temp2 ]]
    then
        bitrate=$temp1
    else
        bitrate=$temp2
    fi
    format=$(mediainfo --Inform="Video;%Format%" "$filename")
    vert=$(mediainfo --Inform="Video;%Height%" "$filename")
    hort=$(mediainfo --Inform="Video;%Width%" "$filename")
    tempbr=$(($bitrate/4*3))
    tempbr=${tempbr%.*}
    if  [[ $vert -eq $hdh ]] || [[ $hort -eq $hdw ]]
        then
        echo "1080p Resolution"
            if [[ $bitrate -gt $maxfhdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $hdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        elif [[ $vert -eq $shdh ]] || [[ $hort -eq $shdw ]]
        then
        echo "720p Resolution"
            if [[ $bitrate -gt $maxhdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $shdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        else
        echo "SD"
            if [[ $bitrate -gt $maxsdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $sdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        fi
done

for filename in *.wmv
do
    echo "wmv Found"
    tempname="${filename%.*}".mkv
    bitrate=0
    temp1=$(mediainfo --Inform="General;%OverallBitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
    temp2=$(mediainfo --Inform="Video;%BitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
    if [[ $temp1 -ge $temp2 ]]
    then
        bitrate=$temp1
    else
        bitrate=$temp2
    fi
    format=$(mediainfo --Inform="Video;%Format%" "$filename")
    vert=$(mediainfo --Inform="Video;%Height%" "$filename")
    hort=$(mediainfo --Inform="Video;%Width%" "$filename")
    tempbr=$(($bitrate/4*3))
    tempbr=${tempbr%.*}
    if  [[ $vert -eq $hdh ]] || [[ $hort -eq $hdw ]]
        then
        echo "1080p Resolution"
            if [[ $bitrate -gt $maxfhdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $hdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        elif [[ $vert -eq $shdh ]] || [[ $hort -eq $shdw ]]
        then
        echo "720p Resolution"
            if [[ $bitrate -gt $maxhdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $shdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        else
        echo "SD"
            if [[ $bitrate -gt $maxsdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $sdbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e $encoder -b $tempbr --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        fi
done
