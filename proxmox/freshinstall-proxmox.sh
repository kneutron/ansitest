#!/bin/bash

# BKP2FSARCHIVE 1ST!!
# Add std pkgs to new install, after running -purgedebs 1st to make space

# 2018.0122 for MX 17

logfile=~/freshinstall.log

function addpkgs {
# apt-get install -y --force-yes $*
 apt-get install -y --allow-unauthenticated $*
} 2>>$logfile

# REF: https://www.virtualbox.org/wiki/Linux_Downloads
#wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
#wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -

apt update

# essential
addpkgs joe mc screen nano vim tmux lzop fsarchiver netcat-traditional bwm-ng smartmontools sysstat

# 2006.0828 for vmware:
addpkgs linux-headers-`uname -r` build-essential
#libc6-i386 ia32-libs

# Admin
addpkgs synaptic aptitude apt-file
addpkgs mbr lm-sensors gawk hddtemp
addpkgs sshfs  pv buffer  ethtool  parted  iotop dos2unix
addpkgs p7zip unrar parallel pbzip2 xz-utils     # TODO - codecs? - to play dvds
#addpkgs exfat-utils  jfsutils

# SCSI stuff
addpkgs lsscsi scsitools sdparm  sg3-utils
#/unstable

# Removed from deflt knoppix
addpkgs lftp  ethstatus nmap iptraf
# ncftp 

# AUDIO/VIDEO STUFF
#addpkgs sox vorbis-tools deadbeef cdparanoia vlc youtube-dl handbrake handbrake-cli lame mpg123 ffmpeg devede
addpkgs udftools dvd+rw-tools growisofs #wodim icedax
#addpkgs xine-ui mplayer vlc 
#TODO?  + installed pkg /usr/share/doc/libdvdread4/install-css.sh

#addpkgs pavucontrol pulseaudio # for HDMI sound 
# 2017.1029 no install pkg  deadbeef for antix

# X stuff
#addpkgs rdesktop  ssh mingetty  xlsx2csv  arandr 
#addpkgs thunar  xfce4-terminal xterm rxvt xvt xtightvncviewer x11vnc xfce4-screenshooter scrot mesa-utils
#addpkgs lxde  ttf-dejavu-core fonts-liberation ttf-mscorefonts-installer xfonts-scalable
#addpkgs  evince   chromium 

#addpkgs libreoffice

# xffm4 no pkg 2017.1029
#log2mail 
#debian-goodies 
#addpkgs nano nedit  reportbug 


# TOYS
addpkgs cmatrix #xaos #imagemagick geeqie ristretto jpegoptim tumbler
#xearth  xsnow  


# Printing
#addpkgs cups hplip hplip-gui # run ' hp-doctor ' non-root


#addpkgs firefox-esr 


#+ installed pkg # apt-get install virtualbox 
#addpkgs virtualbox-6.0 


# Moved to end due to prompt/weirdness/needs config

# ZFS on linux
#2017.0223 FIX + installed pkg zfsutils-linux # was missing 'zpool' cmd
# REF: https://github.com/zfsonlinux/zfs/wiki/Debian / https://packages.debian.org/source/stretch/zfs-linux

#addpkgs zfs-dkms zfsutils-linux 
addpkgs samba smbclient cifs-utils 
#  && modprobe zfs


addpkgs localepurge vsftpd #squid libdvd-pkg
#dpkg-reconfigure libdvd-pkg

#addpkgs discover  vsftpd  sawfish  localepurge  rcconf scsiadd icewm
addpkgs mutt

#addpkgs sarg 
# for squid reports - REF: https://www.tecmint.com/sarg-squid-analysis-report-generator-and-internet-bandwidth-monitoring-tool/

addpkgs netr lm-sensors hwloc htop sshfs nbtscan avahi-utils sg3-utils

apt-file update &
#[ `lsmod |grep -c zfs` -gt 0 ] && zpool import

echo "`date` - DONE"

exit;

2018.jan all-in-1 for mx17:
# apt-get install ethtool xterm rdesktop evince gparted httrack gedit lftp chromium  \
 udftools xz-utils lzop exfat-utils bwm-ng geeqie xine-ui mplayer synaptic aptitude apt-file sysstat fbpager  \
 vsftpd openssh-server localepurge icedax cdparanoia growisofs nmap vorbis-tools pv pbzip2 lsscsi mbr p7zip-full filezilla \
 vlc youtube-dl fsarchiver lm-sensors mesa-utils gawk dos2unix xlsx2csv lame arandr ffmpeg wodim android-tools-adb \
 dvd+rw-tools lsdvd scrot rxvt cifs-utils xtightvncviewer jpegoptim iotop handbrake handbrake-cli x11vnc \
 xvt hplip hplip-gui imagemagick bittornado-gui sox ristretto xfce4-screenshooter  tumbler pavucontrol \
 libdvd-pkg buffer fonts-liberation ttf-mscorefonts-installer xfonts-scalable parallel hddtemp


# No longer provided by cron
#addpkgs checksecurity


# NVIDIA driver
#addpkgs linux-amd64-generic
#addpkgs nvidia-glx

# AUDIO STUFF
addpkgs sox deadbeef
##addpkgs abcde
##addpkgs ecawave
##addpkgs mpgtx
##addpkgs grip
##addpkgs mp3burn
##addpkgs mp3c
# (mp3 creator)
##addpkgs id3
##addpkgs flac
##addpkgs groovycd

# No longer avail; use JRE
##addpkgs jdk1.1

# not exist anymore
##addpkgs pine
## Remember to remove mutt!

##addpkgs cdplayer

#timezoneconf 
## autoinstall
# (duplicate system installation pkgs)

##addpkgs bastille
##addpkgs dmsetup
##addpkgs easyfw
# (firewall config GUI)

##addpkgs jablicator
# (Allow others to dup your setup)

##addpkgs linuxconf
# - consider webmin...

#addpkgs webmin webmin-lvm webmin-samba webmin-smart-status webmin-squid webmin-status webmin-filemanager
#lvm2 

##addpkgs psad
# (attack detection)
##svgatextmode

##addpkgs xarchon
##addpkgs xonix

#VERY BAD - removes sysvinit!!
##addpkgs usbmgr

#addpkgs zgv  xwpe gnome-terminal multi-gnome-terminal rxvt
# powershell
#  sysv-rc  sysv-rc-conf

# 2006.0828
#addpkgs xmms

#2006.0407
#addpkgs gaim bittorrent cadaver gqview libjpeg-progs

##addpkgs ntop

#2003.0325 - Sopwith game!! :)
##addpkgs sopwith
##addpkgs gnome-gataxx
# Too many gnome dependencies; also, replaced by gnome-games. 2006.0407

##addpkgs kpoker
