#!/bin/bash

# May work even if the ctr storage is no longer defined
# REF: https://forum.proxmox.com/threads/how-to-delete-a-vm-or-container-that-has-no-storage-and-no-or-missing-storage-pool.87483/

# Requires 1 arg, number of LXC ctr to destroy

lxc-ls --fancy

exit; # comment me if you're serious, I take NO RESPONSIBILITY for data loss!


echo "Press Enter to proceed with destroy or ^C to back out!"
read

set -x
time lxc-destroy -n $1

lxc-ls --fancy
