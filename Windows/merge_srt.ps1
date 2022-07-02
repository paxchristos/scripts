$mkv = Get-ChildItem *.mkv

foreach ($file in $mkv)
{
    $filename = $file.name
    $unmerged = $filename+".old"
    $tempname = [io.path]::GetFileNameWithoutExtension($file.name)
    $srtname  = $tempname+".srt"
    $langsrt  = $tempname+".en.srt"
    $oldsrt   = $srtname+".old"
    if (Test-Path -Path $srtname)
    {
        mkvmerge -o "$tempname" "$filename" "$srtname"
        Rename-Item -Path "$file"     -NewName "$unmerged"
        Rename-Item -Path "$tempname" -NewName "$filename"
        Rename-Item -Path "$srtname"  -NewName "$oldsrt"
    }
    if (Test-Path -Path $langsrt)
    {
        mkvmerge -o "$tempname" "$filename" "$langsrt"
        Rename-Item -Path "$file"     -NewName "$unmerged"
        Rename-Item -Path "$tempname" -NewName "$filename"
        Rename-Item -Path "$srtname"  -NewName "$oldsrt"
    }
}