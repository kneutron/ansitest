#!/bin/bash

# REF: https://pve.proxmox.com/wiki/Recover_From_Grub_Failure

# TODO EDITME before running if disk devices are different (nvme, etc)
vgscan
vgchange -a y

#Mount all the filesystems that are already there so we can upgrade/install grub. Your paths may vary depending on your drive configuration.

mkdir /media/RESCUE
mount /dev/pve/root /media/RESCUE/

# EDITME
mount /dev/sda1 /media/RESCUE/boot

mount -t proc proc /media/RESCUE/proc
mount -t sysfs sys /media/RESCUE/sys
mount -o bind /dev /media/RESCUE/dev
mount -o bind /run /media/RESCUE/run

# Chroot into your proxmox install.

chroot /media/RESCUE
#Then update grub and install it.

update-grub
grub-install /dev/sda
# ^ EDITME
