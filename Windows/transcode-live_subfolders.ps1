## Variables
$hdh        = 1080
$hdw        = 1920
$shdh       = 720
$shdw       = 1280
$hdbr       = 1500
$shdbr      = 1250
$sdbr       = 100
$maxfhdbr   = 2000
$maxhdbr    = 1667
$maxsdbr    = 1334
$sdh        = 480
$sdw        = 640
$HEVC       = "HEVC"
$encoder    = "nvenc_h265"
$langlist   = 'eng,jpn,rus,und'

#renames files and folder removing special characters
$ErrorActionPreference= 'silentlycontinue'
(Get-ChildItem -Directory -Recurse) | Rename-Item -NewName { $_.Name -replace "[^\p{L}\p{Nd}/./\s/-/_/(/)]+" }
(Get-ChildItem -File -Recurse) | Rename-Item -NewName { $_.Name -replace "[^\p{L}\p{Nd}/./\s/-/_/(/)]+" }
$ErrorActionPreference= 'continue'
$directories        = Get-ChildItem -Directory -Recurse | Select-Object -ExpandProperty FullName
$originaldirectory  = Get-Location | Select-Object -ExpandProperty Path
$logFile            = $originaldirectory + "\remux.log"
$currentTime        = Get-Date -Format "MM/dd/yyyy hh:mm"

