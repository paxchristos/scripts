$mkv = Get-ChildItem *.mkv

foreach ($file in $mkv)
{
    echo "$file"
    $filename = $file.name
    $wordsathome=[System.IO.Path]::GetFileNameWithoutExtension("$file")
    mkvmerge --output split-"$wordsathome".mkv --split timestamps:00:00:05.005,01:00:00 "$file"
    rm split-"$wordsathome"-001.mkv
    rm "$file"
    mv "split-"$wordsathome"-002.mkv" "$filename"
}