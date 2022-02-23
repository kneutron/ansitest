#!/bin/bash

# This is useful with Maximized lxterminal, xfce4-terminal, etc where you can easily resize the font
# if using ssh Use: ssh -t localhost /$HOME/bin/topscrn4-xterm.sh

# open 4-pane screen with sys monitoring

# Requires: bwm-ng top screen iostat watch openvt/open
# Requires other files: dot-screenrc-mon1-combined ( renamed as .screenrc-mon1-combined in user's home dir )
# ^^ mon1-df-short in /usr/local/bin 

# if we try to throw it in the BG, get "screen must be connected to a terminal" error - must be FG
TERM=linux screen -R -c $HOME/.screenrc-mon1-combined 
