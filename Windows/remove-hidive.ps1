## Removes HiDive intro from all files in folder
# Removes brackets from all 
(Get-ChildItem -File -Recurse) | Rename-Item -NewName { $_.Name -replace "[\[\]]" }

# Gets all MKV Files in folder
$mkv = Get-ChildItem *.mkv

# Iterates through all MKV files in folder
foreach ($file in $mkv)
{
    Write-Host "$file"
    $filename = $file.name
    $wordsathome=[System.IO.Path]::GetFileNameWithoutExtension("$file")
    mkvmerge --output split-"$wordsathome".mkv --split timestamps:00:00:05.005,02:00:00 "$file"
    Remove-Item "split-$($wordsathome)-001.mkv"
    Remove-Item "$file"
    Rename-Item "split-$($wordsathome)-002.mkv" "$filename"
}