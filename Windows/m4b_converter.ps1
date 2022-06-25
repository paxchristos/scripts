$gathering   = "C:\temp"
$directories = Get-ChildItem -Recurse -Directory 
ForEach ($directory in $directories)
{
    $rtfm = "$($directory.FullName)"    
    #Write-Host $rtfm
    
    cd "$rtfm"
    $results    = Get-ChildItem -recurse -depth 1 | Where-Object { ".mp3" -contains $_.extension}
    ##DEBUG STATEMENT##Get-ChildItem -recurse
    $count      = $results.count
    Write-Host $count
    if ($count -gt 0)
    {
        Write-Host "Made it into if loop"
        $folder     = $directory.name
        $filename   = $directory.name+".mp3"
        $newname    = $directory.name+".m4b"
        
        ##DEBUG STATEMENTS##
        Write-Host $folder
        Write-Host $filename
        Write-Host $newname
        Write-Host $PWD
        cmd /c copy /b *.mp3 "$($filename)"
        ffmpeg  -i "$($filename)" -c:a aac -vn "$($newname)"
        copy-item $newname $gathering
    }
}