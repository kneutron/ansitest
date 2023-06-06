#!/bin/bash

# BKP2FSARCHIVE 1ST!!
# Add std pkgs to new install, after running -purgedebs 1st to make space

# 2020.0522 for opensuse leap 15.3

logfile=~/freshinstall.log

function addpkgs {
  zypper install -y $*
} 2>>$logfile

# REF: https://www.virtualbox.org/wiki/Linux_Downloads
#wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
#wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -

zypper ref

# essential
addpkgs joe mc lynx w3m screen lzop fsarchiver netcat-openbsd bwm-ng openssh-server smartmontools sysstat 

addpkgs mlocate net-tools net-tools-deprecated # ifconfig

# 2006.0828 for vmware:
#addpkgs linux-headers-`uname -r` build-essential
#libc6-i386 ia32-libs

# Admin
#addpkgs synaptic aptitude apt-file
addpkgs mlocate ntpdate
addpkgs mbr lm-sensors gawk net-tools-deprecated # ifconfig
addpkgs sshfs 
addpkgs pv buffer  ethtool  gparted  iotop dos2unix # android-tools-adb  notavl
addpkgs p7zip unrar parallel pbzip2 # xz-utils     # TODO - codecs? - to play dvds
addpkgs jfsutils xfsprogs

# SCSI stuff
addpkgs lsscsi scsitools sdparm  sg3-utils
#/unstable

# Removed from deflt knoppix
addpkgs lftp ncftp gftp   nmap iptraf-ng autossh filezilla  httrack # ethstatus

# AUDIO/VIDEO STUFF
addpkgs sox vorbis-tools  cdparanoia vlc youtube-dl handbrake handbrake-cli lame mpg123 ffmpeg devede
addpkgs udftools dvd+rw-tools growisofs 
addpkgs xine-ui mplayer 
#TODO?  + installed pkg /usr/share/doc/libdvdread4/install-css.sh

addpkgs pavucontrol pulseaudio # for HDMI sound 
# 2017.1029 no install pkg  deadbeef for antix

# X stuff
addpkgs rdesktop  ssh mingetty  xlsx2csv  arandr wmctrl
addpkgs thunar  xfce4-terminal xterm rxvt-unicode  xtightvncviewer x11vnc xfce4-screenshooter scrot mesa-utils
addpkgs fonts-liberation ttf-mscorefonts-installer xfonts-scalable evince 

addpkgs libreoffice

# xffm4 no pkg 2017.1029
#log2mail 
#debian-goodies 
addpkgs nano nedit vim  


# TOYS
addpkgs cmatrix xaos imagemagick geeqie ristretto jpegoptim tumbler
#xearth  xsnow  


# Printing
addpkgs cups hplip hplip-gui # run ' hp-doctor ' non-root


addpkgs thunderbird


#+ installed pkg # apt-get install virtualbox 
#addpkgs virtualbox


# Moved to end due to prompt/weirdness/needs config

# ZFS on linux
#2017.0223 FIX + installed pkg zfsutils-linux # was missing 'zpool' cmd
# REF: https://github.com/zfsonlinux/zfs/wiki/Debian / https://packages.debian.org/source/stretch/zfs-linux
#addpkgs zfs-dkms zfsutils-linux
addpkgs samba cifs-utils 
addpkgs samba-client samba-test samba-tool yast2-samba\*
#addpkgs cifs-utils 
#  && modprobe zfs


addpkgs localepurge vsftpd  #libdvd-pkg
#addpkgs squid3
#dpkg-reconfigure libdvd-pkg

#addpkgs discover  vsftpd  sawfish  localepurge  rcconf scsiadd icewm
addpkgs mutt  sarg 
# for squid reports - REF: https://www.tecmint.com/sarg-squid-analysis-report-generator-and-internet-bandwidth-monitoring-tool/

addpkgs rsyslog

addpkgs scout man man-pages

# REF: https://en.opensuse.org/OpenZFS
zypper addrepo https://download.opensuse.org/repositories/filesystems/openSUSE_Tumbleweed/filesystems.repo
addpkgs zfs zfs-kmp-default dkms

#apt-file update &
[ `lsmod |grep -c zfs` -gt 0 ] && zpool import

echo "`date` - DONE"

exit;

2022.0522 opensuse / rpm

2018.jan all-in-1 for mx17:
# apt-get install ethtool xterm rdesktop evince gparted httrack gedit lftp chromium  \
 udftools xz-utils lzop exfat-utils bwm-ng geeqie xine-ui mplayer synaptic aptitude apt-file sysstat fbpager  \
 vsftpd openssh-server localepurge icedax cdparanoia growisofs nmap vorbis-tools pv pbzip2 lsscsi mbr p7zip-full filezilla \
 vlc youtube-dl fsarchiver lm-sensors mesa-utils gawk dos2unix xlsx2csv lame arandr ffmpeg wodim android-tools-adb \
 dvd+rw-tools lsdvd scrot rxvt cifs-utils xtightvncviewer jpegoptim iotop handbrake handbrake-cli x11vnc \
 xvt hplip hplip-gui imagemagick bittornado-gui sox ristretto xfce4-screenshooter  tumbler pavucontrol \
 libdvd-pkg buffer fonts-liberation ttf-mscorefonts-installer xfonts-scalable parallel hddtemp

