## File Arrays
$Matroska       = Get-ChildItem -recurse *.mkv
$Mpeg4          = Get-ChildItem -recurse *.mp4
$WindowsMedia   = Get-ChildItem -recurse *.wmv
$AudioVideo     = Get-ChildItem -recurse *.avi
$divx           = Get-ChildItem -recurse *.divx  
$Mpeg           = Get-ChildItem -recurse *.mpg
$Mpeg4V         = Get-ChildItem -recurse *.m4v

## Variables
$hdh        = 1080
$hdw        = 1920
$shdh       = 720
$shdw       = 1280
$hdbr       = 1500
$shdbr      = 1000
$sdbr       = 500
$maxfhdbr   = 2000
$maxhdbr    = 1334
$maxsdbr    = 666
$HEVC       = "HEVC"
$encoder    = "nvenc_h265"

## Checks for MKV files
if ($null -ne $Matroska)
{
    Write-Output "MKV Found"
    Write-Output $Matroska.count

    foreach ($file in $Matroska)
    {
        ## Variables in loop
        Write-Output $file.name
        $bitrate    = 0
        $temp1      = [math]::Round((mediainfo.exe --inform="General;%OverallBitRate%" $file.Name) / 1024,2)
        $temp2      = [math]::Round((mediainfo.exe --inform="Video;%BitRate%" $file.Name) / 1024,2)
        if ($temp1 -ge $temp2)
        {
            $bitrate = $temp1
        }
        else 
        {
            $bitrate = $temp2
        }
        $format = mediainfo.exe --Inform="Video;%Format%" $file.name
        $vert   = mediainfo.exe --Inform="Video;%Height%" $file.name
        $hort   = mediainfo.exe --Inform="Video;%Width%" $file.name
        $tempbr = ($bitrate/4*3)

        if ( $format = $HEVC )
        {
            Write-Output "HEVC Codec"
            if  (( $vert -eq $hdh ) -or ( $hort -eq $hdw ))
            {
                Write-Output "1080p Resolution"
                if ( $bitrate -gt $maxfhdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$hdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                    Remove-Item "$file"
                    Move-Item "temp.mkv" "$file"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                    Remove-Item "$file"
                    Move-Item "temp.mkv" "$file"
                }
            }
            elseif (( $vert -eq $shdh ) -or ( $hort -eq $shdw ))
            {
                Write-Output "720p Resolution"
                if ( $bitrate -gt $maxhdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$shdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                    Remove-Item "$file"
                    Move-Item ""temp.mkv"" "$file"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                    Remove-Item "$file"
                    Move-Item ""temp.mkv"" "$file"
                }
            }
            else
            {
                Write-Output "SD"
                if ( $bitrate -gt $maxsdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$sdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    remove-item "$file"
                    move-item "temp.mkv" "$file"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    remove-item "$file"
                    move-item "temp.mkv" "$file"
                }
            }
        }
        else
        {
            Write-Output "Not HEVC Codec"
            if  (( $vert -eq $hdh ) -or ( $hort -eq $hdw ))
            {
                Write-Output "1080p Resolution"
                if ( $bitrate -gt $maxfhdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$hdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac   --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                    Remove-Item "$file"
                    Move-Item "temp.mkv" "$file"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                    Remove-Item "$file"
                    Move-Item "temp.mkv" "$file"
                }
            }
            elseif (( $vert -eq $shdh ) -or ( $hort -eq $shdw ))
            {
                Write-Output "720p Resolution"
                if ( $bitrate -gt $maxhdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$shdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                    Remove-Item "$file"
                    Move-Item ""temp.mkv"" "$file"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                    Remove-Item "$file"
                    Move-Item ""temp.mkv"" "$file"
                }
            }
            else
            {
                Write-Output "SD"
                if ( $bitrate -gt $maxsdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$sdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    remove-item "$file"
                    move-item "temp.mkv" "$file"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    remove-item "$file"
                    move-item "temp.mkv" "$file"
                }
            }
        }
    }
}

