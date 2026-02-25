#!/bin/sh

# 2025.Jul bechteld
#for vmid in $(vim-cmd vmsvc/getallvms |awk '{print $1}'); do echo "VMID: $vmid"; vim-cmd vmsvc/get.snapshotinfo $vmid; done; date

lf=/tmp/allvms.list

vmlist="jenkins|astrogit|rhelbldr"

vim-cmd vmsvc/getallvms |sort -fd -k 4 > $lf    # sort by name  # need to sort by col 4 == valid order
cat $lf
echo '====='

for vmid in $(egrep -i "$vmlist" $lf |awk '{print $1}'); do
  echo "VMID: $vmid - VMName: $(grep -w "^$vmid" $lf |head -n 1 |awk '{print $2}')";
#:
  echo "o Snapshot"
  vim-cmd vmsvc/snapshot.create $vmid "$(date +%Y%m%d@%H%M) bechteld";
done
date

