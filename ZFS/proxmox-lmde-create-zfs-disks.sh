#!/bin/bash

# 2025.Jan kneutron

# bash heredoc / here document
cat <<EOF

# Purpose: Populate a proxmox vm with the max number of disks (that I know of) for zfs raidz / raidz2 expansion testing
# OLDNOTE VM must be EFI boot to see all drives! (2025.Jan apparently works OK with Seabios now)

# NOTE DO NOT RUN THIS AGAINST A VM WITHOUT HAVING BACKED IT UP OR SNAPSHOTTED IT FIRST!!!

##############################################
# README - EDIT THIS SCRIPT BEFORE RUNNING IT!
#
# NOTE - run this script when the VM is POWERED OFF!
# current boot disk is set to scsi0 - make sure the VM is backed up in case scsi0 gets deleted!!
#
# NOTE - this is important - DO NOT DO ZFS-ON-ZFS! 
# -> Use XFS/ext4 or lvm-thin for backing storage when creating ZFS virtual disks or you will get write amplification!!
#
##############################################


# NOTE you will probably need to use /dev/disk/by-path in-vm
# NOTE may need to reboot to have vm recognize all drives, or run rescan-scsi-bus

# NOTE - THIS IS A UTILITY SCRIPT, I TAKE NO RESPONSIBILITY FOR DATA LOSS! RUN THIS AT YOUR OWN RISK!

# *** DO NOT RUN THIS SCRIPT IF YOU HAVE AN ACTIVE ZFS POOL IN THE VM, THE DISKS WILL BE FORCIBLY RECREATED!! ***

# NOTE this script assumes the boot drive (sda) is scsi0!!
Press Enter to proceed or ^C
EOF
read -n 1

# xxx TODO editme
#vmid=100
vmid=99999
#usestor=dir1-xfs # storage name from gui
#usestor=local-lvm # storage name from gui
usestor=tosh10-xfs-multi # storage name from gui
dsize=1 # create disk of this size in GB

skipscsi=1 # if limited storage on host
#skipscsi=0

# NOTE also remove disk 1st if exist, for resizing
# ISSUE virtio only supports 0-15, sata only supports 0-5, scsi supports 0-30 - so we have to do this in sets

# NOTE proxmox sata drives are not hotplug and will not be de-rezzed if the vm is running
# NOTE this is important, skip sda as it may be the boot disk
i=1
echo "$(date) - Creating additional SATA disks for VM $vmid of size ${dsize}GB"
# these end up being sda .. sde in by-path
#for d in $(echo a{w..z}); do
for d in {b..f}; do
  echo $d $i
#  time qm set $vmid --delete scsi${i}
#  qm set $vmid --delete unused0
  qm unlink $vmid --force 1 --idlist sata${i} # dont move disk to unused, delete outright 

  time qm set $vmid --sata${i} $usestor:$dsize,cache=writeback,discard=on,ssd=0,backup=0,format=raw &
  let i=$i+1
done

wait;
let total=$total+$i-1


# NOTE you can change dsize here if needed!
# Do virtio disks
i=0
echo "$(date) - Creating virtio disks for VM $vmid of size ${dsize}GB"
# these end up being vda .. vdp in by-path
#for d in $(echo a{g..v}); do
for d in {a..p}; do
  echo $d $i
#  time qm set $vmid --delete scsi${i}
  qm unlink $vmid --force 1 --idlist virtio${i} # dont move disk to unused, delete outright 

# NOTE no ssd option for virtio
  time qm set $vmid --virtio${i} $usestor:$dsize,cache=writeback,discard=on,backup=0,format=raw &
  let i=$i+1
done

wait;
let total=$total+$i #-1


if [ $skipscsi -eq 0 ]; then
# These end up being sdf .. sdaj in by-path
# i=0
 i=1 # attempt to preserve boot drive!
 echo "$(date) - Creating SCSI disks for VM $vmid of size ${dsize}GB"
#for d in {b..z} $(echo a{a..f}); do
#for d in {b..z} $(echo a{a..f}); do
 for d in {g..z} $(echo a{a..k}); do
  echo $d $i
#  time qm set $vmid --delete scsi${i}
  qm unlink $vmid --force 1 --idlist scsi${i} # dont move disk to unused, delete outright 

  time qm set $vmid --scsi${i} $usestor:$dsize,cache=writeback,discard=on,ssd=0,backup=0,format=raw &
  let i=$i+1
 done

 wait;
 let total=$total+$i # we started from 1 # 0
fi

# WARNING dont do this - vm disappeared!! along with snapshot!
#time qm destroy $vmid --destroy-unreferenced-disks

echo "$(date) - Done - Total $total disks created for VM $vmid"

exit;

# HOWTO Distribute virtio disks between 2x XFS where 0,2..etc are on tosh10-xfs (for better I/O):
# for d in 1 3 5 7 9 11 13 15; do echo "$(date) - $d"; time qm move_disk 100 virtio$d dir1-xfs --delete; done; date


#grep -v unused 130.conf |grep -c qcow2                                                           
#51

# 52 in vm - EFI disk is not qcow2

# REF: https://forum.proxmox.com/threads/vm-and-maximum-number-of-block-devices.108348/


# ISSUE - for some reason we only get up to sdaj in devuan 5 and systemrescuecd (36 drives) with standard seabios
# REF: https://www.reddit.com/r/DataHoarder/comments/cqdtzd/proxmoxerror_is_there_a_maximum_number_of_drives/

# (FIX) Interesting - efi boot sees (52) drives = sda thru sdaj + vda thru vdp + sda thru sde (NOTE the efi drive does not show)
# ls -l /dev/disk/by-path |egrep -v 'part|sr0|virtio|ata-.*.0|total' # 52

# So we have (50) drives available for zfs / draid + 1 hotspare, not including the boot disk

# without scsi, we have (21) drives not including boot disk, so 20 for zfs + 1 hotspare

--scsihw <lsi | lsi53c810 | megasas | pvscsi | virtio-scsi-pci | virtio-scsi-single> (default = lsi)
SCSI controller model

Proxmox VE emulates by default a LSI 53C895A controller

sata0 = sda, boot

sata: (remember 0 = sda / boot)
  1  2  3  4    5
sdb  c  d  e  sdf
-----------------


scsi drives:
                      1                   1
  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8   9 
sdg h i j k l m n o p q r s t u v w x y sdz

scsi continued:
echo a{a..k}
  20 21 22 23 24 25 26 27 28 29   30
sdaa ab ac ad ae af ag ah ai aj sdak


virtio:
                               1               1
0   1  2  3  4  5  6  7  8  9  0  1  2  3  4   5
vda b  c  d  e  f  g  h  i  j  k  l  m  n  o vdp
------------------------------------------------ 

## cleanup:
# qm unlink 130 --force 1 --idlist "$(echo unused{0..24})"
#update VM 130: -delete unused3 unused4 unused5 unused6 unused7 unused8 unused9 unused10 unused11 unused12 unused13 unused14 unused15 unused16 unused17 unused18 unused19 unused20 unused21 unused22 unused23 unused24 -force 1


Cleanup / start over: NOTE cant do these in BG, lock fails
# time for d in {1..5}; do qm unlink 130 --force 1 --idlist sata$d; done; date
# time for d in {0..15}; do qm unlink 130 --force 1 --idlist virtio$d; done
# time for d in {0..30}; do qm unlink 130 --force 1 --idlist scsi$d; done
 