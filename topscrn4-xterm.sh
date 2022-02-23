#!/bin/bash

# Use: ssh -t localhost /home/dave/bin/topscrn4-xterm.sh

#chvt 10
#ff

# open 4-pane screen with sys monitoring
#setterm -blank 0 2>/dev/null

# if we try to throw it in the BG, get "screen must be connected to a terminal" error
TERM=linux screen -R -c $HOME/.screenrc-mon1-combined #&
#disown -a

