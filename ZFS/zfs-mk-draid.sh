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

zps=`zpool status -v |awk 'NF>0'`

pooldisks=$(echo /dev/sd{b..y})
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
    echo -e -n "o Clearing label for disk $d\r"
    zpool labelclear "$d"1
  done
  zpool status -v

  exit; # early
fi

if [ "$1" = "fail" ]; then
  echo "$(date) - Simulating disk failure for $(ls -l $DBI |grep $2)"
  echo offline > /sys/block/$2/device/state
  cat /sys/block/$2/device/state
  
  $zps #  zpool status -v |awk 'NF>0'

  exit; # early
fi

# zpool create <pool> draid[<parity>][:<data>d][:<children>c][:<spares>s] <vdevs...>
# ex: draid2:4d:1s:11c
( set -x
time zpool create -o ashift=12 -o autoexpand=on -O atime=off -O compression=zstd-3 \
  $zp \
    draid$rzl:5d:$td'c':$spr's' $pooldisks \
|| failexit 101 "Failed to create DRAID"
)

# requires external script in the same PATH
zfs-newds-zstd.sh 11 $zp shrcompr
zfs-newds-zstd.sh 10 $zp notshrcompr
  
$zps # zpool status -v |awk 'NF>0'
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

# zpool create zdraidtest draid2:5d:24c:2s /dev/sdb /dev/sdc /dev/sdd \
 /dev/sde /dev/sdf /dev/sdg /dev/sdh /dev/sdi /dev/sdj /dev/sdk /dev/sdl \
 /dev/sdm /dev/sdn /dev/sdo /dev/sdp /dev/sdq /dev/sdr /dev/sds /dev/sdt \
 /dev/sdu /dev/sdv /dev/sdw /dev/sdx /dev/sdy
real    0m4.108s
user    0m0.024s
sys     0m0.162s

  pool: zdraidtest
 state: ONLINE
config:
        NAME                  STATE     READ WRITE CKSUM
        zdraidtest            ONLINE       0     0     0
          draid2:5d:24c:2s-0  ONLINE       0     0     0
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
          draid2-0-0          AVAIL
          draid2-0-1          AVAIL
errors: No known data errors


NOTE with ashift not specified (virtualbox simulates 512-sector disks):
Filesystem     Type      Size  Used Avail Use% Mounted on
zdraidtest     zfs        29T  128K   29T   1% /zdraidtest

with ashift=12:
zdraidtest     zfs        26T  512K   26T   1% /zdraidtest


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
 zpool replace zdraidtest draid2-0-0 scsi-SATA_VBOX_HARDDISK_VBbcc6c97e-f68b8368 # same disk but labelcleared
 zpool status -v
