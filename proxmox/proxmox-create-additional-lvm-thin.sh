#!/bin/bash

# 2024.Dec kneutron

# This creates an ADDITIONAL lvm-thin on another disk/partition besides the one the PVE installer creates
# Avoids resizing and multiple LVM failures in non-RAID systems

# xxx TODO EDITME
declare -i lvmthins # integer
if [ "$1" = "" ]; then
  lvmthins=2
else
  lvmthins=$1
fi
# set to 3, etc if you already have more than 1

# failexit.mrg
# REF: https://sharats.me/posts/shell-script-best-practices/
function failexit () {
  echo '! Something failed! Code: '"$1 $2" >&2 # code (and optional description)
  exit $1
}

if [ "$1" = "0" ] || [ "$1" -lt 2 ]; then
  failexit 66 "Nice try - arg1 needs to be an integer number greater than 1"
fi

# xxx TODO EDITME
target=/dev/nvme0n1p6

echo '-- YOU NEED TO EDIT THIS SCRIPT BEFORE RUNNING IT --'
echo "About to create lvm-thin number: $lvmthins on $target - Enter to continue or ^C"
read -n 1

pvcreate $target
vgcreate -A y pvethin${lvmthins} $target
# pvethin2

#lvcreate -L 100G -n data pve
lvcreate -A y  --readahead auto \
 --name lvmthin${lvmthins}data --extent 99%FREE pvethin${lvmthins} || failexit 99 "Failed to lvcreate lvmthin${lvmthins}data on VG pvethin${lvmthins}"
# lvmthin2 , pvethin2

lvconvert --type thin-pool pvethin${lvmthins}/lvmthin${lvmthins}data || failexit 101 "Failed to convert pvethin${lvmthins}/lvmthin${lvmthins}data to lvm-thin"
# pvethin2 , lvmthin2

(pvs; vgs; lvs) |tee >/root/lvminfo.txt

# backup lvm config for DR - see man page
# In a default installation, each VG is backed up into a separate file bearing the name of the VG in the directory /etc/lvm/backup.
# It may also be useful to regularly back up the files in /etc/lvm.
vgcfgbackup

echo "Define storage in pve GUI as lvm-thin2"
