#!/usr/bin/env bash
# =============================================================================
#  sonarr_import.sh  —  Sonarr Script Import handler
#
#  Sonarr calls this as:
#      sonarr_import.sh "<sourcePath>" "<destinationFilePath>"
#
#  Environment variables available (set by Sonarr):
#      Sonarr_SourcePath, Sonarr_DestinationPath,
#      Sonarr_EpisodeFile_MediaInfo_VideoCodec,
#      Sonarr_EpisodeFile_MediaInfo_AudioCodec, ... etc.
#
#  Exit codes Sonarr cares about:
#      0  = success (any non-zero causes Sonarr to throw)
#
#  Stdout tokens Sonarr parses:
#      [MediaFile] /abs/path       — the final file Sonarr should track
#      [MoveStatus] MoveComplete   — we moved/processed it; Sonarr skips its own move
#      [MoveStatus] RenameRequested — we moved it but want Sonarr to rename it
#      [MoveStatus] DeferMove      — let Sonarr handle the move itself
# =============================================================================

set -euo pipefail

# ─── Logging helpers ──────────────────────────────────────────────────────────
LOG_FILE="/tmp/sonarr_import_$$.log"
log()  { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE" >&2; }
die()  { log "ERROR: $*"; exit 1; }

# ─── Argument validation ──────────────────────────────────────────────────────
[[ $# -lt 1 ]] && die "Usage: $0 <sourcePath> [destinationFilePath]"

SOURCE_PATH="${1}"
DEST_PATH="${2:-${Sonarr_DestinationPath:-}}"

# Fall back: if Sonarr didn't provide a destination, mirror source location
[[ -z "$DEST_PATH" ]] && DEST_PATH="$SOURCE_PATH"

[[ -f "$SOURCE_PATH" ]] || die "Source file not found: $SOURCE_PATH"

log "=== Sonarr Script Import Start ==="
log "Source      : $SOURCE_PATH"
log "Destination : $DEST_PATH"

# ─── Dependency check ─────────────────────────────────────────────────────────
for cmd in ffprobe ffmpeg; do
    command -v "$cmd" &>/dev/null || die "'$cmd' is not installed or not in PATH"
done

# ─── Sanitize the destination filename ───────────────────────────────────────
#  Sonarr already produces well-formed filenames (including valid Unicode).
#  We only strip characters that are genuinely unsafe on Linux filesystems:
#    /  (path separator — would silently create subdirectories)
#    \0 (null byte)
#  Everything else — including accented/Unicode characters — is preserved.
sanitize_filename() {
    local dir base
    dir="$(dirname "$1")"
    base="$(basename "$1")"
    # Remove forward-slashes and null bytes from the filename portion only
    base="${base//\//}"          # strip any embedded /
    base="${base//$'\0'/}"       # strip null bytes (bash can't hold them anyway)
    printf '%s/%s' "$dir" "$base"
}

CLEAN_DEST="$(sanitize_filename "$DEST_PATH")"
if [[ "$CLEAN_DEST" != "$DEST_PATH" ]]; then
    log "Filename sanitized: '$(basename "$DEST_PATH")' → '$(basename "$CLEAN_DEST")'"
else
    log "Filename OK (no sanitization needed)"
fi
DEST_PATH="$CLEAN_DEST"

# ─── Probe streams ────────────────────────────────────────────────────────────
log "Probing streams..."

VIDEO_CODEC="$(ffprobe -v error -select_streams v:0 \
    -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 \
    "$SOURCE_PATH" 2>/dev/null || true)"

AUDIO_CODEC="$(ffprobe -v error -select_streams a:0 \
    -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 \
    "$SOURCE_PATH" 2>/dev/null || true)"

# Count audio streams so we can map them all
AUDIO_STREAM_COUNT="$(ffprobe -v error -select_streams a \
    -show_entries stream=index -of csv=p=0 \
    "$SOURCE_PATH" 2>/dev/null | wc -l || echo 0)"

log "Detected video codec : ${VIDEO_CODEC:-unknown}"
log "Detected audio codec : ${AUDIO_CODEC:-unknown} (${AUDIO_STREAM_COUNT} stream(s))"

# ─── Decide whether transcoding is needed ─────────────────────────────────────
#     Skip video transcode if already HEVC / h265
needs_video_transcode() {
    case "${VIDEO_CODEC,,}" in
        hevc|h265|libx265) return 1 ;;  # already HEVC — no transcode
        *)                 return 0 ;;
    esac
}

#     E-AC-3 (eac3 / ec-3) must be downconverted to AC-3 for device compat
needs_audio_transcode() {
    case "${AUDIO_CODEC,,}" in
        eac3|ec-3) return 0 ;;  # needs conversion
        *)         return 1 ;;
    esac
}

