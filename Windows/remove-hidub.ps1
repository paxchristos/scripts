## Removes HiDive and Dubcast intro from all MKVs in folder
# Removes all Brackets from all filenames 
(Get-ChildItem -File -Recurse) | Rename-Item -NewName { $_.Name -replace "[\[\]]" }

# Gets all MKVs in folder
$mkv = Get-ChildItem *.mkv

# Iterates through all MKVs in folder removing HiDive and Dubcast intros
foreach ($file in $mkv)
{
    Write-Host "$file"
    $filename = $file.name
    $wordsathome=[System.IO.Path]::GetFileNameWithoutExtension("$file")
    mkvmerge --output "split-$($wordsathome).mkv" --split timestamps:00:00:10.010,05:00:00 "$file"
    Remove-Item "split-$($wordsathome)-001.mkv"
    Remove-Item "$file"
    Rename-Item "split-$($wordsathome)-002.mkv" "$filename"
}