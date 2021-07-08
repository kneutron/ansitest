#!/bin/bash

echo "$0 - 2021 Dave Bechtel - make a ZFS DRAID pool"
echo "- pass arg1='reset' to destroy test pool"
echo "- pass arg1='fail' and arg2=dev2fail to simulate failure"
echo "Reboot to clear simulated device failures before issuing 'reset'"

# Requires at least zfs 2.1.0
DD=/dev/disk
DBI=/dev/disk/by-id

# total disks for pool / children
td=24 # 26 - root and 1 spare

# raidz level (usually 2)
rzl=1

# spares - per vdev
spr=1 

# TODO EDITME
zp=zdraidtest

function zps () {
  zpool status -v |awk 'NF>0'
}

#pooldisks=$(echo /dev/sd{b..y})

#pooldisks1=$(echo /dev/sd{b..m})
#pooldisks2=$(echo /dev/sd{n..y})
#pooldisks=$pooldisks1' '$pooldisks2 # need entire set for reset

# 24 disks = groups of 8
pooldisks1=$(echo /dev/sd{b..i}) # bcdefghi
pooldisks2=$(echo /dev/sd{j..q}) # jklmnopq
pooldisks3=$(echo /dev/sd{r..y}) # rstuvwxy # z is reserved phys spare
pooldisks=$pooldisks1' '$pooldisks2' '$pooldisks3 # need entire set for reset
#pooldisks=$pooldisks1' '$pooldisks2' '$pooldisks3' '$pooldisks4' '$pooldisks5' '$pooldisks6 # need entire set for reset

# 24, groups of 6 drives = 4 vdevs
# 1   2   3   4   5   6    1   2   3   4   5   6   1   2   3   4   5   6   1   2   3   4   5   6
# sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy
# D   D   D   Z2  Z2  S               = draid2:3d:6'c':1's'
# D   D   D   D   Z1  S               = draid1:4d:6'c':1's'
# D   D   D   D   D   Z1 (no vspare)  = draid1:5d:6'c':0's'


# extending to 32 disks
#pooldisks2=$(echo /dev/sda{a..h})
#sdaa sdab sdac sdad sdae sdaf sdag sdah

# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

# cre8 drive translation table - NOTE 32 disk config gets overridden vv
source ~/bin/boojum/draid-pooldisks-assoc.sh $td

# Flame the pool and start over from 0
if [ "$1" = "reset" ]; then

# no need to worry if its not imported / already destroyed
  if [ $(zpool list |grep -c $zp) -gt 0 ]; then
    zpool destroy $zp || failexit 999 "Failed to destroy $zp"
  fi
    
  for d in $pooldisks; do
    echo -e -n "o Clearing label for disk $d          \r"
    zpool labelclear -f "$d"1
  done
  echo ''
# also reset hotspares
# echo ${hotspares[@]}
# zpool status -v |egrep 'sdz|sday|sdaz|sdby|sdbz|sdcy|sdcz'
  for d in ${hotspares[@]}; do
#echo $d # DEBUG
    echo -e -n "o Clearing label for Hotspare disk $d                 \r"
    zpool labelclear -f "/dev/$d"1
  done
  echo ''

  zpool status -v

  exit; # early
fi

# Simulate a drive failure; if zed daemon is running, a spare should auto kick in
if [ "$1" = "fail" ]; then
# NOTE we do NO error checking here, so if you fail your ROOT DISK, THAT'S ON YOU!

  echo "$(date) - $0 - Simulating disk failure for $2 $(ls -lR $DD |grep $2)" |tee |logger
  echo offline > /sys/block/$2/device/state
  cat /sys/block/$2/device/state |tee |logger

  time dd if=/dev/urandom of=/$zp/^^tmpfileDELME bs=1M count=$td; sync
  # force a write; if not work, try scrub
    
  zps 

  exit; # early
fi

# zpool create <pool> draid[<parity>][:<data>d][:<children>c][:<spares>s] <vdevs...>
# ex: draid2:4d:1s:11c

