#!/bin/bash

# 2024.Dec kneutron

# This is script 2 of 2 - run the below one 1st to create the LXC
# https://github.com/kneutron/ansitest/blob/master/proxmox/proxmox-create-lxc-xrdp-icewm-thunderbird-debian.sh

# Goal: Setup Unprivileged LXC with Debian Standard 12, 2xvCPU (you can probably get away with 1), rootfs 10GB, RAM 1GB, 512MB Swap, IP = DHCP or static, DNS as appropriate

# REF: https://www.reddit.com/r/Proxmox/comments/1hayp1j/comment/m1ilo4n/?context=3


# Fire up LXC console after it builds, root login should already be there, no password needed: #

# Run this script INSIDE the running LXC, you may need to ' chmod +x ' it first

# (root) Cmds to accomplish everything:

# xxx TODO editme
myid=dave

apt update
apt upgrade -y

# SKIP #  apt install fluxbox # rdesktop clicking did nothing, so went with icewm

apt install -y icewm xterm xfce4-terminal

apt install -y xrdp

adduser xrdp ssl-cert

systemctl restart xrdp

apt install -y joe mc screen tmux vim

apt install -y thunderbird

# Requires input for passwd
adduser $myid
echo ''

#screen -aAO -h 2000

# =============

echo "Fire up rdesktop client / mstsc, point it to the below IP address, login as $myid"
echo "  You should see icewm minimal desktop with 4 virtual screens preconfigured."
echo ''
echo "Right-click the desktop, open Terminal, enter ' thunderbird & '"
echo '(or use the "Start" menu) and setup your email account(s).'

ip a

date;

# NOTE you can install e.g. fluxbox afterward to save RAM, and switching to it from icewm should work
