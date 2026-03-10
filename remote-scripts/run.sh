#!/usr/bin/env bash
set -euo pipefail

# Discover this droplet's ID from the metadata API
export DROPLET_ID=$(curl -s http://169.254.169.254/metadata/v1/id)

STAGING="$(dirname "$0")"
LOG_SYNC_PID=""

trap '[[ -n "$LOG_SYNC_PID" ]] && kill "$LOG_SYNC_PID" 2>/dev/null || true; bash "$STAGING/cleanup.sh"' EXIT

bash "$STAGING/install.sh"

# Periodically upload run.log to Google Drive in the background in case the
# machine crashes before cleanup.sh has a chance to run.
(
  while true; do
    sleep 60
    cp /root/run.log /tmp/run.log.sync 2>/dev/null || true
    rclone copyto /tmp/run.log.sync "gdrive:logs/takeout-backup-run-INPROGRESS.log" \
      --config /root/takeout/rclone.conf 2>/dev/null || true
  done
) &
LOG_SYNC_PID=$!

# Create and attach volume (sets VOLUME_ID and VOLUME_DEVICE)
source "$STAGING/create-volume.sh"

cp "$STAGING"/{backup.sh,rclone.conf,.envrc} "$REMOTE_DIR/"

cd "$REMOTE_DIR"
bash backup.sh

echo "Backup done. Self-destructing..."