#!/bin/bash

# 2014 Dave Bechtel

# cre8 a new ZFS dataset with options and loggit
echo "$0 opt1=(1)compression opt2=(1)sharesmb, 0 == OFF zpool dirname"
echo "Example: $0 11 zpoolname datasetname"
echo "== create zpoolname/datasetname as Shared Samba dataset with recordsize 1M and set owner"

# TODO -e /tmp/infile read it and process it

logfile=~/boojum-zfs-newds.log

#source ~/bin/failexit.mrg
# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" |tee -a $logfile # code # (and optional description)
  exit $1
}

# xxx TODO editme
#zp=zredpool2; myds=home/vmtmpdir/vmware-virtmachines
zp="$2"; myds="$3"
user=dave
# this is for chown later

# defaults
dcompr=lz4
#dcompr=zstd-2  ## for zfs 2.0.x
dshrwin=off

# opt1=compression, opt2=sharesmb
case "$1" in
	"10" )
# use defaults
		compr=$dcompr; shrwin=$dshrwin
    ;;
	"11" )
		compr=$dcompr; shrwin="on -o xattr=sa"
# NOTE xattr=sa may not work in older versions of freebsd		
    ;;
	"01" )
		compr=off; shrwin="on -o xattr=sa"
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
  atime=off -o compression=$compr -o sharesmb=${shrwin} -o recordsize=1024k \
  $zp/$myds || failexit 99 "! Failed to create ZFS $zp/$myds"
) 

echo "$(date) + $zp/$myds + compr=$compr:shr=${shrwin} + Owner:$user" >> $logfile

# NOTE does not take into account alt.mountpoints like /home!
chown -v $user /$zp/$myds; ls -al /$zp/$myds
#df -h /$zp/$myds
df -hT |head -n 1
df -hT |grep $myds

exit;

This is not intended to be comprehensive, but should provide a good example
