#!/bin/bash

# 2024.Dec kneutron

# REF: https://www.reddit.com/r/Proxmox/comments/1hayp1j/comment/m1ilo4n/?context=3

# Setup Unprivileged LXC with Debian Standard 12, 2xvCPU (you can probably get away with 1), rootfs 10GB, RAM 2GB, 512MB Swap, IP = DHCP or static, DNS as appropriate

# Fire up LXC console after it builds, login as root with the password you set

# Run this script INSIDE the running LXC
# TODO 2nd script for pct create

# (root) Cmds to accomplish everything:

# xxx TODO editme
myid=dave

apt update

apt upgrade -y

# SKIP #  apt install fluxbox # rdesktop clicking did nothing, so went with icewm

apt install -y icewm xterm xfce4-terminal

ip a

apt install -y xrdp

adduser xrdp ssl-cert

systemctl restart xrdp

apt install -y joe mc screen tmux vim

apt install -y thunderbird

# Requires input for passwd
adduser $myid

#screen -aAO -h 2000

# =============

echo "Fire up rdesktop client, login as $myid, you should see icewm minimal desktop with 4 virtual screens preconfigured."
echo ''
echo "Right-click desktop, open Terminal, enter ' thunderbird & '"
echo '(or use the "Start" menu) and setup your email account.'

date;
