[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $Full_Path
)

$videoTranscode = $false

$video_stream = ffprobe -v error `
    -select_streams v:0 `
    -show_entries stream=codec_name,height,bit_rate `
    -of csv=p=0 `
    "$Full_Path" |
ConvertFrom-Csv -Header codec,height,bitrate

$audio_streams = ffprobe -v error -select_streams a `
    -show_entries stream=index,codec_name,channels,bit_rate `
    -of csv=p=0  "$Full_Path" |
ConvertFrom-Csv -Header index,codec,channels,bitrate

#Write-Output $video_stream `n 
#Write-Output $audio_streams

if ($video_stream.codec -notmatch "hevc")
{
    $videoTranscode = $true
}

<#
else
{
    Write-Output "File already HEVC"
}
#>

#Write-Output "Tracks requiring transcode = $($trackTranscode)"

$videoArgs = @()

if ($videoTranscode)
{

    # Try GPU first (NVENC)
    $videoArgs = @(
        "-map", "0:v:0",
        "-c:v", "hevc_nvenc",
        "-rc:v", "vbr",
        "-b:v", "1500k",
        "-maxrate:v", "3000k",
        "-bufsize:v", "3000k"
    )


    $usingGpu = $true
}
else
{
    # Already HEVC → copy
    $videoArgs += @(
        "-map", "0:v:0",
        "-c:v", "copy"
    )
}

$audioArgs = @()

foreach ($stream in $audio_streams)
{

    $mapIndex = $stream.index - 1

    $audioArgs += "-map"
    $audioArgs += "0:a:$mapIndex"

    if ($stream.codec -match "eac3")
    {
        $audioArgs += @(
            "-c:a:$mapIndex", "ac3",
            "-b:a:$mapIndex", "320k"
        )
    }
    else
    {
        $audioArgs += @(
            "-c:a:$mapIndex", "copy"
        )
    }
}

$miscArgs = @(
    "-map", "0:s?",
    "-c:s", "copy",
    "-map_metadata", "0"
)

$outputPath = [System.IO.Path]::ChangeExtension($Full_Path, ".hevc.mkv")

$ffmpegArgs = @(
    "-y",
    "-i", "$Full_Path"
) + $videoArgs + $audioArgs + $miscArgs + @(
    "$outputPath"
)


Start-Process ffmpeg -ArgumentList $ffmpegArgs -Wait -NoNewWindow

if (-not(Test-Path -Path $outputPath -PathType Leaf))
{

    Write-Output "GPU encode failed — falling back to CPU"

    # Replace NVENC with CPU HEVC
    $videoArgs = @(
        "-map", "0:v:0",
        "-c:v", "libx265",
        "-b:v", "1500k",
        "-maxrate:v", "3000k",
        "-bufsize:v", "3000k",
        "-preset", "medium"
    )

    $ffmpegArgs = @(
        "-y",
        "-i", "$Full_Path"
    ) + $videoArgs + $audioArgs + $miscArgs + @(
        "$outputPath"
    )

    Start-Process ffmpeg -ArgumentList $ffmpegArgs -Wait -NoNewWindow
}
