#!/bin/bash

# this is to make a new blank UDF filesystem (on zfs) to fill up and burn to ~25GB blu-ray disc
# this works WITH ' burnUDFsystem2DVD+R '

mydate=`date +%Y%m%d`
volid="BRBURNME$mydate" # "BRBKP20140103"

source ~/bin/failexit.mrg

# clean slate
umount /mnt/bluray-ondisk
#[ -e /mnt/bluray-ondisk/NOTHERE ] || failexit 99 "! Error - cannot umount bluray-ondisk filesystem - check df"

# alt.test for not mounted
[ `df |grep bluray-ondisk |wc -l` -gt 0 ] && failexit 99 "! Error - bluray-ondisk filesystem is still mounted - check df"

mount /mnt/bluraytemp25
[ `df |grep bluraytemp25 |wc -l` -gt 0 ] || failexit 101 "! Error - bluraytemp25 filesystem is not mounted - check df"

mkdir -pv /mnt/bluray-ondisk
touch /mnt/bluray-ondisk/NOTHERE 

# bluray disc size REF: http://forum.blu-ray.com/showthread.php?t=76407
#  24,220,008,448 Bytes  after formatting
# ALTREF: http://forum.my.nero.com/index.php?showtopic=13290
#  25.000.000.000 bytes = 24.414.062 KB = 23.841 MB = 23.28 GB

brsize="23652352K" # overly conservative, but this is the "spec" and should work with ANY BR disc

brsize="24129280K" # VERIFIED WORKS OK 2016.mar WITH OVERBURN
#-rw-r--r--  1 root root 24708382720 Mar 24 16:13 bdiscimage.udf

# TODO - try: 24176630K with test burn
# TODO REF: http://www.hughsnews.ca/faqs/authoritative-blu-ray-disc-bd-faq/9-disc-capacity
# 24,438,784.977 KB

brsize="24176630K" # TODO VERIFY WORKS WITH OVERBURN?


# this is on non-compr zfs with quota
cd /mnt/bluraytemp25 && truncate -s $brsize bdiscimage.udf
cd /mnt/bluraytemp25 && mkudffs --vid="$volid" bdiscimage.udf && \
  mount -t udf -o loop /mnt/bluraytemp25/bdiscimage.udf  /mnt/bluray-ondisk -onoatime

cd /mnt/bluray-ondisk || failexit 199 "! Error - cant cd to mnt/bluray-ondisk - check df"

mkdir -pv bkp && chown dave /mnt/bluray-ondisk/bkp

df -h |grep bluray
# also see fixudf

exit;

To recreate: 
# zfs-newds.sh 10 zsg25lap1 bluraytemp
zsg25lap1/bluraytemp       570415104      1024 570414080   1% /zsg25lap1/bluraytemp

# zfs set mountpoint=/mnt/bluraytemp25 zsg25lap1/bluraytemp
zsg25lap1/bluraytemp       570416128      1024 570415104   1% /mnt/bluraytemp25


#brsize="24414012K" # bigger, but reduced a bit for FS overhead = FAIL, too big
#-rw-r--r--  1 root root 24999948288 Mar 19 01:20 bdiscimage.udf
# BURNFAIL:
#24708382720/24999948288 (98.8%) @2.4x, remaining 0:26 RBU 100.0% UBU  98.6% = OK (with overburn enabled)
#24745082880/24999948288 (99.0%) @2.4x, remaining 0:22 RBU 100.0% UBU  98.6%
#:-[ WRITE@LBA=b87400h failed with SK=5h/LOGICAL BLOCK ADDRESS OUT OF RANGE]: No space left on device
# bc:
#24708382720/1024
#24129280.00


24220008448/1024
23652352.00

Filesystem                       Type     Size  Used Avail Use% Mounted on
bigvaiterazfs                    zfs      280G     0  280G   0% /bigvaiterazfs
bigvaiterazfs/bluraytemp         zfs       24G   22G  2.2G  91% /mnt/bluraytemp25
/dev/loop0                       udf       23G   22G  1.3G  95% /mnt/bluray-ondisk

Free space on disc: 24220008448 formatted, according to  ' dvd+rw-mediainfo /dev/bluray '

Free space from -mediainfo: 24756879360 - theoretical limit?
24756879360/1024
24176640.00 - a bit less, but maybe safer with other brands of BR disc

