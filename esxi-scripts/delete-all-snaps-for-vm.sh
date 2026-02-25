#!/bin/sh

# 2026.Feb bechteld.adm

echo -e "VMID \t VMNAME"
vim-cmd vmsvc/getallvms |awk 'NF>0 {print $1"\t"$2"\t"$3"\t"$4}' |grep vmx |sort -f -k 2 # by name, case-insens

#declare -i vmid # integer
if [ "$1" = "" ]; then
  echo "Enter VMID"
  read vmid
else
  vmid=$1
fi

echo "$(date) - Deleting snapshots for VMID $vmid"
time vim-cmd vmsvc/snapshot.removeall $vmid

date;