## Checks for MP4 files
if ($null -ne $Mpeg4)
{
    Write-Output "MP4 Found"
    Write-Output $Mpeg4.count

foreach ($file in $Mpeg4)
    {
        ## Variables in loop
        Write-Output $file.name
        $bitrate    = 0
        $temp1      = [math]::Round((mediainfo.exe --inform="General;%OverallBitRate%" $file.Name) / 1024,2)
        $temp2      = [math]::Round((mediainfo.exe --inform="Video;%BitRate%" $file.Name) / 1024,2)
        if ($temp1 -ge $temp2)
        {
            $bitrate = $temp1
        }
        else 
        {
            $bitrate = $temp2
        }
        $format = mediainfo.exe --Inform="Video;%Format%" $file.name
        $vert   = mediainfo.exe --Inform="Video;%Height%" $file.name
        $hort   = mediainfo.exe --Inform="Video;%Width%" $file.name
        $tempbr = ($bitrate/4*3)

        if ( $format = $HEVC )
        {
            Write-Output "HEVC Codec"
            if  (( $vert -eq $hdh ) -or ( $hort -eq $hdw ))
            {
                Write-Output "1080p Resolution"
                if ( $bitrate -gt $maxfhdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$hdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                    Remove-Item "$file"
                    Move-Item "temp.mkv" "$file"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                    Remove-Item "$file"
                    Move-Item "temp.mkv" "$file"
                }
            }
            elseif (( $vert -eq $shdh ) -or ( $hort -eq $shdw ))
            {
                Write-Output "720p Resolution"
                if ( $bitrate -gt $maxhdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$shdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                    Remove-Item "$file"
                    Move-Item ""temp.mkv"" "$file"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                    Remove-Item "$file"
                    Move-Item ""temp.mkv"" "$file"
                }
            }
            else
            {
                Write-Output "SD"
                if ( $bitrate -gt $maxsdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$sdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    remove-item "$file"
                    move-item "temp.mkv" "$file"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    remove-item "$file"
                    move-item "temp.mkv" "$file"
                }
            }
        }
        else
        {
            Write-Output "Not HEVC Codec"
            if  (( $vert -eq $hdh ) -or ( $hort -eq $hdw ))
            {
                Write-Output "1080p Resolution"
                if ( $bitrate -gt $maxfhdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$hdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac   --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                    Remove-Item "$file"
                    Move-Item "temp.mkv" "$file"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                    Remove-Item "$file"
                    Move-Item "temp.mkv" "$file"
                }
            }
            elseif (( $vert -eq $shdh ) -or ( $hort -eq $shdw ))
            {
                Write-Output "720p Resolution"
                if ( $bitrate -gt $maxhdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$shdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                    Remove-Item "$file"
                    Move-Item ""temp.mkv"" "$file"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                    Remove-Item "$file"
                    Move-Item ""temp.mkv"" "$file"
                }
            }
            else
            {
                Write-Output "SD"
                if ( $bitrate -gt $maxsdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$sdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    remove-item "$file"
                    move-item "temp.mkv" "$file"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                    remove-item "$file"
                    move-item "temp.mkv" "$file"
                }
            }
        }
    }
}

## Checks for WMV files
if ($null -ne $WindowsMedia)
{
    Write-Output "WMV Found"
    Write-Output $WindowsMedia.count

    foreach ($file in $WindowsMedia)
    {
        ## Variables in loop
        Write-Output $file.name
        $bitrate    = 0
        $temp1      = [math]::Round((mediainfo.exe --inform="General;%OverallBitRate%" $file.Name) / 1024,2)
        $temp2      = [math]::Round((mediainfo.exe --inform="Video;%BitRate%" $file.Name) / 1024,2)
        if ($temp1 -ge $temp2)
        {
            $bitrate = $temp1
        }
        else 
        {
            $bitrate = $temp2
        }
        $vert   = mediainfo.exe --Inform="Video;%Height%" $file.name
        $hort   = mediainfo.exe --Inform="Video;%Width%" $file.name
        $tempbr = ($bitrate/4*3)

        if  (( $vert -eq $hdh ) -or ( $hort -eq $hdw ))
        {
            Write-Output "1080p Resolution"
            if ( $bitrate -gt $maxfhdbr )
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$hdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                Remove-Item "$file"
                Move-Item "temp.mkv" "$file"
            }
            else
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                Remove-Item "$file"
                Move-Item "temp.mkv" "$file"
            }
        }
        elseif (( $vert -eq $shdh ) -or ( $hort -eq $shdw ))
        {
            Write-Output "720p Resolution"
            if ( $bitrate -gt $maxhdbr )
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$shdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                Remove-Item "$file"
                Move-Item ""temp.mkv"" "$file"
            }
            else
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                Remove-Item "$file"
                Move-Item ""temp.mkv"" "$file"
            }
        }
        else
        {
            Write-Output "SD"
            if ( $bitrate -gt $maxsdbr )
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$sdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                remove-item "$file"
                move-item "temp.mkv" "$file"
            }
            else
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                remove-item "$file"
                move-item "temp.mkv" "$file"
            }
        }
        
    }
}

