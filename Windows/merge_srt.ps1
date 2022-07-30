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
        Remove-Item -Path "$file"
        Remove-Item -Path "$srtname"
        Rename-Item -Path "$tempname" -NewName "$filename"
    }
    if (Test-Path -Path $langsrt)
    {
        mkvmerge -o "$tempname" "$filename" "$langsrt"
        Remove-Item -Path "$file"
        Remove-Item -Path "$langsrt"
        Rename-Item -Path "$tempname" -NewName "$filename"
    }
}