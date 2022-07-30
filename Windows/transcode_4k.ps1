#Variables Used
$Matroska       = Get-ChildItem -recurse *.mkv

<#
$vbr       		= 6000
$abr			= 384
$aud			= "ac3"
$subs			= "eng,jpn,rus,und"
$enc			= "nvenc_h265"

#> 
foreach ($file in $Matroska)
{
	$tempname = [io.path]::GetFileNameWithoutExtension($file.name)
	$tempname = $tempname+"-remux.mkv"
	$original = $file.name
	HandBrakeCLI.exe -i "$file" -o "$tempname" --format=av_mkv --encoder=nvenc_h265 --vb=6000 --encoder-preset=slowest --two-pass --vfr --audio-lang-list=eng,jpn,rus --all-audio --aencoder flac16 --no-loose-crop --subtitle-lang-list=eng,jpn,rus,und --all-subtitles --crop 0:0:0:0
	Remove-Item "$file"
    rename-Item "$tempname" "$original"
}

<#
foreach ($file in $Matroska)
{
	$tempname = [io.path]::GetFileNameWithoutExtension($file.name)
	$original = $file.name
	HandBrakeCLI.exe -i "$file" -o "$tempname" --encoder $enc --vb $vbr --encoder-preset slowest --two-pass --vfr --all-audio --aencoder $aud --audio-copy-mask $aud --ab $abr --subtitle-lang-list $subs --all-subtitles --crop 0:0:0:0
	Remove-Item "$file"
    rename-Item "$tempname" "$original"
}
#>