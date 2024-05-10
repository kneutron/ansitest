#!/bin/bash

# Install veeam agent for linux for bare-metal backup/restore of root FS + LVM
# 2024.May kneutron

# NOTE you will also need to download the "veeam Linux Recovery Media" ISO to be able to Restore!
# https://www.veeam.com/download_add_packs/backup-agent-linux-free/recovery-64

# HOWTO video:
# REF: https://www.youtube.com/watch?v=g9J-mmoCLTs

# NOTE - WARNING - veeam only restores rootfs ext4 + LVM structure, does **NOT** restore LVM-thin!
# You still need to backup your VMs!

# Install veeam agent for linux 
apt update

apt install pve-headers-$(uname -r) squashfs-tools libisoburn1 xorriso
apt-get install linux-headers-$(uname -r)

# Needs to be already downloaded and in current dir
# https://www.veeam.com/linux-backup-free-download.html?sec=linux-backup-free-download.html&subsec=&part=&item=
dpkg -i veeam-release*deb

apt update
apt install -y veeam 

# run the backup setup program TUI
veeam

exit;

# to start backup job out of schedule:
# veeamconfig job start --name "BackupJob1"

NOTE veeam does NOT allow restore to a smaller disk - fsarchiver does!
e.g. if you backed up a 256GB boot disk, you cannot restore your root + LVM with veeam to a 128GB disk!
