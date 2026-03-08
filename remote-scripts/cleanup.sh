#!/usr/bin/env bash
set -euo pipefail

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