# data - The number of data devices per redundancy group
# In general a smaller value of D will increase IOPS, improve the compression
# ratio, and speed up resilvering at the expense of total usable capacity.

# SLOW writing to zstd-3
#   draid$rzl:8d:12'c':$spr's' $pooldisks1 \
#   draid$rzl:8d:12'c':$spr's' $pooldisks2 \

# handy REF: https://arstechnica.com/gadgets/2021/07/a-deep-dive-into-openzfs-2-1s-new-distributed-raid-topology/

# groups of 8 drives = 3 vdevs (z is reserved for physical hotspare)
# sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy
# 1   2   3   4   5   6   7   8    1   2   3   4   5   6   7   8   1   2   3   4   5   6   7   8
# D   D   D   D   D   Z2  Z2  S              = draid2:5d:8'c':1's'
# D   D   D   D   D   D   Z1  S              = draid1:6d:8'c':1's'
# D   D   D   D   D   D   D   Z1 (no vspare) = draid1:7d:8'c':0's'

# TODO EDITME
iteration=1
if [ "$iteration" = "1" ]; then 
# compression=zstd-3
# -o ashift=12
# NOTE will NOT do 7d
( set -x
time zpool create -o autoexpand=on -o autoreplace=on -O atime=off -O compression=lz4 \
  $zp \
   draid$rzl:6d:8'c':$spr's' $pooldisks1 \
   draid$rzl:6d:8'c':$spr's' $pooldisks2 \
   draid$rzl:6d:8'c':$spr's' $pooldisks3 \
|| failexit 101 "Failed to create DRAID"
)
elif [ "$iteration" = "2" ]; then 
# raidz level (usually 2)
  rzl=2
# spares - per vdev
  spr=1 
( set -x
time zpool create -o autoexpand=on -o autoreplace=on -O atime=off -O compression=lz4 \
  $zp \
   draid$rzl:5d:8'c':$spr's' $pooldisks1 \
   draid$rzl:5d:8'c':$spr's' $pooldisks2 \
   draid$rzl:5d:8'c':$spr's' $pooldisks3 \
|| failexit 101 "Failed to create DRAID"
)
elif [ "$iteration" = "3" ]; then 
# This appears to be a "useless" config, you gain nothing apparent by going down to 5D
# raidz level (usually 2)
  rzl=1
# spares - per vdev
  spr=1 
( set -x
time zpool create -o autoexpand=on -o autoreplace=on -O atime=off -O compression=lz4 \
  $zp \
   draid$rzl:5d:8'c':$spr's' $pooldisks1 \
   draid$rzl:5d:8'c':$spr's' $pooldisks2 \
   draid$rzl:5d:8'c':$spr's' $pooldisks3 \
|| failexit 101 "Failed to create DRAID"
)
else
# One Big Mother, 1 vspare, 0x pspares
# -o ashift=12
# raidz level (usually 2)
  rzl=1
# spares
  spr=1
( set -x
  time zpool create -o autoexpand=on -O atime=off -O compression=lz4 \
    $zp \
     draid$rzl:8d:$td'c':$spr's' $pooldisks \
  || failexit 101 "Failed to create DRAID"
)
#rc=$?
#[ $rc -gt 0 ] && exit $rc
fi

rc=$?
[ $rc -gt 0 ] && exit $rc
# ^ Need this check because of subshell, will not exit early otherwise

#[ $(zpool list |grep -c "no pools") -eq 0 ] && \
#  zpool add $zp spare ${hotspares[@]}

# The below will not work: gets error
#   "requested number of dRAID data disks per group 6 is too high, at most 3 disks are available for data"
#( set -x
#time zpool create -o ashift=12 -o autoexpand=on -O atime=off -O compression=lz4 \
#  $zp \
#   draid$rzl:6d:6'c':$spr's' $pooldisks1 \
#   draid$rzl:6d:6'c':$spr's' $pooldisks2 \
#   draid$rzl:6d:6'c':$spr's' $pooldisks3 \
#   draid$rzl:6d:6'c':$spr's' $pooldisks4 \
#|| failexit 101 "Failed to create DRAID"
#)

