#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

source .envrc

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

total_start=$(date +%s)

# First, download takeout
log "Starting rclone download"
step_start=$(date +%s)
RCLONE_PROGRESS=""
[[ -t 1 ]] && RCLONE_PROGRESS="--progress"  # only use --progress when running interactively
rclone --config ./rclone.conf copy $RCLONE_PROGRESS gdrive:/Takeout ./Takeout
step_end=$(date +%s)
log "rclone download done ($(( step_end - step_start ))s)"

# We unzip all zip files so that we can better leverage restic's deduplication.
log "Starting unzip"
step_start=$(date +%s)

while IFS= read -r zip; do
  dest="$(dirname "$zip")"
  size=$(du -sh "$zip" | cut -f1)
  uncompressed=$(unzip -l "$zip" | tail -1 | awk '{print $1}' | numfmt --to=iec)
  log "Unzipping $zip ($size compressed, $uncompressed uncompressed)"
  unzip -q -o "$zip" -d "$dest" && rm "$zip"
  log "Done $zip"
done < <(find ./Takeout -name "*.zip")

step_end=$(date +%s)
log "Unzip done ($(( step_end - step_start ))s)"

# Backup to restic
log "Starting restic backup"
step_start=$(date +%s)
restic backup --tag auto ./Takeout
step_end=$(date +%s)
log "Restic backup done ($(( step_end - step_start ))s)"

total_end=$(date +%s)
log "Total time: $(( total_end - total_start ))s"
