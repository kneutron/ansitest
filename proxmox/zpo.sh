#!/bin/bash

# Bring a zfs file-backed mirror file online/offline to refresh/resilver the backup
# 2024.Jun kneutron

logf=~/rpool-online-offline-mirdisk.log

# change online/offline state of sshfs mirror disk for STABILITY and resilver updating
mirdisk=$(zpool status -v |grep rpool-mirror-.*zfs-efi.disk |awk '{print $1}')

if [ "$1" = "1" ]; then
# TODO add if-mounted test here
  echo "$(date) - Onlining rpool $mirdisk" |tee -a $logf
  (set -x; time zpool online rpool $mirdisk) 
  zfs-watchresilver-boojum.sh
else
  echo "$(date) - Offlining rpool $mirdisk" |tee -a $logf
  (set -x; time zpool offline rpool $mirdisk) 
fi

zpool status rpool -v |awk 'NF>0'
