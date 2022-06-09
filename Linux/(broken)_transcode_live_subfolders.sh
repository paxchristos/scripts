#!/bin/bash
# Automated transcoding to h265 for any (current) file type
clear
hd=1080
shd=720
hdbr=4000
shdbr=2000
sdbr=1000
HEVC=HEVC
counter=1
for dir in */;
do
    for filename in "$dir"/*.mkv
    do
        tempname=$counter.mkv
        format=$(mediainfo --Inform="Video;%Format%" "$filename")
        vert=$(mediainfo --Inform="Video;%Height%" "$filename")
        bitrate=$(mediainfo --Inform="General;%OverallBitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
        abitrate=$(mediainfo --Inform="Audio;%BitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
        bitrate=$(($bitrate-$abitrate))
        tempbr=$(($bitrate/4*3))
        tempbr=${tempbr%.*}
        echo "MKV Found"
        if [[ $format = $HEVC ]]
        then
            echo "HEVC Codec"
            if  [[ $vert -eq $hd ]]
            then
            echo "1080p Resolution"
                if [[ $bitrate -gt $hdbr ]]
                then
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $hdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    rm "$filename"
                    mv "$tempname" "$filename"
                fi
            elif [[ $vert -eq 720 ]]
            then
            echo "720p Resolution"
                if [[ $bitrate -gt $shdbr ]]
                then
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $shdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    rm "$filename"
                    mv "$tempname" "$filename"
                fi
            else
            echo "SD"
                if [[ $bitrate -gt $sdbr ]]
                then
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $sdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    rm "$filename"
                    mv "$tempname" "$filename"
                fi
            fi
        else
        echo "Not HEVC"
            if [[ $vert -eq $hd ]]
            then
            echo "1080p Resolution"
                if [[ $bitrate -gt $hdbr ]]
                then
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $hdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    rm "$filename"
                    mv "$tempname" "$filename"
                else
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $tempbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                fi
            elif [[ $vert -eq $shd ]]
            then
            echo "720p Resolution"
                if [[ $bitrate -gt $shdbr ]]
                then
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $shdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    rm "$filename"
                    mv "$tempname" "$filename"
                else
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $tempbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    rm "$filename"
                    mv "$tempname" "$filename"
                fi
            else
                echo "SD"
                if [[ $bitrate -gt $sdbr ]]
                then
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $sdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    rm "$filename"
                    mv "$tempname" "$filename"
                else
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $tempbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    rm "$filename"
                    mv "$tempname" "$filename"
                fi
            fi
        fi
    done
    for filename in "$dir"/*.mp4
    do
        tempname="${filename%.*}".mkv
        format=$(mediainfo --Inform="Video;%Format%" "$filename")
        vert=$(mediainfo --Inform="Video;%Height%" "$filename")
        bitrate=$(mediainfo --Inform="General;%OverallBitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
        abitrate=$(mediainfo --Inform="Audio;%BitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
        bitrate=$(($bitrate-$abitrate))
        tempbr=$(($bitrate/4*3))
        tempbr=${tempbr%.*}
        echo "MP4 Found"
        if [[ $format = $HEVC ]]
        then
            echo "HEVC Codec"
            if  [[ $vert -eq $hd ]]
            then
            echo "1080p Resolution"
                if [[ $bitrate -gt $hdbr ]]
                then
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $hdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    rm "$filename"
                else
                    echo "remuxing file"
                    mkvmerge -o "$tempname" "$filename"
                    rm "$filename"
                fi
            elif [[ $vert -eq $shd ]]
            then
            echo "720p Resolution"
                if [[ $bitrate -gt $shdbr ]]
                then
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $shdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    rm "$filename"
                else
                    echo "remuxing file"
                    mkvmerge -o "$tempname" "$filename"
                    rm "$filename"
                fi
            else
            echo "SD"
                if [[ $bitrate -gt $sdbr ]]
                then
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $sdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    rm "$filename"
                else
                    echo "remuxing file"
                    mkvmerge -o "$tempname" "$filename"
                    rm "$filename"
                fi
            fi
        else
        echo "Not HEVC"
            if [[ $vert -eq $hd ]]
            then
            echo "1080p Resolution"
                if [[ $bitrate -gt $hdbr ]]
                then
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $hdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    rm "$filename"
                else
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $tempbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                fi
            elif [[ $vert -eq $shd ]]
            then
            echo "720p Resolution"
                if [[ $bitrate -gt $shdbr ]]
                then
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $shdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    rm "$filename"
                else
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $tempbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    rm "$filename"
                fi
            else
                echo "SD"
                if [[ $bitrate -gt $sdbr ]]
                then
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $sdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    rm "$filename"
                else
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $tempbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    rm "$filename"
                fi
            fi
        fi
    done

    for filename in "$dir"/*.avi
    do
        echo "AVI Found"
        tempname="${filename%.*}".mkv
        format=$(mediainfo --Inform="Video;%Format%" "$filename")
        vert=$(mediainfo --Inform="Video;%Height%" "$filename")
        bitrate=$(mediainfo --Inform="General;%OverallBitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
        abitrate=$(mediainfo --Inform="Audio;%BitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
        bitrate=$(($bitrate-$abitrate))
        tempbr=$(($bitrate/4*3))
        tempbr=${tempbr%.*}
        if [[ $vert -eq $hd ]]
        then
            echo "1080p Resolution"
            if [[ $bitrate -gt $hdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $hdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $tempbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        elif [[ $vert -eq $shd ]]
        then
            echo "720p Resolution"
            if [[ $bitrate -gt $shdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $shdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $tempbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            fi
        else
            echo "SD"
            if [[ $bitrate -gt $sdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $sdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $tempbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
                mv "$tempname" "$filename"
            fi
        fi
    done


    for filename in "$dir"/*.divx
    do
        echo "DIVX Found"
        tempname="${filename%.*}".mkv
        format=$(mediainfo --Inform="Video;%Format%" "$filename")
        bitrate=$(mediainfo --Inform="General;%OverallBitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
        abitrate=$(mediainfo --Inform="Audio;%BitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
        bitrate=$(($bitrate-$abitrate))
        tempbr=$(($bitrate/4*3))
        tempbr=${tempbr%.*}
        if [[ $vert -eq $hd ]]
            then
            echo "1080p Resolution"
                if [[ $bitrate -gt $hdbr ]]
                then
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $hdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    rm "$filename"

                else
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $tempbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                fi
            elif [[ $vert -eq $shd ]]
            then
            echo "720p Resolution"
                if [[ $bitrate -gt $shdbr ]]
                then
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $shdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    rm "$filename"

                else
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $tempbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    rm "$filename"

                fi
            else
                echo "SD"
                if [[ $bitrate -gt $sdbr ]]
                then
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $sdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    rm "$filename"

                else
                    HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $tempbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    rm "$filename"

                fi
            fi
    done

    for filename in "$dir"/*.mpg
    do
        echo "MPG Found"
        tempname="${filename%.*}".mkv
        format=$(mediainfo --Inform="Video;%Format%" "$filename")
        vert=$(mediainfo --Inform="Video;%Height%" "$filename")
        bitrate=$(mediainfo --Inform="General;%OverallBitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
        abitrate=$(mediainfo --Inform="Audio;%BitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
        bitrate=$(($bitrate-$abitrate))
        tempbr=$(($bitrate/4*3))
        tempbr=${tempbr%.*}
        if [[ $vert -eq $hd ]]
        then
            echo "1080p Resolution"
            if [[ $bitrate -gt $hdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $hdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $tempbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        elif [[ $vert -eq $shd ]]
        then
            echo "720p Resolution"
            if [[ $bitrate -gt $shdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $shdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $tempbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
            fi
        else
            echo "SD"
            if [[ $bitrate -gt $sdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $sdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $tempbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
            fi
        fi
    done

    for filename in "$dir"/*.m4v
    do
        echo "M4V Found"
        tempname="${filename%.*}".mkv
        format=$(mediainfo --Inform="Video;%Format%" "$filename")
        vert=$(mediainfo --Inform="Video;%Height%" "$filename")
        bitrate=$(mediainfo --Inform="General;%OverallBitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
        abitrate=$(mediainfo --Inform="Audio;%BitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
        bitrate=$(($bitrate-$abitrate))
        tempbr=$(($bitrate/4*3))
        tempbr=${tempbr%.*}
        if [[ $vert -eq $hd ]]
        then
            echo "1080p Resolution"
            if [[ $bitrate -gt $hdbr ]]
            then    
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $hdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $tempbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        elif [[ $vert -eq $shd ]]
        then
            echo "720p Resolution"
            if [[ $bitrate -gt $shdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $shdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $tempbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
            fi
        else
            echo "SD"
            if [[ $bitrate -gt $sdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $sdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $tempbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
            fi
        fi
    done

    for filename in "$dir"/*.wmv
    do
        echo "wmv Found"
        tempname="${filename%.*}".mkv
        format=$(mediainfo --Inform="Video;%Format%" "$filename")
        vert=$(mediainfo --Inform="Video;%Height%" "$filename")
        bitrate=$(mediainfo --Inform="General;%OverallBitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
        abitrate=$(mediainfo --Inform="Audio;%BitRate%" "$filename"  |  awk '{$1=sprintf("%.0f",$1/1024)}1')
        bitrate=$(($bitrate-$abitrate))
        tempbr=$(($bitrate/4*3))
        tempbr=${tempbr%.*}
        if [[ $vert -eq $hd ]]
        then
            echo "1080p Resolution"
            if [[ $bitrate -gt $hdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $hdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $tempbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
            fi
        elif [[ $vert -eq $shd ]]
        then
        echo "720p Resolution"
            if [[ $bitrate -gt $shdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $shdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $tempbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
            fi
        else
            echo "SD"
            if [[ $bitrate -gt $sdbr ]]
            then
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $sdbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
            else
                HandBrakeCLI -i "$filename" -o "$tempname" -e nvenc_h265 -b $tempbr --no-two-pass --audio-lang-list eng,jpn,rus,und --all-audio -E copy:aac --audio-fallback aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                rm "$filename"
            fi
        fi
    done
done
