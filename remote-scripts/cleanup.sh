#!/usr/bin/env bash
set -euo pipefail

LOG_DATE=$(date +%Y%m%d-%H%M%S)
LOG_DEST="gdrive:logs/takeout-backup-run-${LOG_DATE}.log"

echo "Uploading run.log to Google Drive as logs/takeout-backup-run-${LOG_DATE}.log..."
rclone copyto /root/run.log "$LOG_DEST" --config /root/takeout/rclone.conf || \
  echo "Warning: failed to upload run.log to Google Drive"

echo "Cleaning up droplet, volume, and mounts..."
echo "Droplet ID: ${DROPLET_ID:-}"
echo "Volume ID: ${VOLUME_ID:-}"

if [[ -n "${VOLUME_ID:-}" && -n "${DROPLET_ID:-}" ]]; then
  echo "Detaching volume $VOLUME_ID from droplet $DROPLET_ID..."
  doctl compute volume-action detach "$VOLUME_ID" "$DROPLET_ID" --wait || true
fi

if [[ -n "${VOLUME_ID:-}" ]]; then
  echo "Deleting volume $VOLUME_ID..."
  doctl compute volume delete "$VOLUME_ID" --force || true
fi

if [[ -n "${DROPLET_ID:-}" ]]; then
  echo "Deleting droplet $DROPLET_ID..."
  doctl compute droplet delete "$DROPLET_ID" --force || true
fi