# requires external script in the same PATH
# going with lz4 so not limited by CPU for compression
zfs-newds.sh 11 $zp shrcompr
zfs-newds.sh 10 $zp notshrcompr
zfs-newds-zstd.sh 10 $zp notshrcompr-zstd
zfs-newds.sh 00 $zp notshrnotcompr

zps 
zpool list
zfs list

df -hT |egrep 'ilesystem|zfs'

echo "NOTE - best practice is to export the pool and # zpool import -a -d $DBI"

date
exit;


# REFS:
https://openzfs.github.io/openzfs-docs/Basic%20Concepts/dRAID%20Howto.html

https://klarasystems.com/articles/openzfs-draid-finally/

https://www.reddit.com/r/zfs/comments/lnoh7v/im_trying_to_understand_how_draid_works_but_im/

https://insider-voice.com/a-deep-dive-into-the-new-openzfs-2-1-distributed-raid-topology/

https://docs.google.com/presentation/d/1uo0nBfY84HIhEqGWEx-Tbm8fPbJKtIP3ICo4toOPcJo/edit#slide=id.g9d6b9fd59f_0_27

Group size must divide evenly into draid size
E.g., 30 drives can only support
3 drive group
5 drive group
10 drive group
15 drive group

Only need to specify group size at creation

Group Size - the number of pieces the data is partitioned into plus the amount of parity
o The amount of parity determines the redundancy
o The number of data pieces determines the overhead

dRAID Size - the number of drives used for data
(Does not include spare drives)

-----

# make a OneBigMother 24-disk draid with raidz1, 1 VDEV, 8 data disks, 24 children, 0 vspare + 5 pspares

+ zpool create -o autoexpand=on -O atime=off -O compression=lz4 zdraidtest \
 draid1:8d:24c:0s \
   /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg /dev/sdh /dev/sdi \
   /dev/sdj /dev/sdk /dev/sdl /dev/sdm /dev/sdn /dev/sdo /dev/sdp /dev/sdq \
   /dev/sdr /dev/sds /dev/sdt /dev/sdu /dev/sdv /dev/sdw /dev/sdx /dev/sdy
real    0m3.210s

Dumping shortdisk == longdisk assoc array to /tmp/draid-pooldisks-assoc.log

+ zfs create -o atime=off -o compression=lz4 -o sharesmb=on -o xattr=sa -o recordsize=1024k zdraidtest/shrcompr
cannot share 'zdraidtest/shrcompr: system error': SMB share creation failed
filesystem successfully created, but not shared
changed ownership of '/zdraidtest/shrcompr' from root to user

Filesystem          Type      Size  Used Avail Use% Mounted on
zdraidtest/shrcompr zfs        76G  1.0M   76G   1% /zdraidtest/shrcompr

+ zfs create -o atime=off -o compression=lz4 -o sharesmb=off -o recordsize=1024k zdraidtest/notshrcompr
changed ownership of '/zdraidtest/notshrcompr' from root to user

Filesystem             Type      Size  Used Avail Use% Mounted on
zdraidtest/notshrcompr zfs        76G  1.0M   76G   1% /zdraidtest/notshrcompr

+ zfs create -o atime=off -o compression=off -o sharesmb=off -o recordsize=1024k zdraidtest/notshrnotcompr
changed ownership of '/zdraidtest/notshrnotcompr' from root to user

Filesystem                Type      Size  Used Avail Use% Mounted on
zdraidtest/notshrnotcompr zfs        76G  1.0M   76G   1% /zdraidtest/notshrnotcompr

  pool: zdraidtest
 state: ONLINE
