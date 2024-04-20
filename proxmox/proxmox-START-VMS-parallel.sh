#!/bin/bash

# 2024.Apr kneutron
# REF: https://forum.proxmox.com/threads/shutting-down-all-vm-ct-in-parallel.112519/

[ $(which parallel |wc -l) -gt 0 ] || apt-get install -y parallel

VM_LIST=~/vmlist.in # put the number of the VMs that you want to parastart in this file
# TODO MAKE SURE you uncheck " Start at boot " in the VM/ctr options, or proxmox startup will interfere with what this script is trying to do!

tmpout=/dev/shm/vms-parallel-start.in

# 1         2 3         
# processor : 7
lastcpu=$(grep processor /proc/cpuinfo |tail -n 1 |awk '{print $3}')
[ $lastcpu -gt 1 ] && let lastcpu=$lastcpu-1

# You can manually set a lower limit here
let lastcpu=3

[ -e "$tmpout" ] && rm -f "$tmpout" # delete the old file ONLY IF it exists
for vmid in $(cat $VM_LIST); do
  echo "qm start $vmid" >>"$tmpout"
#  echo "qm suspend $vmid --todisk" >>"$VM_LIST"
done

echo "$(date) - parallel START VMS using $lastcpu threads"
time cat "$tmpout" |parallel -j $lastcpu --progress
date

exit;


Example ~/vmlist.in:

104
108
109
111
112
