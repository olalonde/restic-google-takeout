#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

DO_REGION="${DO_REGION:-nyc3}"
DO_SSH_KEY="${DO_SSH_KEY:-$(doctl compute ssh-key list --format ID --no-header | head -n 1)}"
DO_TOKEN="${DIGITALOCEAN_ACCESS_TOKEN:-$(doctl auth token)}"
DROPLET_SIZE="s-4vcpu-8gb"
DROPLET_NAME="google-takeout-backup-$(date +%Y%m%d-%H%M%S)"
REMOTE_DIR="/mnt/takeout"
SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=10"
STAGING="/root/takeout"

echo "Creating droplet $DROPLET_NAME..."
DROPLET_ID=$(doctl compute droplet create "$DROPLET_NAME" \
  --region "$DO_REGION" \
  --size "$DROPLET_SIZE" \
  --image ubuntu-24-04-x64 \
  --ssh-keys "$DO_SSH_KEY" \
  --no-header \
  --format ID \
  --wait)

DROPLET_IP=$(doctl compute droplet get "$DROPLET_ID" --no-header --format PublicIPv4)
echo "Droplet $DROPLET_ID created. IP: $DROPLET_IP"

echo "Waiting for SSH..."
until ssh $SSH_OPTS root@"$DROPLET_IP" true 2>/dev/null; do
  sleep 5
done

echo "Uploading files..."
ssh $SSH_OPTS root@"$DROPLET_IP" "mkdir -p $STAGING"
scp $SSH_OPTS \
  backup.sh rclone.conf .envrc \
  remote-scripts/install.sh remote-scripts/run.sh \
  remote-scripts/create-volume.sh remote-scripts/cleanup.sh \
  root@"$DROPLET_IP":"$STAGING/"

echo "Launching setup in background..."
ssh $SSH_OPTS root@"$DROPLET_IP" "
  export DIGITALOCEAN_ACCESS_TOKEN='$DO_TOKEN'
  export REMOTE_DIR='$REMOTE_DIR'
  nohup bash $STAGING/run.sh > /root/run.log 2>&1 &
"

echo "Done. Backup is running on droplet $DROPLET_ID and will self-destroy when complete."
echo "To monitor: "
echo "ssh root@$DROPLET_IP 'tail -f /root/run.log'"
# ssh root@$DROPLET_IP 'tail -f /root/run.log'
