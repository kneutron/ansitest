#!/bin/bash

# OSX - gdd
# Mod for RAID10 test (replace 4TB with 6TB HGST) == OK
# REF: https://www.reddit.com/r/zfs/comments/fwv7ky/help_expanding_zfs_mirror/

# make sure mirror is not degraded when replacing disks with larger sizes

source ~/bin/failexit.mrg 
logfile=~/zpool-resizeup-mirror.log

cd /Users/dave

zp=ztestpool

disk1=zdisk1
disk2=zdisk2
disk3=zdisk3
disk4=zdisk4
disk5=zdisk5L
disk6=zdisk6L

ddp=dd
[ -e /usr/local/bin/gdd ] && ddp=gdd

# Note hfs+ DOES NOT support sparse files
function mkdisks () {
  echo "Checking exist / creating pool $zp disks"
  [ -e $disk1 ] || time $ddp if=/dev/zero of=$disk1 bs=1M count=1024
  [ -e $disk2 ] || time $ddp if=/dev/zero of=$disk2 bs=1M count=1024
  [ -e $disk3 ] || time $ddp if=/dev/zero of=$disk3 bs=1M count=1024
  [ -e $disk4 ] || time $ddp if=/dev/zero of=$disk4 bs=1M count=1024
  [ -e $disk5 ] || time $ddp if=/dev/zero of=$disk5 bs=1M count=2048
  [ -e $disk6 ] || time $ddp if=/dev/zero of=$disk6 bs=1M count=2048
  ls -alh

# only if not exist
[ `echo $(zpool list|grep -c $zp)` -ge 1 ] || \
  time zpool create -o ashift=12 -o autoexpand=on -O atime=off -O compression=lz4 $zp \
    mirror $PWD/$disk1 $PWD/$disk2 \
    mirror $PWD/$disk3 $PWD/$disk4 \
    || failexit 101 "Cant create zpool $zp"

echo "Populating $zp with data"
  time cp -v /Volumes/zsgtera2B/shrcompr-zsgt2B/ISO/bl-Helium_i386_cdsized+build2.iso /Volumes/$zp \
  || failexit 102 "Copy file to pool $zp fail"
} #END FUNC

function zps () {
  zpool status -v $zp |awk 'NF > 0'
  zpool list -v
}

mkdisks # comment me if nec

zps |tee -a $logfile

echo "PK to attach larger disks ONE AT A TIME to 1st mirror-0"
read -n 1

# REF: https://docs.oracle.com/cd/E19253-01/819-5461/gcfhe/index.html

time zpool attach $zp $PWD/$disk1 $PWD/$disk5 || failexit 103 "zpool attach disk5 fail"
zfs-watchresilver-boojum.sh

time zpool attach $zp $PWD/$disk2 $PWD/$disk6 || failexit 104 "zpool attach disk6 fail"
zfs-watchresilver-boojum.sh

zps |tee -a $logfile

gdf -hT |tee -a $logfile

echo "PK to detach smaller mirror disks and increase pool size"
read -n 1

time zpool detach $zp $PWD/$disk1
time zpool detach $zp $PWD/$disk2

zps |tee -a $logfile

gdf -hT |tee -a $logfile
