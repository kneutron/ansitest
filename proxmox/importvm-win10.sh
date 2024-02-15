#!/bin/bash

source ~/bin/failexit.mrg

# converted qcows from vbox
cd /mnt/seatera4-xfs

echo "Usage: \$1=name-of-vm \$2=RAM-in-GB"

if [ "$1" = "" ]; then
  failexit 101 "1st arg not supplied, must be VMNAME"
else
 newname="$1"
fi

#linux=126
#oldlinux=124

# integer / number
declare -i ram lastid newid

if [ "$2" = "" ]; then
 ram=4096
else
 ram=$2
fi

echo "$(date) - Getting last VM number"
lastid=$(qm list |tail -n 1 |awk '{print $1}')
date
# qm list
#      VMID NAME                 STATUS     MEM(MB)    BOOTDISK(GB) PID
#       100 lmde                 stopped    4096              21.00 0
#       101 pxenetboot           stopped    4096              21.00 0
#       103 win10-restore-from-vbox-choco stopped    6144              80.00 0
#       104 pfsense-272          running    1500              20.00 813250
 
let newid=$lastid+1 
echo "Last vmid: $lastid - New id: $newid -- RAM: $ram -- PK"
read -n 1       
       
# --ostype l26 \
# --boot order=scsi0 \
qm create $newid \
 --net0 e1000,bridge=vmbr2,firewall=0,link_down=0 \
 --name "$newname" \
 --scsihw virtio-scsi-single \
 --cores 2 --sockets 1 --cpu cputype=host \
 --bios ovmf \
 --ide2 none,media=cdrom \
 --memory $ram \
 --vga=virtio,memory=128 \
 --balloon 2048 \
 --start 0 \
 --boot order="ide2;sata0" \
 --ostype win11 \
 --sata0 zfs1:0,cache=writeback,import-from=$PWD/win11test-chocolatey-wsl2.vdi.qcow2 \
 --sata1 zfs1:0,cache=writeback,import-from=$PWD/win11test-chocolatey-wsl2-disk1.vdi.qcow2 \
|| failexit 40 "Failed to create VM $newid $newname"

qm list

exit;

          L, not One
--ostype <l24 | l26 | other | solaris | w2k | w2k3 | w2k8 | win10 | win11 | win7 | win8 | wvista | wxp>

400 Parameter verification failed.  
ostype: value '126' does not have a
value in the enumeration 'other, wxp, w2k, w2k3, w2k8, wvista, win7, win8,
win10, win11, l24, l26, solaris'
