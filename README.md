# Google Takeout backup using Restic

Google Takeout backup using Restic. Runs either locally or remotely on a
temporary DigitalOcean VM.

When running locally, it will download the Google Takeout locally so make sure
you have enough disk space and decent bandwidth. 

When running remotely, it creates a temporary DitialOcean VM (droplet +
volume) where it runs the backup. The resources self-destruct when the backup
completes or fails. Cost is negligible since DO VMs come with a lot of
free bandwidth and we're just using the VM for a short period.

PS: make sure you select the `.zip` option and saving to Google Drive when
generating your Google Takeout.

Note: I build this script for myself so it's not super tested nor configurable,
but it works well for my use case. 

# Install

Requirements: [rclone](https://rclone.org/), [doctl](https://docs.digitalocean.com/reference/doctl/), [restic](https://restic.net/)

## Configure Restic

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

## Configure rclone.conf

Generate a `rclone.conf` with a Google Drive remote (it must be named `gdrive`):

```sh
rclone config --config ./rclone.conf
```

## Make sure your doctl is logged in

If running remotey, make sure doctl is logged in.

```sh
doctl auth init
```

## Run

### Remotely

Useful if you don't have enough disk space to download the Takeout, have slow
bandwidth or don't want to worry about keeping your computer on.

Launches a DigitalOcean droplet + volume that downloads the `/Takeout` directory in your Google Drive (using rclone), and runs the backup script. The droplet and volume are destroyed once the process is finished and a log file is written to your Google Drive's `/logs` directory.

```bash
./remote-backup.sh
```

### Locally

Downloads `Takeout/` from Google Drive. Unzips any zipped files to take full
advantage of Restic deduplication. 

```bash
./backup.sh
```

# TODO

- Support more VM providers
- Make things more configurable, better error handling, etc.
