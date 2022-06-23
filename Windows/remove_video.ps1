$mkv = Get-ChildItem *.mkv
$counter = 1
foreach ($file in $mkv)
{
    echo "$file"
    $wordsathome=[System.IO.Path]::GetFileNameWithoutExtension($file)
    mkvmerge --output "$($counter).mka" -D "$file"
    $counter++
    #rm split-"$wordsathome"-001.mkv
    #rm "$file"
    #mv "split-"$wordsathome"-002.mkv" "$file"
}