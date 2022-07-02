## Remuxes mp4 files into mkv

$mp4 = Get-ChildItem *.mp4
## DEBUG STATEMENT ##
##write-host $mp4.count##

foreach ($file in $mp4)
{
    Write-Host "$file"
    $tempname = [System.IO.Path]::GetFileNameWithoutExtension($file)
    $tempname = $tempname+".mkv"
    mkvmerge -o "$tempname" "$file"
    Remove-Item "$file"
}