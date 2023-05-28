#Removes Aniplex/Funimation intro from all files in the folder
(Get-ChildItem -File -Recurse) | Rename-Item -NewName { $_.Name -replace "[\[\]]" }

#Gets all mkv files in the folder
$mkv = Get-ChildItem *.mkv

#iterates through each mkv in folder and removes aniplex/funimation based on timestamp
foreach ($file in $mkv)
{
    Write-Host "$file"
    $filename = $file.name
    $wordsathome=[System.IO.Path]::GetFileNameWithoutExtension($file)
    mkvmerge --output "split-$wordsathome.mkv" --split timestamps:00:00:10.010,05:00:00 "$file"
    remove-item "split-$wordsathome-001.mkv"
    remove-item "$file"
    rename-item "split-$wordsathome-002.mkv" "$filename"
}