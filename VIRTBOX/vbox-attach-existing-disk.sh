#!/bin/bash

# REF:https://serverfault.com/questions/171665/how-to-attach-a-virtual-hard-disk-using-vboxmanage

# VBoxManage storageattach my-vm-name \
#                         --storagectl "SATA Controller" \
#                         --device 0 \
#                         --port 0 \
#                         --type hdd \
#                         --medium /path/to/my-new.vdi
 
VBoxManage list vms
echo 'Paste vmname'
read myvmname

# EDITME
diskk=""

VBoxManage storageattach $myvmname \
                         --storagectl "SATA" \
                         --device 0 \
                         --port 0 \
                         --type hdd \
                         --medium $diskk
                         