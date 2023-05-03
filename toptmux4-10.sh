#!/bin/bash

ff

useprog=open
[ -e `which openvt` ] && useprog=openvt
# open 4-pane screen on vt10
setterm -blank 0 2>/dev/null

#( TERM=linux $useprog -f -c 10 -s -w -- /usr/bin/tmux -S topscrn410 -c /root/.screenrc-mon1-combined ) &
( TERM=linux $useprog -f -c 10 -s -w -- /opt/local/bin/tmux -S topTM410 tmux new-session \; \
  send-keys 'top -d15' C-m \; \
  split-window -v \; \
  send-keys 'bwm-ng -t 2000' C-m \; \
  split-window -h \; \
  send-keys 'iostat -k 5' C-m \;
  split-window -h \; \
  send-keys 'watch -n 61 /Users/dave/bin/mon1-df-short' ) &
