## Removes dubcast intro from all files in folder ##
# Removes all brackets from files names in folder
(Get-ChildItem -File -Recurse) | Rename-Item -NewName { $_.Name -replace "[\[\]]" }

#Gets all mkvs in folders
$mkv = Get-ChildItem *.mkv

#iterates through all mkvs in folder and removes dubcast intro
foreach ($file in $mkv)
{
    Write-Host "$file"
    $filename = $file.name
    $wordsathome=[System.IO.Path]::GetFileNameWithoutExtension($file)
    mkvmerge --output "split-$($wordsathome).mkv" --split timestamps:00:00:04.504,05:00:00 "$file"
    Remove-Item "split-$($wordsathome)-001.mkv"
    Remove-Item "$file"
    Rename-Item "split-$($wordsathome)-002.mkv" "$filename"
}