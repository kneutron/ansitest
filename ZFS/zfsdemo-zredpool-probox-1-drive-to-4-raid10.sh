#!/bin/bash

# =LLC= © (C)opyright 2017 Boojum Consulting LLC / Dave Bechtel, All rights reserved.
## NOTICE: Only Boojum Consulting LLC personnel may use or redistribute this code,
## Unless given explicit permission by the author - see http://www.boojumconsultingsa.com
#

# TODO color print banner

# Intent - start with (1) 1TB RED disk in Probox 4-bay,
# + Add mirror to 1TB (RAID1)
# + Add another 2-disk mirror set to make RAID10

#usb-WDC_WD10_EFRX-68FYTN0_152D00539000-0:0 -> sdb	START WITH THIS		pooldisks[1]
# + Add 100MB file(s) of random data
#usb-WDC_WD10_EFRX-68FYTN0_152D00539000-0:1 -> sdc	+Add mirror				pooldisks[2] = RAID1
#usb-WDC_WD10_EFRX-68FYTN0_152D00539000-0:2 -> sdd +ADD RAID10A				pooldisks[3] = RAID10
#usb-WDC_WD10_EFRX-68FYTN0_152D00539000-0:3 -> sde +ADD RAID10B				pooldisks[4] = RAID10

# HOWTO - edit, search this file for TODO and replace things where necessary before running!
# NOTE this script will auto-GPT-label new disks and destroy existing pool+data!!!

# GOAL - create an expandable ZFS pool in real-time

# NOTE special handling for starting with RAID0 (D1+D2=NOMIR) then adding (1&3 + 2&4=RAID10) 
# -- available space will only increase when an entire MIRROR COLUMN is done!
# assuming:
#        zdynpool1              ONLINE       0     0     0
#  1 *     mirror-0             ONLINE       0     0     0
#      a     /zdisks/zdyndisk1  ONLINE       0     0     0
#      b     /zdisks/zdyndisk3  ONLINE       0     0     0
#  2 *     mirror-1             ONLINE       0     0     0
#      c     /zdisks/zdyndisk2  ONLINE       0     0     0
#      d     /zdisks/zdyndisk4  ONLINE       0     0     0
# To increase available space immediately, we would need to replace 1, then 3 // then 2... and finally 4 

# enables sound; set to 2 for extra debug
debugg=1

# TODO xxxxx change this to the zfs pool you are working on!
zp=zredpool1

logfile=~/zfsdemo-$zp-expand.log
> $logfile # clearit

# TODO update this 1st if disks change!
source /root/bin/getdrive-byids

# This also includes WWN
dpath=/dev/disk/by-id
#dpath=/dev/disk/by-path
# If doing SCSI drives, use this

# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

# Echo something to current console AND log
# Can also handle piped input ( cmd |logecho )
# Warning: Has trouble echoing '*' even when quoted.
function logecho () {
  args=$@

  if [ -z "$args" ]; then
    args='tmp'

    while [ 1 ]; do
      read -e -t2 args

      if [ -n "$args" ]; then
         echo $args |tee -a $logfile;
      else
        break;
      fi
    done

  else
    echo $args |tee -a $logfile;
  fi
} # END FUNC


# xxxxx TODO change disks here!
declare -a pooldisks 	# regular indexed array
pooldisks[1]=$Dzredpool1A # usb-WDC_WD10_EFRX-68FYTN0_152D00539000-0:0
pooldisks[2]=$Dzredpool1B # usb-WDC_WD10_EFRX-68FYTN0_152D00539000-0:1
pooldisks[3]=$Dzredpool1C # usb-WDC_WD10_EFRX-68FYTN0_152D00539000-0:2
pooldisks[4]=$Dzredpool1D # usb-WDC_WD10_EFRX-68FYTN0_152D00539000-0:3
#pooldisks[5]=

function waitforresilver () {
	printf `date +%H:%M:%S`' ...waiting for resilver to complete...'
	waitresilver=1
	while [ $waitresilver -gt 0 ];do 
	  waitresilver=`zpool status -v $zp |grep -c resilvering`
	  sleep 5
	done 
	echo 'Syncing to be sure...'; time sync;
	date |logecho
}

