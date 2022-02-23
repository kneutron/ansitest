#!/bin/bash

ff

useprog=open
[ -e `which openvt` ] && useprog=openvt
# open 4-pane screen on vt10
setterm -blank 0 2>/dev/null
( TERM=linux $useprog -f -c 10 -s -w -- /usr/bin/screen -S topscrn410 -c /root/.screenrc-mon1-combined ) &
