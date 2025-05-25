#!/bin/bash

# 2025.May / 2024.0419 kneutron
# Mod for proxmox LVM+ext4 root
# EFI version

# To be run from systemrescuecd environment; NOTE restore disk MUST be partitioned 1st!

# Standard ext4+lvm install with no lvm-thin:
#
#Disk /dev/vda: 32 GiB, 34359738368 bytes, 67108864 sectors
#Sector size (logical/physical): 512 bytes / 512 bytes
#I/O size (minimum/optimal): 512 bytes / 512 bytes
#Disklabel type: gpt
#
#Device       Start      End  Sectors  Size Type
#/dev/vda1       34     2047     2014 1007K BIOS boot
#/dev/vda2     2048  1050623  1048576  512M EFI System
#/dev/vda3  1050624 67108830 66058207 31.5G Linux LVM

# ===========

# This script REQUIRES 1 arg: filename of .fsa
# copy this script to /tmp and chmod +x, run from there

# If you prefer not to use an ISO to restore from, systemrescuecd has sshfs:

# HOWTO mount your backup storage over sshfs:
# sshfs -C -o Ciphers=chacha20-poly1305@openssh.com  loginid@ipaddress:/path/to/backupfile \
#  /mnt/path \
#  -o follow_symlinks

# mkdir -pv /mnt/restore; sshfs -C -o Ciphers=chacha20-poly1305@openssh.com dave@192.168.1.185:/mnt/seatera4-xfs/notshrcompr/bkpsys-proxmox \
#   /mnt/restore -o follow_symlinks

# If using sshfs, cd to restore-dir and run /tmp/$0


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

# TODO editme
efidev=/dev/vda2

# FIX
rtdevonly=${efidev%[[:digit:]]}
umount $rootdev # failsafe

#cdr=/mnt/cdrom2
#mkdir -pv $cdr
rootdir=/mnt/tmp2
umount $rootdir # failsafe
mkdir -pv $rootdir

myres=BOOJUM-RESTORE.sh # injection script

# NOTE sr0 is systemrescue
chkmount=$(df |grep -c $rootdir)
[ $chkmount -eq 0 ] || failexit 5 "$rootdir is still mounted - cannot restore!";

pwd

echo "$(date) - Restoring EFI partition to $efidev"
[ -e boot-efi.dd.gz ] && time gzip -cd boot-efi.dd.gz > $efidev
[ -e boot-efi.dd.lzop ] && time lzop -cd boot-efi.dd.lzop > $efidev
[ -e boot-efi.dd ] && time dd if=boot-efi.dd of=$efidev bs=1M status=progress 

# debugg
#read -n 1 -p "PK"

echo "$(date) - RESTORING root filesystem to $rootdev"

# PROBLEM with long filenames in UDF - gets cut off, use $1
#time fsarchiver restfs *.fsa id=0,dest=$rootdev

time fsarchiver restfs -v "$1" id=0,dest=$rootdev  || failexit 40 "Restore to $rootdev failed!";

# TODO fix
#while `wait -n`; do ## notwork - endless loop
#while [ `jobs |wc -l` -gt 0 ]; do
#  df -h |grep $rootdev # grep fsa
#  sleep 5
#done

date

# boojumtastic!
tune2fs -m2 $rootdev

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
grub-install --root-directory=$rootdir $rtdevonly
mount -o bind /dev $rootdir/dev; mount -o bind /proc $rootdir/proc; mount -o bind /sys $rootdir/sys
#mount -o bind $efidev $rootdir/boot/efi # not work?
 
# FIXED
myres2=$rootdir/$myres
touch $myres2 || failexit 98 "Check if R/O filesystem?"

echo "#!/bin/bash" > $myres2 || failexit 99 "Cannot update $myres2 injection script - Check R/O filesystem?"
echo "mount /boot/efi" >>$myres2
echo "grub-install $rtdevonly" >> $myres2  # from chroot
echo "update-grub" >> $myres2
echo "exit;" >> $myres2
#^D

# inject script here!
chroot $rootdir /bin/bash /$myres

# Leave chroot mounted in case we need it
#umount -a $rootdir/*
#umount -a $rootdir/{dev,proc,sys}

#umount $rootdir/* 2>/dev/null
#umount $rootdir 2>/dev/null

df -hT

echo "DON'T FORGET TO COPY /home and adjust fstab for swap / home / squid BEFORE booting new drive!"
echo "+ also adjust etc/network/interfaces , getdrives-byid , etc/rc.local , etc/hostname , etc/hosts ,"
echo "+ etc/init/tty11 port (home/cloudssh/.bash_login"
echo '====='
echo "If restoring to VM and a zpool on the host does not exist:"
echo " systemctl disable zfs-import@zpoolnamehere "
echo "...and it should not hold up the reboot anymore"
echo "- Also remove anything from /etc/fstab that exists on the host but not in-vm"

exit;


# 2025.May / 2024.0419 kneutron

=======================================
Full restore instructions:

Run the Proxmox installer from ISO / USB and recreate the LVM + ext4 root FS with appropriate disk size 

Boot systemrescuecd

cd /tmp
Fire up ' mc ' Midnight Commander

Tab to right pane, Esc+9 (or F9) and SFTP to where your .fsa backup file(s) are

SCP the appropriate restore script over to local /tmp and ' chmod +x ' it

EDIT THIS SCRIPT (look for EDITME) and change the appropriate values to match your restore environnment

Follow the sshfs HOWTO in the comment at the beginning of this script to mount your backup file storage

cd /mnt/restore
/tmp/$0 backupfilename.fsa # Start the restore

From here you can still chroot into the /mnt/tmp2 dir and disable zfs imports, edit /etc/fstab, et al

Shutdown, remove rescue media and it should reboot into Proxmox VE
If not, boot Super Grub Disc and that should do it

Once you have a PVE login prompt, you can login as root and reinstall grub
' grub-install /dev/blah '

and then do a test reboot to make sure everything comes up as expected.

=======================================
  
########

2024.0419 Tested, works OK with proxmox lvm
2017.0827 Tested, works OK
