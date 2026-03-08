#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${REMOTE_DIR:-}" ]]; then
  umount "$REMOTE_DIR" || true
fi

if [[ -n "${VOLUME_ID:-}" && -n "${DROPLET_ID:-}" ]]; then
  doctl compute volume-action detach "$VOLUME_ID" --droplet-id "$DROPLET_ID" --wait || true
fi

if [[ -n "${VOLUME_ID:-}" ]]; then
  doctl compute volume delete "$VOLUME_ID" --force || true
fi

if [[ -n "${DROPLET_ID:-}" ]]; then
  doctl compute droplet delete "$DROPLET_ID" --force
fi