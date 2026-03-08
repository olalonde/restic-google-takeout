#!/usr/bin/env bash
set -euo pipefail

apt-get update -q
apt-get install -y -q unzip restic curl
restic self-update
curl -fsSL https://rclone.org/install.sh | bash

DOCTL_VERSION=$(curl -s https://api.github.com/repos/digitalocean/doctl/releases/latest | grep -oP '"tag_name": "v\K[^"]+')
curl -sL "https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-amd64.tar.gz" | tar -xz -C /usr/local/bin/

