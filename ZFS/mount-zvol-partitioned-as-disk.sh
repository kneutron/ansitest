#!/bin/bash

# TODO EDITME do not run blind

exit;

# This is for when you have a 64GB 'dd' backup and want to access the partitions without restoring to original media
# dd if=/dev/sdXX of=dd-pny-64gig-b4-reimage-with-memtest-20221108.dd bs=1M

zp=zseatera2
size=64 # GB
zfs create -sV "$size"g $zp/zvol01

# restore to compressed zvol (compression is inherited from pool level but can be set OTF)
# zfs set compression=zstd-3 $zp/zvol01
# time dd if=dd-pny-64gig-b4-reimage-with-memtest-20221108.dd of=/dev/zvol/$zp/zvol01 bs=1M

fdisk -l /dev/zvol/$zp/zvol01

# ISSUE:
# mount /dev/zvol/zseatera2/zvol01p5 /mnt/tmp
#mount: special device /dev/zvol/zseatera2/zvol01p5 does not exist

#FIX: REF: https://www.golinuxcloud.com/losetup-command-in-linux/#1_Create_a_loop_device_with_losetup
losetup -P -f /dev/zvol/$zp/zvol01      # need -P for partitions

losetup
#NAME       SIZELIMIT OFFSET AUTOCLEAR RO BACK-FILE DIO
#/dev/loop0         0      0         0  0 /dev/zd0    0

# TODO grep ls /dev/zvol/$zp/zvol01 for the right one, its a symlink
mydev=$(losetup |grep zd0 |awk '{print $1}')
fdisk -l $mydev   # /dev/loop0

mkdir -pv /mnt/tmp
mount /dev/"$mydev"p5 /mnt/tmp -oro # rw,noatime
