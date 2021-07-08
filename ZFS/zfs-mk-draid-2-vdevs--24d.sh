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
spr=2

# TODO EDITME
zp=zdraidtest

function zps () {
  zpool status -v |awk 'NF>0'
}

#pooldisks=$(echo /dev/sd{b..y})
pooldisks1=$(echo /dev/sd{b..m})
pooldisks2=$(echo /dev/sd{n..y})
pooldisks=$pooldisks1' '$pooldisks2 # need entire set for reset
# sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy

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

# TODO EDITME
#iteration=OBM
iteration=2
if [ "$iteration" = "1" ]; then
# compression=zstd-3
# -o ashift=12
# raidz level (usually 2)
  rzl=1
# Vspares - this is a 96-drive pool, you DON'T want to skimp!
  spr=2
( set -x
time zpool create -o autoreplace=on -o autoexpand=on -O atime=off -O compression=lz4 \
  $zp \
   draid$rzl:8d:12'c':$spr's' $pooldisks1 \
   draid$rzl:8d:12'c':$spr's' $pooldisks2 \
|| failexit 101 "Failed to create DRAID"
)
elif [ "$iteration" = "2" ]; then
# zpool create <pool> draid[<parity>][:<data>d][:<children>c][:<spares>s] <vdevs...>
# ex: draid2:4d:1s:11c
# raidz level (usually 2)
  rzl=2
# Vspares - this is a 96-drive pool, you DON'T want to skimp!
  spr=2
( set -x
time zpool create -o ashift=12 -o autoexpand=on -O atime=off -O compression=zstd-3 \
  $zp \
   draid$rzl:8d:12'c':$spr's' $pooldisks1 \
   draid$rzl:8d:12'c':$spr's' $pooldisks2 \
|| failexit 101 "Failed to create DRAID"
)
else
# One Big Mother
# -o ashift=12
# raidz level (usually 2)
  rzl=2
# spares - this is a 96-drive pool, you DON'T want to skimp!
  spr=2
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
#   zpool add $zp spare ${hotspares[@]}


# The below will not work: gets error
#   "requested number of dRAID data disks per group 10 is too high, at most 8 disks are available for data"
#( set -x
#time zpool create -o ashift=12 -o autoexpand=on -O atime=off -O compression=zstd-3 \
#  $zp \
#    draid$rzl:10d:12'c':$spr's' $pooldisks1 \
#    draid$rzl:10d:12'c':$spr's' $pooldisks2 \
#|| failexit 101 "Failed to create DRAID"
#)

# cre8 datasets
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

# make a draidz1 with x2 VDEVs, 8 data disks, 12 children, 2 spares (per vdev)

Defining for 24 disks in pool b4 hotspares (1)

+ zpool create -o autoreplace=on -o autoexpand=on -O atime=off -O compression=lz4 zdraidtest \
 draid1:8d:12c:2s /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg /dev/sdh /dev/sdi /dev/sdj /dev/sdk /dev/sdl /dev/sdm \
 draid1:8d:12c:2s /dev/sdn /dev/sdo /dev/sdp /dev/sdq /dev/sdr /dev/sds /dev/sdt /dev/sdu /dev/sdv /dev/sdw /dev/sdx /dev/sdy
real    0m3.304s

+ zfs create -o atime=off -o compression=lz4 -o sharesmb=on -o xattr=sa -o recordsize=1024k zdraidtest/shrcompr
changed ownership of '/zdraidtest/shrcompr' from root to user
Filesystem          Type      Size  Used Avail Use% Mounted on
zdraidtest/shrcompr zfs        63G  1.0M   63G   1% /zdraidtest/shrcompr

+ zfs create -o atime=off -o compression=lz4 -o sharesmb=off -o recordsize=1024k zdraidtest/notshrcompr
changed ownership of '/zdraidtest/notshrcompr' from root to user
Filesystem             Type      Size  Used Avail Use% Mounted on
zdraidtest/notshrcompr zfs        63G  1.0M   63G   1% /zdraidtest/notshrcompr

