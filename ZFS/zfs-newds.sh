#!/bin/bash

# =LLC= © (C)opyright 2017 Boojum Consulting LLC / Dave Bechtel, All rights reserved.
## NOTICE: Only Boojum Consulting LLC personnel may use or redistribute this code,
## Unless given explicit permission by the author - see http://www.boojumconsultingsa.com
#

# cre8 a new ZFS dataset with options
echo "$0 opt1=(1)compression opt1=(1)sharesmb, 0 == OFF zpool dirname"

# TODO -e /tmp/infile read it and process it

source ~/bin/failexit.mrg
logfile=/var/root/boojum-zfs-newds.log

# TODO editme
#zp=zredpool2; myds=home/vmtmpdir/vmware-virtmachines
zp="$2"; myds="$3"
user=dave
#user=nerdz

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
		compr=lz4; shrwin=on    
    ;;
	"01" )
		compr=off; shrwin=on
    ;;
	"00" )
		compr=off; shrwin=off
    ;;
	"" )
# no arg passed; bash NOP ref: https://stackoverflow.com/questions/17583578/what-command-means-do-nothing-in-a-conditional-in-bash
		:
		;;
  * )
    echo "WNG: Invalid arg passed, +$1+ not recognized"
    ;;
esac      

# trace on
(set -x
zfs create -o \
  atime=off -o compression=$compr -o sharesmb=$shrwin -o recordsize=1024k \
  $zp/$myds || failexit 99 "! Failed to create ZFS $zp/$myds"
) 

echo "`date` + $zp/$myds + compr=$compr:shr=$shrwin + owner:$user" >> $logfile

# NOTE does not take into account alt.mountpoints like /home!
chown -v $user /$zp/$myds; ls -al /$zp/$myds
#df -h /$zp/$myds
df -h |head -n 1
df -h |grep $myds

exit;

# MAC mods
/var/root/bin/boojum/zfs-newds.sh: line 57: /root/boojum-zfs-newds.log: No such file or directory
chown: /zwdgreentera/dvnotshrcompr: No such file or directory
ls: /zwdgreentera/dvnotshrcompr: No such file or directory
Filesystem                              Size   Used  Avail Capacity   iused     ifree %iused  Mounted on
zwdgreentera/dvnotshrcompr             449Gi  324Ki  449Gi     1%        10 942667768    0%   /Volumes/zwdgreentera/dvnotshrcompr
 40 root ~ # pwd
/var/root
