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


xterm -bg black -fg green -rightbar -geometry 104x29-0-33 \
 -name mondf \
 -e "watch -n 61 'df -T -h |grep -v tmpfs'" &


# 4MAC      
xterm -bg black -fg green -rightbar -geometry 61x24+1092+0 \
 -name mac-tempwatch \
 -e ~/bin/mac-tempwatch.sh &

# switch to virtual desktop #2
sleep 1; wmctrl -s 1; mon96.sh
