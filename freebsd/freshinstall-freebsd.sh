#!/usr/local/bin/bash

ln -sfn /usr/local/bin/bash /bin/bash

logfile=$HOME/freshinstall.log
>$logfile # clearit

user=dave
useproxy=1
# xxx TODO editme

# use squid 
if [ $useproxy -gt 0 ]; then
 ip="10.9.0.4"
 export http_proxy=http://"$ip":3128
 export https_proxy=http://"$ip":3128
 export ftp_proxy=http://"$ip":3128
 export no_proxy=localhost
 set|grep proxy=
fi

function inst () {
  echo y| pkg install "$@"
} 2>>$logfile

inst joe mc screen bash vim

inst xorg xdm xfce xfce4-terminal

inst chromium libreoffice  

inst samba413 smb4k linuxfdisk bwm-ng iftop 
# inst fusefs-smbnetfs
# ^ REF: https://forums.freebsd.org/threads/samba-smbv2-client-under-freebsd.70242/

# Utils
inst 7-zip bzip2 gtar lzop pbzip2 rar unrar star zstd pv mbuffer rsync detox eject gdisk parallel
inst smartmontools gsmartcontrol jailutils lsof psmisc sg3_utils shuf usbutils open lsblk fuck
# open is openvt - fuck will try to smart-correct commandline typoes


#TODO logrotate?

inst sudo doas bash-completion 
# replacement for sudo

inst  hexedit nano 
# dos2unix not found

# FTP
inst lftp  fusefs-sshfs
# ncftp3 not found

# Extra
inst mkjail # req. zfs

# TODO cdrtools brasero cdrdao dvd+rw-tools xorriso html2text

# X
inst alarm-clock-applet xfce4-tumbler frozen-bubble hexxagon ImageMagick7 geeqie ristretto xmountains xfractint xaos
inst lxterminal wmctrl arandr xterm xwininfo xalarm xclock pcmanfm thunar fluxbox icewm cmatrix

# TODO xbacklight xbrightness 

# TODO mutt? findutils? remmina chntpw 
# TODO X screen sharing - tigervnc-server / tigervnc-viewer

# TODO qemu , virtualbox


# vbox guest adds - REF: https://docs.freebsd.org/en/books/handbook/virtualization/#virtualization-guest-virtualbox
#cd /usr/ports/emulators/virtualbox-ose-additions && make install clean # Takes HOURS
inst virtualbox-ose-additions

# Virtbox
cp -v /etc/rc.conf /etc/rc.conf.bkp

addline='vboxguest_enable="YES"'
[ $(grep -c ${addline} /etc/rc.conf) -eq 0 ] && echo ${addline} >> /etc/rc.conf

addline='vboxservice_enable="YES"'
[ $(grep -c ${addline} /etc/rc.conf) -eq 0 ] && echo ${addline} >> /etc/rc.conf

addline='hald_enable="YES"'
[ $(grep -c ${addline} /etc/rc.conf) -eq 0 ] && echo ${addline} >> /etc/rc.conf

service hald start


[ $(grep -c 'dbus_enable="YES"' /etc/rc.conf) -eq 0 ] && echo 'dbus_enable="YES"' >> /etc/rc.conf


# Enable long disk names - REF: https://rubenerd.com/enabling-dev-diskid-and-dev-gpt-on-freebsd/
# Enables /dev/diskid/
cp -v /boot/loader.conf /boot/loader.conf.bkp

addline='kern.geom.label.disk_ident.enable="1"'
[ $(grep -c ${addline} /boot/loader.conf) -eq 0 ] && echo ${addline} >> /boot/loader.conf

addline='kern.geom.label.gptid.enable="1"'
[ $(grep -c ${addline} /boot/loader.conf) -eq 0 ] && echo ${addline} >> /boot/loader.conf


# VM assumed - SKIP mount samba share, still need something better than v1 - probably use sshfs
mkdir -pv /mnt/imac5
chown $user /mnt/imac5
#mount_smbfs -I 192.168.56.1 -U dave  //dave@imac5/shrcompr-zsgt2B /mnt/imac5

# use sshfs instead
kldload fusefs
sysctl vfs.usermount=1
pw group mod operator -m $user # add user to operator group, per /dev/fuse ownership

ls -alh $logfile
