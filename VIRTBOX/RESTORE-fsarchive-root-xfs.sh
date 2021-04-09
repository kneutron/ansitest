#!/bin/bash

# restore ext4 (or other) root filesystem from fsarchiver to XFS on the fly (usually into VM)
# To be run from systemrescuecd environment; NOTE restore disk MUST be partitioned 1st!
# REQUIRES 1 arg: filename of .fsa
# copy this script to /tmp and chmod +x, run from there
# NOTE ISO from mkrestoredvdiso should be mounted on 2nd dvd drive
# NOTE having a copy of supergrubdisc is handy if the VM fails to boot
# REF: https://distrowatch.com/table.php?distribution=supergrub

# TODO include /home and restore that? IF EXIST

# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

# xxx TODO editme; assumes swap is on sda1
rootdev=/dev/sda2
rdevonly=${rootdev%[[:digit:]]}
umount $rootdev # failsafe

cdr=/mnt/cdrom2
mkdir -pv $cdr
rootdir=/mnt/tmp2
umount $rootdir # failsafe
mkdir -pv $rootdir

myres=BOOJUM-RESTORE.sh # injection script

# NOTE sr0 is systemrescue
mount /dev/sr1 $cdr -oro
chkmount=$(df |grep -c $cdr)
[ $chkmount -gt 0 ] || failexit 99 "Failed to mount $cdr"; # failed to mount
chkmount=$(df |grep -c $rootdir)
[ $chkmount -eq 0 ] || failexit 98 "$rootdir is still mounted - cannot restore!"

cd $cdr || failexit 199 "Cannot CD to $cdr";
pwd
echo "$(date) - RESTORING root filesystem to $rootdev"

# PROBLEM with long filenames in UDF - gets cut off, use $1
#time fsarchiver restfs *.fsa id=0,dest=$rootdev
time fsarchiver restfs "$1" id=0,mkfs=xfs,dest=$rootdev  || failexit 400 "Restore failed!";

date

# boojumtastic!
#tune2fs -m1 $rootdev

# TODO assuming a ~20GB root
mount $rootdev $rootdir -onoatime,rw && \
  xfs_io -x -c "resblks 1024" $rootdir

# Comment out any existing swap partitions in restored fstab
# REF: https://unix.stackexchange.com/questions/295537/how-do-i-comment-lines-in-fstab-using-sed
#sed -e '/[/]/common s/^/#/' /etc/fstab
/bin/cp -v $rootdir/etc/fstab $rootdir/etc/fstab--bkp && \
  sed -i '/swap/s/^/#/' $rootdir/etc/fstab; grep swap $rootdir/etc/fstab

# Detect swap partition(s) in restore environ - print /dev/sdXX w/o ":"
for p in `blkid |grep TYPE=\"swap\" |awk -F: '{ print $1 }'`; do
  pmod=${p##*/} # strip off beginning /dev/, leave sdXX 
  swapuuid=$(ls -l /dev/disk/by-uuid |grep $pmod |awk '{ print $9 }')

# check have we already done this?
  [ $(grep -c $swapuuid $rootdir/etc/fstab) -gt 0 ] || \
    echo "UUID=$swapuuid  swap  swap  defaults,pri=2  0 0" |tee -a $rootdir/etc/fstab
#    echo "UUID=$swapuuid  swap  swap  defaults,pri=2  0 0" >> $rootdir/etc/fstab
done

# /dev/sdb5
#ls -l /dev/disk/by-uuid |grep sdb5
# 1         2 3    4    5  6   7  8     9                                    10 11
#lrwxrwxrwx 1 root root 10 Aug 27 11:09 dfc46f8f-bcfa-4e73-b62f-b24dd0bf60cf -> ../../sdb5

# Make sure we can boot!
grub-install --root-directory=$rootdir $rdevonly
mount -o bind /dev $rootdir/dev; mount -o bind /proc $rootdir/proc; mount -o bind /sys $rootdir/sys

# FIXED
myres2=$rootdir/$myres
touch $myres2 || failexit 298 "Check if R/O filesystem?"

echo "#!/bin/bash" > $myres2 || failexit 299 "Cannot update $myres2 injection script - Check R/O filesystem?"
echo "update-grub" >> $myres2
echo "grub-install $rdevonly" >> $myres2  # from chroot
echo "exit;" >> $myres2

# inject script here!
chroot $rootdir /bin/bash /$myres

#umount -a $rootdir/* 
umount -a $rootdir/{dev,proc,sys}
 
      
umount $rootdir/* 2>/dev/null
#umount $rootdir 2>/dev/null

df -hT

echo "DON'T FORGET TO COPY /home and adjust fstab for home / squid BEFORE booting new drive!"
echo "+ also adjust etc/network/interfaces , getdrives-byid , etc/rc.local , etc/hostname , etc/hosts ,"
echo "+ etc/init/tty11 port (home/cloudssh/.bash_login"
echo "DONT FORGET to edit fstab and change root ext4 to xfs"

exit;

