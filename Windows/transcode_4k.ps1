<#
### Single Use script: 
$Matroska       = Get-ChildItem -recurse *.mkv
 
foreach ($file in $Matroska)
{
	$tempname = [io.path]::GetFileNameWithoutExtension($file.name)
	$tempname = $tempname+"-remux.mkv"
	$original = $file.name
	HandBrakeCLI.exe -i "$file" -o "$tempname" --format=av_mkv --encoder=nvenc_h265 --vb=6000 --encoder-preset=slowest --two-pass --vfr --audio-lang-list=eng,jpn,rus --all-audio --aencoder flac16 --no-loose-crop --subtitle-lang-list=eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
	Remove-Item "$file"
    rename-Item "$tempname" "$original"
}
#>


##Going thru the whole shebang##

##Variables Used
$vbr       		= 6000
$langs			= "eng,jpn,rus"
$vencoder		= "nvenc_h265"
$aencoder		= "flac16"
$format			= "av_mkv"
$nohdr			= "709"
$surround		= "5point1"
##Collects all directories
$directories = Get-ChildItem -Directory -Recurse | Select-Object -ExpandProperty FullName

##Sets the original Location
$original	 = Get-Location | Select-Object -ExpandProperty Path

##iterates through each directory 
foreach ($directory in $directories)
{
	##Changes directory to current working one
	Set-Location "$directory"
	##Looks for MKVs in the current directory
	$videos = Get-ChildItem *.mkv
	##If it finds MKVs, it starts transcoding them
	foreach ($file in $videos)
	{
		##Creates variables used for this look
		##Gets the filename without any extension
		$tempname = [io.path]::GetFileNameWithoutExtension($file.name)
		##adds a "unique" addition to the end of transcoded file
		$tempname = $tempname+"-remux.mkv"
		##creates a variable for the renamed file
		$oldname  = $file.name+".old"
		##holds the original filename in a variable
		$original = $file.name

		##The meat and bones:
		##HandBrakeCli is in my paths, otherwise you'd need to do the full path for it
		##-i <filename> 		= $file from the $videos array
		##-o <filename>	 		= $tempname from above
		##--format 				= the format for the finished product, in this case mkv
		##--encoder				= the video encoder used, nvidia encoder h265, using the gpu
		##--vb					= the video bitrate, match $vbr
		##--encoder-preset		= slowest to make both the best quality and smallest file size
		##--two-pass			= using two pass encoding instead of one pass for best file quality
		##--vfr					= using a variable frame rate to preserve the source timing
		##--audio-lang-list		= isolating which audio tracks to keep, in this case, english, japanese and russian
		##--all-audio			= all audio tracks mentioned in --audio-lang-list are kept in the new transcoded video
		##--aencoder			= changes all audio track to the chosen audio encoder, in this case flac16
		##--no-loose-crop		= disables the preset loose crop
		##--subtitle-lang-list	= isolates which subtitle track to keep, in this case english, japanses and russian
		##--all-subtitles		= all subtitles tracks mentioned in --subtitle-lang-list are kept in the new transcoded video
		##--crop 0:0:0:0		= disables any automatic crop by using the pixel count 0:0:0:0
		##--color-matrix		= sets the color matrix (hdr to sdr tonemapping)
		##--mixdown				= sets the surround sound settings. 
		HandBrakeCLI.exe -i "$file" -o "$tempname" --format="$format" --encoder="$vencoder" --vb=$vbr --encoder-preset=slowest --two-pass --vfr --audio-lang-list="$langs" --all-audio --aencoder="$aencoder" --no-loose-crop --subtitle-lang-list="$langs" --all-subtitles --crop 0:0:0:0 --color-matrix="$nohdr" --mixdown="$surround"

		##Renames the original final to filename.mkv.old
		Rename-Item "$file" "$oldname"
		##Renames the new transcoded file into the original filename
    	rename-Item "$tempname" "$original"
		##Fixes broken tags from handbrake
		mkvpropedit --add-track-statistics-tags "$original"

	}
	
	##goes back to the original folder location set outside this loop
	Set-Location "$original"
}