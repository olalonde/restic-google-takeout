#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

source .envrc

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

total_start=$(date +%s)

# First, download takeout
log "Starting rclone download"
step_start=$(date +%s)
rclone --config ./rclone.conf copy --progress gdrive:/Takeout ./Takeout
step_end=$(date +%s)
log "rclone download done ($(( step_end - step_start ))s)"

# We unzip all zip files so that we can better leverage restic's deduplication.

# Optimization for DigitalOcean: each zip is extracted to a temporary directory
# on the local SSD (/tmp) first, then moved to the destination on the slower
# mounted volume. This avoids read/write thrashing on the mounted volume during
# extraction.
log "Starting unzip"
step_start=$(date +%s)
find ./Takeout -name "*.zip" -exec sh -c '
  zip="$1"
  dest="$(dirname "$zip")"
  tmp=$(mktemp -d /tmp/takeout-unzip.XXXXXX)
  unzip -o "$zip" -d "$tmp" && \
  mv "$tmp"/* "$dest/" && \
  rm -rf "$tmp" && \
  rm "$zip"
' _ {} \;
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
