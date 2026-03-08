#!/usr/bin/env bash
# Meant to be sourced from setup.sh

REGION=$(curl -s http://169.254.169.254/metadata/v1/region)
VOLUME_NAME="takeout-scratch-$(date +%Y%m%d-%H%M%S)"

echo "Creating volume $VOLUME_NAME in region $REGION..."

VOLUME_ID=$(doctl compute volume create "$VOLUME_NAME" \
  --region "$REGION" \
  --size 2TiB \
  --no-header \
  --format ID)

echo "Attaching volume $VOLUME_ID to droplet $DROPLET_ID..."

doctl compute volume-action attach "$VOLUME_ID" "$DROPLET_ID" --wait

VOLUME_DEVICE="/dev/disk/by-id/scsi-0DO_Volume_$VOLUME_NAME"

echo "Creating filesystem and mounting volume..."

mkfs.ext4 -q "$VOLUME_DEVICE"
mkdir -p "$REMOTE_DIR"
mount "$VOLUME_DEVICE" "$REMOTE_DIR"

export VOLUME_ID
export VOLUME_DEVICE