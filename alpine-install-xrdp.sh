#!/bin/sh

# Alpine instance setup (proxmox lxc)
# Runs remote desktop on :3389 - NOTE rdesktop works, jump desktop (mac) does not

# 2026.0409 kneutron

# REF: https://linuxvox.com/blog/alpine-linux-desktop/
# REF: https://wiki.alpinelinux.org/wiki/Remote_Desktop_Server

# REF: https://wiki.alpinelinux.org/wiki/Alpine_Configuration_Framework_Design

# HOWTO Easiest way to get this onto a new instance:
#
# apk update
# apk add netcat-openbsd				# in-alpine
# ip a |grep 'inet '; nc -l -p 32100 |tar xpvf -	# in-alpine, netcat listen on port 32100 and tar extract to curdir
#
# On the host that has this script:
# tar cpvf - $0 |nc -w 2 IPofalpine 32100		# tar create stream using stdin and sendit to IP of alpine, port 32100; auto-end after 2 seconds of no data
#
# OR:
# apk add openssh-server openssh-ftp-server		# and then  scp $0 user@alpineIP: 	# from box #2 after adding a non-root user/password in alpine


apk update
apk add bash joe mc screen tmux vim nano pigz openssh-server openssh-client openssh-sftp-server netcat-openbsd lftp shadow tz
# shadow provides chsh
# TODO edit /etc/profile, export TZ="America/majorcity"

# Locate/ping thisbox on the network as hostname.local
apk add avahi avahi-tools avahi-openrc avahi-ui avahi-ui-gtk3 avahi-ui-tools
rc-update  add avahi-daemon
rc-service avahi-daemon start
# To test: 	avahi-browse --resolve --terminate  _ipp._tcp

# NOTE can also use icewm
apk add xfce4 xfce4-terminal xterm xfce4-screenshooter dbus-x11 xrandr xsetroot xrdb ttf-dejavu xclock firefox-esr thunar geeqie
 
# apk add thunderbird	# email
# setup-acf	# run light webmin equivalent daemon on :80
 
apk add lightdm lightdm-gtk-greeter
rc-update add lightdm default

adduser dave 	# will prompt to set password

apk add xrdp xorgxrdp xorg-server xorgxrdp-dev
adduser xrdp ssl-cert 	# may/not work

rc-update add xrdp default # start at boot
rc-service xrdp start

rc-update add xrdp-sesman
rc-service xrdp-sesman start

echo "PK to reboot, or ^C"
read -n 1
reboot
