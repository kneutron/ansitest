#!/bin/bash

based="/zseatera4-f4m8/virtbox-virtmachines"
cd "$based" || exit 44;

dest=/mnt/seatera4-xfs

for disk in $(find  -name *.vdi |sed 's|^./||'); do 
  dirn=$(dirname "$disk")
  cd "$based/$dirn"; echo "HERE is: $PWD"
  
  diskn=$(basename "$disk")
  
echo "dirn=$dirn"
echo "disk=$disk"
echo "diskn=$diskn"
  
  echo "$(date) - Convert $PWD $diskn" 
  time qemu-img convert -f vdi -O qcow2 "$PWD/$diskn" "$dest/$diskn.qcow2"
#  cd "$based"
done

ls -alh "$dest"
date
