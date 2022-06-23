# Powershell
# Merges video and audio track, assumes only 1 season
$mkv = Get-ChildItem *.mkv
$counter=1

foreach ($file in $mkv)
{
    echo "$file"
    $tempname = "s01e$($counter).mkv"
    $wordsathome=[System.IO.Path]::GetFileNameWithoutExtension($file)
    mkvmerge.exe --output "$tempname" "$file" "$($counter).mka"
    remove-item "$($counter).mka"
    remove-item "$file"
    move-item "$tempname" "$($wordsathome).mkv"
    $counter++
}