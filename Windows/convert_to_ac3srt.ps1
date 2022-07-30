$mkv = get-childitem *.mkv 

foreach ($file in $mkv) 
{
	$filename = [io.path]::GetFileNameWithoutExtension($file.name)
	$filename = $filename + "-ac3.mkv" 
	$fullname = $file.name
	ffmpeg -i $file.name -map 0 -c:v copy -c:s srt -c:a copy $filename
	remove-item $fullname
	rename-item $filename $fullname
}