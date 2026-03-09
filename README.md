# Google Takeout backup using Restic

Google Takeout backup using Restic. Runs remotely on a temporary DigitalOcean VM.

# Install

Requirements: rclone, doctl, restic


## 1) Configure Restic

```sh
cp .envrc.example .envrc
# edit .envrc variables
# Any Restic environment variable is supported, so you can use any repository location
# not just Backblaze B2
```

Initialize the Restic repository:

```sh
restic init -r b2:your-bucket:restic/google-takeout  
```

To browse any existing backups:

```sh
mkdir /tmp/restic/
restic mount /tmp/restic
open /tmp/restic
```

## 2) Configure rclone.conf

Generate a `rclone.conf` with a Google Drive remote (it must be named `gdrive`):

```sh
rclone config --config ./rclone.conf
```

## 3) Make sure your doctl is logged in

```sh
doctl auth init
```

## Run

Launches a DigitalOcean droplet + volume that downloads the `/Takeout` directory in your Google Drive (using rclone), unzips its files and backs it up using Restic. We unzip the files first to take full advantage of Restic deduplication. The droplet and volume are destroyed once the process is finished and a log file is written to your Google Drive's `/logs` directory.

PS: make sure you select the `.zip` option when requesting your Google Takeout.

```bash
./remote-backup.sh
```

# TODO

- Support more VM providers