function initdisk () {
([ "$debugg" -gt 1 ] && set -x
	logecho "FYI GPT initdisk $1"
# using getdrive-byids doesnt need dpath
#  zpool labelclear $dpath/$1 || failexit 1000 "! Failed to zpool labelclear $1"
  zpool labelclear $1 || failexit 1000 "! Failed to zpool labelclear $1"
#  parted -s $dpath/$1 mklabel gpt || failexit 1234 "! Failed to apply GPT label to disk $1"
  parted -s $1 mklabel gpt || failexit 1234 "! Failed to apply GPT label to disk $1"
)
}

function logzpstatus () {
  df /$zp 
  df /$zp >> $logfile

	zpool status -v $zp |awk 'NF > 0' # no blank lines
  zpool status -v $zp >> $logfile

	zfs list $zp >> $logfile 
	zpool list $zp >> $logfile 
  echo '=====' >> $logfile
}

function nomorepool () {
 zpool status -v $1 |awk 'NF > 0'
 df -h /$1

[ "$debugg" -gt 0 ] && \
 AUDIODRIVER=alsa /usr/bin/play -q /home/dave/wavs/destruct.wav 2>/dev/null

 logecho "!!! I AM ABOUT TO DESTROY ZFS POOL $1 !!!"
 logecho "-- ENTER BOOJUM ADMIN PASSWORD TO CONFIRM OR Press ^C to abort!"
 read

 zfs umount -f $1 2>> $logfile

 zpool export $1 2>> $logfile
# zpool status $1

 zpool destroy -f $1 2>> $logfile
 zpool status -L -P -x
}

################################# TEH MAIN THING

clear
logecho `date`
#df -h

# TODO random color print
echo "*********************************************************************"
echo "*       ** Welcome to the Boojum Consulting LLC ZFS Demo! **        *"
echo "* We will start with creating a 1-disk ZFS pool with no redundancy, *"
echo "* Add a mirror disk on-the-fly to make it RAID1,                    *"
echo "* And then dynamically grow the pool to a RAID10, all in real-time! *"
echo "*********************************************************************"

# DESTROY!!
umount -f /mnt/demoshare # samba
nomorepool $zp

df -h
zpool status $zp
echo "POOL $zp SHOULD BE GONE -Press Enter TO PROCEED, or ^C"
read

# double check!
[ `df |grep $zp |wc -l` -gt 0 ] && failexit 999 "! Cannot proceed - $zp still exists!"

# getting rid of sync for each dd should speed things up
# xxx TODO alter number for however many disks
logecho "o Preparing disks..."
for i in {1..4};do
  printf $i...

# NECESSARY if re-using disks that were previously in a pool!!
  initdisk ${pooldisks[$i]}
done
    

############ create 1-disk NORAID
(set -x
 time zpool create -f -o ashift=12 -O compression=off -O atime=off $zp \
   ${pooldisks[1]} )

# Evidently we can only do 1 setting at a time... turn trace=on for this 1 command in subshell
(set -x
  zpool set autoexpand=on $zp) || failexit 99 "! Autoexpand failed with $zp"
(set -x
  zpool set autoreplace=on $zp) || failexit 992 "! Autoreplace failed with $zp"

echo ''
logecho 'o Initial state of new 1-disk pool:'
df /$zp

startdata1="NOTE Starting pool size: `date`"
startdata2=`df|head -n 1`
startdata2=$startdata2'\n'`df |grep $zp`
#Filesystem                     1K-blocks       Used Available Use% Mounted on
#zredpool2                      722824320   33628416 689195904   5% /zredpool2
#zredpool2/dvcompr              898452224  209256320 689195904  24% /zredpool2/dvcompr

echo $startdata1 >> $logfile
echo -e "$startdata2" >> $logfile

logecho 'o Populating pool with random,uncompressible data...'
# if file not there, create
[ -e /root/tmpfile ] || time dd if=/dev/urandom of=/root/tmpfile bs=1M count=100