+ zfs create -o atime=off -o compression=zstd-3 -o sharesmb=off -o recordsize=1024k zdraidtest/notshrcompr-zstd
changed ownership of '/zdraidtest/notshrcompr-zstd' from root to user
Filesystem                  Type      Size  Used Avail Use% Mounted on
zdraidtest/notshrcompr-zstd zfs        63G  1.0M   63G   1% /zdraidtest/notshrcompr-zstd

+ zfs create -o atime=off -o compression=off -o sharesmb=off -o recordsize=1024k zdraidtest/notshrnotcompr
changed ownership of '/zdraidtest/notshrnotcompr' from root to user
Filesystem                  Type      Size  Used Avail Use% Mounted on
zdraidtest/notshrnotcompr   zfs        63G  1.0M   63G   1% /zdraidtest/notshrnotcompr

  pool: zdraidtest
 state: ONLINE
config:
        NAME                  STATE     READ WRITE CKSUM
        zdraidtest            ONLINE       0     0     0
          draid1:8d:12c:2s-0  ONLINE       0     0     0
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
          draid1:8d:12c:2s-1  ONLINE       0     0     0
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
          draid1-0-0          AVAIL
          draid1-0-1          AVAIL
          draid1-1-0          AVAIL
          draid1-1-1          AVAIL
errors: No known data errors

NAME         SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zdraidtest  73.0G  1.77M  73.0G        -         -     0%     0%  1.00x    ONLINE  -

NAME                          USED  AVAIL     REFER  MOUNTPOINT
zdraidtest                   1.15M  62.9G      112K  /zdraidtest
zdraidtest/notshrcompr       96.0K  62.9G     96.0K  /zdraidtest/notshrcompr
zdraidtest/notshrcompr-zstd  96.0K  62.9G     96.0K  /zdraidtest/notshrcompr-zstd
zdraidtest/notshrnotcompr    96.0K  62.9G     96.0K  /zdraidtest/notshrnotcompr
zdraidtest/shrcompr          96.0K  62.9G     96.0K  /zdraidtest/shrcompr
Filesystem                  Type      Size  Used Avail Use% Mounted on
zdraidtest                  zfs        63G  128K   63G   1% /zdraidtest
zdraidtest/shrcompr         zfs        63G  1.0M   63G   1% /zdraidtest/shrcompr
zdraidtest/notshrcompr      zfs        63G  1.0M   63G   1% /zdraidtest/notshrcompr
zdraidtest/notshrcompr-zstd zfs        63G  1.0M   63G   1% /zdraidtest/notshrcompr-zstd
zdraidtest/notshrnotcompr   zfs        63G  1.0M   63G   1% /zdraidtest/notshrnotcompr
NOTE - best practice is to export the pool and # zpool import -a -d /dev/disk/by-id

-----

Here is a severely degraded pool with (6) drive fails and all vspares in use, still going strong with no data loss
  despite being raidz1 -- NOTE if we had some pspares configured it could take even more damage:

  pool: zdraidtest
 state: DEGRADED
status: One or more devices could not be used because the label is missing or
        invalid.  Sufficient replicas exist for the pool to continue
        functioning in a degraded state.
action: Replace the device using 'zpool replace'.
   see: https://openzfs.github.io/openzfs-docs/msg/ZFS-8000-4J
  scan: scrub repaired 0B in 00:00:49 with 0 errors on Wed Jul  7 21:51:51 2021
  scan: resilvered (draid1:8d:12c:2s-0) 273M in 00:00:34 with 0 errors on Wed Jul  7 21:38:06 2021
  scan: resilvered (draid1:8d:12c:2s-1) 779M in 00:00:38 with 0 errors on Wed Jul  7 21:51:02 2021
