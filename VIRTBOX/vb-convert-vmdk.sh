#!/bin/bash

echo "o NOTE .vmdk must be removed from VM 1st!!"

# REF:  https://nfolamp.wordpress.com/2010/06/10/converting-vmdk-files-to-vdi-using-vboxmanage/

#VBoxManage clonehd --format VDI myserver.vmdk \
# VirtualBox/HardDisks/myserver.vdi

outdir=/Volumes/tmpdel/vmdisks
mkdir -pv $outdir

time VBoxManage clonehd --format VDI "$1" $outdir/"$1.to.vdi"
ls -alh $outdir/*
date

