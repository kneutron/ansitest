#!/bin/bash

# 2025.Jan kneutron
# Expand raidz2 with 1-2 disks for more free space

# NOTE zfs-2.3.0-1 or higher is required!

# xxx TODO EDITME
usedisk=vdo
#usedisk=vdp # 2nd run, comment above line and uncomment thisline
zp=zraidz2expandtest

# zpool attach tank raidz2-0 sda
# REF: https://github.com/openzfs/zfs/pull/15022
# REF: https://arstechnica.com/gadgets/2021/06/raidz-expansion-code-lands-in-openzfs-master/

zpool status -v |awk 'NF>0'

echo '====='
echo "Enter to proceed expanding $zp with disk $usedisk / $(ls -l /dev/disk/by-path |grep $usedisk |head -n 1 |awk '{print $9}')"
echo " or ^C to stop"
read -n 1

time zpool attach $zp raidz2-0 $usedisk
#echo "PK to watch resilver"
#read
zfs-watchresilver-boojum.sh $zp

date
