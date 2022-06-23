$mkv = Get-ChildItem *.mkv

foreach ($file in $mkv)
{
    echo "$file"
    $wordsathome=[System.IO.Path]::GetFileNameWithoutExtension($file)
    mkvmerge --output "split-$($wordsathome).mkv" --split timestamps:00:00:13.013,01:00:00 "$file"
    remove-item "split$($wordsathome)001.mkv"
    remove-item "$file"
    move-item "split$($wordsathome)002.mkv" "$($wordsathome).mkv"
}