config:
        NAME                  STATE     READ WRITE CKSUM
        zdraidtest            DEGRADED     0     0     0
          draid1:8d:12c:2s-0  DEGRADED     0     0     0
            spare-0           DEGRADED     0     0     0
              sdb             UNAVAIL      0     0     0
              draid1-0-0      ONLINE       0     0     0
            sdc               ONLINE       0     0     0
            spare-2           DEGRADED     0     0     0
              sdd             UNAVAIL      0     0     0
              draid1-0-1      ONLINE       0     0     0
            sde               ONLINE       0     0     0
            sdf               UNAVAIL      0     0     0
            sdg               ONLINE       0     0     0
            sdh               ONLINE       0     0     0
            sdi               ONLINE       0     0     0
            sdj               ONLINE       0     0     0
            sdk               ONLINE       0     0     0
            sdl               ONLINE       0     0     0
            sdm               ONLINE       0     0     0
          draid1:8d:12c:2s-1  DEGRADED     0     0     0
            spare-0           DEGRADED     0     0     0
              sdn             UNAVAIL      0     0     0
              draid1-1-0      ONLINE       0     0     0
            sdo               ONLINE       0     0     0
            spare-2           DEGRADED     0     0     0
              sdp             UNAVAIL      0     0     0
              draid1-1-1      ONLINE       0     0     0
            sdq               ONLINE       0     0     0
            sdr               UNAVAIL      0     0     0
            sds               ONLINE       0     0     0
            sdt               ONLINE       0     0     0
            sdu               ONLINE       0     0     0
            sdv               ONLINE       0     0     0
            sdw               ONLINE       0     0     0
            sdx               ONLINE       0     0     0
            sdy               ONLINE       0     0     0
        spares
          draid1-0-0          INUSE     currently in use
          draid1-0-1          INUSE     currently in use
          draid1-1-0          INUSE     currently in use
          draid1-1-1          INUSE     currently in use
errors: No known data errors

-----

# source draid-pooldisks-assoc.sh 24
Defining for 24 disks in pool b4 hotspares (1)
Dumping shortdisk == longdisk assoc array to /tmp/draid-pooldisks-assoc.log

# zpool add $zp spare ${hotspares[@]}

            sdy               ONLINE       0     0     0
        spares
          draid1-0-0          INUSE     currently in use
          draid1-0-1          INUSE     currently in use
          draid1-1-0          INUSE     currently in use
          draid1-1-1          INUSE     currently in use
          sdz                 AVAIL
errors: No known data errors

We have added a hotspare on the fly but the ZED daemon hasnt done anything with the already-unavail disks,
  still need to do a manual replace.

# zpool replace $zp sdf sdz

  pool: zdraidtest
 state: DEGRADED
status: One or more devices could not be used because the label is missing or
        invalid.  Sufficient replicas exist for the pool to continue
        functioning in a degraded state.
action: Replace the device using 'zpool replace'.
   see: https://openzfs.github.io/openzfs-docs/msg/ZFS-8000-4J
  scan: resilvered 1.57G in 00:00:42 with 0 errors on Wed Jul  7 21:59:23 2021
  
          draid1:8d:12c:2s-0  DEGRADED     0     0     0
            spare-0           DEGRADED     0     0     0
              sdb             UNAVAIL      0     0     0
              draid1-0-0      ONLINE       0     0     0
            sdc               ONLINE       0     0     0
            spare-2           DEGRADED     0     0     0
              sdd             UNAVAIL      0     0     0
              draid1-0-1      ONLINE       0     0     0
            sde               ONLINE       0     0     0
            spare-4           DEGRADED     0     0     0
              sdf             UNAVAIL      0     0     0
              sdz             ONLINE       0     0     0
            sdg               ONLINE       0     0     0

We still have a quandary however, the pool will still show as DEGRADED because a hotspare was used;
  to clear this condition we can reboot and bring sdf back online + detach sdz to roll it back to the hotspares,
  or replace sdf with a permanent replacement:
  
# zpool replace $zp sdf sdaa

  pool: zdraidtest
 state: DEGRADED
status: One or more devices is currently being resilvered.  The pool will
        continue to function, possibly in a degraded state.
