#!/bin/bash

exit;

# https://forum.proxmox.com/threads/how-do-you-squeeze-max-performance-with-software-raid-on-nvme-drives.127869/

pvcreate /dev/md0
vgcreate SSD-RAID-10 /dev/md0
lvcreate -l 97%FREE -n SSD-RAID-10 SSD-RAID-10
lvconvert --type thin-pool --poolmetadatasize 2048M --chunksize 64 SSD-RAID-10/SSD-RAID-10
