#!/bin/bash

# Keep firewire dock drives spinning or they go to sleep WAY too fast

# TODO check 1st char Z = zpool, otherwise check all mounted fs for existing file and poke dem

# easy way
#zp=zredtera1

#zp=`zfs list -H -d 0 |awk '{print $1}'`
#zmac5int
#zsgtera2

# KDS format = /zredtera1/.keepThisDriveSpinning
# 2019-05-05 16:10:49 CDT

PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/games:/usr/games:/root/bin:/root/bin/boojum:/usr/X11R6/bin:/usr/NX/bin:

while [ true ]; do
  mydate=`date +%Y-%m-%d" "%R":"%S" "%Z`
# 2019-05-05 16:53:07 CDT

  for zr in `zfs list -H -d 0 |awk '{print $1}'`; do
    echo $mydate > /$zr/.keepThisDriveSpinning
  done
  sleep 60
done

# 2019.0607 TODO do one better - change OTF
