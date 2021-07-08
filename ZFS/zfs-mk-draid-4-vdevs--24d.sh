#!/bin/bash

echo "$0 - 2021 Dave Bechtel - make a ZFS DRAID pool"
echo "- pass arg1='reset' to destroy test pool"
echo "- pass arg1='fail' and arg2=dev2fail to simulate failure"
echo "Reboot to clear simulated device failures before issuing 'reset'"

# Requires at least zfs 2.1.0
DD=/dev/disk
DBI=/dev/disk/by-id

# total disks for pool / children
td=24

# raidz level (usually 2)
rzl=1

# spares
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

pooldisks1=$(echo /dev/sd{b..g})
pooldisks2=$(echo /dev/sd{h..m})
pooldisks3=$(echo /dev/sd{n..s})
pooldisks4=$(echo /dev/sd{t..y})
pooldisks=$pooldisks1' '$pooldisks2' '$pooldisks3' '$pooldisks4 # need entire set for reset
#pooldisks=$pooldisks1' '$pooldisks2' '$pooldisks3' '$pooldisks4' '$pooldisks5' '$pooldisks6 # need entire set for reset
# sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy
# 1   2   3   4   5   6    1   2   3   4   5   6   1   2   3   4   5   6   1   2   3   4   5   6
# D   D   D   Z2  Z2  S
# D   D   D   D   Z1  S
# D   D   D   D   D   Z1 (no vspare)

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
  logger "$(date) - $0 - RESET issued - destroying $zp"

# no need to worry if its not imported / already destroyed
  if [ $(zpool list |grep -c $zp) -gt 0 ]; then
    zpool destroy $zp || failexit 999 "Failed to destroy $zp"
  fi

  for d in $pooldisks; do
    echo -e -n "o Clearing label for disk $d                          \r"
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

# also cp syslog
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

# In general a smaller value of D will increase IOPS, improve the compression
# ratio, and speed up resilvering at the expense of total usable capacity.

# SLOW writing to zstd-3
#   draid$rzl:8d:12'c':$spr's' $pooldisks1 \
#   draid$rzl:8d:12'c':$spr's' $pooldisks2 \

# TODO EDITME
#iteration=OBM
iteration=2
if [ "$iteration" = "1" ]; then 
# compression=zstd-3
( set -x
time zpool create -o ashift=12 -o autoexpand=on -O atime=off -O compression=lz4 \
  $zp \
   draid$rzl:4d:6'c':$spr's' $pooldisks1 \
   draid$rzl:4d:6'c':$spr's' $pooldisks2 \
   draid$rzl:4d:6'c':$spr's' $pooldisks3 \
   draid$rzl:4d:6'c':$spr's' $pooldisks4 \
|| failexit 101 "Failed to create DRAID"
)
elif [ "$iteration" = "2" ]; then
# 4xVDEVs with 4 vspares
# raidz level (usually 2)
  rzl=2
# spares
  spr=1
( set -x
time zpool create -o autoreplace=on -o autoexpand=on -O atime=off -O compression=lz4 \
  $zp \
   draid$rzl:3d:6'c':$spr's' $pooldisks1 \
   draid$rzl:3d:6'c':$spr's' $pooldisks2 \
   draid$rzl:3d:6'c':$spr's' $pooldisks3 \
   draid$rzl:3d:6'c':$spr's' $pooldisks4 \
|| failexit 101 "Failed to create DRAID"
)
else
# One Big Mother
# -o ashift=12
# raidz level (usually 2)
  rzl=2
# spares - this is a 96-drive pool, you DON'T want to skimp!
  spr=6
( set -x
  time zpool create -o autoreplace=on -o autoexpand=on -O atime=off -O compression=lz4 \
    $zp \
     draid$rzl:8d:$td'c':$spr's' $pooldisks \
  || failexit 101 "Failed to create DRAID"
)
fi

rc=$?
[ $rc -gt 0 ] && exit $rc
# ^ Need this check because of subshell, will not exit early otherwise

# [ $(zpool list |grep -c "no pools") -eq 0 ] && \
#   zpool add $zp spare ${hotspares[0]} ${hotspares[1]} ${hotspares[2]} ${hotspares[3]} 
# NOTE we're still keeping a few pspares in reserve

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

# make a draid with raidz2, x4 VDEVs, 3 data disks, 6 children, 1 spare

 zpool create -o ashift=12 -o autoexpand=on -O atime=off -O compression=lz4 \
  zdraidtest \
   draid2:3d:6c:1s /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg \
   draid2:3d:6c:1s /dev/sdh /dev/sdi /dev/sdj /dev/sdk /dev/sdl /dev/sdm \
   draid2:3d:6c:1s /dev/sdn /dev/sdo /dev/sdp /dev/sdq /dev/sdr /dev/sds \
   draid2:3d:6c:1s /dev/sdt /dev/sdu /dev/sdv /dev/sdw /dev/sdx /dev/sdy
real    0m3.515s
user    0m0.039s
sys     0m0.136s

