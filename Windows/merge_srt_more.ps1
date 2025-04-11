$mkv = Get-ChildItem *.mkv

foreach ($file in $mkv)
{
    $filename = $file.name
    $unmerged = $filename+".old"
    $tempname = [io.path]::GetFileNameWithoutExtension($file.name)
    $srtname  = $tempname+".srt"
    $idxname  = $tempname+".idx"
    $subname  = $tempname+".sub"
    $assname  = $tempname+".ass"
    $langsrt  = $tempname+".en.srt"
    $oldsrt   = $srtname+".old"
    $extrasrt = $tempname+".eng.srt"
    if (Test-Path -Path $srtname -PathType Leaf)
    {
        mkvmerge -o "$tempname" "$filename" "$srtname"
        Remove-Item -Path "$file"
        Remove-Item -Path "$srtname"
        Rename-Item -Path "$tempname" -NewName "$filename"
    }
    if (Test-Path -Path $idxname -PathType Leaf)
    {
        mkvmerge -o "$tempname" "$filename" "$idxname"
        Remove-Item -Path "$file"
        Remove-Item -Path "$idxname"
        Rename-Item -Path "$tempname" -NewName "$filename"
    }
    if (Test-Path -Path $subname -PathType Leaf)
    {
        mkvmerge -o "$tempname" "$filename" "$subname"
        Remove-Item -Path "$file"
        Remove-Item -Path "$subname"
        Rename-Item -Path "$tempname" -NewName "$filename"
    }
    if (Test-Path -Path $assname -PathType Leaf)
    {
        mkvmerge -o "$tempname" "$filename" "$assname"
        Remove-Item -Path "$file"
        Remove-Item -Path "$assname"
        Rename-Item -Path "$tempname" -NewName "$filename"
    }
    if (Test-Path -Path $langsrt -PathType Leaf)
    {
        mkvmerge -o "$tempname" "$filename" "$langsrt"
        Remove-Item -Path "$file"
        Remove-Item -Path "$langsrt"
        Rename-Item -Path "$tempname" -NewName "$filename"
    }
    if (Test-Path -Path $extrasrt -PathType Leaf)
    {
        mkvmerge -o "$tempname" "$filename" "$extrasrt"
        Remove-Item -Path "$file"
        Remove-Item -Path "$extrasrt"
        Rename-Item -Path "$tempname" -NewName "$filename"
    }
}