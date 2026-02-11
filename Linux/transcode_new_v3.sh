#!/usr/bin/env bash
set -euo pipefail

# Sonarr provides this during import
INPUT="${sonarr_destinationpath:-${1:-}}"

if [[ -z "$INPUT" || ! -f "$INPUT" ]]; then
  echo "Input file not found: $INPUT"
  exit 0   # IMPORTANT: do not fail import
fi

DIR="$(dirname "$INPUT")"
BASE="$(basename "$INPUT")"
TEMP="${DIR}/.${BASE}.sonarr-transcode.tmp"

video_transcode=false

# ------------------------
# VIDEO INFO
# ------------------------
IFS=',' read -r v_codec v_height v_bitrate < <(
  ffprobe -v error \
    -select_streams v:0 \
    -show_entries stream=codec_name,height,bit_rate \
    -of csv=p=0 \
    "$INPUT"
)

[[ "$v_codec" != "hevc" ]] && video_transcode=true

# ------------------------
# AUDIO INFO
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
  IFS=',' read -r a_index a_codec _ _ <<< "$line"
  map_index=$((a_index - 1))
  audio_args+=(-map "0:a:$map_index")

  if [[ "$a_codec" == "eac3" ]]; then
    audio_args+=("-c:a:$map_index" ac3 "-b:a:$map_index" 320k)
  else
    audio_args+=("-c:a:$map_index" copy)
  fi
done

# ------------------------
# MISC
# ------------------------
misc_args=(
  -map 0:s?
  -c:s copy
  -map_metadata 0
)

# ------------------------
# TRANSCODE TO TEMP
# ------------------------
set +e
ffmpeg -y -i "$INPUT" \
  "${video_args[@]}" \
  "${audio_args[@]}" \
  "${misc_args[@]}" \
  "$TEMP"
status=$?
set -e

# ------------------------
# FALLBACK
# ------------------------
if [[ $status -ne 0 || ! -f "$TEMP" ]]; then
  rm -f "$TEMP"
  ffmpeg -y -i "$INPUT" \
    -map 0:v:0 -c:v libx265 \
    -b:v 1500k -maxrate:v 3000k -bufsize:v 3000k -preset medium \
    "${audio_args[@]}" \
    "${misc_args[@]}" \
    "$TEMP"
fi

# ------------------------
# ATOMIC REPLACE (SONARR CRITICAL)
# ------------------------
if [[ -f "$TEMP" ]]; then
  mv -f "$TEMP" "$INPUT"
fi

exit 0   # NEVER fail import
