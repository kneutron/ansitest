#!/bin/bash

#ff # fix fontsize

# Requires: bwm-ng top screen iostat watch openvt/open
# Requires other files: dot-screenrc-mon1-combined ( renamed as .screenrc-mon1-combined in root's home dir )
# ^^ mon1-df-short in /usr/local/bin or $HOME/bin

useprog=open
[ -e `which openvt` ] && useprog=openvt

# turn off screensaver
setterm -blank 0 2>/dev/null

# open 4-pane screen on vt10 and switch to it
( TERM=linux $useprog -f -c 10 -s -w -- /usr/bin/screen -S topscrn410 -c /root/.screenrc-mon1-combined ) &
disown -a
