#!/bin/bash

# TODO EDITME do not run blind

exit;

# This is for when you have a 64GB 'dd' backup and want to access the partitions without restoring to original media

zp=zseatera2
size=64 # GB
zfs create -sV "$size"g $zp/zvol01

fdisk -l /dev/zvol/$zp/zvol01
 
# mount /dev/zvol/zseatera2/zvol01p5 /mnt/tmp
#mount: special device /dev/zvol/zseatera2/zvol01p5 does not exist

#FIX: REF: https://www.golinuxcloud.com/losetup-command-in-linux/#1_Create_a_loop_device_with_losetup
losetup -P -f /dev/zvol/$zp/zvol01      # need -P for partitions

losetup
#NAME       SIZELIMIT OFFSET AUTOCLEAR RO BACK-FILE DIO
#/dev/loop0         0      0         0  0 /dev/zd0    0


mydev=$(losetup |grep zd0 |awk '{print $1}')
fdisk -l $mydev   # /dev/loop0

mkdir -pv /mnt/tmp
mount /dev/"$mydev"p5 /mnt/tmp -oro # rw,noatime