# Make 9 copies of random data
for i in $(seq 9);do
  cp -v /root/tmpfile /$zp/tmpfile$i
done

sync

ls -lh /$zp >> $logfile

echo ''
logecho 'o We should now have a 1-disk, non-redundant ZFS pool with some data in it:'
logzpstatus

echo '';printf 'Press Enter to add a Mirror disk to the single-disk pool, or ^C:';read -n 1


########### add mirror to 1-disk
# REF: http://docs.oracle.com/cd/E19253-01/819-5461/6n7ht6qvl/index.html
echo 'o Adding mirror to single-disk pool for RAID1...' >> $logfile
(set -x
 time zpool attach $zp \
  ${pooldisks[1]} ${pooldisks[2]} )

echo ''
logecho 'o We should now have a 2-disk, MIRRORED ZFS pool with RAID1 redundancy:'
logzpstatus

echo ''
echo '! We need to wait for the resilver to complete before proceeding! # zpool status  ## until resilvered'

waitforresilver
logzpstatus

logecho 'o NOTE that available pool space has not increased yet - we have only added a "failsafe" mirror drive!'
echo '';printf 'Press Enter to add another set of mirrored disks to the existing pool to make the pool RAID10:';read -n 1

########### add 2-disk mirror to 2-disk for RAID10
# REF: http://docs.oracle.com/cd/E19253-01/819-5461/6n7ht6qvk/index.html
(set -x
 time zpool add -o ashift=12 $zp \
   mirror ${pooldisks[3]} ${pooldisks[4]} )

waitforresilver

logecho 'o Populating pool with a bit more data... Watch the blinkenlights!'
for i in $(seq 4);do
  cp -v /root/tmpfile /$zp/tmpfileTWO$i
done
  
sync
  
echo ''
logecho 'o We should now have a 4-disk, redundant pool with RAID10:'
logzpstatus

echo '';logecho 'o NOTE that the available pool space should be approximately 2x what we had before, minus a bit of overhead...'

echo ''
logecho "REMEMBER we started with:"
logecho "$startdata1"
echo -e "$startdata2" 
echo -e "$startdata2" >> $logfile
echo ''
logecho "NOW we have a fully expanded-in-place RAID10 ZFS pool with more free space..."
logecho "+ Pool size after in-situ expansion, with NO DOWNTIME:"

df /$zp 
df /$zp >> $logfile

echo ''

# Make some datasets
# TODO make func.mrg
# zfs create -o compression=lz4 -o atime=off -o sharesmb=on zredpool2/0DISPOSABLE-VEEAM-P3300-BKP ;chown dave /zredpool2/0DISPOSABLE-VEEAM-P3300-BKP

# TODO change if needed
myuser=dave; carg=""

myds=sambasharecompr
[ "$debugg" -gt 1 ] && carg="-v"
(set -x
  zfs create -o compression=lz4 -o atime=off -o sharesmb=on $zp/$myds ; chown $carg $myuser /$zp/$myds ) # chown -v

myds=notsharedcompr
(set -x                       
  zfs create -o compression=lz4 -o atime=off -o sharesmb=off $zp/$myds ; chown $carg $myuser /$zp/$myds )

# mount samba share locally
mount /mnt/demoshare

logecho "o Taking demo snapshot of $zp and all datasets..." 
# we dont need this, pool is brand new
#zfs destroy -R -v $zp@demosnapshot 2>&1 >>$logfile
zfs snapshot -r $zp@demosnapshot
zfs-list-snaps--boojum.sh #|logecho
zfs-list-snaps--boojum.sh >> $logfile

logecho "# time zfs rollback $zp@demosnapshot ## after deleting data"

echo "# mount //court2130antix/zredpool1_sambasharecompr /mnt/tmp -ouid=dave,credentials=/root/.smb-court" >> $logfile
df -h -T >> $logfile

logecho 'o Complete!'
logecho `date`

exit;

2017.0323 SUCCESSFULLY TESTED 4X1TB WD RED DISKS with Probox 4-bay! 
