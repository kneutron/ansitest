#!/bin/bash

# xxx TODO EDITME
target=/dev/sda4

pvcreate $target
vgcreate -A y pve $target

#lvcreate -L 100G -n data pve
lvcreate -A y  --readahead auto \
 --name data --extent 99%FREE pve

lvconvert --type thin-pool pve/data

(pvs; vgs; lvs) |tee >/root/lvminfo.txt
echo "Define storage in pve GUI as local-lvm"
