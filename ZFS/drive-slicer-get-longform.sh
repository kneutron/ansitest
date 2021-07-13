#!/bin/bash

# 2021 Dave Bechtel
# REQUIRES output file from zfs-drive-slicer.sh, sed, awk, grep, head

# Translate short-form disks
#sdb   sdc   sdd   sde   sdf   sdg   sdh   sdi   sdj   sdk   sdl   
# To long-form:
#pci-0000:00:16.0-sas-phy0-lun-0   pci-0000:00:16.0-sas-phy1-lun-0   pci-0000:00:16.0-sas-phy2-lun-0   pci-0000:00:16.0-sas-phy3-lun-0   pci-0000:00:16.0-sas-phy4-lun-0   pci-0000:00:16.0-sas-phy5-lun-0   pci-0000:00:16.0-sas-phy6-lun-0   pci-0000:00:16.0-sas-phy7-lun-0   pci-0000:00:16.0-sas-phy8-lun-0   pci-0000:00:16.0-sas-phy9-lun-0   pci-0000:00:16.0-sas-phy10-lun-0

# Useful when creating ZFS arrays
# Pseudocode:
# get zfs-drive-slicer output file
# use sed to delete line cont chars out
# read a line
## for every word in line; lookup + print dev/disk/by-path equivalent  no-newline
# at line end print line continuation char

DBP=/dev/disk/by-path
DBI=/dev/disk/by-id
usetype=$DBP
# ^^ TODO EDITME

# NOTE WARNING when using SAS disks we are NOT guaranteed an entry in disk-by-id!

infile=/tmp/zfsds.txt
[ "$1" = "" ] || infile="$1" # override, if 1st arg passed

sed -i 's/\\//g' "$infile"   # remove line-continuation chars

# set -x  ## DEBUG
while read inline; do
  for word in $inline; do
    printf $(ls -l $usetype |grep -w /$word |awk '{print $9}' |head -n 1)" "
  done
  echo ' \'
done < $infile
# NOTE ^^ this may be inaccurate, no error checking for missing disks, just print what we find

#lrwxrwxrwx 1 root root  9 Jul 12 23:10 pci-0000:00:16.0-sas-phy9-lun-0 -> ../../sdk
# 1         2 3    4     5 j   7  8     9
