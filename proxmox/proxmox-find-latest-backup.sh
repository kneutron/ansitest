#!/bin/bash

# arg1 = ctr / vm / both (defaults to vm only if blank)

# 2024.Oct kneutron
# Purpose: Find latest backups of vm / ctr on $STORAGE and list the filenames
# Designed to be useful when needing to restore a bunch of ctr/vms in bulk

# NOTE this does NOT take into account archival backup files that have no corresponding active ctr/VM on the node!
# NOTE that ctr/VMs that have presence on the node may have backups on different storage as well, or no backups at all!

# REQUIRES: grep awk sort tail

outdir=/tmp
ctrlist="$outdir/ctrlist.txt"
vmlist="$outdir/vmlist.txt"

# blankit
>$ctrlist
>$vmlist

# TODO EDITME - this is the Backup Storage to query
bkpdir=/mnt/macpro-sgtera2/proxmox/dump

echo "$(date) - Getting CTR/VM info..."
# containers - list active on-node only
time pct list |grep -v VMID |awk '{print $1}' >$ctrlist

# VMs
time qm list |grep -v VMID |awk '{print $1}' >$vmlist

#VMID       Status     Lock         Name
#105        running                 gotify

#      VMID NAME                 STATUS     MEM(MB)    BOOTDISK(GB) PID
#       100 lmde                 stopped    4096              21.00 0

cd "$bkpdir"

if [ "$1" = "" ] || [ "$1" = "vm" ] || [ "$1" = "both" ]; then
echo '===== VM:'
  for vmid in $(cat $vmlist); do
    ls -1rt vzdump-qemu-${vmid}*.{lzo,zst} 2>/dev/null |sort |tail -n 1
  done
fi
if [ "$1" = "" ] || [ "$1" = "ctr" ] || [ "$1" = "both" ]; then
echo '===== CTR:'
  for vmid in $(cat $vmlist); do
    ls -1rt vzdump-lxc-${vmid}*.{lzo,zst} 2>/dev/null |sort |tail -n 1
  done
fi

pwd
exit;

/mnt/macpro-sgtera2/proxmox/dump # ls -1rt vzdump-lxc*.zst |sort
vzdump-lxc-102-2024_02_15-03_00_00.tar.zst
vzdump-lxc-105-2024_09_29-03_00_50.tar.zst
vzdump-lxc-105-2024_09_30-03_01_07.tar.zst
vzdump-lxc-105-2024_10_01-03_00_46.tar.zst
vzdump-lxc-110-2024_02_24-12_55_33.tar.zst
vzdump-lxc-110-2024_09_21-00_15_00.tar.zst
vzdump-lxc-110-2024_09_28-00_15_12.tar.zst
vzdump-lxc-113-2024_09_21-00_16_28.tar.zst
vzdump-lxc-113-2024_09_28-00_16_40.tar.zst
vzdump-lxc-114-2024_04_05-21_47_55.tar.zst
vzdump-lxc-114-2024_09_21-00_17_33.tar.zst
vzdump-lxc-114-2024_09_28-00_17_45.tar.zst
vzdump-lxc-118-2024_08_10-00_20_00.tar.zst
vzdump-lxc-118-2024_08_17-00_20_26.tar.zst
vzdump-lxc-122-2024_09_21-00_23_32.tar.zst
vzdump-lxc-122-2024_09_28-00_25_21.tar.zst
vzdump-lxc-123-2024_04_06-16_38_27.tar.zst
vzdump-lxc-99998-2024_02_27-14_21_18.tar.zst
vzdump-lxc-99998-2024_03_15-10_02_00.tar.zst
