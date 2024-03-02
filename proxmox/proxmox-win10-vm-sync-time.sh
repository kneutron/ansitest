#!/bin/bash

# arg1 = vmid
echo "$(date) - syncing time on Win VM $1"
set -x
qm guest exec $1 w32tm /resync
set +x
date

# REF: https://windowsloop.com/windows-time-sync-command/
# REF: https://pve.proxmox.com/pve-docs/qm.1.html
