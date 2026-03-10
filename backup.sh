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

# We unzip all zip files so that we can better leverage restic's deduplication
log "Starting unzip"
step_start=$(date +%s)
find ./Takeout -name "*.zip" -exec sh -c 'unzip -o "$1" -d "$(dirname "$1")" && rm "$1"' _ {} \;
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
