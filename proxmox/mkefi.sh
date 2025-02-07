#!/bin/bash

# 2025.Feb kneutron
# for zfsbootmenu
# run from systemrescuecd environment

# make new gpt partition and a 512MB EFI partition for zfsbootmenu
# AUTHOR TAKES NO RESPONSIBILITY FOR DATA LOSS - GET THE DISK RIGHT!!

# TODO EDITME - short devname only
drv=vda
[ "$1" = "" ] || drv=$1

fdisk -l /dev/$drv
echo "Enter to proceed with making EFI zfsmenu boot partition on /dev/$drv, or ^C"
echo "- SCRIPT AUTHOR TAKES NO RESPONSIBILITY FOR DATA LOSS -"
ecgi "GET THE DISK RIGHT - AND HAVE BACKUPS!!"
read 

parted /dev/$drv mklabel gpt
sync
parted --align optimal /dev/$drv mkpart primary fat16 1MiB 512MiB
sync
parted /dev/$drv set 1 boot on
sync
parted /dev/$drv name 1 zfsbootmenuefi
sync
gdisk -l /dev/$drv

echo "Enter to proceed with mkdosfs, or ^C"
read -n 1

mkdosfs -F 16 -n zfsbtmnu -v /dev/${drv}1
mkdir -pv /mnt/tmpefi
mount /dev/${drv}1 /mnt/tmpefi
ls -al /mnt/tmpefi

df -hT

echo 'Now you can cd to /mnt/tmpefi and run ~/get-latest-zfsbootmenu.sh'