config:
        NAME                  STATE     READ WRITE CKSUM
        zdraidtest            ONLINE       0     0     0
          draid1:8d:24c:0s-0  ONLINE       0     0     0
            sdb               ONLINE       0     0     0
            sdc               ONLINE       0     0     0
            sdd               ONLINE       0     0     0
            sde               ONLINE       0     0     0
            sdf               ONLINE       0     0     0
            sdg               ONLINE       0     0     0
            sdh               ONLINE       0     0     0
            sdi               ONLINE       0     0     0
            sdj               ONLINE       0     0     0
            sdk               ONLINE       0     0     0
            sdl               ONLINE       0     0     0
            sdm               ONLINE       0     0     0
            sdn               ONLINE       0     0     0
            sdo               ONLINE       0     0     0
            sdp               ONLINE       0     0     0
            sdq               ONLINE       0     0     0
            sdr               ONLINE       0     0     0
            sds               ONLINE       0     0     0
            sdt               ONLINE       0     0     0
            sdu               ONLINE       0     0     0
            sdv               ONLINE       0     0     0
            sdw               ONLINE       0     0     0
            sdx               ONLINE       0     0     0
            sdy               ONLINE       0     0     0
        spares
          sdz                 AVAIL
          sday                AVAIL
          sdaz                AVAIL
          sdby                AVAIL
          sdbz                AVAIL
errors: No known data errors

NAME         SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zdraidtest  88.0G  1.52M  88.0G        -         -     0%     0%  1.00x    ONLINE  -

NAME                        USED  AVAIL     REFER  MOUNTPOINT
zdraidtest                  948K  75.8G     96.0K  /zdraidtest
zdraidtest/notshrcompr     96.0K  75.8G     96.0K  /zdraidtest/notshrcompr
zdraidtest/notshrnotcompr  96.0K  75.8G     96.0K  /zdraidtest/notshrnotcompr
zdraidtest/shrcompr        96.0K  75.8G     96.0K  /zdraidtest/shrcompr
Filesystem                Type      Size  Used Avail Use% Mounted on
zdraidtest                zfs        76G  128K   76G   1% /zdraidtest
zdraidtest/shrcompr       zfs        76G  1.0M   76G   1% /zdraidtest/shrcompr
zdraidtest/notshrcompr    zfs        76G  1.0M   76G   1% /zdraidtest/notshrcompr
zdraidtest/notshrnotcompr zfs        76G  1.0M   76G   1% /zdraidtest/notshrnotcompr

NOTE - best practice is to export the pool and # zpool import -a -d /dev/disk/by-id

Spares for this configuration can be used for the entire pool.

-----

Below is a severely degraded pool with all physical spares in use; despite the raidz1 level it has 
sustained (6) simultaneous drive failures; one more with no replacements will kill the pool
and there are no vspares allocated, but it was configured for maximum available space:

  pool: zdraidtest
 state: DEGRADED
status: One or more devices could not be used because the label is missing or
        invalid.  Sufficient replicas exist for the pool to continue
        functioning in a degraded state.
action: Replace the device using 'zpool replace'.
   see: https://openzfs.github.io/openzfs-docs/msg/ZFS-8000-4J
  scan: scrub repaired 0B in 00:00:05 with 0 errors on Mon Jul  5 12:31:42 2021
config:
        NAME                  STATE     READ WRITE CKSUM
        zdraidtest            DEGRADED     0     0     0
          draid1:8d:24c:0s-0  DEGRADED     0     0     0
            spare-0           DEGRADED     0     0     0
              sdb             UNAVAIL      0     0     0
              sdz             ONLINE       0     0     0
            sdc               ONLINE       0     0     0
            spare-2           DEGRADED     0     0     0
              sdd             UNAVAIL      0     0     0
              sday            ONLINE       0     0     0
            sde               ONLINE       0     0     0
            spare-4           DEGRADED     0     0     0
              sdf             UNAVAIL      0     0     0
              sdaz            ONLINE       0     0     0
            sdg               ONLINE       0     0     0
            spare-6           DEGRADED     0     0     0
              sdh             UNAVAIL      0     0     0
              sdby            ONLINE       0     0     0
            sdi               ONLINE       0     0     0
            spare-8           DEGRADED     0     0     0
              sdj             UNAVAIL      0     0     0
              sdbz            ONLINE       0     0     0
            sdk               ONLINE       0     0     0
            sdl               ONLINE       0     0     0
            sdm               ONLINE       0     0     0
            sdn               ONLINE       0     0     0
            sdo               ONLINE       0     0     0
            sdp               ONLINE       0     0     0
            sdq               ONLINE       0     0     0
            sdr               ONLINE       0     0     0
            sds               ONLINE       0     0     0
            sdt               ONLINE       0     0     0
            sdu               ONLINE       0     0     0
            sdv               ONLINE       0     0     0
            sdw               ONLINE       0     0     0
            sdx               ONLINE       0     0     0
            sdy               UNAVAIL      0     0     0
        spares
          sdz                 INUSE     currently in use
          sday                INUSE     currently in use
          sdaz                INUSE     currently in use
          sdby                INUSE     currently in use
          sdbz                INUSE     currently in use
