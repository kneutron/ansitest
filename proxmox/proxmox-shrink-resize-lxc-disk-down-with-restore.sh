#!/bin/bash

echo "EDITME before running!"

exit

# LXC MUST BE POWERED OFF

#pct restore {ID} {backup volume}:{backup path} --storage {target storage} --rootfs {target storage}:{new size in GB}. 

#The Path can be extracted from the backup task.  It's something like
#ct/104/2025-03-09T10:13:55Z.  For PBS it has to be prefixed with backup/. 
#After filling out all of the other arguments, it should look something like
#this: 
# pct restore 100 pbs:backup/ct/104/2025-03-09T10:13:55Z --storage local-zfs --rootfs local-zfs:8
#time pct restore 108 ct/108/2025_08_25-22_21_22 --storage xfs-tosh10-multi --rootfs zexos10-shared-xfs:64 # GB
#CT 108 already exists on node 'proxmox'

# pct restore 600 /mnt/backup/vzdump-lxc-777.tar.tar --storage system_lvms

# Works:
time pct restore $(pvesh get /cluster/nextid) /mnt/toshtera10-xfs/dump/vzdump-lxc-108-2025_08_25-22_21_22.tar.zst --rootfs sgexos10-shared-xfs:64 # GB -- resized down from 250


la /mnt/toshtera10-xfs/dump/
-rw-r--r--  1 root root         825 Aug 25 22:22 vzdump-lxc-108-2025_08_25-22_21_22.log
-rw-r--r--  1 root root   355466467 Aug 25 22:21 vzdump-lxc-108-2025_08_25-22_21_22.tar.zst
-rw-r--r--  1 root root          41 Aug 25 22:21 vzdump-lxc-108-2025_08_25-22_21_22.tar.zst.notes