+ zfs create -o atime=off -o compression=lz4 -o sharesmb=on -o xattr=sa -o recordsize=1024k zdraidtest/shrcompr
cannot share 'zdraidtest/shrcompr: system error': SMB share creation failed
filesystem successfully created, but not shared
changed ownership of '/zdraidtest/shrcompr' from root to user

Filesystem          Type      Size  Used Avail Use% Mounted on
zdraidtest/shrcompr zfs        21T  1.0M   21T   1% /zdraidtest/shrcompr

+ zfs create -o atime=off -o compression=lz4 -o sharesmb=off -o recordsize=1024k zdraidtest/notshrcompr
changed ownership of '/zdraidtest/notshrcompr' from root to user

Filesystem             Type      Size  Used Avail Use% Mounted on
zdraidtest/notshrcompr zfs        21T  1.0M   21T   1% /zdraidtest/notshrcompr

  pool: zdraidtest
 state: ONLINE
config:
        NAME                 STATE     READ WRITE CKSUM
        zdraidtest           ONLINE       0     0     0
          draid2:3d:6c:1s-0  ONLINE       0     0     0
            sdb              ONLINE       0     0     0
            sdc              ONLINE       0     0     0
            sdd              ONLINE       0     0     0
            sde              ONLINE       0     0     0
            sdf              ONLINE       0     0     0
            sdg              ONLINE       0     0     0
          draid2:3d:6c:1s-1  ONLINE       0     0     0
            sdh              ONLINE       0     0     0
            sdi              ONLINE       0     0     0
            sdj              ONLINE       0     0     0
            sdk              ONLINE       0     0     0
            sdl              ONLINE       0     0     0
            sdm              ONLINE       0     0     0
          draid2:3d:6c:1s-2  ONLINE       0     0     0
            sdn              ONLINE       0     0     0
            sdo              ONLINE       0     0     0
            sdp              ONLINE       0     0     0
            sdq              ONLINE       0     0     0
            sdr              ONLINE       0     0     0
            sds              ONLINE       0     0     0
          draid2:3d:6c:1s-3  ONLINE       0     0     0
            sdt              ONLINE       0     0     0
            sdu              ONLINE       0     0     0
            sdv              ONLINE       0     0     0
            sdw              ONLINE       0     0     0
            sdx              ONLINE       0     0     0
            sdy              ONLINE       0     0     0
        spares
          draid2-0-0         AVAIL
          draid2-1-0         AVAIL
          draid2-2-0         AVAIL
          draid2-3-0         AVAIL
errors: No known data errors

NAME         SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zdraidtest  36.4T  5.61M  36.4T        -         -     0%     0%  1.00x    ONLINE  -

NAME                     USED  AVAIL     REFER  MOUNTPOINT
zdraidtest              2.24M  21.0T      278K  /zdraidtest
zdraidtest/notshrcompr   278K  21.0T      278K  /zdraidtest/notshrcompr
zdraidtest/shrcompr      278K  21.0T      278K  /zdraidtest/shrcompr

Filesystem             Type      Size  Used Avail Use% Mounted on
zdraidtest             zfs        21T  384K   21T   1% /zdraidtest
zdraidtest/shrcompr    zfs        21T  1.0M   21T   1% /zdraidtest/shrcompr
zdraidtest/notshrcompr zfs        21T  1.0M   21T   1% /zdraidtest/notshrcompr

NOTE - best practice is to export the pool and # zpool import -a -d /dev/disk/by-id

-----

A different iteration - raidz1 with  4 data disks, 6 children, 1 spare = more space available
 since we are using small (2TB) disks this should not be an issue

 zpool create -o ashift=12 -o autoexpand=on -O atime=off -O compression=lz4 \
  zdraidtest \
   draid1:4d:6c:1s /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg \
   draid1:4d:6c:1s /dev/sdh /dev/sdi /dev/sdj /dev/sdk /dev/sdl /dev/sdm \
   draid1:4d:6c:1s /dev/sdn /dev/sdo /dev/sdp /dev/sdq /dev/sdr /dev/sds \
   draid1:4d:6c:1s /dev/sdt /dev/sdu /dev/sdv /dev/sdw /dev/sdx /dev/sdy
real    0m3.288s
user    0m0.034s
sys     0m0.162s

+ zfs create -o atime=off -o compression=lz4 -o sharesmb=on -o xattr=sa -o recordsize=1024k zdraidtest/shrcompr
cannot share 'zdraidtest/shrcompr: system error': SMB share creation failed
filesystem successfully created, but not shared
changed ownership of '/zdraidtest/shrcompr' from root to user

Filesystem          Type      Size  Used Avail Use% Mounted on
zdraidtest/shrcompr zfs        29T  1.0M   29T   1% /zdraidtest/shrcompr

+ zfs create -o atime=off -o compression=lz4 -o sharesmb=off -o recordsize=1024k zdraidtest/notshrcompr
changed ownership of '/zdraidtest/notshrcompr' from root to user

Filesystem             Type      Size  Used Avail Use% Mounted on
zdraidtest/notshrcompr zfs        29T  1.0M   29T   1% /zdraidtest/notshrcompr

  pool: zdraidtest
 state: ONLINE
