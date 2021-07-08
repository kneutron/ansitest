#!/bin/bash

# for 1440x900
# Useful to monitor I/O for ZFS 96 disks

# For icewm all-desktops - see ~/.icewm/winoptions 
#http://www.osnews.com/story.php/7774/IceWM--The-Cool-Window-Manager/page5/

# Setup 3 xxterms for monitoring on 2ndary scrn
# Used ' xwininfo ' to get geom
# Occupy-all

xterm -bg black -fg green -sl 1 -rightbar -geometry 87x29+0+0 \
 -name montop \
 -e top -d 7&

#cmdstr='bwm 2' # Check for bwm-ng and use it if there 
#[ -e /usr/bin/bwm-ng ] && cmdstr='bwm-ng -t 2000'
#xterm -bg black -fg green -sl 1 -rightbar -geometry 80x17-0+0 \
#xterm -bg black -fg green -sl 1 -rightbar -geometry 80x17+488+0 \
#xterm -bg black -fg green -sl 1 -rightbar -geometry 80x13+536+0 \
# -name monbwm \
# -e $cmdstr &

#-geometry 80x26+1772+0
# linux mint 11
#xterm -bg black -fg green -sl 2000 -rightbar -geometry 69x24-0+0 \
# -name mondf \
# -e watch --no-title -n 61 df -T -h -x{tmpfs,usbfs,devtmpfs,debugfs} &

# linux mint 13
#xterm -bg black -fg green -rightbar -geometry 92x20-0+180 \
#xterm -bg black -fg green -rightbar -geometry 92x23-0+180 \
#xterm -bg black -fg green -rightbar -geometry 84x29--14-26 \
xterm -bg black -fg green -rightbar -geometry 104x29-0-33 \
 -name mondf \
 -e "watch -n 61 'df -T -h |grep -v tmpfs'" &
# -e "watch -n 61 df -T -h -x {tmpfs,usbfs,devtmpfs,debugfs}" &
# -e watch --no-title -n 61 df -h&
#   Corners:  +931+24  -1+24  -1-560  +931-560
#  -geometry 84x24-0+0

# IOSTAT for vmware-lvm
# Check for debian vs ubuntu
#cmdstr='iostat 5 -k'
#[ -e /usr/bin/iceweasel ] && cmdstr='iostat -k 5 sd{a,b,c,d,e,f,g,h,i,j,k,l,m}'
#xterm -bg black -fg green -sl 2000 -rightbar -geometry 74x24-0+345 \
#xterm -bg black -fg green -sl 2000 -rightbar -geometry 74x31-0-22 \
#xterm -bg black -fg green -sl 2000 -rightbar -geometry 72x33-0+0 \
# -name IOSTAT \
# -e "$cmdstr" &
#    Corners:  +955+369  -1+369  -1-215  +955-215
#    -geometry 80x24-0+345

# 4MAC      
xterm -bg black -fg green -rightbar -geometry 61x24+1092+0 \
 -name mac-tempwatch \
 -e ~/bin/mac-tempwatch.sh &

# switch to virtual desktop #2
sleep 1; wmctrl -s 1; mon96.sh
