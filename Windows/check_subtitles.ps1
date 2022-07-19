###Returns codec for video, audio, and subtitle. You need to use a full path to a text file for mediainfo to work

##Used to clear out brackets
##(Get-ChildItem -File -Recurse) | Rename-Item -NewName { $_.Name -replace "[\[\]]" }

$txtpath = "C:\Users\peter\Documents\scripts\mediainfo\check_subtitles.txt"

$mkv = get-childitem *.mkv

foreach ($file in $mkv)
{
    write-host $file.name
    MediaInfo.exe --Inform=file://$txtpath "$($file.name)"
}