#!/bin/bash

echo "$0 - 2021 Dave Bechtel - make a ZFS DRAID pool"
echo "- pass arg1='reset' to destroy test pool"
echo "- pass arg1='fail' and arg2=dev2fail to simulate failure"

# Requires at least zfs 2.1.0
DBI=/dev/disk/by-id

# total disks for pool / children
td=24

# raidz level
rzl=2

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

if [ "$1" = "reset" ]; then
  zpool destroy $zp
  for d in $pooldisks; do
    echo -e -n "o Clearing label for disk $d          \r"
    zpool labelclear "$d"1
  done
  echo ''
  zpool status -v

  exit; # early
fi

if [ "$1" = "fail" ]; then
  echo "$(date) - Simulating disk failure for $(ls -l $DBI |grep $2)"
  echo offline > /sys/block/$2/device/state
  cat /sys/block/$2/device/state

  time dd if=/dev/urandom of=/$zp/^^tmpfileDELME bs=1M count=1; sync
  # force a write; if not work, try scrub
    
  zps 

  exit; # early
fi

# zpool create <pool> draid[<parity>][:<data>d][:<children>c][:<spares>s] <vdevs...>
# ex: draid2:4d:1s:11c
( set -x
time zpool create -o ashift=12 -o autoexpand=on -O atime=off -O compression=zstd-3 \
  $zp \
   draid$rzl:8d:12'c':$spr's' $pooldisks1 \
   draid$rzl:8d:12'c':$spr's' $pooldisks2 \
|| failexit 101 "Failed to create DRAID"
)

# The below will not work: gets error
#   "requested number of dRAID data disks per group 10 is too high, at most 8 disks are available for data"
#( set -x
#time zpool create -o ashift=12 -o autoexpand=on -O atime=off -O compression=zstd-3 \
#  $zp \
#    draid$rzl:10d:12'c':$spr's' $pooldisks1 \
#    draid$rzl:10d:12'c':$spr's' $pooldisks2 \
#|| failexit 101 "Failed to create DRAID"
#)

# requires external script in the same PATH
zfs-newds-zstd.sh 11 $zp shrcompr
zfs-newds-zstd.sh 10 $zp notshrcompr
  
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

# make a draid with x2 VDEVs, 5 data disks, 12 children, 2 spares

# zpool create -o ashift=12 -o autoexpand=on -O atime=off -O compression=zstd-3 zdraidtest \
  draid2:5d:12c:2s \
    /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg /dev/sdh /dev/sdi /dev/sdj /dev/sdk /dev/sdl /dev/sdm \
  draid2:5d:12c:2s \
    /dev/sdn /dev/sdo /dev/sdp /dev/sdq /dev/sdr /dev/sds /dev/sdt /dev/sdu /dev/sdv /dev/sdw /dev/sdx /dev/sdy
real    0m3.247s

+ zfs create -o atime=off -o compression=zstd-3 -o sharesmb=on -o xattr=sa -o recordsize=1024k zdraidtest/shrcompr
cannot share 'zdraidtest/shrcompr: system error': SMB share creation failed
filesystem successfully created, but not shared
changed ownership of '/zdraidtest/shrcompr' from root to user

+ zfs create -o atime=off -o compression=zstd-3 -o sharesmb=off -o recordsize=1024k zdraidtest/notshrcompr
changed ownership of '/zdraidtest/notshrcompr' from root to user

Filesystem             Type      Size  Used Avail Use% Mounted on
zdraidtest/notshrcompr zfs        24T  1.0M   24T   1% /zdraidtest/notshrcompr

  pool: zdraidtest
 state: ONLINE
config:
        NAME                  STATE     READ WRITE CKSUM
        zdraidtest            ONLINE       0     0     0
          draid2:5d:12c:2s-0  ONLINE       0     0     0
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
          draid2:5d:12c:2s-1  ONLINE       0     0     0
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

NAME         SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zdraidtest  36.4T  7.63M  36.4T        -         -     0%     0%  1.00x    ONLINE  -

NAME                     USED  AVAIL     REFER  MOUNTPOINT
zdraidtest              3.96M  23.6T      438K  /zdraidtest
zdraidtest/notshrcompr   438K  23.6T      438K  /zdraidtest/notshrcompr
zdraidtest/shrcompr      438K  23.6T      438K  /zdraidtest/shrcompr

Filesystem             Type      Size  Used Avail Use% Mounted on
zdraidtest             zfs        24T  512K   24T   1% /zdraidtest
zdraidtest/shrcompr    zfs        24T  1.0M   24T   1% /zdraidtest/shrcompr
zdraidtest/notshrcompr zfs        24T  1.0M   24T   1% /zdraidtest/notshrcompr

NOTE - best practice is to export the pool and # zpool import -a -d /dev/disk/by-id

-----

A different iteration: 8 Data disks, 12 children, 2 spares - gives more space and should allow more disks to fail:

+ zpool create -o ashift=12 -o autoexpand=on -O atime=off -O compression=zstd-3 \
  zdraidtest \
    draid2:8d:12c:2s \
      /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg /dev/sdh /dev/sdi /dev/sdj /dev/sdk /dev/sdl /dev/sdm \
    draid2:8d:12c:2s \
      /dev/sdn /dev/sdo /dev/sdp /dev/sdq /dev/sdr /dev/sds /dev/sdt /dev/sdu /dev/sdv /dev/sdw /dev/sdx /dev/sdy
real    0m3.403s

+ zfs create -o atime=off -o compression=zstd-3 -o sharesmb=on -o xattr=sa -o recordsize=1024k zdraidtest/shrcompr
cannot share 'zdraidtest/shrcompr: system error': SMB share creation failed
filesystem successfully created, but not shared
changed ownership of '/zdraidtest/shrcompr' from root to user

Filesystem          Type      Size  Used Avail Use% Mounted on
zdraidtest/shrcompr zfs        29T  1.0M   29T   1% /zdraidtest/shrcompr

+ zfs create -o atime=off -o compression=zstd-3 -o sharesmb=off -o recordsize=1024k zdraidtest/notshrcompr
changed ownership of '/zdraidtest/notshrcompr' from root to user

Filesystem             Type      Size  Used Avail Use% Mounted on
zdraidtest/notshrcompr zfs        29T  1.0M   29T   1% /zdraidtest/notshrcompr

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

NAME         SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zdraidtest  36.4T  10.7M  36.4T        -         -     0%     0%  1.00x    ONLINE  -

NAME                     USED  AVAIL     REFER  MOUNTPOINT
zdraidtest              6.65M  28.9T      767K  /zdraidtest
zdraidtest/notshrcompr   767K  28.9T      767K  /zdraidtest/notshrcompr
zdraidtest/shrcompr      767K  28.9T      767K  /zdraidtest/shrcompr

Filesystem             Type      Size  Used Avail Use% Mounted on
zdraidtest             zfs        29T  768K   29T   1% /zdraidtest
zdraidtest/shrcompr    zfs        29T  1.0M   29T   1% /zdraidtest/shrcompr
zdraidtest/notshrcompr zfs        29T  1.0M   29T   1% /zdraidtest/notshrcompr


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
