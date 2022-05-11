#!/bin/bash

# This is a nice little hack to create a dummy VM and attach known ISOs to it to populate Media Manager
# REF: http://www.allgoodbits.org/articles/view/54
# REF: https://superuser.com/questions/741734/virtualbox-how-can-i-add-mount-a-iso-image-file-from-command-line

vmname=dummyisofinder

VBoxManage createvm --name "$vmname" --ostype 'Linux_64' --basefolder "$HOME" --register
VBoxManage modifyvm "$vmname" --description "NOTE this is just a temp VM used to conveniently register ISOs with vbox media manager - it was created with $0"

VBoxManage storagectl $vmname --name IDE --add ide --controller piix3 --portcount 2 --bootable on
#VBoxManage storageattach "$vmname" --storagectl IDE --port 0 --device 0 --type dvddrive --medium emptydrive  #"X:\Folder\containing\the.iso"
#VBoxManage showvminfo "$vmname"

function registeriso () {
  for this in *.iso; do
    echo $PWD/${this}
    VBoxManage storageattach "$vmname" --storagectl IDE --port 0 --device 0 --type dvddrive --medium $PWD/${this}
#  VBoxManage modifyvm $vmname --dvd $PWD/${this}
  done
}

# xxx TODO EDITME, this is where your ISOs live
cd /Volumes/zsgtera4/shrcompr-zsgt2B/ISO && registeriso

# shared drive, use if mounted
if [ $(df |grep /mnt/imac5 |wc -l) -gt 0 ]; then
  cd /mnt/imac5/ISO
  registeriso
fi

# eject
VBoxManage storageattach "$vmname" --storagectl IDE --port 0 --device 0 --type dvddrive --medium emptydrive 

exit;

# 2021 Dave Bechtel
