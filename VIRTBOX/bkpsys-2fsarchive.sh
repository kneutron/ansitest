#!/bin/bash

# Intention: bare-metal backup and restore linux running system (root), quite handy for restoring to VM
# REF: http://crunchbang.org/forums/viewtopic.php?id=24268

# DEPENDS: fsarchiver, /root/bin/boojum/BKPDEST.mrg (up to date with a valid destination dir)

# NOTE define a PATH here if you want to run from CRON
# NOTE if you're running stuff like mysql or anything making live updates, you should stop the related service

keepdays=31

rootdev=$(df / |grep /dev |awk '{print $1}')
bkpdate=$(date +%Y%m%d)

# xxx TODO EDITME       vv edit BKPDEST to define your backup destination dir before running this
source /root/bin/boojum/BKPDEST.mrg     # now provides mount test
dest=$bkpdest/notshrcompr

ddir=$dest/bkpsys-$myhn
mkdir -pv $ddir
chmod 750 $ddir # drwxr-x---
cd $ddir || failexit 199 "! Could not CD to $ddir"

# need shorter filename for UDF restores 2017.0827
#outfile=bkpsys--p2300m-dell-1550-studio--backup-root-sda6--antix16-64--debian-no-systemd--1tb-drive--$bkpdate-fsarc1.fsa
outfile="bkpsys-$myhn-64-debstable10-$bkpdate-fsarc-ZSTD.fsa"
# xxx TODO ^^ EDITME

cp -v /tmp/fdisk-l.txt $ddir
cp -v /tmp/smartctl.txt $ddir
cp -v $0 $ddir
cp -v ~/bin/boojum/RESTORE-fsarchive-root.sh $ddir
# copy restore script to backup dir, goes with mkrestoredvdiso.sh

# NOTE autoclean !! find bkps and flist files more than XX days old and delete
cd $ddir && \
   find $ddir/* \( -name "bkp*fsa" -o -name "flist*" \) -type f -mtime +$keepdays -exec /bin/rm -v {} \;
   
echo "o $0 - backing up ROOT"
df -hT / $dest
date
numproc=$(nproc --ignore=1)
#time fsarchiver -v -o -A -z 1 -j 2 savefs \
# NOTE older / LTS distros may need to use lower-case -z since the package ver may not support zstd
time fsarchiver -o -A -Z 1 -j $numproc savefs \
  $ddir/$outfile \
  $rootdev

cd $ddir
fsarchiver archinfo $outfile 2> flist--$outfile.txt

ls -lh $ddir/*
echo "$(date) - $0 done"

exit;


NOTE this script does NOT cover zfs-as-root on linux! 
run bkpcrit.sh for that before doing any update/upgrades

HOWTO restore: 
# time fsarchiver restfs backup-root-sda1--fryserver--ubuntu1404-*-fsarc1.fsa id=0,dest=/dev/sdf1
Statistics for filesystem 0
* files successfully processed:....regfiles=159387, directories=25579, symlinks=49276, hardlinks=25, specials=108
* files with errors:...............regfiles=0, directories=0, symlinks=0, hardlinks=0, specials=0
real    4m26.116s
( 3.9GB )

PROTIP fsarchiver can restore to a different filesystem OTF such as xfs, should Just Work as long as you edit fstab
  after restore (make sure no filesystem-specific mount options such as {commit,errors=remount-ro}; 
  + changing ext4 to auto may also work) 
  and before booting restored system / VM

NOTE if you have a separate /home (and you should) you will need to restore that as well into the VM b4 booting it