## Checks for AVI files
if ($null -ne $AudioVideo)
{
    Write-Output "AVI Found"
    Write-Output $AudioVideo.count

foreach ($file in $AudioVideo)
    {
        ## Variables in loop
        Write-Output $file.name
        $bitrate    = 0
        $temp1      = [math]::Round((mediainfo.exe --inform="General;%OverallBitRate%" $file.Name) / 1024,2)
        $temp2      = [math]::Round((mediainfo.exe --inform="Video;%BitRate%" $file.Name) / 1024,2)
        if ($temp1 -ge $temp2)
        {
            $bitrate = $temp1
        }
        else 
        {
            $bitrate = $temp2
        }
        $vert   = mediainfo.exe --Inform="Video;%Height%" $file.name
        $hort   = mediainfo.exe --Inform="Video;%Width%" $file.name
        $tempbr = ($bitrate/4*3)

        if  (( $vert -eq $hdh ) -or ( $hort -eq $hdw ))
        {
            Write-Output "1080p Resolution"
            if ( $bitrate -gt $maxfhdbr )
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$hdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac   --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                Remove-Item "$file"
                Move-Item "temp.mkv" "$file"
            }
            else
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                Remove-Item "$file"
                Move-Item "temp.mkv" "$file"
            }
        }
        elseif (( $vert -eq $shdh ) -or ( $hort -eq $shdw ))
        {
            Write-Output "720p Resolution"
            if ( $bitrate -gt $maxhdbr )
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$shdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                Remove-Item "$file"
                Move-Item ""temp.mkv"" "$file"
            }
            else
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                Remove-Item "$file"
                Move-Item ""temp.mkv"" "$file"
            }
        }
        else
        {
            Write-Output "SD"
            if ( $bitrate -gt $maxsdbr )
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$sdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                remove-item "$file"
                move-item "temp.mkv" "$file"
            }
            else
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                remove-item "$file"
                move-item "temp.mkv" "$file"
            }
        }
    }
}

## Checks for divx files
if ($null -ne $divx)
{
    Write-Output "divx Found"
    Write-Output $divx.count

foreach ($file in $divx)
    {
        ## Variables in loop
        Write-Output $file.name
        $bitrate    = 0
        $temp1      = [math]::Round((mediainfo.exe --inform="General;%OverallBitRate%" $file.Name) / 1024,2)
        $temp2      = [math]::Round((mediainfo.exe --inform="Video;%BitRate%" $file.Name) / 1024,2)
        if ($temp1 -ge $temp2)
        {
            $bitrate = $temp1
        }
        else 
        {
            $bitrate = $temp2
        }
        $vert   = mediainfo.exe --Inform="Video;%Height%" $file.name
        $hort   = mediainfo.exe --Inform="Video;%Width%" $file.name
        $tempbr = ($bitrate/4*3)

        if  (( $vert -eq $hdh ) -or ( $hort -eq $hdw ))
        {
            Write-Output "1080p Resolution"
            if ( $bitrate -gt $maxfhdbr )
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$hdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac   --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                Remove-Item "$file"
                Move-Item "temp.mkv" "$file"
            }
            else
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                Remove-Item "$file"
                Move-Item "temp.mkv" "$file"
            }
        }
        elseif (( $vert -eq $shdh ) -or ( $hort -eq $shdw ))
        {
            Write-Output "720p Resolution"
            if ( $bitrate -gt $maxhdbr )
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$shdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                Remove-Item "$file"
                Move-Item ""temp.mkv"" "$file"
            }
            else
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                Remove-Item "$file"
                Move-Item ""temp.mkv"" "$file"
            }
        }
        else
        {
            Write-Output "SD"
            if ( $bitrate -gt $maxsdbr )
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$sdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                remove-item "$file"
                move-item "temp.mkv" "$file"
            }
            else
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                remove-item "$file"
                move-item "temp.mkv" "$file"
            }
        }
    }
}

