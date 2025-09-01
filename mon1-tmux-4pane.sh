#!/bin/bash

# REQUIRES: tmux bwm-ng sysstat

tmux new-session \; \
  send-keys 'top -d 7' C-m \; \
  split-window -v -p 70 \; \
  send-keys 'bwm-ng -t 2000' C-m \; \
  split-window -v \; \
  send-keys 'S_COLORS=never iostat -k 5 -s -y -z' C-m \; \
  select-pane -t 1 \; \
  split-window -h \; \
  send-keys 'watch -n 61 /usr/local/bin/mon1-df-short' C-m \;
