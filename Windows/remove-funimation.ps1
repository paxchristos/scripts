## Removes funimation and vis intros from all files in folder
# Removes all brackets from filenames 
(Get-ChildItem -File -Recurse) | Rename-Item -NewName { $_.Name -replace "[\[\]]" }

#Gets all Mkvs 
$mkv = Get-ChildItem *.mkv

#Iterates through all mkvs in the folder
foreach ($file in $mkv)
{
    Write-Host "$file"
    $filename = $file.name
    $wordsathome=[System.IO.Path]::GetFileNameWithoutExtension($file)
    mkvmerge --output "split-$($wordsathome).mkv" --split timestamps:00:00:07.000,01:00:00 "$file"
    remove-item "split-$($wordsathome)-001.mkv"
    remove-item "$file"
    move-item "split-$($wordsathome)-002.mkv" "$filename"
}