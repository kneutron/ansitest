#!/bin/bash

# for LXC/VM
# Requires: Arg $1 = vmid

logf=~/proxmox-manual-backup-lxc-vm.log
ss=/dev/shm/storage-status.txt

# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

[ "$1" = "" ] && failexit 44 "No VMID passed as arg - cannot continue"

echo "$(date) - Checking storage status"
time pvesm status >$ss

echo "$(date) - $0 - Manual Backup requested for VMID: $1" |tee -a $logf

# xxx TODO EDITME
autosel=1
if [ "$autosel" -gt 0 ]; then
# autoselect storage with most free space
  usestor=$(grep -v Available $ss |sort -n -k 6 |tail -n 1 |awk '{print $1}')
  echo "$(date) o Autoselect dest storage by max free space: True" |tee -a $logf
else
# usestor="local"
  usestor="zexos10-proxmox-multi"
  echo "$(date) o Autoselect dest storage by max free space: False" |tee -a $logf
fi

echo "- Using this storage to backup VMID $1: $usestor" |tee -a $logf
[ $(grep -c $usestor $ss) -eq 0 ] && failexit 45 "! Storage $usestor not found in pvesm - cannot continue"

(set -x; time vzdump $1 --mode suspend --compress zstd --storage $usestor # zexos10-proxmox-multi
rc=$?; set +x
echo "$(date) - Exit code for VMID $1 manual backup: $rc" |tee -a $logf
)
date

echo '=====' |tee -a $logf
ls -lh $logf

# pct restore 999 /mnt/backup/filename.tar	# LXC, restore as vmid 999
# qmrestore /mnt/backup/filename.tar 999	# vm

# DONE - store auto to maxfree
#pvesm status |grep -v Available |sort -n -k 6 |tail -n 1
#dir1-xfs                                    dir     active      5366622188       959955960      4406666228   17.89%
# 1					     2		3		4		5		6

# pct list
# qm list
