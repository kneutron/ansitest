#!/usr/bin/bash

# void linux
# REF: https://docs.voidlinux.org/xbps/index.html

logfile=~/freshinstall-void.log

mv -v $logfile $logfile.old

# Get latest
xbps-install -u xbps

function instpkg () {
  xbps-install -y $*
} 2>>$logfile

instpkg joe mc screen tmux vim nano sysstat bwm-ng xclock unzip lzop

# gpg not found
instpkg  wget curl

instpkg fsarchiver openssh smartmontools netcat

instpkg linux-headers 

# g++ not found
buildessential="gcc make glibc-devel"  
instpkg "$buildessential"

instpkg mlocate ntp lm_sensors gawk net-tools

instpkg fuse-sshfs pv buffer ethtool gparted iotop dos2unix 

instpkg p7zip parallel pbzip2 xz xfsprogs

instpkg lsscsi sdparm sg3_utils 

instpkg lftp gftp ncftp

# nmap not found 2023.0910
instpkg ethstatus  iptraf-ng autossh 

instpkg cdparanoia vlc youtube-dl handbrake handbrake-cli lame mpg123 ffmpeg devedeng

instpkg udftools dvd+rw-tools zisofs-tools imagewriter isoimagewriter xorriso

instpkg mplayer mpv arandr wmctrl

instpkg xterm xfontsel 

instpkg libreoffice

# Toys
instpkg cmatrix xaos ImageMagick geeqie ristretto jpegoptim tumbler xsnow

instpkg thunderbird firefox-esr mutt

instpkg samba smbclient cifs-utils
instpkg zfs
modprobe zfs
dmesg|grep zfs

instpkg vsftpd

# NON-VM only
# instpkg virtualbox-ose

result=$(grep -c toor /etc/passwd)
if [ $result -eq 0 ]; then
  useradd -d /root -g 0 -G 0 -M -N -o -r -s `which bash` -u 0 toor # bash root user
  echo "+ Added toor bash user"
else
  echo "toor user already exists - skipped"
fi

# updt - requires Y input
xbps-install -Su

echo "$(date) - Checking if reboot needed"
time xcheckrestart

zpool import

date

exit;
