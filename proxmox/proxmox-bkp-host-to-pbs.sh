#!/usr/bin/env bash

# REF: https://www.reddit.com/r/Proxmox/comments/tfbhp1/newbie_here_what_are_the_benefits_of_proxmox/
# REF: https://pbs.proxmox.com/docs/backup-client.html
# REF: https://linuxconfig.org/how-to-create-a-backup-with-proxmox-backup-client
# SOURCE: https://github.com/kneutron/ansitest/blob/master/proxmox/proxmox-bkp-host-to-pbs.sh

# 2025-07-14 v0.1

## Config
CONFIG_FILE="proxmox-bkp-host-to-pbs.env"

## Code

# Check for required binaries
requirements() {
  local missing=()
  for bin; do
    if ! command -v "$bin" >/dev/null 2>&1; then
      missing+=("$bin")
    fi
  done

  if (( ${#missing[@]} )); then
    echo >&2 "Error: the following required commands are not installed or not in \$PATH:"
    for bin in "${missing[@]}"; do
      echo >&2 "  • $bin"
    done
    exit 1
  fi
}

# Switch to directory where script is located (to use relative path for config file)
switch_path() {
  source="${BASH_SOURCE[0]}"
  while [ -h "$source" ]; do
    directory="$(cd -P "$(dirname "$source")" >/dev/null 2>&1 && pwd)"
    source="$(readlink "$source")"
    # if $SOURCE was a relative symlink, resolve it relative to the symlink’s dir
    [[ $source != /* ]] && source="$dir/$source"
  done
  # Get the real directory
  script_dir="$(cd -P "$(dirname "$source")" >/dev/null 2>&1 && pwd)"
  # cd to the script’s directory
  cd "$script_dir"
}

# Print formatted date
pdate() {
  if [ $LOGGING -eq 1 ]; then
    date "+%Y-%m-%d %H:%M"
  fi
}

# Run command and log to stdout
run() {
  # Print if logging is enabled
  if [ $LOGGING -eq 1 ]; then
    printf '%s\n' "$*"
  fi
  # Run command
  "$@"
}

# Start backup
backup() {
  run proxmox-backup-client backup \
    $namespace_cmd \
    --all-file-systems "$INCLUDE_ALL_MOUNTS" \
    ${INCLUDE_MOUNTS[@]/#/--include-dev } \
    root-$(hostname).pxar:/
  if [ $? -ne 0 ]; then
    error=1
  fi
}

# Output backup status and write touchfile for monitoring
check_successful() {
  if [ $error -eq 0 ]; then
    if [ $LOGGING -eq 1 ]; then
      echo "Backup successful"
    fi
    if [[ -n $TOUCHFILE ]]; then
      run touch $TOUCHFILE
    fi
  else
    if [ $LOGGING -eq 1 ]; then
      echo "Backup NOT successful"
    fi
    exit 1
  fi
}

error=0

requirements proxmox-backup-client date touch
switch_path

# Source config file
set -a
source "$CONFIG_FILE"
set +a

# Use namespace if set
if [[ -n $NAMESPACE ]]; then
  namespace_cmd="--ns $NAMESPACE"
fi

pdate
backup
pdate
check_successful

exit 0

# root.pxar is name of bkp, / is root dir
# REF: https://pbs.proxmox.com/docs/backup-client.html

# CRON:
#  mkdir -p /root/scripts/proxmox-bkp-host-to-pbs
#  >copy script and config into /root/scripts/proxmox-bkp-host-to-pbs
#  chmod -R 700 /root/scripts/proxmox-bkp-host-to-pbs
#  chown -R root:root /root/scripts/proxmox-bkp-host-to-pbs
#  chmod 600 /root/scripts/proxmox-bkp-host-to-pbs/proxmox-bkp-host-to-pbs.env
#  echo "30 3 * * * root /root/scripts/proxmox-bkp-host-to-pbs/proxmox-bkp-host-to-pbs.sh" > /etc/cron.d/proxmox-bkp-host-to-pbs

# RESTORE:
#  Live-restore: This feature can allow you to start a VM when the restore job is started, rather than waiting for it to finish.
#  proxmox-backup-client snapshot list
#  proxmox-backup-client snapshot list --repository 10.9.1.23:zpbs1
#  proxmox-backup-client restore host/elsa/2019-12-03T09:35:01Z root.pxar /target/path/
#  proxmox-backup-client restore --repository 192.168.122.72:datastore0 host/doc-standardpcq35ich92009/2024-01-11T11:01:49Z etc.pxar /etc
