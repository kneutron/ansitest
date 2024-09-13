#!/bin/bash

exit;

#lvresize -L +300G vmdata/thinvol
lvresize -A --verbose -r -L +100% pve/data

# REF: https://forum.proxmox.com/threads/how-to-extend-lvm-thin-pool.54900/
