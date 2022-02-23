#!/bin/bash

#ff # fix fontsize

# Requires: bwm-ng top screen iostat watch openvt/open

useprog=open
[ -e `which openvt` ] && useprog=openvt

# turn off screensaver
setterm -blank 0 2>/dev/null

# open 4-pane screen on vt10 and switch to it
( TERM=linux $useprog -f -c 10 -s -w -- /usr/bin/screen -S topscrn410 -c /root/.screenrc-mon1-combined ) &
disown -a
