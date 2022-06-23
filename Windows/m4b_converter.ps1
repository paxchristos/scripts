$gathering   = "C:\temp"
$directories = Get-ChildItem -Recurse -Directory 
ForEach ($directory in $directories)
{
    Write-Host $directory
    $results    = gci  -recurse |where-object {".mp3" -contains $_.extension}
    $count      = $results.count
    Write-Host $count
    if ($count -gt 0)
    {
        $filename   = (dir).directory.name[0]
        $newname    = $filename+".m4b"
        $filename   = $filename+".mp3" 
        cmd /c copy /b *.mp3 $filename
        ffmpeg  -i "$filename" -c:a aac -vn "$newname"
        copy-item $newname $gathering
    }
}