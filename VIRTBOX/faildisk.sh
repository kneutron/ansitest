#!/bin/bash
# arg = shortname disk e.g. sdc , omit the /dev

echo "Failing $1"
echo offline > /sys/block/$1/device/state 
echo 1 > /sys/block/$1/device/delete 

sleep 2
dmesg|grep $1