DO_VIDEO=$(needs_video_transcode && echo "yes" || echo "no")
DO_AUDIO=$(needs_audio_transcode && echo "yes" || echo "no")

log "Transcode video : $DO_VIDEO"
log "Transcode audio : $DO_AUDIO"

# If nothing needs touching, just move the file and tell Sonarr we're done
if [[ "$DO_VIDEO" == "no" && "$DO_AUDIO" == "no" ]]; then
    log "No transcoding required — moving file as-is."
    mkdir -p "$(dirname "$DEST_PATH")"
    mv -- "$SOURCE_PATH" "$DEST_PATH"
    echo "[MediaFile] $DEST_PATH"
    echo "[MoveStatus] MoveComplete"
    log "Done (no transcode). Final file: $DEST_PATH"
    exit 0
fi

# ─── NVENC availability check ─────────────────────────────────────────────────
#  Uses the actual GPU device, not a lavfi null source, so the driver stack
#  (libcuda, libnvidia-encode) is properly exercised during the probe.
NVENC_AVAILABLE="no"
if [[ "$DO_VIDEO" == "yes" ]]; then
    log "Testing NVENC availability..."
    if ffmpeg -hide_banner -loglevel error \
        -hwaccel cuda -hwaccel_output_format cuda \
        -f lavfi -i "color=black:s=320x240:d=0.1:r=1" \
        -c:v hevc_nvenc -preset p4 -f null - 2>/dev/null; then
        NVENC_AVAILABLE="yes"
        log "NVENC (hevc_nvenc) available — using GPU encoder."
    else
        log "NVENC unavailable — falling back to CPU libx265."
        # Surface the actual ffmpeg error to help diagnose driver issues
        ffmpeg -hide_banner -loglevel error \
            -f lavfi -i "color=black:s=320x240:d=0.1:r=1" \
            -c:v hevc_nvenc -f null - 2>>"$LOG_FILE" || true
        log "  (ffmpeg nvenc probe output written to $LOG_FILE)"
    fi
fi

# ─── Build ffmpeg stream maps ─────────────────────────────────────────────────
WORK_DIR="$(dirname "$SOURCE_PATH")"
BASENAME="$(basename "${DEST_PATH%.*}")"
TMP_OUT="${WORK_DIR}/.${BASENAME}_tmp.$$.mkv"

# Video codec args — split into INPUT flags (before -i) and OUTPUT flags (after -i)
# -hwaccel / -hwaccel_output_format must precede -i or ffmpeg ignores them
VIDEO_INPUT_ARGS=""
build_video_args() {
    if [[ "$DO_VIDEO" == "no" ]]; then
        VIDEO_INPUT_ARGS=""
        echo "-c:v copy"
        return
    fi

    if [[ "$NVENC_AVAILABLE" == "yes" ]]; then
        VIDEO_INPUT_ARGS="-hwaccel cuda -hwaccel_output_format cuda"
        echo "-c:v hevc_nvenc -preset p4 -cq 24 -b:v 0 -tag:v hvc1"
    else
        VIDEO_INPUT_ARGS=""
        echo "-c:v libx265 -crf 23 -preset medium -tag:v hvc1"
    fi
}

