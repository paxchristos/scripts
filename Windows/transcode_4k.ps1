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

<## Variables Used ##

$vbr       		= 6000
$langs			= "eng,jpn,rus"
$vencoder		= "nvenc_h265"
$aencoder		= "copy:aac,copy:ac3,copy:truehd,copy:dts,copy:dtshd,copy:eac3"
$format			= "av_mkv"
$abr 			= 640
$surround		= "dpl2"
$passAudio		= "aac,ac3,truehd,dts,dtshd,eac3"
$fallAudio		= "eac3"

### Unused Variables ###
#$nohdr			= "709"#>

$json 			= "C:\Users\peter\Documents\scripts\Windows\4k.json"

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
		##holds the original filename in a variable
		$original = $file.name
		HandBrakeCLI.exe  `
		--input $file `
		--output $tempname `
		--preset-import-file $json `
		--preset "4k" `

		<#
		##The meat and bones:
		##HandBrakeCli is in my paths, otherwise you'd need to do the full path for it
		##--input <filename> 	= $file from the $videos array
		##--output <filename>	= $tempname from above
		##--format 				= the format for the finished product, in this case mkv
		##--encoder				= the video encoder used, nvidia encoder h265, using the gpu
		##--vb					= the video bitrate, match $vbr
		##--encoder-preset		= slowest to make both the best quality and smallest file size
		##--two-pass			= using two pass encoding instead of one pass for best file quality
		##--turbo				= improved first pass speed
		##--vfr					= using a variable frame rate to preserve the source timing
		##--audio-lang-list		= isolating which audio tracks to keep, in this case, english, japanese and russian
		##--all-audio			= all audio tracks mentioned in --audio-lang-list are kept in the new transcoded video
		##--aencoder			= changes all audio track to the chosen audio encoder, in this case EAC3
		##--no-loose-crop		= disables the preset loose crop
		##--subtitle-lang-list	= isolates which subtitle track to keep, in this case english, japanses and russian
		##--all-subtitles		= all subtitles tracks mentioned in --subtitle-lang-list are kept in the new transcoded video
		##--crop 0:0:0:0		= disables any automatic crop by using the pixel count 0:0:0:0	
		##--mixdown				= sets the surround sound settings. 
		HandBrakeCLI.exe `
			--input "$file"`
			--output "$tempname" `
			--format="$format" `
			--encoder="$vencoder" `
			--vb=$vbr `
			--encoder-preset=slowest `
			--vfr `
			--no-two-pass `
			--audio-lang-list="$langs" `
			--all-audio `
			--aencoder="$aencoder" `
			--ab $abr `
			--no-loose-crop `
			--subtitle-lang-list="$langs" `
			--all-subtitles `
			--crop 0:0:0:0 `
			--mixdown $surround
		#>
		<# removed the following #>
		<#Removed Options
		--audio-copy-mask $passAudio `
			--audio-fallback $fallAudio `
		--color-matrix					= sets the color matrix (hdr to sdr tonemapping) #### Didn't check for HDR, caused washout
		#>
		##Renames the original final to filename.mkv.old
		Remove-Item "$file"
		##Renames the new transcoded file into the original filename
    	rename-Item "$tempname" "$original"
		##Fixes broken tags from handbrake
		mkvpropedit --add-track-statistics-tags "$original"

	}
	
	##goes back to the original folder location set outside this loop
	Set-Location "$original"
}