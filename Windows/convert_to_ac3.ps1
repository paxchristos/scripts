$mkv = gci *.mkv 

foreach ($file in $mkv) 
{
	$filename = [io.path]::GetFileNameWithoutExtension($file.name)
	$filename = $filename+"-ac3.mkv"
	ffmpeg -i $file.name -map 0 -c:v copy -c:s ass -c:a ac3 -b:a 192k $filename
}