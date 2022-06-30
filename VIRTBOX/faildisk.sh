#!/bin/bash
#d2f=$(ls -l /sys/dev/block |awk '/'$1'/ {print $9}')

echo "Failing $1"
echo offline > /sys/block/$1/device/state 
echo 1 > /sys/block/$1/device/delete 

sleep 2
dmesg|grep $1
