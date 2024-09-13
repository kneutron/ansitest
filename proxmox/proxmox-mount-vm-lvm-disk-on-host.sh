#!/bin/bash

# REF: https://forum.proxmox.com/threads/filled-up-disk-and-cannot-boot.148515/

exit;

#First I have to mount disk in loopback:

losetup --partscan -f /dev/mapper/pve-vm--200--disk--0

#then i could activate the vg:

vgchange -ay ubuntu-vg

#then i could mount the lv:

mount /dev/mapper/ubuntu--vg-ubuntu--lv /mnt
