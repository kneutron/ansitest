#!/bin/sh

# 2026.0409 kneutron
# REF: https://linuxvox.com/blog/alpine-linux-desktop/
# REF: https://wiki.alpinelinux.org/wiki/Remote_Desktop_Server

apk update
apk add bash joe mc screen tmux vim nano pigz openssh-server openssh-client openssh-sftp-server netcat-openbsd lftp shadow

apk add avahi avahi-tools avahi-openrc avahi-ui avahi-ui-gtk3 avahi-ui-tools

apk add xfce4 xfce4-terminal xterm xfce4-screenshooter dbus-x11 xrandr xsetroot xrdb ttf-dejavu xclock firefox-esr thunar geeqie
 
# apk add thunderbird
 
apk add lightdm lightdm-gtk-greeter
rc-update add lightdm default

adduser dave

apk add xrdp xorgxrdp xorg-server xorgxrdp-dev
adduser xrdp ssl-cert
rc-update add xrdp default # start at boot

rc-service xrdp start
rc-service xrdp-sesman start

rc-update add xrdp-sesman

echo "PK to reboot"
read -n 1
reboot
