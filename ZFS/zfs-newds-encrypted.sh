#!/bin/bash

# NOTE mod for osx
# NOTE dataset will be encrypted!
# =LLC= © (C)opyright 2017 Boojum Consulting LLC / Dave Bechtel, All rights reserved.

# cre8 a new ZFS dataset with options
echo "$0 opt1=(1)compression opt2=(1)sharesmb, 0 == OFF zpool dirname"

# TODO -e /tmp/infile read it and process it

source ~/bin/failexit.mrg
logfile=/var/root/boojum-zfs-newds.log

# TODO editme
#zp=zredpool2; myds=home/vmtmpdir/vmware-virtmachines
zp="$2"; myds="$3"
user=davebechtel

zfskeyloc=/Users/"$user"/zfskey
mkdir -pv "$zfskeyloc"

# defaults
compr=lz4
shrwin=off

# opt1=compression, opt2=sharesmb
case "$1" in
	"10" )
# use defaults
		compr=lz4; shrwin=off
    ;;
	"11" )
		compr=lz4; shrwin="on -o xattr=sa "    
    ;;
	"01" )
		compr=off; shrwin="on -o xattr=sa "
    ;;
	"00" )
		compr=off; shrwin=off
    ;;
	"" )
# no arg passed; print help and exit
	failexit 101 "No arg passed!"
		;;
  * )
    failexit 201 "Invalid arg passed, +$1+ not recognized"
    
    ;;
esac      

encrkey="$zfskeyloc/zek-$zp-$user"
[ -e "$encrkey" ] || dd if=/dev/urandom of="$encrkey" bs=1 count=32 # dont overwrite if exists!
        
#zfs create -o atime=off -o compression=lz4 -o sharesmb=off -o recordsize=1024k 
#-o encryption=aes-128-ccm -o keyformat=raw -o keylocation=file:///var/root/zek-testencr-zfs.key 
#-o normalization=formD -o xattr=sa zint500/Test-aes-128-ccm

set -x       
        ##create encrypted dataset
        ##for description of options see section 2.4b:
        ##https://github.com/zfsonlinux/zfs/wiki/Debian-Buster-Encrypted-Root-on-ZFS
        ##Note options with -O are file-system-properties. options with -o aren't. need to use upper and lowercase correctly.
        ##use create -n for dry-run
        zfs create -o encryption=aes-192-gcm \
                -o keyformat=raw \
                -o keylocation=file://"$encrkey" \
                -o compression=$compr \
                -o sharesmb=${shrwin} \
                -o atime=off \
                -o recordsize=1024k \
                $zp/$myds || failexit 99 "! Failed to create encrypted $zp/$myds"

# trace on
#(set -x
#zfs create -o \
#  atime=off -o compression=$compr -o sharesmb=${shrwin} -o recordsize=1024k \
#  $zp/$myds || failexit 99 "! Failed to create ZFS $zp/$myds"
#) 

echo "$(date) + $zp/$myds + compr=$compr:shr=${shrwin} + Owner:$user" >> $logfile

# NOTE does not take into account alt.mountpoints like /home!
chown -v $user /Volumes/$zp/$myds; ls -al /Volumes/$zp/$myds
#df -h /$zp/$myds
gdf -hT |head -n 1
gdf -hT |grep $myds

exit;

# MAC mods
/var/root/bin/boojum/zfs-newds.sh: line 57: /root/boojum-zfs-newds.log: No such file or directory
chown: /zwdgreentera/dvnotshrcompr: No such file or directory
ls: /zwdgreentera/dvnotshrcompr: No such file or directory
Filesystem                              Size   Used  Avail Capacity   iused     ifree %iused  Mounted on
zwdgreentera/dvnotshrcompr             449Gi  324Ki  449Gi     1%        10 942667768    0%   /Volumes/zwdgreentera/dvnotshrcompr
 40 root ~ # pwd
/var/root
