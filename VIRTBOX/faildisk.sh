#!/bin/bash
# arg = shortname disk e.g. sdc , omit the /dev

# Primarily used in ZFS VM to simulate disk failures in a zpool / test RAIDZx / DRAID recovery scenarios
# NOTE rebooting will fix the failed disks

echo "Failing $1"
echo offline > /sys/block/$1/device/state 
echo 1 > /sys/block/$1/device/delete 

sleep 2
dmesg|grep $1