## Checks for MPG files
if ($null -ne $Mpeg)
{
    Write-Output "MPG Found"
    Write-Output $Mpeg.count

foreach ($file in $Mpeg)
    {
        ## Variables in loop
        Write-Output $file.name
        $bitrate    = 0
        $temp1      = [math]::Round((mediainfo.exe --inform="General;%OverallBitRate%" $file.Name) / 1024,2)
        $temp2      = [math]::Round((mediainfo.exe --inform="Video;%BitRate%" $file.Name) / 1024,2)
        if ($temp1 -ge $temp2)
        {
            $bitrate = $temp1
        }
        else 
        {
            $bitrate = $temp2
        }
        $vert   = mediainfo.exe --Inform="Video;%Height%" $file.name
        $hort   = mediainfo.exe --Inform="Video;%Width%" $file.name
        $tempbr = ($bitrate/4*3)

        if  (( $vert -eq $hdh ) -or ( $hort -eq $hdw ))
        {
            Write-Output "1080p Resolution"
            if ( $bitrate -gt $maxfhdbr )
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$hdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac   --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                Remove-Item "$file"
                Move-Item "temp.mkv" "$file"
            }
            else
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                Remove-Item "$file"
                Move-Item "temp.mkv" "$file"
            }
        }
        elseif (( $vert -eq $shdh ) -or ( $hort -eq $shdw ))
        {
            Write-Output "720p Resolution"
            if ( $bitrate -gt $maxhdbr )
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$shdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                Remove-Item "$file"
                Move-Item ""temp.mkv"" "$file"
            }
            else
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                Remove-Item "$file"
                Move-Item ""temp.mkv"" "$file"
            }
        }
        else
        {
            Write-Output "SD"
            if ( $bitrate -gt $maxsdbr )
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$sdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                remove-item "$file"
                move-item "temp.mkv" "$file"
            }
            else
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                remove-item "$file"
                move-item "temp.mkv" "$file"
            }
        }
    }
}

## Checks for M4v files
if ($null -ne $Mpeg4v)
{
    Write-Output "M4V Found"
    Write-Output $Mpeg4v.count

foreach ($file in $Mpeg4v)
    {
        ## Variables in loop
        Write-Output $file.name
        $bitrate    = 0
        $temp1      = [math]::Round((mediainfo.exe --inform="General;%OverallBitRate%" $file.Name) / 1024,2)
        $temp2      = [math]::Round((mediainfo.exe --inform="Video;%BitRate%" $file.Name) / 1024,2)
        if ($temp1 -ge $temp2)
        {
            $bitrate = $temp1
        }
        else 
        {
            $bitrate = $temp2
        }
        $vert   = mediainfo.exe --Inform="Video;%Height%" $file.name
        $hort   = mediainfo.exe --Inform="Video;%Width%" $file.name
        $tempbr = ($bitrate/4*3)

        if  (( $vert -eq $hdh ) -or ( $hort -eq $hdw ))
        {
            Write-Output "1080p Resolution"
            if ( $bitrate -gt $maxfhdbr )
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$hdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac   --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                Remove-Item "$file"
                Move-Item "temp.mkv" "$file"
            }
            else
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                Remove-Item "$file"
                Move-Item "temp.mkv" "$file"
            }
        }
        elseif (( $vert -eq $shdh ) -or ( $hort -eq $shdw ))
        {
            Write-Output "720p Resolution"
            if ( $bitrate -gt $maxhdbr )
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$shdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                Remove-Item "$file"
                Move-Item ""temp.mkv"" "$file"
            }
            else
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
                Remove-Item "$file"
                Move-Item ""temp.mkv"" "$file"
            }
        }
        else
        {
            Write-Output "SD"
            if ( $bitrate -gt $maxsdbr )
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$sdbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                remove-item "$file"
                move-item "temp.mkv" "$file"
            }
            else
            {
                HandBrakeCLI.exe -i "$file" -o "temp.mkv" -e "$encoder" -b "$tempbr" --no-two-pass --all-audio --aencoder aac --audio-copy-mask aac --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles
                remove-item "$file"
                move-item "temp.mkv" "$file"
            }
        }
    }
}
