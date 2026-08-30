#!/bin/bash

# this create an lvm-thin with the same naming scheme the proxmox installer uses

# xxx TODO EDITME
target=/dev/sdd1
devonly=${target%1}

smartctl -a $devonly |head -n 20
echo ''
fdisk -l $devonly
echo '
====='

echo '*** YOU NEED TO EDIT THIS SCRIPT BEFORE RUNNING IT ***'
echo '*** AUTHOR IS NOT RESPONSIBLE FOR DATA LOSS!! ***'
echo ''
echo "About to create lvm-thin on $target - Enter to continue or ^C"
read

pvcreate $target
vgcreate -A y pve $target

#lvcreate -L 100G -n data pve
lvcreate -A y  --readahead auto \
 --name data --thin --extent 99%FREE pve

#lvconvert --type thin-pool pve/data

(pvs; vgs; lvs) |tee >/root/lvminfo.txt
# backup lvm config for DR - see man page
# In a default installation, each VG is backed up into a separate file bearing the name of the VG in the directory /etc/lvm/backup.
# It may also be useful to regularly back up the files in /etc/lvm.
vgcfgbackup

echo "$(date) - Defining storage in pve GUI as local-lvm"
#pvesm add lvmthin your_storage_id --content images,rootdir --vgname your_vg_name --thinpool your_lv_name
pvesm add lvmthin local-lvm --content images,rootdir --vgname pve --thinpool data

#your_storage_id: A unique identifier for this storage in Proxmox.
#--content images,rootdir: Specifies what kind of content this storage will hold (e.g., virtual machine disk images and container root directories). You can adjust this as needed.
#--vgname your_vg_name: The name of the volume group where the thin pool resides.
#--thinpool your_lv_name: The name of the logical volume that is the thin pool.

ls -lh /root/lvminfo.txt