action: Wait for the resilver to complete.
  scan: resilver in progress since Wed Jul  7 22:03:14 2021
        23.1G scanned at 987M/s, 14.1G issued at 604M/s, 23.1G total
        806M resilvered, 61.15% done, 00:00:15 to go
config:
        NAME                  STATE     READ WRITE CKSUM
        zdraidtest            DEGRADED     0     0     0
          draid1:8d:12c:2s-0  DEGRADED     0     0     0
            spare-0           DEGRADED     0     0     0
              sdb             UNAVAIL      0     0     0
              draid1-0-0      ONLINE       0     0     0  (resilvering)
            sdc               ONLINE       0     0     0  (resilvering)
            spare-2           DEGRADED     0     0     0
              sdd             UNAVAIL      0     0     0
              draid1-0-1      ONLINE       0     0     0  (resilvering)
            sde               ONLINE       0     0     0  (resilvering)
            spare-4           DEGRADED     0     0     0
              replacing-0     DEGRADED     0     0     0
                sdf           UNAVAIL      0     0     0
                sdaa          ONLINE       0     0     0  (resilvering)
              sdz             ONLINE       0     0     0  (resilvering)
            sdg               ONLINE       0     0     0  (resilvering)

  scan: resilvered 1.89G in 00:00:52 with 0 errors on Wed Jul  7 22:04:06 2021

            sde               ONLINE       0     0     0
            sdaa              ONLINE       0     0     0
            sdg               ONLINE       0     0     0

        spares
          draid1-0-0          INUSE     currently in use
          draid1-0-1          INUSE     currently in use
          draid1-1-0          INUSE     currently in use
          draid1-1-1          INUSE     currently in use
          sdz                 AVAIL   
errors: No known data errors

# zpool replace $zp sdr sdab  

  scan: resilvered 1.52G in 00:01:05 with 0 errors on Wed Jul  7 22:07:17 2021

-----

Another iteration - raidz2

# make a draidz2 with x2 VDEVs, 8 data disks, 12 children, 2 spares (per vdev)

  pool: zdraidtest
 state: ONLINE
config:
        NAME                  STATE     READ WRITE CKSUM
        zdraidtest            ONLINE       0     0     0
          draid2:8d:12c:2s-0  ONLINE       0     0     0
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
          draid2:8d:12c:2s-1  ONLINE       0     0     0
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
          draid2-0-0          AVAIL
          draid2-0-1          AVAIL
          draid2-1-0          AVAIL
          draid2-1-1          AVAIL
errors: No known data errors

-----

Here is the above pool in a severely degraded condition, one more drive failure will kill it but we have
  sustained (8) drive failures despite it being a raidz2 - and still no data loss:
  
  pool: zdraidtest
 state: DEGRADED
status: One or more devices could not be used because the label is missing or
        invalid.  Sufficient replicas exist for the pool to continue
        functioning in a degraded state.
action: Replace the device using 'zpool replace'.
   see: https://openzfs.github.io/openzfs-docs/msg/ZFS-8000-4J
  scan: scrub repaired 0B in 00:00:36 with 0 errors on Wed Jul  7 22:30:03 2021
  scan: resilvered (draid2:8d:12c:2s-0) 319M in 00:00:10 with 0 errors on Wed Jul  7 22:23:40 2021
  scan: resilvered (draid2:8d:12c:2s-1) 598M in 00:00:30 with 0 errors on Wed Jul  7 22:29:27 2021