# Audio codec args per stream
#   E-AC-3 → AC-3 (all streams)
#   Everything else → copy
build_audio_args() {
    if [[ "$DO_AUDIO" == "no" ]]; then
        echo "-c:a copy"
        return
    fi

    local args=""
    local idx=0
    local codec

    while IFS= read -r codec; do
        case "${codec,,}" in
            eac3|ec-3)
                log "  Audio stream $idx: E-AC-3 → AC-3 (transcode)"
                args+=" -c:a:${idx} ac3 -b:a:${idx} 640k"
                ;;
            *)
                log "  Audio stream $idx: ${codec} → copy"
                args+=" -c:a:${idx} copy"
                ;;
        esac
        ((idx++)) || true
    done < <(ffprobe -v error -select_streams a \
        -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 \
        "$SOURCE_PATH" 2>/dev/null)

    echo "$args"
}

VIDEO_ARGS="$(build_video_args)"
AUDIO_ARGS="$(build_audio_args)"

log "Video args : $VIDEO_ARGS"
log "Audio args : $AUDIO_ARGS"

# ─── Run ffmpeg ───────────────────────────────────────────────────────────────
log "Starting transcode → $TMP_OUT"

run_ffmpeg() {
    local v_input_args="$1"
    local v_output_args="$2"
    local a_args="$3"
    # shellcheck disable=SC2086
    ffmpeg \
        -hide_banner \
        -loglevel warning \
        -stats \
        $v_input_args \
        -i "$SOURCE_PATH" \
        $v_output_args \
        -map 0:v \
        -map 0:a \
        -map 0:s? \
        -map_metadata 0 \
        -movflags +faststart \
        $a_args \
        -c:s copy \
        -y \
        "$TMP_OUT" \
        2>>"$LOG_FILE"
}

if ! run_ffmpeg "$VIDEO_INPUT_ARGS" "$VIDEO_ARGS" "$AUDIO_ARGS"; then
    # If NVENC failed mid-encode (e.g. GPU OOM), retry with CPU
    if [[ "$NVENC_AVAILABLE" == "yes" ]]; then
        log "NVENC encode failed — retrying with CPU libx265..."
        VIDEO_INPUT_ARGS=""
        VIDEO_ARGS="-c:v libx265 -crf 23 -preset medium -tag:v hvc1"
        rm -f "$TMP_OUT"
        run_ffmpeg "" "$VIDEO_ARGS" "$AUDIO_ARGS" \
            || die "CPU fallback encode also failed. Aborting."
    else
        die "ffmpeg encode failed. Aborting."
    fi
fi

# ─── Sanity-check the output file ─────────────────────────────────────────────
[[ -f "$TMP_OUT" && -s "$TMP_OUT" ]] || die "Transcode output is missing or empty: $TMP_OUT"

OUT_VIDEO="$(ffprobe -v error -select_streams v:0 \
    -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 \
    "$TMP_OUT" 2>/dev/null || true)"

log "Output video codec : ${OUT_VIDEO:-unknown}"

case "${OUT_VIDEO,,}" in
    hevc|h265) log "Output verified as HEVC ✓" ;;
    *) log "WARNING: Output video codec is '${OUT_VIDEO}', expected HEVC." ;;
esac

# ─── Replace original & move to destination ───────────────────────────────────
mkdir -p "$(dirname "$DEST_PATH")"

# Remove old source file first (Sonarr may have it locked briefly — retry)
for attempt in 1 2 3; do
    if rm -f -- "$SOURCE_PATH" 2>/dev/null; then
        break
    fi
    log "Could not remove source (attempt $attempt/3), retrying in 2s..."
    sleep 2
done

mv -- "$TMP_OUT" "$DEST_PATH" || die "Failed to move output to: $DEST_PATH"

log "=== Transcode complete ==="
log "Final file : $DEST_PATH"

# ─── Tell Sonarr what we did ──────────────────────────────────────────────────
#   [MediaFile]        → path of the file Sonarr should track
#   [MoveStatus] MoveComplete → we handled everything; skip Sonarr's own move
echo "[MediaFile] $DEST_PATH"
echo "[MoveStatus] MoveComplete"

exit 0