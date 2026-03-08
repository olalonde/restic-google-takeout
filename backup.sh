#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

source .envrc

# First, download takeout
rclone --config ./rclone.conf copy --progress gdrive:/Takeout ./Takeout

# We unzip all zip files so that we can better leverage restic's deduplication
find ./Takeout -name "*.zip" -exec sh -c 'unzip -o "$1" -d "$(dirname "$1")" && rm "$1"' _ {} \;

# Backup to restic
restic backup --tag auto ./Takeout
