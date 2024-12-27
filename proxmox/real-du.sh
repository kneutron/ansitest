#!/bin/bash

# show actual at-the-moment disk usage VS what applications see / what they can address in thin-provisioned / compressed storage

# REF: https://forum.proxmox.com/threads/when-migrating-to-smb-cifs-the-disk-expands.159645/#post-733180

du -h "$@" # ACTUAL space being taken up on disk at the moment - can grow to the "allocated limit"
# 288G    .

du --apparent-size -h "$@" # What applications see / what they can actually address in a thin-provisioned / growable disk
# 352G    .
