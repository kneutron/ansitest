#!/bin/bash

# OSX version - use gdd and gdf from brew/macports
# Proof of concept with file-backed pool
# Mod for RAID10 test (replace 4TB with 6TB HGST) == OK
# REF: https://www.reddit.com/r/zfs/comments/fwv7ky/help_expanding_zfs_mirror/

# make sure mirror is not degraded when replacing disks with larger sizes

#source ~/bin/failexit.mrg 
# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

logfile=~/zpool-resizeup-mirror.log

cd /Users/dave
# xxx TODO EDITME, primary user and this is where the disks will be created

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
[ $(zpool list|grep -c $zp) -ge 1 ] || \
  time zpool create -o ashift=12 -o autoexpand=on -O atime=off -O compression=lz4 $zp \
    mirror $PWD/$disk1 $PWD/$disk2 \
    mirror $PWD/$disk3 $PWD/$disk4 \
    || failexit 101 "Cant create zpool $zp"

# xxx TODO EDITME
echo "Populating $zp with data"
  time cp -v /Volumes/zsgtera4/shrcompr-zsgt2B/ISO/bl-Helium_i386_cdsized+build2.iso /Volumes/$zp \
  || failexit 102 "Copy file to pool $zp failed"
} #END FUNC

function zps () {
  zpool status -v $zp |awk 'NF > 0'
  zpool list -v
}

mkdisks # comment me if nec

# wait4resilver.mrg
function wait4resilver () {
  sdate=$(date)
# do forever
  while :; do
    clear
  
    echo "Pool: $1 - NOW: $(date) -- Watchresilver started: $sdate"
    zpool status $1 |grep -A 2 'resilver in progress' || break 2
    zpool iostat -v -y $1 2 3 &
    sleep 9
    date
  done

  ndate=$(date)

  zpool status -v $1
  echo "o Resilver watch $1 start: $sdate // Completed: $ndate"
}

zps |tee -a $logfile

echo "PK to attach larger disks ONE AT A TIME to 1st mirror-0"
read -n 1

# REF: https://docs.oracle.com/cd/E19253-01/819-5461/gcfhe/index.html

time zpool attach $zp $PWD/$disk1 $PWD/$disk5 || failexit 103 "zpool attach disk5 fail"
#zfs-watchresilver-boojum.sh
wait4resilver

time zpool attach $zp $PWD/$disk2 $PWD/$disk6 || failexit 104 "zpool attach disk6 fail"
wait4resilver

zps |tee -a $logfile

gdf -hT |tee -a $logfile

echo "PK to detach smaller mirror disks and increase pool size"
read -n 1

time zpool detach $zp $PWD/$disk1
time zpool detach $zp $PWD/$disk2

zps |tee -a $logfile

gdf -hT |tee -a $logfile
