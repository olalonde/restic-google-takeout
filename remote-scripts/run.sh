#!/usr/bin/env bash
set -euo pipefail

# Discover this droplet's ID from the metadata API
export DROPLET_ID=$(curl -s http://169.254.169.254/metadata/v1/id)

STAGING="$(dirname "$0")"

trap 'bash "$STAGING/cleanup.sh"' EXIT

bash "$STAGING/install.sh"

# Create and attach volume (sets VOLUME_ID and VOLUME_DEVICE)
source "$STAGING/create-volume.sh"

cp "$STAGING"/{backup.sh,rclone.conf,.envrc} "$REMOTE_DIR/"

cd "$REMOTE_DIR"
bash backup.sh

echo "Backup done. Self-destructing..."