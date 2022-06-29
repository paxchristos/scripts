$srt = get-childitem *.srt
$mkv = Get-ChildItem *.mkv

foreach ($file in $mkv)
{
    $filename = $file.name
    $unmerged = $filename+".old"
    $tempname = [io.path]::GetFileNameWithoutExtension($file.name)
    $srtname  = $tempname+".srt"
    $oldsrt   = $srtname+".old"
    if (Test-Path -Path $srtname)
    {
        mkvmerge -o $tempname $filename $srtname
        Rename-Item -Path $file     -NewName $unmerged
        Rename-Item -Path $tempname -NewName $filename
        Rename-Item -Path $srtname  -NewName $oldsrt
    }
}