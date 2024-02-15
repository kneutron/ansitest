#!/bin/bash

# to convert existing virtualbox VDI disks to qcow2, for import into proxmox vm environment
# 2024 kneutron

# xxx TODO EDITME - this is the base dir for virtualbox / disk images
based="/zseatera4-f4m8/virtbox-virtmachines"
cd "$based" || exit 44;

# xxx TODO EDITME - this is where converted disks .qcow2 will go
dest=/mnt/seatera4-xfs

for disk in $(find  -name *.vdi |sed 's|^./||'); do 
  dirn=$(dirname "$disk")
  cd "$based/$dirn"; echo "HERE is: $PWD"
  
  diskn=$(basename "$disk")
  
#echo "dirn=$dirn"
#echo "disk=$disk"
#echo "diskn=$diskn"
  
  echo "$(date) - Converting $PWD $diskn" 
  time qemu-img convert -f vdi -O qcow2 "$PWD/$diskn" "$dest/$diskn.qcow2"
#  cd "$based"
done

ls -alh "$dest"
date
