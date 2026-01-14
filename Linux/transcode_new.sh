#!/usr/bin/env bash
set -euo pipefail

INPUT="$1"

if [[ ! -f "$INPUT" ]]; then
  echo "Input file not found"
  exit 1
fi

OUTPUT="${INPUT%.*}.hevc.mkv"

video_transcode=false

# ------------------------
# VIDEO STREAM INFO
# ------------------------
IFS=',' read -r v_codec v_height v_bitrate < <(
  ffprobe -v error \
    -select_streams v:0 \
    -show_entries stream=codec_name,height,bit_rate \
    -of csv=p=0 \
    "$INPUT"
)

if [[ "$v_codec" != "hevc" ]]; then
  video_transcode=true
fi

# ------------------------
# AUDIO STREAM INFO
# ------------------------
mapfile -t audio_streams < <(
  ffprobe -v error \
    -select_streams a \
    -show_entries stream=index,codec_name,channels,bit_rate \
    -of csv=p=0 \
    "$INPUT"
)

# ------------------------
# BUILD VIDEO ARGS
# ------------------------
video_args=()

if $video_transcode; then
  video_args+=(
    -map 0:v:0
    -c:v hevc_nvenc
    -rc:v vbr
    -b:v 1500k
    -maxrate:v 3000k
    -bufsize:v 3000k
  )
else
  video_args+=(
    -map 0:v:0
    -c:v copy
  )
fi

# ------------------------
# BUILD AUDIO ARGS
# ------------------------
audio_args=()

for line in "${audio_streams[@]}"; do
  IFS=',' read -r a_index a_codec a_channels a_bitrate <<< "$line"

  map_index=$((a_index - 1))

  audio_args+=(-map "0:a:$map_index")

  if [[ "$a_codec" == "eac3" ]]; then
    audio_args+=(
      "-c:a:$map_index" ac3
      "-b:a:$map_index" 320k
    )
  else
    audio_args+=(
      "-c:a:$map_index" copy
    )
  fi
done

# ------------------------
# MISC ARGS
# ------------------------
misc_args=(
  -map 0:s?
  -c:s copy
  -map_metadata 0
)

# ------------------------
# RUN FFMPEG (GPU FIRST)
# ------------------------
set +e
ffmpeg -y -i "$INPUT" \
  "${video_args[@]}" \
  "${audio_args[@]}" \
  "${misc_args[@]}" \
  "$OUTPUT"
status=$?
set -e

# ------------------------
# FALLBACK TO CPU IF GPU FAILS
# ------------------------
if [[ $status -ne 0 || ! -f "$OUTPUT" ]]; then
  echo "GPU encode failed — falling back to CPU"

  video_args=(
    -map 0:v:0
    -c:v libx265
    -b:v 1500k
    -maxrate:v 3000k
    -bufsize:v 3000k
    -preset medium
  )

  ffmpeg -y -i "$INPUT" \
    "${video_args[@]}" \
    "${audio_args[@]}" \
    "${misc_args[@]}" \
    "$OUTPUT"
fi