errors: No known data errors

-----

NOTE if you simulate/take a drive offline, you cant just "echo online" to it later, that wont bring it back up!
try  rescan-scsi-bus.sh  or  reboot

FIX: if a drive is offline, replace it temporarily with a builtin spare:
# zpool replace zdraidtest sdd draid2-0-0

# zps
  pool: zdraidtest
 state: DEGRADED
status: One or more devices could not be used because the label is missing or
        invalid.  Sufficient replicas exist for the pool to continue
        functioning in a degraded state.
action: Replace the device using 'zpool replace'.
   see: https://openzfs.github.io/openzfs-docs/msg/ZFS-8000-4J
  scan: resilvered 0B in 00:00:00 with 0 errors on Sat Jul  3 14:43:51 2021
config:
        NAME                  STATE     READ WRITE CKSUM
        zdraidtest            DEGRADED     0     0     0
          draid2:5d:24c:2s-0  DEGRADED     0     0     0
            sdb               ONLINE       0     0     0
            sdc               ONLINE       0     0     0
            spare-2           DEGRADED     0     0     0
              sdd             UNAVAIL      0     0     0
              draid2-0-0      ONLINE       0     0     0
            sde               ONLINE       0     0     0
            sdf               ONLINE       0     0     0
            sdg               ONLINE       0     0     0
            sdh               ONLINE       0     0     0
            sdi               ONLINE       0     0     0
            sdj               ONLINE       0     0     0
            sdk               ONLINE       0     0     0
            sdl               ONLINE       0     0     0
            sdm               ONLINE       0     0     0
            sdn               ONLINE       0     0     0
            sdo               ONLINE       0     0     0
            sdp               ONLINE       0     0     0
            sdq               ONLINE       0     0     0
            sdr               ONLINE       0     0     0
            sds               ONLINE       0     0     0
            sdt               ONLINE       0     0     0
            sdu               ONLINE       0     0     0
            sdv               ONLINE       0     0     0
            sdw               ONLINE       0     0     0
            sdx               ONLINE       0     0     0
            sdy               ONLINE       0     0     0
        spares
          draid2-0-0          INUSE     currently in use
          draid2-0-1          AVAIL
errors: No known data errors

HOWTO fix the above situation with the same disk (you rebooted / it came back online) and decouple the in-use spare:

 zpool export -a

 fdisk -l /dev/sdd #  scsi-SATA_VBOX_HARDDISK_VBbcc6c97e-f68b8368
 zpool labelclear /dev/sdd
 zpool labelclear -f /dev/sdd1

 zpool import -a 
 zpool status -v # This will show a degraded pool with a missing disk

# This wont work but gives useful info:  
 zpool replace zdraidtest spare-2 scsi-SATA_VBOX_HARDDISK_VBbcc6c97e-f68b8368 # got error, use detach

 zpool detach zdraidtest 2582498653363374334 # this was listed as UNAVAIL with the spare in-use underneath it
 zpool status -v # should now show only the spare where sdd was

# we labelcleared it so it should be ready for re-use; 
# if you want to be really thorough you can DD zeros to the entire drive but not really necessary
 zpool replace zdraidtest draid2-0-0 scsi-SATA_VBOX_HARDDISK_VBbcc6c97e-f68b8368 # same disk (sdd) but labelcleared
 zpool status -v
