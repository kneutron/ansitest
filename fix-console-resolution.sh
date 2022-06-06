#!/bin/bash

# Run from tty1 or similar
# Good for VMs on 1920x1080 monitors
# sets the text console / tty to have more cols/lines
# helpful with topscrn4-10

# REQUIRES fbset
# REF: https://www.reddit.com/r/linuxadmin/comments/sefh94/cant_change_console_resolution/

[ -e /bin/fbset ] || apt-get -y install fbset

fbset -xres 1440 -yres 900
