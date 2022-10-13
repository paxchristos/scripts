# Powershell
# Merges video and audio track
# removes brackets
(Get-ChildItem -File -Recurse) | Rename-Item -NewName { $_.Name -replace "[\[\]]" }

#Gets all MKV Files
$mkv = Get-ChildItem *.mkv

#Iterates thru each MKV file matching mkv file with mka containing audio and subtitle track
foreach ($file in $mkv)
{
    $tempname = [System.IO.Path]::GetFileNameWithoutExtension($file)
    $original = $tempname+".mkv"
    $mkaname = $tempname+".mka"
    if (Test-Path $mkaname -PathType Leaf)
    {
        mkvmerge.exe --output "$tempname" "$file" "$mkaname"
        remove-item "$mkaname"
        remove-item "$file"
        rename-item "$tempname" "$original"
        Write-Host "$original merged into dual audio"
    }
    else
    {
        Write-host "Unable to merge $original, audio file doesn't exist"    
    }
}