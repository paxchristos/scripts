$original = get-location | select-object -expandproperty Path
$encoder    = "nvenc_h265"
$hdbr       = 1500
$mpegs = Get-Content -Path "C:\temp\big_files.txt"
foreach ($file in $mpegs) 
{ 
    $actualFile = Get-ChildItem $file
    $folder = Split-Path -Path $actualFile
    Set-Location $folder
    ## Variables in loop
    Write-Output $file.name
    $tempname = [io.path]::GetFileNameWithoutExtension($actualFile.name)
    $tempname = $tempname+"-remux.mkv"
    $originalFile = $actualFile.Name
    #Write-Host $actualFile
    #Write-Host $folder
    #Write-Host $tempname
    #Write-Host $originalFile
    
    HandBrakeCLI.exe -i "$actualFile" -o "$tempname" -e "$encoder" -b "$hdbr" --no-two-pass --all-audio --aencoder ac3 --audio-copy-mask ac3 --mixdown stereo --no-loose-crop --subtitle-lang-list eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
    Remove-Item "$actualFile"
    rename-Item "$tempname" "$originalFile"
    mkvpropedit --add-track-statistics-tags "$originalFile"
    Set-Location $original
}