#!/bin/bash

#cd /mnt/toshtera10-xfs
#pwd

# XXX TODO EDITME
#isopath=/var/lib/vz/template/iso
isopath=/mnt/seatera4-xfs/template/iso

useiso=proxmox-ve_8.2-1.iso
answerfile=/root/proxmox-unattended-install.toml

echo "$(date) - Preparing $isopath/$useiso using $answerfile"
time proxmox-auto-install-assistant prepare-iso $isopath/$useiso --fetch-from iso --answer-file $answerfile

#ls -lrth |tail -n 5
#pwd

date;

exit;

# REF: https://pve.proxmox.com/wiki/Automated_Installation

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
