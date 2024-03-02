#!/bin/bash

# 2024.feb kneutron
# This does a HIBERNATE to disk, not shutdown -- in parallel
# Useful if you are switched to UPS power and need to shutdown gracefully in minimum time
# NOTE - Will generate A LOT of disk I/O

# Use "Bulk actions / Bulk shutdown" in the GUI otherwise

# REF: https://forum.proxmox.com/threads/shutting-down-all-vm-ct-in-parallel.112519/

[ $(which parallel |wc -l) -gt 0 ] || apt-get install -y parallel

VM_LIST=/dev/shm/vmlist.in

# 1         2 3         
# processor : 7
lastcpu=$(grep processor /proc/cpuinfo |tail -n 1 |awk '{print $3}')
[ $lastcpu -gt 1 ] && let lastcpu=$lastcpu-1

[ -e "$VM_LIST" ] && rm -f "$VM_LIST" # delete the old file ONLY IF it exists
for vmid in $(qm list |grep running |awk '{print $1}'); do
  echo "qm shutdown $vmid" >>"$VM_LIST"
#  echo "qm suspend $vmid --todisk" >>"$VM_LIST"
done

echo "$(date) - HIBER ALL VMS using $lastcpu threads"
time cat "$VM_LIST" |parallel -j $lastcpu --progress
date

exit;
