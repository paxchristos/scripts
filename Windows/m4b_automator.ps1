Function Get-MP3MetaData
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([Psobject])]
    Param
    (
        [String] [Parameter(Mandatory = $true, ValueFromPipeline = $true)] $Directory
    )

    Begin
    {
        $shell = New-Object -ComObject "Shell.Application"
    }
    Process
    {

        Foreach ($Dir in $Directory)
        {
            $ObjDir = $shell.NameSpace($Dir)
            $Files = gci $Dir | ? { $_.Extension -in '.mp3', '.mp4', '.wma' }

            Foreach ($File in $Files)
            {
                $ObjFile = $ObjDir.parsename($File.Name)
                $MetaData = @{}
                $MP3 = ($ObjDir.Items() | ? { $_.path -like "*.mp3" -or $_.path -like "*.mp4" -or $_.path -like "*.wma" })
                $PropertArray = 0, 1, 2, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 27, 28, 36, 220, 223
            
                Foreach ($item in $PropertArray)
                { 
                    If ($ObjDir.GetDetailsOf($ObjFile, $item)) #To avoid empty values
                    {
                        $MetaData[$($ObjDir.GetDetailsOf($MP3, $item))] = $ObjDir.GetDetailsOf($ObjFile, $item)
                    }
                 
                }
            
                New-Object psobject -Property $MetaData | select *, @{n = "Directory"; e = { $Dir } }, @{n = "Fullname"; e = { Join-Path $Dir $File.Name -Resolve } }, @{n = "Extension"; e = { $File.Extension } }
            }
        }
    }
    End
    {
    }
}
$ErrorActionPreference= 'silentlycontinue'
(Get-ChildItem -Directory -Recurse) | Rename-Item -NewName { $_.Name -replace "[^\p{L}\p{Nd}/./\s/-/_]+" }
$ErrorActionPreference= 'continue'
$directories = Get-ChildItem -Directory -Recurse | Select-Object -ExpandProperty FullName
$originaldirectory = Get-Location | Select-Object -ExpandProperty Path
$automator_log = $originaldirectory + "\automator.log"
$beginning = Get-Date -Format "dd/mm/yyyy"
if (Test-Path -Path $automator_log -PathType Leaf)
{
    Add-Content -Path $automator_log -Value "---***---"
    Add-Content -Path $automator_log -Value "Started new automation on $($beginning)"
}
else
{
    [void](New-Item -Path $automator_log -ItemType file)
    Add-Content -Path $automator_log -Value "---***---"
    Add-Content -Path $automator_log -Value "Started new automation on $($beginning)"
}

