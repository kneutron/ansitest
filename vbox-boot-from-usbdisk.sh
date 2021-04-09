#!/bin/bash

# NOTE this is OSX specific

# Linux version REF: https://www.ostechnix.com/how-to-boot-from-usb-drive-in-virtualbox-in-linux/
# REF: https://apple.stackexchange.com/questions/192292/how-to-do-raw-device-access-with-virtualbox
# REF: https://www.maketecheasier.com/boot-from-usb-drive-virtualbox/

diskutil list

mydisk="/dev/disk1"
myuser="dave"

#/dev/disk3 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
#   0:     FDisk_partition_scheme                        *8.1 GB     disk3
#   1:                  Apple_HFS Install macOS High S... 8.1 GB     disk3s1

diskutil unmount $mydisk''s1

echo "NOTE make sure $mydisk is unmounted partition in Disk Utility 1st! PK"
read -n 1


#VBoxManage internalcommands createrawvmdk -filename C:\extdisk.vmdk -rawdisk \\.\PhysicalDrive1

# create in home dir -- appears easier
cd # /Volumes/zmac/virtbox-virtmachines
[ -e usbdisk.vmdk ] && /bin/rm usbdisk.vmdk

sudo VBoxManage internalcommands createrawvmdk -filename usbdisk.vmdk -rawdisk $mydisk

sudo chown $myuser usbdisk.vmdk
sudo chown -R $myuser $mydisk* # ''s1

ls -al $mydisk*
#VBoxManage internalcommands listpartitions -rawdisk usbdisk.vmdk

cat << EOF

NOTE - the VM MUST have at least a dual-CPU!
MAKE SURE the VM has 128MB video RAM and ~2200-2300MB RAM

NOTE - you will probably have to re- chown $myuser $mydisk everytime you boot the VM!
( Use ' vbox-reown-usb-rawdisk.sh ' )

AND - as an additional pain in the ass, if the installer USB disk ID changes you have to REMOVE it FIRST
  in Vbox Global Tools BEFORE re-adding the usbdisk.vmdk to the VM 
  as Hotplug (SSD may not be nec)!!!
  
...and REMEMBER to Run DISK UTILITY **1st** (Erase) if the vbox HD is unformatted!  
This will allow Selecting it as the Startup disk.
  
Make sure General \ Basic \ Version is set to the right OS + Bits

Format with GPT table -- Try APFS + GPT ?? Vbox has problems booting from GPT + HFS+
REF: As of 2018.0519 : VirtualBox does not yet support HFS+ filesystems on GPT partitioned drives when starting from EFI.
REF: https://superuser.com/questions/964037/getting-uefi-shell-when-trying-to-boot-os-x-in-virtual-box

Disk Utility \ View \ All devices - format as MBR - does NOT work
  
EOF

diskutil unmount $mydisk''s1

pwd
ls -alh *.vmdk $mydisk*
