## Removes video track from folder of videos, leaves audio and subtitle tracks ##

# remove brackets from file names #
(Get-ChildItem -File -Recurse) | Rename-Item -NewName { $_.Name -replace "[\[\]]" }

#Gets all MKV files in a folder 
$mkv = Get-ChildItem *.mkv

#Iterates through all mkv files in a folder remove videos
foreach ($file in $mkv)
{
    Write-Host "$file"
    $wordsathome=[System.IO.Path]::GetFileNameWithoutExtension($file)
    $wordsathome = $wordsathome+".mka"
    mkvmerge --output "$wordsathome" -D "$file"
    Remove-Item "$file"
}