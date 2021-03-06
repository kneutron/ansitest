#!/bin/bash

# 2021 Dave Bechtel
# for 1440x900

# Setup 4 xterms for monitoring I/O for (90) drives
# Used ' xwininfo ' to get geom
# Occupy-all

cmdstr="iostat -k 5 --dec=0 -y -z sd{a..z}"
xterm -bg black -fg green -sl 2000 -rightbar -geometry 72x33+0+31 \
 -name IOSTAT \
 -e "$cmdstr" &

cmdstr="iostat -k 5 --dec=0 -y -z sda{a..z}"
xterm -bg black -fg green -sl 2000 -rightbar -geometry 72x33+0-0 \
 -name IOSTAT \
 -e "$cmdstr" &

cmdstr="iostat -k 5 --dec=0 -y -z sdb{a..z}"
xterm -bg black -fg green -sl 2000 -rightbar -geometry 72x33-0+31 \
 -name IOSTAT \
 -e "$cmdstr" &

cmdstr="iostat -k 5 --dec=0 -y -z sdc{a..z}"
xterm -bg black -fg green -sl 2000 -rightbar -geometry 72x33-0-0 \
 -name IOSTAT \
 -e "$cmdstr" &


cmdstr='bwm 2' # Check for bwm-ng and use it if there 
[ -e /usr/bin/bwm-ng ] && cmdstr='bwm-ng -t 2000'
xterm -bg black -fg green -sl 1 -rightbar -geometry 80x13+536+0 \
 -name monbwm \
 -e $cmdstr &

cmdstr="watch -n 5 /sbin/zpool status -v|awk 'NF>0'"
xterm -bg black -fg green -sl 1 -rightbar -geometry 92x57+434-28 \
 -name zps \
 -e $cmdstr &
