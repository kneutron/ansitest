#!/bin/bash

# this create an lvm-thin with the same naming scheme the proxmox installer uses

# xxx TODO EDITME
target=/dev/sda4

echo '*** YOU NEED TO EDIT THIS SCRIPT BEFORE RUNNING IT ***'
echo '*** AUTHOR IS NOT RESPONSIBLE FOR DATA LOSS!! ***'
echo ''
echo "About to create lvm-thin on $target - Enter to continue or ^C"
read

pvcreate $target
vgcreate -A y pve $target

#lvcreate -L 100G -n data pve
lvcreate -A y  --readahead auto \
 --name data --extent 99%FREE pve

lvconvert --type thin-pool pve/data

(pvs; vgs; lvs) |tee >/root/lvminfo.txt
echo "Define storage in pve GUI as local-lvm"
