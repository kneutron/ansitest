#!/bin/bash

# 2024.mar kneutron
# Works on almalinux 9

# Target disk
# TODO EDITME - maybe better to use partition instead of whole device
tdisk="pci-0000:06:0b.0-part1" # -> ../../vdb1

# REF: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html-single/deduplicating_and_compressing_logical_volumes_on_rhel/index

# NOTE Starting with RHEL 9, VDO can only be managed using LVM tools


#Replace logical-size with the amount of logical storage that the VDO volume should present:

#For active VMs or container storage, use logical size that is ten times the
#physical size of your block device.  For example, if your block device is
# 1TB in size, use 10T here.

#For object storage, use logical size that is three times the physical size
# of your block device.  For example, if your block device is 1TB in size, use 3T here.

modprobe kvdo

# TODO EDITME 
vdoname=vdotest

# TODO EDITME physical disk size 128G
let pdisk=128-1 # GB
# NOTE if we dont do -1 get insufficient free extents error

lsize=$(echo $[$pdisk * 3])

set -x -u
# RHEL8
#time vdo create --name=$vdoname \
#   --device=/dev/disk/by-path/pci-0000:06:0b.0-part1  \
#   --vdoLogicalSize=${lsize}G --writePolicy=async

# RHEL9
vgcreate $vdoname-vg "/dev/disk/by-path/$tdisk" # pci-0000:06:0b.0-part1

lvcreate --type vdo -n $vdoname-lv -L ${pdisk}G -V ${lsize}G $vdoname-vg/vdo-pool1

# vdotest--vg-vdotest--lv -> ../dm-4
time mkfs.xfs -K /dev/mapper/$vdoname--vg-$vdoname--lv

echo "$(date) - waiting for Godot"   
time udevadm settle
date

systemctl enable --now fstrim.timer # auto once a week

mkdir -pv /mnt/vdo1
mount /dev/mapper/$vdoname--vg-$vdoname--lv /mnt/vdo1 -odefaults,noatime

set +x
echo ''
df -hT /mnt/vdo1
echo ''
echo "fstab:
/dev/mapper/$vdoname--vg-$vdoname--lv  mount-point  xfs  defaults,noatime 0 0"
echo ''
vdostats --human-readable