config:
        NAME                  STATE     READ WRITE CKSUM
        zdraidtest            DEGRADED     0     0     0
          draid2:8d:12c:2s-0  DEGRADED     0     0     0
            spare-0           DEGRADED     0     0     0
              sdb             UNAVAIL      0     0     0
              draid2-0-0      ONLINE       0     0     0
            sdc               ONLINE       0     0     0
            spare-2           DEGRADED     0     0     0
              sdd             UNAVAIL      0     0     0
              draid2-0-1      ONLINE       0     0     0
            sde               ONLINE       0     0     0
            sdf               UNAVAIL      0     0     0
            sdg               ONLINE       0     0     0
            sdh               UNAVAIL      0     0     0
            sdi               ONLINE       0     0     0
            sdj               ONLINE       0     0     0
            sdk               ONLINE       0     0     0
            sdl               ONLINE       0     0     0
            sdm               ONLINE       0     0     0
          draid2:8d:12c:2s-1  DEGRADED     0     0     0
            spare-0           DEGRADED     0     0     0
              sdn             UNAVAIL      0     0     0
              draid2-1-0      ONLINE       0     0     0
            sdo               ONLINE       0     0     0
            spare-2           DEGRADED     0     0     0
              sdp             UNAVAIL      0     0     0
              draid2-1-1      ONLINE       0     0     0
            sdq               ONLINE       0     0     0
            sdr               UNAVAIL      0     0     0
            sds               ONLINE       0     0     0
            sdt               UNAVAIL      0     0     0
            sdu               ONLINE       0     0     0
            sdv               ONLINE       0     0     0
            sdw               ONLINE       0     0     0
            sdx               ONLINE       0     0     0
            sdy               ONLINE       0     0     0
        spares
          draid2-0-0          INUSE     currently in use
          draid2-0-1          INUSE     currently in use
          draid2-1-0          INUSE     currently in use
          draid2-1-1          INUSE     currently in use
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

  pool: zdraidtest
 state: ONLINE
  scan: resilvered 4.42G in 00:01:14 with 0 errors on Wed Jul  7 22:12:23 2021
config:
        NAME                  STATE     READ WRITE CKSUM
        zdraidtest            ONLINE       0     0     0
          draid1:8d:12c:2s-0  ONLINE       0     0     0
            spare-0           ONLINE       0     0     0
              sdb             ONLINE       0     0     0
              draid1-0-0      ONLINE       0     0     0
            sdc               ONLINE       0     0     0
            spare-2           ONLINE       0     0     0
              sdd             ONLINE       0     0     0
              draid1-0-1      ONLINE       0     0     0
            sde               ONLINE       0     0     0
            sdaa              ONLINE       0     0     0
            sdg               ONLINE       0     0     0
            sdh               ONLINE       0     0     0
            sdi               ONLINE       0     0     0
            sdj               ONLINE       0     0     0
            sdk               ONLINE       0     0     0
            sdl               ONLINE       0     0     0
            sdm               ONLINE       0     0     0
          draid1:8d:12c:2s-1  ONLINE       0     0     0
            spare-0           ONLINE       0     0     0
              sdn             ONLINE       0     0     0
              draid1-1-0      ONLINE       0     0     0
            sdo               ONLINE       0     0     0
            spare-2           ONLINE       0     0     0
              sdp             ONLINE       0     0     0
              draid1-1-1      ONLINE       0     0     0
            sdq               ONLINE       0     0     0
            sdab              ONLINE       0     0     0
            sds               ONLINE       0     0     0
            sdt               ONLINE       0     0     0
            sdu               ONLINE       0     0     0
            sdv               ONLINE       0     0     0
            sdw               ONLINE       0     0     0
            sdx               ONLINE       0     0     0
            sdy               ONLINE       0     0     0
        spares
          draid1-0-0          INUSE     currently in use
          draid1-0-1          INUSE     currently in use
          draid1-1-0          INUSE     currently in use
          draid1-1-1          INUSE     currently in use
          sdz                 AVAIL
errors: No known data errors

The drives are all back, but the vspares are all in use.

FIX: # zpool detach $zp  draid1-0-0
# zpool detach $zp  draid1-0-1
# zpool detach $zp  draid1-1-0
# zpool detach $zp  draid1-1-1

        spares
          draid1-0-0          AVAIL   
          draid1-0-1          AVAIL   
          draid1-1-0          AVAIL   
          draid1-1-1          AVAIL   
          sdz                 AVAIL   
errors: No known data errors

NOTE if you get the following error after rebooting and bringing dead drives back, it should work OK after a scrub:

# zpool detach $zp draid2-0-0
cannot detach draid2-0-0: no valid replicas
