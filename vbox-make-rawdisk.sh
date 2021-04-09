#!/bin/bash

# EDITME - diskutil list 1st

# REF: https://www.serverwatch.com/server-tutorials/using-a-physical-hard-drive-with-a-virtualbox-vm.html
# REF: https://apple.stackexchange.com/questions/192292/how-to-do-raw-device-access-with-virtualbox

# REF: https://digitalsprouts.org/using-raw-disk-access-with-virtualbox-in-mac-os/

# NOTE - eject/umount diskXsX 1st!
# NOTE - may need to chown $USER or :admin /dev/diskX 1st

usedev=disk6

diskutil list /dev/$usedev

sudo chown root:admin /dev/$usedev
sudo chmod 660 /dev/$usedev

ls -al /dev/$usedev
VBoxManage internalcommands createrawvmdk -rawdisk /dev/$usedev -filename "$HOME/vbox-raw-sgtera2tb.vmdk"
ls -l ~/*.vmdk
