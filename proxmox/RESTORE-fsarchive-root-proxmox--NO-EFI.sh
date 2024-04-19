#!/bin/bash

# =LLC= © (C)opyright 2017 Boojum Consulting LLC / Dave Bechtel, All rights reserved.
## NOTICE: Only Boojum Consulting LLC personnel may use or redistribute this code,
## Unless given explicit permission by the author - see http://www.boojumconsultingsa.com
#
# To be run from systemrescuecd environment; NOTE restore disk MUST be partitioned 1st!
# REQUIRES 1 arg: filename of .fsa
# copy this script to /tmp and chmod +x, run from there

# TODO include /home and restore that? IF EXIST


# If you prefer not to use an ISO to restore from, systemrescuecd has sshfs:
#
# sshfs -C -o Ciphers=chacha20-poly1305@openssh.com  loginid@ipaddress:/path/to/backupfile \
#  /mnt/path \
#  -o follow_symlinks

# mkdir -pv /mnt/restore; sshfs -C -o Ciphers=chacha20-poly1305@openssh.com dave@192.168.1.185:/mnt/seatera4-xfs/notshrcompr \
#   /mnt/restore -o follow_symlinks

# Mod for proxmox

# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

vgchange -a y

# TODO editme
#rootdev=/dev/sda3 # for physical disk non-nvme
#rootdev=/dev/vda3 # for restore to VM
rootdev=/dev/mapper/pve-root # for proxmox ext4+LVM restore

rdevonly=${rootdev%[[:digit:]]}
umount $rootdev # failsafe

#cdr=/mnt/cdrom2
#mkdir -pv $cdr
rootdir=/mnt/tmp2
umount $rootdir # failsafe
mkdir -pv $rootdir

myres=BOOJUM-RESTORE.sh # injection script

# NOTE sr0 is systemrescue
#mount /dev/sr1 $cdr -oro
#chkmount=`df |grep -c $cdr`
#[ $chkmount -gt 0 ] || failexit 99 "Failed to mount $cdr"; # failed to mount
chkmount=`df |grep -c $rootdir`
[ $chkmount -eq 0 ] || failexit 98 "$rootdir is still mounted - cannot restore!";

#cd $cdr || failexit 199 "Cannot CD to $cdr";
pwd
echo "`date` - RESTORING root filesystem to $rootdev"

# PROBLEM with long filenames in UDF - gets cut off, use $1
#time fsarchiver restfs *.fsa id=0,dest=$rootdev
time fsarchiver restfs "$1" id=0,dest=$rootdev  || failexit 400 "Restore failed!";

# TODO fix
#while `wait -n`; do ## notwork - endless loop
#while [ `jobs |wc -l` -gt 0 ]; do
#  df -h |grep $rootdev # grep fsa
#  sleep 5
#done

date

# boojumtastic!
tune2fs -m1 $rootdev

mount $rootdev $rootdir -onoatime,rw

# Comment out any existing swap partitions in restored fstab
# REF: https://unix.stackexchange.com/questions/295537/how-do-i-comment-lines-in-fstab-using-sed
#sed -e '/[/]/common s/^/#/' /etc/fstab
/bin/cp -v $rootdir/etc/fstab $rootdir/etc/fstab--bkp && \
  sed -i '/swap/s/^/#/' $rootdir/etc/fstab; grep swap $rootdir/etc/fstab

# Detect swap partition(s) in restore environ - print /dev/sdXX w/o ":"
#for p in `blkid |grep TYPE=\"swap\" |awk -F: '{ print $1 }'`; do
#  pmod=${p##*/} # strip off beginning /dev/, leave sdXX 
#  swapuuid=`ls -l /dev/disk/by-uuid |grep $pmod |awk '{ print $9 }'`
# check have we already done this?
#  [ `grep -c $swapuuid $rootdir/etc/fstab` -gt 0 ] || \
#    echo "UUID=$swapuuid  swap  swap  defaults,pri=2  0 0" |tee -a $rootdir/etc/fstab
#    echo "UUID=$swapuuid  swap  swap  defaults,pri=2  0 0" >> $rootdir/etc/fstab
#done

# /dev/sdb5
#ls -l /dev/disk/by-uuid |grep sdb5
# 1         2 3    4    5  6   7  8     9
#lrwxrwxrwx 1 root root 10 Aug 27 11:09 dfc46f8f-bcfa-4e73-b62f-b24dd0bf60cf -> ../../sdb5

# Make sure we can boot!
echo "$(date) - Installing grub"
grub-install --root-directory=$rootdir $rdevonly
mount -o bind /dev $rootdir/dev; mount -o bind /proc $rootdir/proc; mount -o bind /sys $rootdir/sys

# FIXED
myres2=$rootdir/$myres
touch $myres2 || failexit 298 "Check if R/O filesystem?"

echo "#!/bin/bash" > $myres2 || failexit 299 "Cannot update $myres2 injection script - Check R/O filesystem?"
echo "update-grub" >> $myres2
echo "grub-install $rdevonly" >> $myres2  # from chroot
echo "exit;" >> $myres2
#^D

# inject script here!
chroot $rootdir /bin/bash /$myres

#umount -a $rootdir/*
umount -a $rootdir/{dev,proc,sys}

umount $rootdir/* 2>/dev/null
umount $rootdir 2>/dev/null

df -hT

echo "DON'T FORGET TO COPY /home and adjust fstab for swap / home / squid BEFORE booting new drive!"
echo "+ also adjust etc/network/interfaces , getdrives-byid , etc/rc.local , etc/hostname , etc/hosts ,"
echo "+ etc/init/tty11 port (home/cloudssh/.bash_login"

exit;


HOWTO restore: 
# time fsarchiver restfs *-fsarc1.fsa id=0,dest=/dev/sdf1
Statistics for filesystem 0
* files successfully processed:....regfiles=159387, directories=25579, symlinks=49276, hardlinks=25, specials=108
* files with errors:...............regfiles=0, directories=0, symlinks=0, hardlinks=0, specials=0
real    4m26.116s
( 3.9GB )

# mount /dev/sdf1 /mnt/tmp2

# grub-install --root-directory=/mnt/tmp2 /dev/sdf
# mount -o bind /dev /mnt/tmp2/dev; mount -o bind /proc /mnt/tmp2/proc; mount -o bind /sys /mnt/tmp2/sys
# chroot /mnt/tmp2 /bin/bash
# update-grub
[[
Generating grub configuration file ...
Warning: Setting GRUB_TIMEOUT to a non-zero value when GRUB_HIDDEN_TIMEOUT is set is no longer supported.
Found linux image: /boot/vmlinuz-4.2.0-36-generic
Found initrd image: /boot/initrd.img-4.2.0-36-generic
Found memtest86+ image: /boot/memtest86+.elf
Found memtest86+ image: /boot/memtest86+.bin
Found Ubuntu 14.04.4 LTS (14.04) on /dev/sda1
done
]]
  
# grub-install /dev/sdf  # from chroot
  
^D
# umount -a /mnt/tmp2/*
  
# DON'T FORGET TO COPY /home and adjust fstab for swap / home / squid BEFORE booting new drive!
# also adjust etc/network/interfaces , getdrives-byid , etc/rc.local , etc/hostname , etc/hosts , etc/init/tty11 port (home/cloudssh/.bash_login)
  
  
# umount /mnt/tmp2/*
# umount /mnt/tmp2
  
########

2017.0827 Tested, works OK
