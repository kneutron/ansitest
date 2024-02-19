#!/bin/bash

# Intention: bare-metal backup and restore linux running system
# REF: http://crunchbang.org/forums/viewtopic.php?id=24268
# REQUIRES: fsarchiver

# TODO BOOJUM STAFF - adjust for client retention needs!
keepdays=31

rootdev=`df / |grep /dev |awk '{print $1}'`
rootpedit=`echo ${rootdev##*/}` # strip off beginning, and last slash: sde1

bkpdate=`date +%Y%m%d`

source /root/bin/boojum/BKPDEST.mrg     # now provides mount test
dest=$bkpdest
ddir=$dest/notshrcompr/bkpsys-$myhn

source /etc/os-release

mkdir -pv $ddir
chmod 750 $ddir # drwxr-x---

cd $ddir || failexit 199 "! Could not CD to $ddir"
#pwd

#echo $rootdev $bkpdate

outfile="bkpsys-$myhn--root-$rootpedit--$ID-$VERSION--64--$bkpdate-fsarc1-zstd.fsa"
outfile=$(echo "$outfile" |tr -d ' ')

# TODO re-create??
cp -v /tmp/fdisk-l.txt $ddir
cp -v /tmp/smartctl.txt $ddir
cp -v ~/bin/`basename $0` $ddir
cp -v ~/bin/boojum/RESTORE-fsarchive-root.sh $ddir

# xxx added 2017.0218
# free up some space 1st
# http://bashshell.net/utilities/find-with-multiple-expressions/
# find with OR == works
##cd /mnt/bigvaitera/bkpsys-p3300-linux-mint--ubuntu11-64--sdX1 && \
##  find `pwd`/* \( -name "bkp*gz" -o -name "flist*" \) -type f -mtime +20 -exec ls -alk {} \;
#cd $pathh && find $pathh/* -type f -mtime +28 -exec rm {} \;

# !! find bkp-gz, bkp-bz2 and flist files more than keepdays old and delete
cd $ddir && \
   find $ddir/* \( -name "bkp*fsa" -o -name "flist*" \) -type f -mtime +$keepdays -exec /bin/rm -v {} \;
     
date
echo "o $0 - backing up ROOT"
df -hT / $bkpdest

echo "Backing up EFI partition if it exists"
[ $(df |grep -c /boot/efi) -gt 0 ] && dd if=$(df /boot/efi |grep -v ilesystem |awk {'print $1'}) of=$ddir/boot-efi.dd bs=1M 

numproc=$(nproc --ignore=1)
# -Zstd not supported on deepin xxx 2019.0416
#time fsarchiver -o -A -z 1 -j 2 savefs \
# -Z
time fsarchiver -o -A -Z 1 -j 6 savefs \
  $ddir/$outfile \
  $rootdev

cd $ddir
echo "`date` - Starting flist in BG"
fsarchiver archinfo $outfile 2> flist--$outfile.txt &

ls -lh $ddir/*
echo "$0 done - `date`"

exit;


HOWTO restore: 
# time fsarchiver restfs /zredtera1/dv/backup-root-sda1--fryserver--ubuntu1404--`date +%Y%m%d`-fsarc1.fsa id=0,dest=/dev/sdf1
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
Found linux image: /boot/vmlinuz-3.19.0-25-generic
Found initrd image: /boot/initrd.img-3.19.0-25-generic
Found memtest86+ image: /boot/memtest86+.elf
Found memtest86+ image: /boot/memtest86+.bin
Found Ubuntu 14.04.4 LTS (14.04) on /dev/sda1
done
]]

# grub-install /dev/sdf  # from chroot

^D
# umount /mnt/tmp2/*

# DON'T FORGET TO COPY /home and adjust fstab for swap / home / squid BEFORE booting new drive!
# also adjust etc/network/interfaces , getdrives-byid , etc/rc.local , etc/hostname , etc/hosts , etc/init/tty11 port (home/cloudssh/.bash_login)


# umount /mnt/tmp2/*
# umount /mnt/tmp2

=================================

CHECKLIST for new box:

