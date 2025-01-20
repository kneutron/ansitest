#!/bin/bash

# 2024.feb kneutron
# Read through vm configs and move disks that are on src storage to dest storage
# NOTE changes will propagate auto to GUI

# NOTE all (applicable) vms must be shutdown, no hibernate / snapshots - so check GUI 1st

# This has been tested for zfs <-> zfs moves; NO WARRANTY or fitness of purpose is implied, 
# I am NOT RESPONSIBLE for data loss, HAVE BACKUPS!! before you try this!

# do:
# virtio4: zfs3nvme1T:vm-103-disk-2,cache=writeback,discard=on,iothread=1,size=5223M

# not:
# efidisk0: zfs1:vm-105-disk-2,efitype=4m,pre-enrolled-keys=1,size=1M
# sata0: zfs1:vm-105-disk-0,cache=writeback,size=65000M

# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

outf1=/dev/shm/disklist1
lxcfil=/dev/shm/disklist2
/bin/rm -fv $outf1 $lxcfil
errlog=~/proxmox-migrate-storage-err.log
wedidthis=~/proxmox-migrate-storage.log

# xxx TODO EDITME
#src=zfs3nvme1T
#dest=zfs1 # storage name from GUI
#src=zst4-f4m8-multi
#src=ztosh10-TEMP-ztera4-migrat # storage name from GUI
#dest=zsgexos10t
src=zfs2nvme # storage name from GUI
dest=zfs3nvme1T

debugg=0

echo "$(date) - Checking VMs for disks that use storage $src"
for vm in $(qm list |grep -v VMID |awk '{print $1}'); do
  echo "VM: $vm"
  
  result=$(qm config $vm --current |grep $src |grep -v unused |grep disk\-) 
[ $debugg -gt 0 ] && echo "Result: $result"
  [ "$result" = "" ] && continue; # early abort, next iteration
  
  result2=$(echo "$result" |awk -F\: '{print $1,"  "}') # virtio / sata0 , etc
  echo "Found $result2"
#  echo "Disk list $vm:"
  echo "$vm $result2" >>$outf1
#  read -p PK
done

# NOTE cannot move storage of a running container
for lxc in $(pct list |grep -v VMID |awk '{print $1}'); do
  echo "LXC: $lxc"
  
  result=$(pct config $lxc --current |grep $src |grep -v unused |grep disk\-) 
[ $debugg -gt 0 ] && echo "Result: $result"
  [ "$result" = "" ] && continue; # early abort, next iteration
  
  result2=$(echo "$result" |awk -F\: '{print $1,"  "}') # virtio / sata0 , etc
#  echo "Disk list $lxc:"
  echo "Found $result2 - stopping container $lxc"
  time pct stop $lxc 
  echo "$lxc $result2" >>$lxcfil
done

echo "====="
#cat $outf1 || failexit 44 "No disks in storage $src found to process!"
cat $outf1 || echo "No VM disks in storage $src found to process!"
cat $lxcfil || echo "No LXC disks in storage $src found to process!"
#exit;


# Teh Main Thing
# do VMs
echo "$(date) - Processing VM list"
while read inline; do
  char1=${inline:0:2}
  if [ $(grep -c "[a-z]" <<<"$char1") -gt 0 ]; then
    vmid=$foundvm # from last iteration 
    disktype=$(echo "$inline" |awk '{print $1}') #virtio4 / sata0
  else
    vmid=$(echo "$inline" |awk '{print $1}') #107
    disktype=$(echo "$inline" |awk '{print $2}') #virtio4 / sata0
  fi

  echo "$(date) - Moving VM disk $src - $vmid $disktype to $dest" |tee -a $wedidthis
# qm move_disk <vmid> <disk> <storage> [OPTIONS]
# time qm move_disk 103 sata1 zfs1

  time qm move_disk $vmid "$disktype" "$dest" --delete 2>>$errlog # so we dont have to deal with unused disks - delete source after copy OK
  foundvm=$vmid
done <$outf1  

# now for lxc
echo '====='
echo "$(date) - Processing LXC list"
while read inline; do
  char1=${inline:0:2}
  if [ $(grep -c "[a-z]" <<<"$char1") -gt 0 ]; then
    vmid=$foundvm # from last iteration 
    disktype=$(echo "$inline" |awk '{print $1}') #virtio4 / sata0
  else
    vmid=$(echo "$inline" |awk '{print $1}') #107
    disktype=$(echo "$inline" |awk '{print $2}') #virtio4 / sata0
  fi

  echo "$(date) - Moving LXC disk $src - $vmid $disktype to $dest" |tee -a $wedidthis
# qm move_disk <vmid> <disk> <storage> [OPTIONS]
# time qm move_disk 103 sata1 zfs1

  time pct move-volume $vmid "$disktype" "$dest" --delete 2>>$errlog # so we dont have to deal with unused disks - delete source after copy OK
  foundvm=$vmid
done <$lxcfil 

echo '====='
date
ls -lh $errlog

exit;