foreach ($directory in $directories)
{
    ##Changes directory to current working one
    Set-Location  "$directory"
    Add-Content -Path $automator_log -Value "Working on $($directory)"
    (Get-ChildItem -File -Recurse) | Rename-Item -NewName { $_.Name -replace "[^\p{L}\p{Nd}/./\s/-]+" }
    $current_directory = Get-Location | Select-Object -ExpandProperty Path
    $files_metadata = Get-MP3MetaData $current_directory
    $year = ""
    $title = ""
    $author = ""
    $bitrate = ""
    $metadata_log = "$current_directory\metdata.log"
    $new_file_name = Split-Path ($current_directory) -Leaf
    $temp_file_name = $new_file_name + ".working.m4a"
    $album_cover = $new_file_name + ".jpg"
    $final_file_name = $new_file_name + ".m4b"
    $new_file_name = $new_file_name + ".m4a"
    if (Test-Path -Path $metadata_log -PathType Leaf)
    {
        Remove-Item $metadata_log
        [void](New-Item -Path $metadata_log -ItemType File)
    }
    else
    {
        [void](New-Item -Path $metadata_log -ItemType file)
    }

    $loop_counting_variable = 0
    $metadata_length = $files_metadata.count
    if ($metadata_length -ge 1)
    {
        while ($loop_counting_variable -le $metadata_length)
        {
            foreach ($file in $files_metadata)
            {
                $temp_year = $file.Year
                $temp_title = $file.Album
                $temp_author = $file.Authors
                if ($loop_counting_variable -eq 0)
                {
                    $bitrate = Get-MediaInfo "$($file.FullName)" | Select-Object -ExpandProperty BitRate
                    $bitrate = [string]($bitrate) + "k"
                    Write-Host $bitrate
                    $year = $temp_year
                    $title = $temp_title
                    $author = $temp_author
                    try 
                    {
                        ffmpeg -ss 00:00:00.03 -i "$($file.Name)" -vframes 1 -codec copy "$album_cover"
                        Add-Content -Path $automator_log -Value "Found album art for $($Directory)"
                    }
                    catch 
                    {
                        Add-Content -Path $automator_log -Value "No Album Art for $($directory)"
                    }#>
                }
                else 
                {
                    if ($year -eq $temp_year)
                    {
                        Add-Content -Path $metadata_log -Value "$($file.Name) and track one year match"
                    }
                    else 
                    {
                        Add-Content -Path $metadata_log -Value "$($file.Name) and track one year do not match"
                    }
                    if ($title -eq $temp_title)
                    {
                        Add-Content -Path $metadata_log -Value "$($file.Name) and track one album match"
                    }
                    else
                    {
                        Add-Content -Path $metadata_log -Value "$($file.Name) and track one album do not match"
                    }
                    if ($author -eq $temp_author)
                    {
                        Add-Content -Path $metadata_log -Value "$($file.Name) and track one author match"
                    }
                    else
                    {
                        Add-Content -Path $metadata_log -Value "$($file.Name) and track one author do not match"
                    }
                }
                $loop_counting_variable = $loop_counting_variable + 1
                #Write-Host $loop_counting_variable
            }
        }
    }
    else
    {
        foreach ($file in $files_metadata)
        {
            $year = $file.Year
            $title = $file.Album
            $author = $file.Authors
            $bitrate = Get-MediaInfo "$($file.FullName)" | Select-Object -ExpandProperty BitRate
            $bitrate = [string]($bitrate) + "k"
        }
    }
    Add-Content -Path $automator_log -Value "Metadata done for $($Directory)"
    #$year
    #$title
    #$author
    $temp_metadata_file = "$current_directory\metadata.txt"
    $track_list = "$current_directory\tracks.txt"
    $metadata_file = "$current_directory\FFMETADATA.TXT"
    if (Test-Path -Path $temp_metadata_file -PathType Leaf)
    {
        Remove-Item $temp_metadata_file
        [void](New-Item -Path $temp_metadata_file -ItemType File)
        Add-Content -Path $temp_metadata_file -Encoding UTF8 -Value ';FFMETADATA1'
    }
    else
    {
        [void](New-Item -Path $temp_metadata_file -ItemType file)
        Add-Content -Path $temp_metadata_file -Encoding UTF8 -Value ';FFMETADATA1'
    }
    if (Test-Path -Path $track_list -PathType Leaf)
    {
        Remove-Item $track_list
        [void](New-Item -Path $track_list -ItemType File)

    }
    else
    {
        [void](New-Item -Path $track_list -ItemType file)
    }
    $mp3 = Get-ChildItem *.mp3
    $ogg = Get-ChildItem *.ogg
    $wma = Get-ChildItem *.wma
    $m4a = Get-ChildItem *.m4a
    $mp4 = Get-ChildItem *.mp4
    $m4b = Get-ChildItem *.m4b
    $chapter_starting_point = 1
    $total_length = 0
    if ($null -ne $mp3)
    {
        if ($mp3.count -eq 1)
        {
            foreach ($file in $mp3)
            {
                Add-Content -Path $automator_log -Value "Found one MP3 in folder for $($Directory)"
                ffprobe.exe -show_chapters $file | Out-String | Add-Content -Path $temp_metadata_file -Encoding Ascii
                ffmpeg -i $file -c:a aac -b:a "$bitrate" -vn "$temp_file_name"
                Add-Content -Path $automator_log -Value "Completed conversion to m4a in $($directory)"
            }

        }
        else 
        {
            Add-Content -Path $automator_log -Value "Found $($mp3.count) MP3s in folder for $($Directory)"
            foreach ($file in $mp3)
            {
                $file_name = $file.BaseName
                $file_name = $file_name.substring(3)
                Add-Content -Path $temp_metadata_file -Encoding UTF8 -Value '[CHAPTER]'
                Add-Content -Path $temp_metadata_file -Encoding UTF8 -Value 'TIMEBASE=1/1000'
                Add-Content -Path $temp_metadata_file -Encoding UTF8 -Value "START=$($chapter_starting_point)"
                $file_length = mediainfo.exe --inform="Audio;%Duration/String3%" $file 
                $reformat = $file_length -replace ",", "."
                $track_milliseconds = ([timespan]::Parse($reformat)).TotalMilliseconds
                $chapter_starting_point = $chapter_starting_point + $track_milliseconds
                $total_length = $total_length + $track_milliseconds
                Add-Content -Path $temp_metadata_file -Encoding UTF8 -Value "END=$($total_length)"
                Add-Content -Path $temp_metadata_file -Encoding UTF8 -Value "title=$($file_name)"
                Add-Content -Path $track_list -Value "file '$($current_directory)\$($file.Name)'"
            }
            ffmpeg -f concat -safe 0 -i "$track_list" -c:a aac -b:a "$bitrate" -vn "$temp_file_name"
            Add-Content -Path $automator_log -Value "Converted MP3s in folder for $($Directory) to a single m4b"
        }
        Get-Content $temp_metadata_file | Out-File -Encoding ascii $metadata_file
        ffmpeg -i "$temp_file_name" -i "$metadata_file" -metadata title="$($title)" -metadata author="$($author)" -metadata year="$($year)" -metadata album="$($album)" -map_metadata 1 -codec copy -vn $new_file_name
        Add-Content -Path $automator_log -Value "Added chapters to $($Directory) m4a"
        Remove-Item *.mp3
        Remove-Item "$temp_file_name"
        Remove-Item "$track_list"
        Remove-Item "$temp_metadata_file"
        Remove-Item "$metadata_file"
        Rename-Item "$new_file_name" "$final_file_name"
        Add-Content -Path $automator_log -Value "Removed old files and renamed to  $($Directory) m4b"
        Set-Location $originaldirectory
    }
    if ($null -ne $ogg)
    {
        if ($ogg.count -eq 1)
        {
            foreach ($file in $ogg)
            {
                Add-Content -Path $automator_log -Value "Found 1 OGG in folder for $($Directory)"
                ffprobe.exe -show_chapters $file | Out-String | Add-Content -Path $temp_metadata_file -Encoding Ascii
                ffmpeg -i $file -c:a aac -b:a "$bitrate" -vn "$temp_file_name"
                Add-Content -Path $automator_log -Value "Converted OGG to $($Directory) M4a"
            }

        }
        else 
        {
            Add-Content -Path $automator_log -Value "Found $($ogg.count) OGGs in folder for $($Directory)"
            foreach ($file in $ogg)
            {
                $file_name = $file.BaseName
                $file_name = $file_name.substring(3)
                Add-Content -Path $temp_metadata_file -Encoding UTF8 -Value '[CHAPTER]'
                Add-Content -Path $temp_metadata_file -Encoding UTF8 -Value 'TIMEBASE=1/1000'
                Add-Content -Path $temp_metadata_file -Encoding UTF8 -Value "START=$($chapter_starting_point)"
                $file_length = mediainfo.exe --inform="Audio;%Duration/String3%" $file 
                $reformat = $file_length -replace ",", "."
                $track_milliseconds = ([timespan]::Parse($reformat)).TotalMilliseconds
                $chapter_starting_point = $chapter_starting_point + $track_milliseconds
                $total_length = $total_length + $track_milliseconds
                Add-Content -Path $temp_metadata_file -Encoding UTF8 -Value "END=$($total_length)"
                Add-Content -Path $temp_metadata_file -Encoding UTF8 -Value "title=$($file_name)"
                Add-Content -Path $track_list -Value "file '$($current_directory)\$($file.Name)'"
            }
            Add-Content -Path $automator_log -Value "Caputrued Metadata for $($Directory)"
            ffmpeg -f concat -safe 0 -i "$track_list" -c:a aac -b:a "$bitrate" -vn "$temp_file_name"
            Add-Content -Path $automator_log -Value " $($Directory)"
            Add-Content -Path $automator_log -Value "Converted all OGG in $($Directory) to a single ma4"
        }
        Get-Content $temp_metadata_file | Out-File -Encoding ascii $metadata_file
        ffmpeg -i "$temp_file_name" -i "$metadata_file" -metadata title="$($title)" -metadata author="$($author)" -metadata year="$($year)" -metadata album="$($album)" -map_metadata 1 -codec copy -vn $new_file_name
        Add-Content -Path $automator_log -Value "added metadata to $($Directory) m4a"
        Remove-Item *.ogg
        Remove-Item "$temp_file_name"
        Remove-Item "$track_list"
        Remove-Item "$temp_metadata_file"
        Remove-Item "$metadata_file"
        Rename-Item "$new_file_name" "$final_file_name"
        Add-Content -Path $automator_log -Value "Completed changing $($Directory) to m4b"
        Set-Location $originaldirectory
    }
    if ($null -ne $wma)
    {
        if ($wma.count -eq 1)
        {
            foreach ($file in $wma)
            {
                ffprobe.exe -show_chapters $file | Out-String | Add-Content -Path $temp_metadata_file -Encoding Ascii
                ffmpeg -i $file -c:a aac -b:a "$bitrate" -vn "$temp_file_name"
                Add-Content -Path $automator_log -Value "Converting single WMA to $($Directory) .m4a"
            }

        }
        else 
        {
            Add-Content -Path $automator_log -Value "Found $($wma.count) WMAs in folder for $($Directory)"
            foreach ($file in $wma)
            {
                
                $file_name = $file.BaseName
                $file_name = $file_name.substring(3)
                Add-Content -Path $temp_metadata_file -Encoding UTF8 -Value '[CHAPTER]'
                Add-Content -Path $temp_metadata_file -Encoding UTF8 -Value 'TIMEBASE=1/1000'
                Add-Content -Path $temp_metadata_file -Encoding UTF8 -Value "START=$($chapter_starting_point)"
                $file_length = mediainfo.exe --inform="Audio;%Duration/String3%" $file 
                $reformat = $file_length -replace ",", "."
                $track_milliseconds = ([timespan]::Parse($reformat)).TotalMilliseconds
                $chapter_starting_point = $chapter_starting_point + $track_milliseconds
                $total_length = $total_length + $track_milliseconds
                Add-Content -Path $temp_metadata_file -Encoding UTF8 -Value "END=$($total_length)"
                Add-Content -Path $temp_metadata_file -Encoding UTF8 -Value "title=$($file_name)"
                Add-Content -Path $track_list -Value "file '$($current_directory)\$($file.Name)'"
            }
            Add-Content -Path $automator_log -Value "Grabbed metadata for $($Directory)"
            ffmpeg -f concat -safe 0 -i "$track_list" -c:a aac -vn "$temp_file_name"
            Add-Content -Path $automator_log -Value "converted all wma for $($Directory) to m4a"
        }
        Get-Content $temp_metadata_file | Out-File -Encoding ascii $metadata_file
        ffmpeg -i "$temp_file_name" -i "$metadata_file" -metadata title="$($title)" -metadata author="$($author)" -metadata year="$($year)" -metadata album="$($album)" -map_metadata 1 -codec copy -vn $new_file_name
        Add-Content -Path $automator_log -Value "added metadata to $($Directory) m4a"
        Remove-Item *.mp3
        Remove-Item "$temp_file_name"
        Remove-Item "$track_list"
        Remove-Item "$temp_metadata_file"
        Remove-Item "$metadata_file"
        Rename-Item "$new_file_name" "$final_file_name"
        Add-Content -Path $automator_log -Value "Completed $($Directory) m4b conversion"
        Set-Location $originaldirectory
    }
    if ($null -ne $m4a)
    {
        Get-ChildItem *.m4a | Rename-Item -NewName { [io.path]::ChangeExtension($_.Name, "m4b") }
        Remove-Item "$track_list"
        Remove-Item "$temp_metadata_file"
        Remove-Item "$metadata_file"
        Add-Content -Path $automator_log -Value "converted $($Directory) from m4a to m4b"
        Set-Location $originaldirectory
    }
    if ($null -ne $mp4)
    {
        Get-ChildItem *.mp4 | Rename-Item -NewName { [io.path]::ChangeExtension($_.Name, "m4b") }
        Remove-Item "$track_list"
        Remove-Item "$temp_metadata_file"
        Remove-Item "$metadata_file"
        Add-Content -Path $automator_log -Value "converted $($Directory) from mp4 to m4a"
        Set-Location $originaldirectory
    }
    if ($null -ne $m4b)
    {
        if (Test-Path -Path $track_list -PathType Leaf)
        {
            Remove-Item $track_list
        }
        if (Test-Path -Path $temp_metadata_file -PathType Leaf)
        {
            Remove-Item $temp_metadata_file
        }
        if (Test-Path -Path $metadata_file -PathType Leaf)
        {
            Remove-Item $metadata_file
        }

        Add-Content -Path $automator_log -Value "$($Directory) already m4b"
    }
    Set-Location $originaldirectory
}