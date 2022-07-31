
$original   = get-location | select-object -expandproperty Path
$holding    = "Y:\sharing\temp\mpegs"
$mpegs = Get-Content -Path "$original\mpeg4.txt"

foreach ($file in $mpegs)
{
    #Converts string to file with properties
    $actualFile = Get-ChildItem $file

    $folder = Split-Path -Path $actualFile
    Set-Location $folder
    $originalName = $actualFile.Name
    $tempname = $actualFile.basename+"-remux.mkv"

    Write-Host "Working on $originalName"
    mkvmerge -o "$tempname" "$actualFile"

    Remove-Item "$actualfile"
    Rename-Item $tempname $originalName

    mkvpropedit.exe --add-track-statistics-tags $originalName
    Set-Location $original
}