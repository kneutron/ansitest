#!/bin/bash

# 2025.Jan kneutron

echo "o NOTE zfs-2.3.0-1 or higher is required!"
zfs -V

# vdi..p avail for pool2
zp=zraidz2expandtest

zpool create -o ashift=12 -o autoexpand=on -o autoreplace=off -O atime=off -O compression=lz4 \
  $zp raidz2 \
  vd{i..n} 
  
zpool list -v
zpool status -v |awk 'NF>0'
  