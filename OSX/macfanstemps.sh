#!/bin/bash

outfile=/tmp/macfans.txt

source ~/bin/failexit.mrg

cd /sys/devices/platform/applesmc.768 || failexit 101 "Apple SMC fan control not found!"

# set fan speed
echo 3000 >fan3_min

(for fyl in fan*; do echo $fyl `cat $fyl`;done) > $outfile

sensors -f >> $outfile

tail -n 20 /var/log/macfanctl.log >> $outfile

less $outfile

