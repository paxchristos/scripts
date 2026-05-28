[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $Full_Path
)

$videoTranscode = $false
$maxHeight = 1080

# ----------------------------
# Probe video stream
# ----------------------------

$video_stream = ffprobe -v error `
    -select_streams v:0 `
    -show_entries stream=codec_name,height,bit_rate,color_transfer `
    -of csv=p=0 `
    "$Full_Path" |
ConvertFrom-Csv -Header codec,height,bitrate,color_transfer

# ----------------------------
# Probe audio streams
# ----------------------------

$audio_streams = ffprobe -v error -select_streams a `
    -show_entries stream=index,codec_name,channels,bit_rate `
    -of csv=p=0  "$Full_Path" |
ConvertFrom-Csv -Header index,codec,channels,bitrate

# ----------------------------
# Resolution + HDR detection
# ----------------------------

$needsDownscale = [int]$video_stream.height -gt $maxHeight

$hdrTransferFunctions = @("smpte2084", "arib-std-b67")
$needsToneMap = $hdrTransferFunctions -contains $video_stream.color_transfer

# ----------------------------
# Decide if video must transcode
# ----------------------------

if (
    ($video_stream.codec -notmatch "hevc") -or
    $needsDownscale -or
    $needsToneMap
)
{
    $videoTranscode = $true
}

# ----------------------------
# Build video filter chain
# ----------------------------

$vfParts = @()

if ($needsToneMap)
{
    # HDR → SDR tone-mapping
    $vfParts += "zscale=t=linear:npl=100"
    $vfParts += "tonemap=hable"
    $vfParts += "zscale=t=bt709:m=bt709:r=tv"
}

if ($needsDownscale)
{
    # Cap height at 1080, preserve AR
    $vfParts += "scale=-2:1080"
}

$videoFilterArgs = @()
if ($vfParts.Count -gt 0)
{
    $videoFilterArgs = @(
        "-vf", ($vfParts -join ",")
    )
}

# ----------------------------
# Video arguments
# ----------------------------

$videoArgs = @()

if ($videoTranscode)
{
    # Try GPU first (NVENC)
    $videoArgs = @(
        "-map", "0:v:0"
    ) + $videoFilterArgs + @(
        "-c:v", "hevc_nvenc",
        "-rc:v", "vbr",
        "-b:v", "2000k",
        "-maxrate:v", "3000k",
        "-bufsize:v", "3000k"
    )
}
else
{
    # Already HEVC + SDR + <=1080p → copy
    $videoArgs += @(
        "-map", "0:v:0",
        "-c:v", "copy"
    )
}

# ----------------------------
# Audio arguments
# ----------------------------

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

# ----------------------------
# Subs + metadata
# ----------------------------

$miscArgs = @(
    "-map", "0:s?",
    "-c:s", "copy",
    "-map_metadata", "0"
)

# ----------------------------
# Output
# ----------------------------

$outputPath = [System.IO.Path]::ChangeExtension($Full_Path, ".hevc.mkv")

$ffmpegArgs = @(
    "-y",
    "-i", "`"$Full_Path`""
) + $videoArgs + $audioArgs + $miscArgs + @(
    "`"$outputPath`""
)

Start-Process ffmpeg -ArgumentList $ffmpegArgs -Wait -NoNewWindow

# ----------------------------
# CPU fallback if NVENC fails
# ----------------------------

if (-not (Test-Path -Path $outputPath -PathType Leaf))
{
    Write-Output "GPU encode failed — falling back to CPU"

    $videoArgs = @(
        "-map", "0:v:0"
    ) + $videoFilterArgs + @(
        "-c:v", "libx265",
        "-b:v", "2000k",
        "-maxrate:v", "3000k",
        "-bufsize:v", "3000k",
        "-preset", "medium"
    )

    $ffmpegArgs = @(
        "-y",
        "-i", "`"$Full_Path`""
    ) + $videoArgs + $audioArgs + $miscArgs + @(
        "`"$outputPath`""
    )

    Start-Process ffmpeg -ArgumentList $ffmpegArgs -Wait -NoNewWindow
}

# ----------------------------
# Replace original file
# ----------------------------

if (Test-Path -Path $outputPath -PathType Leaf)
{
    Start-Sleep -Seconds 1
    Remove-Item $Full_Path -Force -Confirm:$false
    Move-Item -LiteralPath $outputPath -Destination $Full_Path -Force
}
