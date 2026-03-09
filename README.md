# Google Takeout backup using Restic

Google Takeout backup using Restic. Runs remotely on a temporary DigitalOcean VM.

Note: I build this script for myself so it's not super tested nor configurable,
but it works well for my use case. 

You can either run it locally with `./backup.sh` or remotely with `./remote-backup.sh`.

When running locally, it will download the Google Takeout locally so make sure
you have enough disk space and decent bandwidth. 

When running remotely, this creates a temporary DitialOcean VM (droplet +
volume) where it runs the backup. The resources self-destruct when the backup
completes or if it fails. Cost is negligible since DO VMs come with a lot of
free bandwidth and we're just using the droplet/volume for a short period.

PS: make sure you select the `.zip` option and saving to Google Drive when
generating your Google Takeout.

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

Launches a DigitalOcean droplet + volume that downloads the `/Takeout` directory in your Google Drive (using rclone), unzips its files and backs it up using Restic. We unzip the files first to take full advantage of Restic deduplication. The droplet and volume are destroyed once the process is finished and a log file is written to your Google Drive's `/logs` directory.


```bash
./remote-backup.sh
```

### Locally

```bash
./backup.sh
```

# TODO

- Support more VM providers
- Make things more configurable, better error handling, etc.
