#!/bin/bash

# 2025.Feb kneutron

# Replace zfs boot/root ashift=9 single disk with same-size disk converting to ashift=12, and fix boot for new disk
# cannot "drain" wrong-ashifted disk to replacement vdev, must have same sector size

# NOTE I TAKE NO RESPONSIBILITY FOR DATA LOSS, EDIT THIS SCRIPT BEFORE RUNNING
# AND MAKE SURE YOU DESIGNATE THE RIGHT DISKS!

# NOTE it is HIGHLY RECOMMENDED to try this in a vm first!!!!

# REF: https://www.reddit.com/r/Proxmox/comments/1cr6wn7/tutorial_howto_migrate_a_pve_zfs_bootroot_mirror/

# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

set -u # abort on undefined var

# TODO EDITME and make sure to put the correct shortnames in!
oldisk1=sdd # ata-128GB_SSD_MP35A00300205
#oldisk2=vdb

newdisk1=sdc # ata-128GB_SSD_MP35A00302533
#newdisk2=vdd


echo "-- YOU NEED TO EDIT THIS SCRIPT BEFORE RUNNING IT!! --"
echo "WARNING: About to destructively apply a new GPT label to disk $newdisk1"
ls -l /dev/disk/by-id |grep $newdisk1
echo "^C to backout or Enter to proceed"
read

# install any missing dependencies
[ $(which pv |wc -l) -eq 0 ] && apt install -y pv
[ $(which wipefs |wc -l) -eq 0 ] && apt install -y util-linux
[ $(which sgdisk |wc -l) -eq 0 ] && apt install -y gdisk
[ $(which pv |wc -l) -eq 0 ] && apt install -y pv

(set -x
zpool export -f rpool2 # if running more than once
zpool destroy rpool2
wipefs -a /dev/$newdisk1
)

set -e # abort on error

#for disk in $newdisk1 $newdisk2; do
echo "Duplicating partition table on /dev/$newdisk1"
for disk in $newdisk1; do
 echo $disk
sgdisk -g \
-n 1:0:+1M \
-n 2:0:+1G \
-n 3:0:0 \
-t 1:8300 \
-t 2:EF00 \
-t 3:BF01 \
-p /dev/$disk

 gdisk -l /dev/$disk
done

echo "$(date) - Prep new disks, blank any filesystem / zfs data"
set +e # OK if we fail here, not fatal
zpool labelclear -f /dev/${newdisk1}3
#zpool labelclear /dev/${newdisk2}3
wipefs -a /dev/${newdisk1}3
#wipefs -a /dev/${newdisk2}3

zpool import -N -f -d /dev rpool # if not here yet; do NOT mount any datasets
set -e

zpool status rpool -v
#  pool: rpool
# state: ONLINE
#status: One or more devices are configured to use a non-native block size.
#        Expect reduced performance.
#action: Replace affected devices with devices that support the
#        configured block size, or migrate data to a properly configured
#        pool.
#  scan: resilvered 13.8G in 00:04:00 with 0 errors on Fri Jan 17 04:01:22 2025
#config:
#        NAME                            STATE     READ WRITE CKSUM
#        rpool                           ONLINE       0     0     0
#          wwn-0x53a5a276780002da-part3  ONLINE       0     0     0  block size: 512B configured, 4096B native
echo '====='
echo "About to create ashift=12 zpool on new disk $newdisk1 partition 3 - ^C to backout / Enter = proceed"
read

features=$(zpool get all rpool |grep feature |awk '{print "-o " $2"=enabled \\" }' |sort)
echo "$features" >/dev/shm/rpool-features.txt

(set -x
time zpool create -o ashift=12 -o autoexpand=on -o autoreplace=off \
 $(cat /dev/shm/rpool-features.txt |tr -d '\') \
 -O atime=off -O compression=lz4 \
 -f rpool2 /dev/${newdisk1}3 || failexit 22 "Failed to create rpool2 on ${newdisk1}3 "
)
zpool list

echo '====='
echo "Killing transfer snapshot and recreating"
zfs destroy -r -v rpool@transfer # kill snapshot
zfs snapshot -r rpool@transfer

echo '====='
echo "$(date) - Enter to send rpool data to rpool2"
read -n 1

time zfs send -R rpool@transfer \
 |pv -t -r -b -W -i 2 -B 250M \
 |zfs recv -F -v rpool2 \
 || failexit 23 "Failed to recv snapshot into rpool2"

date

#Note that -F will destroy the contents of pool2, so be cautious and make sure the command is right.

# wait for resilver
function waitresilver () {
sdate=$(date)
# do forever
while :; do
  clear
  echo "Pool: rpool - NOW: $(date) -- Watchresilver started: $sdate"

  zpool status rpool |grep -A 2 'in progress' || break 2
  zpool iostat -v rpool #2 3 &

  sleep 5
  date
done

ndate=$(date)
echo "o Resilver watch rpool start: $sdate // Completed: $ndate"
}

zpool status -v rpool2 |awk 'NF>0' # skip blank lines
date

echo "$(date) - Enter to Export original rpool and import rpool2 as rpool to rename it"
read
zpool export -f rpool
zpool export rpool2
sleep 2
(set -x
time zpool import -N -f -d /dev/disk/by-id rpool2 rpool
)

zpool list
zpool status -v |awk 'NF>0'

# from sysrescue environment, we can try dd'ing efi from 1 to 2, but no guarantee it will boot!
echo '====='
echo "dd EFI partition from olddisk to new disk"
time dd if=/dev/${oldisk1}2 of=/dev/${newdisk1}2 bs=1M status=progress; time sync
date;

exit;



# TODO we need to do this from ext4-boot proxmox!
# either portable rescue environment or from a running PVE...
# but maybe we can copy it out of a snapshot...? nope
# cannot proceed with sysrescue, no grub

# xxx TODO EDITME
newdisk1=sdX

proxmox-boot-tool status # Note if grub is being used or not here
addgrub=""
[ $(proxmox-boot-tool status |grep -c grub) -gt 0 ] && addgrub="grub"

echo "$(date) - Fixing boot on new drive"
set -x
proxmox-boot-tool format /dev/${newdisk1}2 --force # <new disk's ESP partn>
#proxmox-boot-tool format /dev/${newdisk2}2 --force # <new disk's ESP partn>
time sync; sleep 2

proxmox-boot-tool init /dev/${newdisk1}2 $addgrub # <new disk's ESP partn>
#proxmox-boot-tool init /dev/${newdisk2}2 $addgrub # <new disk's ESP partn>

proxmox-boot-tool refresh
set +x

zpool status rpool -v

echo "After shutdown + remove old disks, run:"
echo  "proxmox-boot-tool clean"
echo "and"
echo " zpool clear rpool"

exit;


Device             Start       End   Sectors  Size Type
/dev/nvme0n1p1        34      2047      2014 1007K BIOS boot
/dev/nvme0n1p2      2048   2099199   2097152    1G EFI System
/dev/nvme0n1p3   2099200 167772160 165672961  119G ZFS

# REFs:
https://forum.proxmox.com/threads/replace-512gb-ssds-with-500gb-ssds.143077/

https://pve.proxmox.com/wiki/ZFS_on_Linux#sysadmin_zfs_change_failed_dev

https://pve.proxmox.com/wiki/Host_Bootloader#sysboot_proxmox_boot_tool

https://forum.proxmox.com/threads/fixing-uefi-boot.87719/
