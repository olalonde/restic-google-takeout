#!/usr/bin/env bash
set -euo pipefail

until apt-get update -q; do sleep 5; done
apt-get install -y -q unzip bzip2

if [[ -n "${LOCAL_TZ:-}" ]]; then
  timedatectl set-timezone "$LOCAL_TZ"
fi

RESTIC_VERSION=$(curl -s https://api.github.com/repos/restic/restic/releases/latest | grep -oP '"tag_name": "v\K[^"]+')
curl -fsSL "https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_amd64.bz2" | bunzip2 > /usr/local/bin/restic
chmod +x /usr/local/bin/restic
curl -fsSL https://rclone.org/install.sh | bash

DOCTL_VERSION=$(curl -s https://api.github.com/repos/digitalocean/doctl/releases/latest | grep -oP '"tag_name": "v\K[^"]+')
curl -sL "https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-amd64.tar.gz" | tar -xz -C /usr/local/bin/

