#!/bin/bash

# 2021 Dave Bechtel - for testing ZFS DRAID 2.1.x
# create ZFS data disks and attach them to existing VM
# REF: http://www.allgoodbits.org/articles/view/54
# REF: https://superuser.com/questions/741734/virtualbox-how-can-i-add-mount-a-iso-image-file-from-command-line
#
# DO NOT RUN AS ROOT or it wont find the VM
# actually we create 96 + 8 hotspares JIC = 104; SAS drives start at number 25

##Check for root priviliges
if [ "$(id -u)" -eq 0 ]; then
   echo "Please do NOT run $0 as root."
   exit 1
fi

vmname=test-zfs-21-Draid--xfs

#VBoxManage createvm --name "$vmname" --ostype 'Linux_64' --basefolder "$HOME" --register
#VBoxManage modifyvm "$vmname" --description "NOTE this is just a temp VM used to conveniently register ISOs with vbox media manager - it was created with $0"

#VBoxManage storagectl $vmname --name IDE --add ide --controller piix3 --portcount 2 --bootable on
#VBoxManage storageattach "$vmname" --storagectl IDE --port 0 --device 0 --type dvddrive --medium emptydrive  #"X:\Folder\containing\the.iso"

#4,000,797,696 - must be evenly div.by 512 = sector size
nd=24
# root is already on port 0
port=1
function mkdisks () {
  for this in $(seq -w 01 $nd); do
    echo $PWD/${this}

# "Actual" 2TB - REF: https://www.virtualbox.org/manual/ch08.html#vboxmanage-createmedium
#    time VBoxManage createmedium disk --filename $PWD/zfs$this.vdi --sizebyte 2000398934016

# "Actual" 4GB - REF: https://www.virtualbox.org/manual/ch08.html#vboxmanage-createmedium
# NOTE want unique naming for backing storage or it gets to be a PITA deleting them from VMM
    time VBoxManage createmedium disk --filename $PWD/zfs$this-onT5.vdi --sizebyte 4000797696 # 400079786802
    VBoxManage storageattach "$vmname" --storagectl SATA --port $port --device 0 --type hdd --medium $PWD/zfs$this-onT5.vdi
    
    let port=$port+1
  done
}

mkdisks

# SAS controller, goin up to 128 ports
# shit, we have a constraint; 465GB SamT5 so max ~114x4GB disks; root is under 4GB and we need to leave freespace
pnd=$nd
nd=104 # we only use 96, (8) are pspares # evenly / 24
let startd=$pnd+1 # 79 more disks on SAS
echo "startd=$startd - nd=$nd"
port=0
function mkdiskSAS () {
  for this in $(seq -w $startd $nd); do
    echo $PWD/${this}

# "Actual" 2TB - REF: https://www.virtualbox.org/manual/ch08.html#vboxmanage-createmedium
#    time VBoxManage createmedium disk --filename $PWD/zfs$this.vdi --sizebyte 2000398934016

# "Actual" 4GB - REF: https://www.virtualbox.org/manual/ch08.html#vboxmanage-createmedium
    time VBoxManage createmedium disk --filename $PWD/zfs-SAS$this.vdi --sizebyte 4000797696
    VBoxManage storageattach "$vmname" --storagectl SAS --port $port --device 0 --type hdd --medium $PWD/zfs-SAS$this.vdi
    
    let port=$port+1
  done
}

mkdiskSAS

VBoxManage showvminfo "$vmname"
date

exit;
