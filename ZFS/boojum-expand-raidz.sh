#!/bin/bash

# 2025.Jan kneutron
# Expand raidz with 1-2 disks for more free space

echo "o NOTE zfs-2.3.0-1 or higher is required!"
zfs -V

# checkver
# zfs -V |head -n 1 |tr -d 'zfs-' |tr -d '.-'
#2301

# xxx TODO EDITME
usedisk=vdg
#usedisk=vdh # 2nd run, comment above and uncomment thisline
zp=zraidzexpandtest

# zpool attach tank raidz1-0 sda
# REF: https://github.com/openzfs/zfs/pull/15022
# REF: https://arstechnica.com/gadgets/2021/06/raidz-expansion-code-lands-in-openzfs-master/

zpool status -v |awk 'NF>0'

echo '====='
echo "Enter to proceed expanding $zp with disk $usedisk / $(ls -l /dev/disk/by-path |grep $usedisk |head -n 1 |awk '{print $9}')"
read -n 1

time zpool attach $zp raidz1-0 $usedisk
echo "Enter to watch resilver or ^C"
read
zfs-watchresilver-boojum.sh

date
