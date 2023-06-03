#!/bin/bash

# EDIT ME 1ST!!

source ~/bin/failexit.mrg

zp=zhgstsas4
zfsuser=dave

DBI=/dev/disk/by-id

disk1=scsi-35000cca07325f6b0
disktmp=$(ls -l $DBI |grep -w $disk1 |head -n 1 |awk '{print $11}') # ../../shortdev
disk1S=${disktmp#../../} # bash inline sed; del == sdf

disk2=scsi-35000cca07321bea8
disktmp=$(ls -l $DBI |grep -w $disk2 |head -n 1 |awk '{print $11}') # ../../shortdev
disk2S=${disktmp#../../} # bash inline sed; del == sdg

#disk3=$DBI/
#disk3L=$DBI/$disk3
#disk4=$DBI/
#disk4L=$DBI/$disk4
#disk5=$DBI/
#disk5L=$DBI/$disk5
#disk6=$DBI/
#disk6L=$DBI/$disk6

# note zpool status -L  # resolves to short names, e.g. sde
outfyl=/tmp/`basename $0`-checktmp.txt
zpool status -Lv > $outfyl

#[ `zpool status -v |grep -c $disk1` -gt 0 ] && failexit 101 "! $disk1 is in use by another zpool!"
[ `grep -c $disk1S $outfyl` -gt 0 ] && failexit 101 "! $disk1 is in use by another zpool!"
[ `grep -c $disk2S $outfyl` -gt 0 ] && failexit 102 "! $disk2 is in use by another zpool!"
#[ `grep -c $disk3 $outfyl` -gt 0 ] && failexit 103 "! $disk3 is in use by another zpool!"
#[ `grep -c $disk4 $outfyl` -gt 0 ] && failexit 104 "! $disk4 is in use by another zpool!"
#[ `grep -c $disk5 $outfyl` -gt 0 ] && failexit 105 "! $disk5 is in use by another zpool!"
#[ `grep -c $disk6 $outfyl` -gt 0 ] && failexit 106 "! $disk6 is in use by another zpool!"


function make1disk () {
	zpool create -o ashift=12 -o autoexpand=on -O atime=off -O compression=lz4 $zp \
	  $disk1
}	  

function make2disk () {
	zpool create -o ashift=12 -o autoreplace=off -o autoexpand=on -O atime=off -O compression=lz4 \
	$zp \
	  mirror $disk1 $disk2 || failexit 99 "! Unable to create zpool $zp"
}

function make4disk () {
	zpool create -o ashift=12 -o autoexpand=on -O atime=off -O compression=lz4 $zp \
		mirror $disk1 $disk2 \
		mirror $disk3 $disk4 || failexit 99 "! Unable to create zpool $zp"
}

function make6disk () {
	zpool create -o ashift=12 -o autoexpand=on -O atime=off -O compression=lz4 $zp \
	  mirror $disk1 $disk2 \
	  mirror $disk3 $disk4 \
	  mirror $disk5 $disk6 || failexit 99 "! Unable to create zpool $zp"
}

# TODO more vdevs
function makerz2 () {
	zpool create -o ashift=12 -o autoexpand=on -O atime=off -O compression=lz4 $zp \
	  raidz2 $disk1 $disk2 $disk3 $disk4 $disk5 $disk6 \
	|| failexit 99 "! Unable to create zpool $zp"
}


# xxx What kind to create?
make2disk; # || failexit 202 "Failed to create $zp"
zpool status -v $zp|awk 'NF>0'


function ownlist () {
	chown -v $zfsuser /$zp/$mydir
	ls -la /$zp/$mydir
}	  

function makezdscompshare () {
	zfs create -o atime=off -o compression=lz4 -o sharesmb=on $zp/$mydir
	ownlist
}

function makezdsNOTcompOKshare () {
	zfs create -o atime=off -o compression=off -o sharesmb=on $zp/$mydir
	ownlist
}

function makezdsOKcompNOTshare () {
	zfs create -o atime=off -o compression=lz4 -o sharesmb=off $zp/$mydir
	ownlist
}

function makezdsNOTcompNOTshare () {
	zfs create -o atime=off -o compression=off -o sharesmb=off $zp/$mydir
	ownlist
}

mydir=shrcompr; makezdscompshare $mydir

mydir=notshrcompr; makezdsOKcompNOTshare $mydir

mydir=notshrnotcompr; makezdsNOTcompNOTshare $mydir


# Custom
mydir=BURNME-shrcompr; makezdsOKcompOKshare $mydir


df -hT |head -n 1
df -hT |grep $zp

exit;

FIXED with head
grep: ../../sdg1: No such file or directory
/root/bin/boojum/newzfs-pool-n-datasets.sh: line 35: [: /tmp/newzfs-pool-n-datasets.sh-checktmp.txt:0: integer expression expected

DONE check 'zpool status' and see if drive(s) are already in use!!