if (Test-Path -Path $logFile -PathType Leaf)
{
    Add-Content -Path $logFile -Value ---***---
    Add-Content -Path $logFile -Value "Stated new batch of remuxes on $($currentTime)"
}
else
{
    New-Item -Path $logFile -ItemType File
}
foreach ($directory in $directories)
{
    ##Changes directory to current working one
    Set-Location  "$directory"
    ## File Arrays
    $Matroska = Get-ChildItem  *.mkv
    $Mpeg4 = Get-ChildItem  *.mp4
    $WindowsMedia = Get-ChildItem  *.wmv
    $AudioVideo = Get-ChildItem  *.avi
    $divx = Get-ChildItem  *.divx  
    $Mpeg = Get-ChildItem *.mpg
    $mpeg2 = Get-ChildItem *.mpeg
    $Mpeg4V = Get-ChildItem  *.m4v
    ## Checks for MKV files
    if ($null -ne $Matroska)
    {   
        Write-Output "MKV Found"
        Write-Output $Matroska.count
        foreach ($file in $Matroska)
        {
            ## Variables in loop
            Write-Output $file.name
            $tempname = [io.path]::GetFileNameWithoutExtension($file.name)
            $tempname = $tempname + "-remux.mkv"
            $original = $file.name
            $bitrate = 0
            $temp1 = [math]::Round((mediainfo.exe --inform="General;%OverallBitRate%" $file.Name) / 1024, 2)
            $temp2 = [math]::Round((mediainfo.exe --inform="Video;%BitRate%" $file.Name) / 1024, 2)
            if ($temp1 -ge $temp2)
            {
                $bitrate = $temp1
            }
            else
            {
                $bitrate = $temp2
            }
            $format = mediainfo.exe --Inform="Video;%Format%" $file.name
            $vert = mediainfo.exe --Inform="Video;%Height%" $file.Name
            $hort = mediainfo.exe --Inform="Video;%Width%" $file.name
            $vert = [int]$vert
            $hort = [int]$hort
            $tempbr = ($bitrate / 4 * 3)

            if ( $format = $HEVC )
            {
                Write-Output "HEVC Codec"
                if ((( $vert -gt $shdh ) -and ( $vert -le $hdh )) -or(($hort -gt $shdw) -and ( $hort -eq $hdw )))
                {
                    Write-Output "1080p Resolution"
                    if ( $bitrate -gt $maxfhdbr )
                    {
                        HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$hdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                        Remove-Item  "$file"
                        Rename-Item "$tempname" "$original"
                        mkvpropedit --add-track-statistics-tags "$original"
                        Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $hdbr"
                    }
                    else
                    {
                        Write-Host "Below expected bit rate"
                        mkvpropedit --add-track-statistics-tags "$original"
                        Add-Content -Path $logFile -Value "$original is below expected bitrate at $Bitrate"
                    }
                }
                elseif (($vert -gt $sdh) -and  ( $vert -lt $hdh ) -or (( $hort -gt $sdw) -and ( $hort -lt $hdh )))
                {
                    Write-Output "720p Resolution"
                    if ( $bitrate -gt $maxhdbr )
                    {
                        HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$shdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo   --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                        Remove-Item  "$file"
                        Rename-Item "$tempname" "$original"
                        mkvpropedit --add-track-statistics-tags "$original"
                        Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $shdbr"
                    }
                    else 
                    {
                        Write-Host "Below expected bit rate"
                        mkvpropedit --add-track-statistics-tags "$original"
                        Add-Content -Path $logFile -Value "$original is below expected bitrate at $Bitrate"
                    }
                }   
                else
                {
                    Write-Output "SD"
                    if ( $bitrate -gt $maxsdbr )
                    {
                        HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$sdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo    --subtitle-lang-list $langlist --all-subtitles
                        Remove-Item  "$file"
                        Rename-Item "$tempname" "$original"
                        mkvpropedit --add-track-statistics-tags "$original"
                        Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $sdbr"
                    }
                    else
                    {
                        Write-Host "Below expected bit rate"
                        mkvpropedit --add-track-statistics-tags "$original"
                        Add-Content -Path $logFile -Value "$original is below expected bitrate at $Bitrate"
                    }
                }
            }
            else
            {
                Write-Output "Not HEVC Codec"
                if (( $vert -eq $hdh ) -or ( $hort -eq $hdw ))
                {
                    Write-Output "1080p Resolution"
                    if ( $bitrate -gt $maxfhdbr )
                    {
                        HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$hdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3   --mixdown stereo  --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                        Remove-Item  "$file"
                        Rename-Item "$tempname" "$original"
                        mkvpropedit --add-track-statistics-tags "$original"
                        Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $hdbr"
                    }
                    else
                    {
                        HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                        Remove-Item  "$file"
                        Rename-Item "$tempname" "$original"
                        mkvpropedit --add-track-statistics-tags "$original"
                        Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $hdbr"
                    }
                }   
                elseif (($vert -gt $sdh) -and  ( $vert -lt $hdh ) -or (( $hort -gt $sdw) -and ( $hort -lt $hdh )))
                {
                    Write-Output "720p Resolution"
                    if ( $bitrate -gt $maxhdbr )
                    {
                        HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$shdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                        Remove-Item  "$file"
                        Rename-Item "$tempname" "$original"
                        mkvpropedit --add-track-statistics-tags "$original"
                        Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $shdbr"
                    }
                    else
                    {
                        HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                        Remove-Item  "$file"
                        Rename-Item "$tempname" "$original"
                        mkvpropedit --add-track-statistics-tags "$original"
                        Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $shdbr"
                    }
                }
                else
                {
                    Write-Output "SD"
                    if ( $bitrate -gt $maxsdbr )
                    {
                        HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$sdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo    --subtitle-lang-list $langlist --all-subtitles
                        Remove-Item  "$file"
                        Rename-Item "$tempname" "$original"
                        mkvpropedit --add-track-statistics-tags "$original"
                        Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $sdbr"
                    }
                    else
                    {
                        HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo  --subtitle-lang-list $langlist --all-subtitles
                        Remove-Item  "$file"
                        Rename-Item "$tempname" "$original"
                        mkvpropedit --add-track-statistics-tags "$original"
                        Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $sdbr"
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
            $tempname = [io.path]::GetFileNameWithoutExtension("$file")
            $tempname = "$tempname" + ".mkv"
            $bitrate = 0
            $temp1 = [math]::Round((mediainfo.exe --inform="General;%OverallBitRate%" $file.Name) / 1024, 2)
            $temp2 = [math]::Round((mediainfo.exe --inform="Video;%BitRate%" $file.Name) / 1024, 2)
            if ($temp1 -ge $temp2)
            {
                $bitrate = $temp1
            }
            else
            {
                $bitrate = $temp2
            }
            $format = mediainfo.exe --Inform="Video;%Format%" $file.name
            $vert = mediainfo.exe --Inform="Video;%Height%" $file.name
            $hort = mediainfo.exe --Inform="Video;%Width%" $file.name
            $vert = [int]$vert
            $hort = [int]$hort
            $tempbr = ($bitrate / 4 * 3)

            if ( $format = $HEVC )
            {   
                Write-Output "HEVC Codec"
                if ((( $vert -gt $shdh ) -and ( $vert -le $hdh )) -or(($hort -gt $shdw) -and ( $hort -eq $hdw )))
                {
                    Write-Output "1080p Resolution"
                    if ( $bitrate -gt $maxfhdbr )
                    {
                        HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$hdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                        Remove-Item  "$file"
                        mkvpropedit --add-track-statistics-tags "$tempname"
                        Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $hdbr"
                    }
                    else
                    {
                        HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                        Remove-Item  "$file"
                        mkvpropedit --add-track-statistics-tags "$tempname"
                        Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $hdbr"
                    }
                }
                elseif (($vert -gt $sdh) -and  ( $vert -lt $hdh ) -or (( $hort -gt $sdw) -and ( $hort -lt $hdh )))
                {
                    Write-Output "720p Resolution"
                    if ( $bitrate -gt $maxhdbr )
                    {
                        HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$shdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                        Remove-Item  "$file"
                        mkvpropedit --add-track-statistics-tags "$tempname"
                        Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $shdbr"
                    }
                    else
                    {
                        HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                        Remove-Item  "$file"
                        mkvpropedit --add-track-statistics-tags "$tempname"
                        Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $shdbr"
                    }
                }
                else
                {
                    Write-Output "SD"
                    if ( $bitrate -gt $maxsdbr )
                    {
                        HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$sdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles
                        Remove-Item  "$file"
                        mkvpropedit --add-track-statistics-tags "$tempname"
                        Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $sdbr"
                    }
                    else
                    {
                        HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles
                        Remove-Item  "$file"
                        mkvpropedit --add-track-statistics-tags "$tempname"
                        Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $sdbr"
                    }
                }
            }
            else
            {
                Write-Output "Not HEVC Codec"
                if ((( $vert -gt $shdh ) -and ( $vert -le $hdh )) -or(($hort -gt $shdw) -and ( $hort -eq $hdw )))
                {
                    Write-Output "1080p Resolution"
                    if ( $bitrate -gt $maxfhdbr )
                    {
                        HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$hdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3   --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                        Remove-Item  "$file"
                        mkvpropedit --add-track-statistics-tags "$tempname"
                        Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $hdbr"
                    }
                    else
                    {
                        HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                        Remove-Item  "$file"
                        mkvpropedit --add-track-statistics-tags "$tempname"
                        Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $hdbr"
                    }
                }
                elseif (($vert -gt $sdh) -and  ( $vert -lt $hdh ) -or (( $hort -gt $sdw) -and ( $hort -lt $hdh )))
                {
                    Write-Output "720p Resolution"
                    if ( $bitrate -gt $maxhdbr )
                    {
                        HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$shdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                        Remove-Item  "$file"
                        mkvpropedit --add-track-statistics-tags "$tempname"
                        Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $shdbr"
                    }
                    else
                    {
                        HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                        Remove-Item  "$file"
                        mkvpropedit --add-track-statistics-tags "$tempname"
                        Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $shdbr"
                    }
                }
                else
                {
                    Write-Output "SD"
                    if ( $bitrate -gt $maxsdbr )
                    {
                        HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$sdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles
                        Remove-Item  "$file"
                        mkvpropedit --add-track-statistics-tags "$tempname"
                        Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $sdbr"
                    }
                    else
                    {
                        HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles
                        Remove-Item  "$file"
                        mkvpropedit --add-track-statistics-tags "$tempname"
                        Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $sdbr"
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
            $tempname = [io.path]::GetFileNameWithoutExtension("$file")
            $tempname = "$tempname" + ".mkv"
            $bitrate = 0
            $temp1 = [math]::Round((mediainfo.exe --inform="General;%OverallBitRate%" $file.Name) / 1024, 2)
            $temp2 = [math]::Round((mediainfo.exe --inform="Video;%BitRate%" $file.Name) / 1024, 2)
            if ($temp1 -ge $temp2)
            {
                $bitrate = $temp1
            }
            else
            {
                $bitrate = $temp2
            }
            $vert = mediainfo.exe --Inform="Video;%Height%" $file.name
            $hort = mediainfo.exe --Inform="Video;%Width%" $file.name
            $vert = [int]$vert
            $hort = [int]$hort
            $tempbr = ($bitrate / 4 * 3)

            if ((( $vert -gt $shdh ) -and ( $vert -le $hdh )) -or(($hort -gt $shdw) -and ( $hort -eq $hdw )))
            {
                Write-Output "1080p Resolution"
                if ( $bitrate -gt $maxfhdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$hdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $hdbr"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $hdbr"
                }
            }
            elseif (($vert -gt $sdh) -and  ( $vert -lt $hdh ) -or (( $hort -gt $sdw) -and ( $hort -lt $hdh )))
            {
                Write-Output "720p Resolution"
                if ( $bitrate -gt $maxhdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$shdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $shdbr"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $shdbr"
                }
            }
            else
            {
                Write-Output "SD"
                if ( $bitrate -gt $maxsdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$sdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $sdbr"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $sdbr"
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
            $tempname = [io.path]::GetFileNameWithoutExtension("$file")
            $tempname = "$tempname" + ".mkv"
            $bitrate = 0
            $temp1 = [math]::Round((mediainfo.exe --inform="General;%OverallBitRate%" $file.Name) / 1024, 2)
            $temp2 = [math]::Round((mediainfo.exe --inform="Video;%BitRate%" $file.Name) / 1024, 2)
            if ($temp1 -ge $temp2)
            {
                $bitrate = $temp1
            }
            else
            {
                $bitrate = $temp2
            }
            $vert = mediainfo.exe --Inform="Video;%Height%" $file.name
            $hort = mediainfo.exe --Inform="Video;%Width%" $file.name
            $vert = [int]$vert
            $hort = [int]$hort
            $tempbr = ($bitrate / 4 * 3)

            if ((( $vert -gt $shdh ) -and ( $vert -le $hdh )) -or(($hort -gt $shdw) -and ( $hort -eq $hdw )))
            {
                Write-Output "1080p Resolution"
                if ( $bitrate -gt $maxfhdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$hdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $hdbr"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $hdbr"
                }
            }
            elseif (($vert -gt $sdh) -and  ( $vert -lt $hdh ) -or (( $hort -gt $sdw) -and ( $hort -lt $hdh )))
            {
                Write-Output "720p Resolution"
                if ( $bitrate -gt $maxhdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$shdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $shdbr"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $shdbr"
                }
            }
            else
            {
                Write-Output "SD"
                if ( $bitrate -gt $maxsdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$sdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $sdbr"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $sdbr"
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
            $bitrate = 0
            $temp1 = [math]::Round((mediainfo.exe --inform="General;%OverallBitRate%" $file.Name) / 1024, 2)
            $temp2 = [math]::Round((mediainfo.exe --inform="Video;%BitRate%" $file.Name) / 1024, 2)
            if ($temp1 -ge $temp2)
            {
                $bitrate = $temp1
            }
            else
            {
                $bitrate = $temp2
            }
            $vert = mediainfo.exe --Inform="Video;%Height%" $file.name
            $hort = mediainfo.exe --Inform="Video;%Width%" $file.name
            $vert = [int]$vert
            $hort = [int]$hort
            $tempbr = ($bitrate / 4 * 3)
            $tempname = [io.path]::GetFileNameWithoutExtension("$file")
            $tempname = "$tempname" + ".mkv"

            if ((( $vert -gt $shdh ) -and ( $vert -le $hdh )) -or(($hort -gt $shdw) -and ( $hort -eq $hdw )))
            {
                Write-Output "1080p Resolution"
                if ( $bitrate -gt $maxfhdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$hdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $hdbr"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $hdbr"
                }
            }
            elseif (($vert -gt $sdh) -and  ( $vert -lt $hdh ) -or (( $hort -gt $sdw) -and ( $hort -lt $hdh )))
            {
                Write-Output "720p Resolution"
                if ( $bitrate -gt $maxhdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$shdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $shdbr"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $shdbr"
                }
            }
            else
            {
                Write-Output "SD"
                if ( $bitrate -gt $maxsdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$sdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $sdbr"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $sdbr"
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
            $bitrate = 0
            $temp1 = [math]::Round((mediainfo.exe --inform="General;%OverallBitRate%" $file.Name) / 1024, 2)
            $temp2 = [math]::Round((mediainfo.exe --inform="Video;%BitRate%" $file.Name) / 1024, 2)
            if ($temp1 -ge $temp2)
            {
                $bitrate = $temp1
            }
            else
            {
                $bitrate = $temp2
            }
            $vert = mediainfo.exe --Inform="Video;%Height%" $file.name
            $hort = mediainfo.exe --Inform="Video;%Width%" $file.name
            $vert = [int]$vert
            $hort = [int]$hort
            $tempbr = ($bitrate / 4 * 3)
            $tempname = [io.path]::GetFileNameWithoutExtension("$file")
            $tempname = "$tempname" + ".mkv"

            if ((( $vert -gt $shdh ) -and ( $vert -le $hdh )) -or(($hort -gt $shdw) -and ( $hort -eq $hdw )))
            {
                Write-Output "1080p Resolution"
                if ( $bitrate -gt $maxfhdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$hdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $hdbr"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $hdbr"
                }
            }
            elseif (($vert -gt $sdh) -and  ( $vert -lt $hdh ) -or (( $hort -gt $sdw) -and ( $hort -lt $hdh )))
            {
                Write-Output "720p Resolution"
                if ( $bitrate -gt $maxhdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$shdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $shdbr"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $shdbr"
                }
            }
            else
            {
                Write-Output "SD"
                if ( $bitrate -gt $maxsdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$sdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $sdbr"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $sdbr"
                }
            }
        
        }
    }
## Checks for MPEG files
if ($null -ne $Mpeg2)
{
    Write-Output "MPG Found"
    Write-Output $mpeg2.count

    foreach ($file in $mpeg2)
    {
        ## Variables in loop
        Write-Output $file.name
        $bitrate = 0
        $temp1 = [math]::Round((mediainfo.exe --inform="General;%OverallBitRate%" $file.Name) / 1024, 2)
        $temp2 = [math]::Round((mediainfo.exe --inform="Video;%BitRate%" $file.Name) / 1024, 2)
        if ($temp1 -ge $temp2)
        {
            $bitrate = $temp1
        }
        else
        {
            $bitrate = $temp2
        }
        $vert = mediainfo.exe --Inform="Video;%Height%" $file.name
        $hort = mediainfo.exe --Inform="Video;%Width%" $file.name
        $vert = [int]$vert
        $hort = [int]$hort
        $tempbr = ($bitrate / 4 * 3)
        $tempname = [io.path]::GetFileNameWithoutExtension("$file")
        $tempname = "$tempname" + ".mkv"

        if ((( $vert -gt $shdh ) -and ( $vert -le $hdh )) -or(($hort -gt $shdw) -and ( $hort -eq $hdw )))
        {
            Write-Output "1080p Resolution"
            if ( $bitrate -gt $maxfhdbr )
            {
                HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$hdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                Remove-Item  "$file"
                mkvpropedit --add-track-statistics-tags "$tempname"
                Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $hdbr"
            }
            else
            {
                HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                Remove-Item  "$file"
                mkvpropedit --add-track-statistics-tags "$tempname"
                Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $hdbr"
            }
        }
        elseif (($vert -gt $sdh) -and  ( $vert -lt $hdh ) -or (( $hort -gt $sdw) -and ( $hort -lt $hdh )))
        {
            Write-Output "720p Resolution"
            if ( $bitrate -gt $maxhdbr )
            {
                HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$shdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                Remove-Item  "$file"
                mkvpropedit --add-track-statistics-tags "$tempname"
                Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $shdbr"
            }
            else
            {
                HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                Remove-Item  "$file"
                mkvpropedit --add-track-statistics-tags "$tempname"
                Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $shdbr"
            }
        }
        else
        {
            Write-Output "SD"
            if ( $bitrate -gt $maxsdbr )
            {
                HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$sdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles
                Remove-Item  "$file"
                mkvpropedit --add-track-statistics-tags "$tempname"
                Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $sdbr"
            }
            else
            {
                HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles
                Remove-Item  "$file"
                mkvpropedit --add-track-statistics-tags "$tempname"
                Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $sdbr"
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
            $bitrate = 0
            $temp1 = [math]::Round((mediainfo.exe --inform="General;%OverallBitRate%" $file.Name) / 1024, 2)
            $temp2 = [math]::Round((mediainfo.exe --inform="Video;%BitRate%" $file.Name) / 1024, 2)
            if ($temp1 -ge $temp2)
            {
                $bitrate = $temp1
            }
            else
            {
                $bitrate = $temp2
            }
            $vert = mediainfo.exe --Inform="Video;%Height%" $file.name
            $hort = mediainfo.exe --Inform="Video;%Width%" $file.name
            $vert = [int]$vert
            $hort = [int]$hort
            $tempbr = ($bitrate / 4 * 3)
            $tempname = [io.path]::GetFileNameWithoutExtension("$file")
            $tempname = "$tempname" + ".mkv"

            if ((( $vert -gt $shdh ) -and ( $vert -le $hdh )) -or(($hort -gt $shdw) -and ( $hort -eq $hdw )))
            {
                Write-Output "1080p Resolution"
                if ( $bitrate -gt $maxfhdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$hdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3   --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $hdbr"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $hdbr"
                }
            }
            elseif (($vert -gt $sdh) -and  ( $vert -lt $hdh ) -or (( $hort -gt $sdw) -and ( $hort -lt $hdh )))
            {
                Write-Output "720p Resolution"
                if ( $bitrate -gt $maxhdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$shdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $shdbr"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles --crop 0:0:0:0
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $shdbr"
                }
            }
            else
            {
                Write-Output "SD"
                if ( $bitrate -gt $maxsdbr )
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$sdbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $sdbr"
                }
                else
                {
                    HandBrakeCLI.exe -i "$file" -o "$tempname" -e "$encoder" -b "$tempbr" --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --subtitle-lang-list $langlist --all-subtitles
                    Remove-Item  "$file"
                    mkvpropedit --add-track-statistics-tags "$tempname"
                    Add-Content -Path $logFile -Value "$original has been transcoded from $format to HEVC and from $bitrate to $sdbr"
                }
            }
        }
    }
    Set-Location $originaldirectory
}