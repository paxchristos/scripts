$directories = Get-ChildItem -Directory -Recurse | Select-Object -ExpandProperty FullName
$originaldirectory = Get-Location | Select-Object -ExpandProperty Path

foreach ($directory in $directories)
{
    ##Changes directory to current working one
    Set-Location "$directory"
    $mkv = Get-ChildItem *.mkv

    foreach ($file in $mkv)
    {
        $filename = $file.name
        $tempname = [io.path]::GetFileNameWithoutExtension($file.name)
        $srtname = $tempname + ".srt"
        $langsrt = $tempname + ".en.srt"
        $extralangsrt = $tempname + ".eng.srt"
        $assname = $tempname + ".ass"
        if (Test-Path -Path $srtname -PathType Leaf)
        {
            mkvmerge -o "$tempname" "$filename" "$srtname"
            Remove-Item -Path "$file"
            Remove-Item -Path "$srtname"
            Rename-Item -Path "$tempname" -NewName "$filename"
        }
        if (Test-Path -Path $langsrt -PathType Leaf)
        {
            mkvmerge -o "$tempname" "$filename" "$langsrt"
            Remove-Item -Path "$file"
            Remove-Item -Path "$langsrt"
            Rename-Item -Path "$tempname" -NewName "$filename"
        }
        if (Test-Path -Path $extralangsrt -PathType Leaf)
        {
            mkvmerge -o "$tempname" "$filename" "$extralangsrt"
            Remove-Item -Path "$file"
            Remove-Item -Path "$extralangsrt"
            Rename-Item -Path "$tempname" -NewName "$filename"
        }
        if (Test-Path -Path $assname -PathType Leaf)
        {
            mkvmerge -o "$tempname" "$filename" "$assname"
            Remove-Item -Path "$file"
            Remove-Item -Path "$assname"
            Rename-Item -Path "$tempname" -NewName "$filename"
        }
    }
    Set-Location $originaldirectory
}