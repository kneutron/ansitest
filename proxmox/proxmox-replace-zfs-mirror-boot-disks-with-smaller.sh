#!/bin/bash

# Replace zfs boot/root mirror disks with smaller ones and fix boot for both
# 2024.May kneutron

# NOTE I TAKE NO RESPONSIBILITY FOR DATA LOSS, EDIT THIS SCRIPT BEFORE RUNNING 
# AND MAKE SURE YOU DESIGNATE THE RIGHT DISKS!

# NOTE it is HIGHLY RECOMMENDED to try this in a vm first!!!!

# REF: https://www.reddit.com/r/Proxmox/comments/1cr6wn7/tutorial_howto_migrate_a_pve_zfs_bootroot_mirror/

set -u # abort on undefined var
set -e # abort on error

echo "WARNING: About to destructively apply a new GPT label to disks - ^C to backout or Enter to proceed"
read

# TODO EDITME and make sure to put the correct shortnames in!
oldisk1=vda
oldisk2=vdb

newdisk1=vdc
newdisk2=vdd

for disk in $newdisk1 $newdisk2; do
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
zpool labelclear /dev/${newdisk1}3
zpool labelclear /dev/${newdisk2}3
wipefs -a /dev/${newdisk1}3
wipefs -a /dev/${newdisk2}3
set -e

zpool status rpool -v
echo "About to replace old boot disks with new disks - ^C to backout / Enter = proceed"
read

set -x
zpool add -f rpool mirror /dev/${newdisk1}3 /dev/${newdisk2}3

zpool detach rpool /dev/${oldisk1}3
time zpool remove rpool /dev/${oldisk2}3
set +x

# wait for resilver
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

zpool status -v rpool |awk 'NF>0' # skip blank lines
echo "o Resilver watch rpool start: $sdate // Completed: $ndate"

proxmox-boot-tool status # Note if grub is being used or not here
addgrub=""
[ $(proxmox-boot-tool status |grep -c grub) -gt 0 ] && addgrub="grub"

echo "$(date) - Fixing boot on both new drives"
set -x
proxmox-boot-tool format /dev/${newdisk1}2 --force # <new disk's ESP partn>
proxmox-boot-tool format /dev/${newdisk2}2 --force # <new disk's ESP partn>
time sync; sleep 2

proxmox-boot-tool init /dev/${newdisk1}2 $addgrub # <new disk's ESP partn>
proxmox-boot-tool init /dev/${newdisk2}2 $addgrub # <new disk's ESP partn>

proxmox-boot-tool refresh
set +x

zpool status rpool -v

echo '====='
echo "You should be able to boot with either disk now! After shutdown + remove old disks, run:"
echo " proxmox-boot-tool clean"
echo "and:"
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
