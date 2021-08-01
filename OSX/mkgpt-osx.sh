#!/bin/bash

# mod for osx 2019.0418 
# typically "disk9" but also want to be able to process long-form by-disk or by-path
# NOTE no wwn's here to worry about
argg="$1"

source ~/bin/failexit.mrg
 ~/bin/boojum/dbi-commasep-osx.sh # run direct, don't SOURCE this

# find short form
infile1=/tmp/dbi-commasep--boojum.csv
infile2=/tmp/dbi-eqsep--boojum.txt

[ -e "$infile1" ] || failexit 404 "$infile1 file not found!"

# leave orig file in place, replace all commas with '=' to file2 for our use
sed 's/,/=/g' $infile1 > $infile2
# 2nd pass - delete all /dev/ in infile2 in-place
sed -i 's|/dev/||g' $infile2

DEV=/dev
DBI=/var/run/disk/by-id
DBP=/var/run/disk/by-path
DBS=/var/run/disk/by-serial

# fryserver will have multiple results per-device
# if length = 5 we already have short "disk9", else search for long and GET shorty
# ${#string}
#set -x
if [ ${#argg} -lt 6 ]; then
  sdev=$argg
else
# grep for what we were passed, take 1st result, print 1st field = shortdev
  res=`grep $argg $infile2 |head -n1 |awk -F'=' '{ print $1 }'`
  sdev=`echo $res |awk -F/ '{print $3}'`
#  [ -e $sdev ] || failexit 999 "Short-form device $argg does not exist in /dev!"
fi

[ `echo $sdev |grep -c "disk"` -gt 0 ] || failexit 502 "Teh craziness happen - cannot find shortdev from $argg"
  [ -e /dev/$sdev ] || failexit 999 "Short-form device $argg does not exist in /dev!"

smartctl -a /dev/$sdev |head -n 16
#fdisk -l /dev/$sdev |awk 'NF>0' 2>/dev/null
diskutil info /dev/$sdev |awk 'NF>0' # skip blank lines

ls -l $DBI/* $DBP/* $DBS/* |grep $argg |awk '{ print $9" "$10" "$11 }' |column -t
#ls -l /dev/disk/by-path|grep $argg

echo "THIS WILL DESTRUCTIVELY APPLY A GPT LABEL + ZPOOL LABELCLEAR to $argg // $sdev"
echo "-ARE YOU SURE- PK OR ^C"
read

#exit # EARLY!

# COMMIT!
# REF: https://openzfsonosx.org/forum/viewtopic.php?f=11&t=2847

(set -x
 zpool labelclear /dev/$sdev
 zpool labelclear -f /dev/$sdev''s1  ## ONLY ENABLE IF NEEDED

# diskutil partitionDisk $sdev GPT 1  ## no way to do this easily
 gpt destroy $sdev && gpt create $sdev
# parted -s /dev/$sdev mklabel gpt || failexit 99 "! Failed to apply GPT label to /dev/$sdev"
 
)

#fdisk -l /dev/$sdev
diskutil list $sdev

exit;

2021.0731 fixed for disk10 and above (iscsi)

2017.1207 mod to find drive using short dev/sdX or long dev/disk/by-id or by-path
# TODO handle wwn BUT deny -part9

# less /tmp/dbi-eqsep--boojum.txt 
sda=ata-ST4000VN008-2DR166_ZGY005C6
sda=pci-0000:01:00.0-sas-0x4433221100000000-lun-0
sdb=ata-ST4000VN000-2AH166_WDH0SB5N
sdb=pci-0000:01:00.0-sas-0x4433221103000000-lun-0
sdc=ata-ST4000VN000-1H4168_Z3076XVL
sdc=pci-0000:01:00.0-sas-0x4433221101000000-lun-0
sdd=ata-ST4000VN000-1H4168_Z3073Z7X
sdd=pci-0000:01:00.0-sas-0x4433221102000000-lun-0
sde=ata-ST9500420AS_5VJ5FDYE
sde=pci-0000:02:00.0-sas-0x4433221101000000-lun-0
sdf=ata-ST1000LM024_HN-M101MBB_S2RQJ9CC903375
sdf=pci-0000:02:00.0-sas-0x4433221103000000-lun-0
sdg=pci-0000:00:14.0-usb-0:1:1.0-scsi-0:0:0:0
sdg=usb-SanDisk_Ultra_Fit_4C530001171117106334-0:0
sdh=ata-ST2000VN000-1HJ164_W523GA5J
sdi=ata-ST2000VN000-1HJ164_W5238TSL
sdj=ata-ST2000VN004-2E4164_Z521TRH4
sdk=ata-ST2000VN000-1HJ164_W7212LTE
sdl=ata-ST2000VN000-1HJ164_W72127JB
sdm=ata-ST2000VN000-1HJ164_Z520DLXJ
sr0=ata-HL-DT-ST_DVDRAM_GH24NSB0_K2EG1QE3246
