#!/bin/bash

# TODO EDITME do not run blind

exit;


zfs create -sV 64g zseatera2/zvol01

fdisk -l /dev/zvol/zseatera2/zvol01
 
# mount /dev/zvol/zseatera2/zvol01p5 /mnt/tmp
#mount: special device /dev/zvol/zseatera2/zvol01p5 does not exist

#FIX: REF: https://www.golinuxcloud.com/losetup-command-in-linux/#1_Create_a_loop_device_with_losetup
losetup -P -f /dev/zvol/zseatera2/zvol01      # need -P for partitions

losetup
#NAME       SIZELIMIT OFFSET AUTOCLEAR RO BACK-FILE DIO
#/dev/loop0         0      0         0  0 /dev/zd0    0

fdisk -l /dev/loop0

mount /dev/loop0p5 /mnt/tmp -onoatime
