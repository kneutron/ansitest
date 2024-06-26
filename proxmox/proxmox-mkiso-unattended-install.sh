#!/bin/bash

# Remaster a proxmox installer ISO with a self-contained answerfile
# 2024.Apr kneutron
# Feature: Now downloads the ISO for you if not exist

# XXX TODO EDIT the .toml file before running this!

# XXX TODO EDITME
isopath=/var/lib/vz/template/iso
#isopath=/mnt/seatera4-xfs/template/iso

useiso=proxmox-ve_8.2-1.iso

# bash if not
if [ ! -e "$isopath/$useiso" ]; then
  (cd $isopath; wget --no-clobber https://enterprise.proxmox.com/iso/$useiso)
fi 

# TODO changeme if needed
answerfile=/root/proxmox-unattended-install.toml

[ $(dpkg -l |grep -c proxmox-auto-install-assistant) -gt 0 ] || apt install -y proxmox-auto-install-assistant

echo "$(date) - Preparing $isopath/$useiso using $answerfile"
time proxmox-auto-install-assistant prepare-iso $isopath/$useiso --fetch-from iso --answer-file $answerfile

date;

exit;

# REF: https://pve.proxmox.com/wiki/Automated_Installation

# Final ISO is available at "/mnt/seatera4-xfs/template/iso/proxmox-ve_8.2-1-auto-from-iso.iso".

# test vm config for pve install
BEGIN /etc/pve/qemu-server/126.conf 
balloon: 2048
bios: ovmf
boot: order=virtio0;ide2
cores: 2
cpu: host,flags=+aes
efidisk0: local-lvm:vm-126-disk-0,efitype=4m,pre-enrolled-keys=1,size=4M
ide2: dir1:iso/proxmox-ve_8.2-1-auto-from-iso.iso,media=cdrom,size=1364160K
machine: q35
memory: 4096
meta: creation-qemu=8.1.5,ctime=1714504207
name: pve-test-unattended-install
net0: virtio=BC:24:11:B5:12:C2,bridge=vmbr0,queues=2
numa: 0
ostype: l26
scsihw: virtio-scsi-single
smbios1: uuid=0fc8815d-9727-480f-818c-0f390b19f8c7
sockets: 1
tablet: 0
vga: virtio
virtio0: tosh10-xfs-multi:126/vm-126-disk-0.qcow2,backup=0,cache=writeback,discard=on,iothread=1,size=256G
