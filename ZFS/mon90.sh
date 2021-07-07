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
#    Corners:  +955+369  -1+369  -1-215  +955-215
#    -geometry 80x24-0+345

cmdstr="iostat -k 5 --dec=0 -y -z sda{a..z}"
xterm -bg black -fg green -sl 2000 -rightbar -geometry 72x33+0-0 \
 -name IOSTAT \
 -e "$cmdstr" &
#    Corners:  +955+369  -1+369  -1-215  +955-215
#    -geometry 80x24-0+345

cmdstr="iostat -k 5 --dec=0 -y -z sdb{a..z}"
xterm -bg black -fg green -sl 2000 -rightbar -geometry 72x33-0+31 \
 -name IOSTAT \
 -e "$cmdstr" &
#    Corners:  +955+369  -1+369  -1-215  +955-215
#    -geometry 80x24-0+345

cmdstr="iostat -k 5 --dec=0 -y -z sdc{a..z}"
xterm -bg black -fg green -sl 2000 -rightbar -geometry 72x33-0-0 \
 -name IOSTAT \
 -e "$cmdstr" &
#    Corners:  +955+369  -1+369  -1-215  +955-215
#    -geometry 80x24-0+345

