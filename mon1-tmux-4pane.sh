#!/bin/bash

tmux new-session \; \
  send-keys 'topp' C-m \; \
  split-window -v -p 70 \; \
  send-keys 'bwmm' C-m \; \
  split-window -v \; \
  send-keys 'ziostatt' C-m \; \
  select-pane -t 1 \; \
  split-window -h \; \
  send-keys 'watch -n 61 /home/dave/bin/mon1-df-short' C-m \;