config:
        NAME                 STATE     READ WRITE CKSUM
        zdraidtest           ONLINE       0     0     0
          draid1:4d:6c:1s-0  ONLINE       0     0     0
            sdb              ONLINE       0     0     0
            sdc              ONLINE       0     0     0
            sdd              ONLINE       0     0     0
            sde              ONLINE       0     0     0
            sdf              ONLINE       0     0     0
            sdg              ONLINE       0     0     0
          draid1:4d:6c:1s-1  ONLINE       0     0     0
            sdh              ONLINE       0     0     0
            sdi              ONLINE       0     0     0
            sdj              ONLINE       0     0     0
            sdk              ONLINE       0     0     0
            sdl              ONLINE       0     0     0
            sdm              ONLINE       0     0     0
          draid1:4d:6c:1s-2  ONLINE       0     0     0
            sdn              ONLINE       0     0     0
            sdo              ONLINE       0     0     0
            sdp              ONLINE       0     0     0
            sdq              ONLINE       0     0     0
            sdr              ONLINE       0     0     0
            sds              ONLINE       0     0     0
          draid1:4d:6c:1s-3  ONLINE       0     0     0
            sdt              ONLINE       0     0     0
            sdu              ONLINE       0     0     0
            sdv              ONLINE       0     0     0
            sdw              ONLINE       0     0     0
            sdx              ONLINE       0     0     0
            sdy              ONLINE       0     0     0
        spares
          draid1-0-0         AVAIL
          draid1-1-0         AVAIL
          draid1-2-0         AVAIL
          draid1-3-0         AVAIL
errors: No known data errors

NAME         SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zdraidtest  36.4T  5.43M  36.4T        -         -     0%     0%  1.00x    ONLINE  -

NAME                     USED  AVAIL     REFER  MOUNTPOINT
zdraidtest              3.00M  28.9T      383K  /zdraidtest
zdraidtest/notshrcompr   383K  28.9T      383K  /zdraidtest/notshrcompr
zdraidtest/shrcompr      383K  28.9T      383K  /zdraidtest/shrcompr

Filesystem             Type      Size  Used Avail Use% Mounted on
zdraidtest             zfs        29T  384K   29T   1% /zdraidtest
zdraidtest/shrcompr    zfs        29T  1.0M   29T   1% /zdraidtest/shrcompr
zdraidtest/notshrcompr zfs        29T  1.0M   29T   1% /zdraidtest/notshrcompr

NOTE - best practice is to export the pool and # zpool import -a -d /dev/disk/by-id

-----

Here is a simulated severely degraded pool with multiple drive failures and a spare in use, 
  with 2 failed disks in the same column - still chugging along:
  
  pool: zdraidtest
 state: DEGRADED
status: One or more devices could not be used because the label is missing or
        invalid.  Sufficient replicas exist for the pool to continue
        functioning in a degraded state.
action: Replace the device using 'zpool replace'.
   see: https://openzfs.github.io/openzfs-docs/msg/ZFS-8000-4J
  scan: resilvered 716M in 00:00:13 with 0 errors on Sat Jul  3 17:18:21 2021
config:
        NAME                 STATE     READ WRITE CKSUM
        zdraidtest           DEGRADED     0     0     0
          draid1:4d:6c:1s-0  DEGRADED     0     0     0
            sdb              ONLINE       0     0     0
            sdc              ONLINE       0     0     0
            sdd              UNAVAIL      0     0     0
            sde              ONLINE       0     0     0
            sdf              ONLINE       0     0     0
            sdg              ONLINE       0     0     0
          draid1:4d:6c:1s-1  DEGRADED     0     0     0
            sdh              ONLINE       0     0     0
            sdi              ONLINE       0     0     0
            sdj              UNAVAIL      0     0     0
            sdk              ONLINE       0     0     0
            sdl              ONLINE       0     0     0
            sdm              ONLINE       0     0     0
          draid1:4d:6c:1s-2  DEGRADED     0     0     0
            sdn              ONLINE       0     0     0
            sdo              ONLINE       0     0     0
            sdp              ONLINE       0     0     0
            sdq              ONLINE       0     0     0
            sdr              UNAVAIL      0     0     0
            sds              ONLINE       0     0     0
          draid1:4d:6c:1s-3  DEGRADED     0     0     0
            sdt              UNAVAIL      0     0     0
            sdu              ONLINE       0     0     0
            sdv              ONLINE       0     0     0
            sdw              ONLINE       0     0     0
            sdx              ONLINE       0     0     0
            spare-5          DEGRADED     0     0     0
              sdy            UNAVAIL      0     0     0
              draid1-3-0     ONLINE       0     0     0
        spares
          draid1-0-0         AVAIL   
          draid1-1-0         AVAIL   
          draid1-2-0         AVAIL   
          draid1-3-0         INUSE     currently in use
errors: No known data errors

NOTE that unless an extra disk is added to the system, the virtual spares for draid1:4d:6c:1s-3 are all burned up;
  if ANY of sdu-sdx also fails at this point, we will have a dead pool. 
Spares for draid1-0-0, 1-1-0 and 1-2-0 CANNOT be used for column 3.

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
