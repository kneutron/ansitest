#!/bin/bash

echo "$0 - 2021 Dave Bechtel - make a ZFS DRAID pool"
echo "- pass arg1='reset' to destroy test pool"
echo "- pass arg1='fail' and arg2=dev2fail to simulate failure"
echo "Reboot to clear simulated device failures before issuing 'reset'"

# Requires at least zfs 2.1.0
DD=/dev/disk
DBI=/dev/disk/by-id

# total disks for pool / children (Not counting spares)
td=96 # evenly/24 - spares and rootdisk + we still have (8) spares beyond

# raidz level (usually 2)
rzl=2

# spares
spr=1

# TODO EDITME
zp=zdraidtest

function zps () {
  zpool status -v |awk 'NF>0'
}

# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

#pooldisks=$(echo /dev/sd{b..y})

#pooldisks1=$(echo /dev/sd{b..m})
#pooldisks2=$(echo /dev/sd{n..y})
#pooldisks=$pooldisks1' '$pooldisks2 # need entire set for reset

# groups of 6 for convenience, also evenly divides into 24, 48, 72, 96 
# (but not 32 [28+4 spares], that gets handled in draid assoc)
pooldisks01=$(echo /dev/sd{b..g}) # a is rootdisk
pooldisks02=$(echo /dev/sd{h..m})
pooldisks03=$(echo /dev/sd{n..s})
pooldisks04=$(echo /dev/sd{t..y}) # z is spare

pooldisks05=$(echo /dev/sda{a..f}) #abcdef
pooldisks06=$(echo /dev/sda{g..l}) #ghijkl
pooldisks07=$(echo /dev/sda{m..r}) #mnopqr
pooldisks08=$(echo /dev/sda{s..x}) #stuvwx # yz are spares

pooldisks09=$(echo /dev/sdb{a..f}) #abcdef
pooldisks10=$(echo /dev/sdb{g..l}) #ghijkl
pooldisks11=$(echo /dev/sdb{m..r}) #mnopqr
pooldisks12=$(echo /dev/sdb{s..x}) #stuvwx # yz are spares

pooldisks13=$(echo /dev/sdc{a..f}) #abcdef
pooldisks14=$(echo /dev/sdc{g..l}) #ghijkl # no idle spares, only virtual
pooldisks15=$(echo /dev/sdc{m..r}) #mnopqr
pooldisks16=$(echo /dev/sdc{s..x}) #stuvwx # yz are spares

pooldisks=$pooldisks01' '$pooldisks02' '$pooldisks03' '$pooldisks04' '$pooldisks05' '$pooldisks06
  pooldisks=$pooldisks' '$pooldisks07' '$pooldisks08' '$pooldisks09' '$pooldisks10' '$pooldisks11
  pooldisks=$pooldisks' '$pooldisks12' '$pooldisks13' '$pooldisks14' '$pooldisks15' '$pooldisks16
# need entire set for reset

# sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy
# 1   2   3   4   5   6    1   2   3   4   5   6   1   2   3   4   5   6   1   2   3   4   5   6
# D   D   D   Z2  Z2  S

# extending to 32 disks
#pooldisks2=$(echo /dev/sda{a..h})
#sdaa sdab sdac sdad sdae sdaf sdag sdah

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

# SLOW writing to zstd-3
#   draid$rzl:8d:12'c':$spr's' $pooldisks1 \
#   draid$rzl:8d:12'c':$spr's' $pooldisks2 \

# cre8 drive translation table
#source ~/bin/boojum/draid-pooldisks-assoc.sh 

# TODO EDITME
#iteration=OBM
iteration=8
if [ "$iteration" = "1" ]; then 
# compression=zstd-3
# -o ashift=12
# raidz level (usually 2)
  rzl=1
# Vspares - this is a 96-drive pool, you DON'T want to skimp!
  spr=4
( set -x
time zpool create -o autoreplace=on -o autoexpand=on -O atime=off -O compression=lz4 \
  $zp \
   draid$rzl:8d:24'c':$spr's' $pooldisks01 $pooldisks02 $pooldisks03 $pooldisks04 \
   draid$rzl:8d:24'c':$spr's' $pooldisks05 $pooldisks06 $pooldisks07 $pooldisks08 \
   draid$rzl:8d:24'c':$spr's' $pooldisks09 $pooldisks10 $pooldisks11 $pooldisks12 \
   draid$rzl:8d:24'c':$spr's' $pooldisks13 $pooldisks14 $pooldisks15 $pooldisks16 \
|| failexit 101 "Failed to create DRAID"
)
elif [ "$iteration" = "2" ]; then
# 4xVDEVs with 12 vspares
# raidz level (usually 2)
  rzl=2
# spares
  spr=3
( set -x
time zpool create -o autoreplace=on -o autoexpand=on -O atime=off -O compression=lz4 \
  $zp \
   draid$rzl:8d:24'c':$spr's' $pooldisks01 $pooldisks02 $pooldisks03 $pooldisks04 \
   draid$rzl:8d:24'c':$spr's' $pooldisks05 $pooldisks06 $pooldisks07 $pooldisks08 \
   draid$rzl:8d:24'c':$spr's' $pooldisks09 $pooldisks10 $pooldisks11 $pooldisks12 \
   draid$rzl:8d:24'c':$spr's' $pooldisks13 $pooldisks14 $pooldisks15 $pooldisks16 \
|| failexit 101 "Failed to create DRAID"
)
elif [ "$iteration" = "3" ]; then 
# compression=zstd-3
# -o ashift=12
# raidz level (usually 2)
  rzl=2
# Vspares - this is a 96-drive pool, you DON'T want to skimp!
  spr=4
( set -x
time zpool create -o autoreplace=on -o autoexpand=on -O atime=off -O compression=lz4 \
  $zp \
   draid$rzl:8d:48'c':$spr's' $pooldisks01 $pooldisks02 $pooldisks03 $pooldisks04 $pooldisks05 $pooldisks06\
     $pooldisks07 $pooldisks08 \
   draid$rzl:8d:48'c':$spr's' $pooldisks09 $pooldisks10 $pooldisks11 $pooldisks12 $pooldisks13 $pooldisks14\
     $pooldisks15 $pooldisks16 \
|| failexit 101 "Failed to create DRAID"
)
elif [ "$iteration" = "4" ]; then 
# raidz level (usually 2)
  rzl=1
# Vspares - this is a 96-drive pool, you DON'T want to skimp!
  spr=4
( set -x
time zpool create -o autoreplace=on -o autoexpand=on -O atime=off -O compression=lz4 \
  $zp \
   draid$rzl:18d:24'c':$spr's' $pooldisks01 $pooldisks02 $pooldisks03 $pooldisks04 \
   draid$rzl:18d:24'c':$spr's' $pooldisks05 $pooldisks06 $pooldisks07 $pooldisks08 \
   draid$rzl:18d:24'c':$spr's' $pooldisks09 $pooldisks10 $pooldisks11 $pooldisks12 \
   draid$rzl:18d:24'c':$spr's' $pooldisks13 $pooldisks14 $pooldisks15 $pooldisks16 \
|| failexit 101 "Failed to create DRAID"
)
elif [ "$iteration" = "6" ]; then 
# sd{b..y} sda{a..x} sdb{a..x} sdc{a..x})
# raidz level (usually 2)
  rzl=1
# Vspares - this is a 96-drive pool, you DON'T want to skimp!
  spr=2
( set -x
time zpool create -o autoreplace=on -o autoexpand=on -O atime=off -O compression=lz4 \
  $zp \
   draid$rzl:13d:16'c':$spr's' sd{b..q} \
   draid$rzl:13d:16'c':$spr's' sda{a..p} \
   draid$rzl:13d:16'c':$spr's' sdb{a..p} \
   draid$rzl:13d:16'c':$spr's' sdc{a..p} \
   draid$rzl:13d:16'c':$spr's' sd{r..y} sda{q..x} \
   draid$rzl:13d:16'c':$spr's' sdb{r..y} sdc{q..x} \
|| failexit 101 "Failed to create DRAID"
)
elif [ "$iteration" = "8" ]; then 
# sd{b..y} sda{a..x} sdb{a..x} sdc{a..x})
# raidz level (usually 2)
  rzl=1
# Vspares - this is a 96-drive pool, you DON'T want to skimp!
  spr=2
( set -x
time zpool create -o autoreplace=on -o autoexpand=on -O atime=off -O compression=lz4 \
  $zp \
   draid$rzl:9d:12'c':$spr's' sd{b..m} \
   draid$rzl:9d:12'c':$spr's' sd{n..y} \
   draid$rzl:9d:12'c':$spr's' sda{a..l} \
   draid$rzl:9d:12'c':$spr's' sda{m..x} \
   draid$rzl:9d:12'c':$spr's' sdb{a..l} \
   draid$rzl:9d:12'c':$spr's' sdb{m..x} \
   draid$rzl:9d:12'c':$spr's' sdc{a..l} \
   draid$rzl:9d:12'c':$spr's' sdc{m..x} \
|| failexit 101 "Failed to create DRAID"
)
else
# One Big Mother
# -o ashift=12
# raidz level (usually 2)
  rzl=2
# spares - this is a 96-drive pool, you DON'T want to skimp!
  spr=8
( set -x
  time zpool create -o autoreplace=on -o autoexpand=on -O atime=off -O compression=lz4 \
    $zp \
     draid$rzl:24d:$td'c':$spr's' $pooldisks \
  || failexit 101 "Failed to create DRAID"
)
#rc=$?
#[ $rc -gt 0 ] && exit $rc

fi

rc=$?
[ $rc -gt 0 ] && exit $rc
# ^ Need this check because of subshell, will not exit early otherwise

# add hotspares
# [ $(zpool list |grep -c "no pools") -eq 0 ] && \
#   zpool add $zp spare ${hotspares[@]}

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
zpool status -v |grep draid

echo "NOTE - best practice is to export the pool and # zpool import -a -d $DBI"

date
exit;


# After the fact - pool is already created, add designated hotspares to the existing virtual set:
# zpool add zdraidtest spare sdz sday sdaz sdby sdbz

# NOTE that if you need to move a 'spare' disk out you can 'zpool remove' it as long as not already in-use
# This is useful to realloc for perm-replacement disks

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

Iteration OBM:

+ zpool create -o autoreplace=on -o autoexpand=on -O atime=off -O compression=lz4 \
 zdraidtest draid2:8d:96c:6s \
/dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg /dev/sdh /dev/sdi
/dev/sdj /dev/sdk /dev/sdl dev/sdm /dev/sdn /dev/sdo /dev/sdp /dev/sdq
/dev/sdr /dev/sds /dev/sdt dev/sdu /dev/sdv /dev/sdw /dev/sdx /dev/sdy
/dev/sdaa /dev/sdab /dev/sdac dev/sdad /dev/sdae /dev/sdaf /dev/sdag
/dev/sdah /dev/sdai /dev/sdaj dev/sdak /dev/sdal /dev/sdam /dev/sdan
/dev/sdao /dev/sdap /dev/sdaq dev/sdar /dev/sdas /dev/sdat /dev/sdau
/dev/sdav /dev/sdaw /dev/sdax dev/sdba /dev/sdbb /dev/sdbc /dev/sdbd
/dev/sdbe /dev/sdbf /dev/sdbg dev/sdbh /dev/sdbi /dev/sdbj /dev/sdbk
/dev/sdbl /dev/sdbm /dev/sdbn dev/sdbo /dev/sdbp /dev/sdbq /dev/sdbr
/dev/sdbs /dev/sdbt /dev/sdbu dev/sdbv /dev/sdbw /dev/sdbx /dev/sdca
/dev/sdcb /dev/sdcc /dev/sdcd dev/sdce /dev/sdcf /dev/sdcg /dev/sdch
/dev/sdci /dev/sdcj /dev/sdck dev/sdcl /dev/sdcm /dev/sdcn /dev/sdco
/dev/sdcp /dev/sdcq /dev/sdcr dev/sdcs /dev/sdct /dev/sdcu /dev/sdcv
/dev/sdcw /dev/sdcx
real    0m18.426s

+ zfs create -o atime=off -o compression=lz4 -o sharesmb=on -o xattr=sa -o recordsize=1024k zdraidtest/shrcompr
cannot share 'zdraidtest/shrcompr: system error': SMB share creation failed
filesystem successfully created, but not shared
changed ownership of '/zdraidtest/shrcompr' from root to user

Filesystem          Type      Size  Used Avail Use% Mounted on
zdraidtest/shrcompr zfs       256G  1.0M  256G   1% /zdraidtest/shrcompr

+ zfs create -o atime=off -o compression=lz4 -o sharesmb=off -o recordsize=1024k zdraidtest/notshrcompr
changed ownership of '/zdraidtest/notshrcompr' from root to user

Filesystem             Type      Size  Used Avail Use% Mounted on
zdraidtest/notshrcompr zfs       256G  1.0M  256G   1% /zdraidtest/notshrcompr

+ zfs create -o atime=off -o compression=zstd-3 -o sharesmb=off -o recordsize=1024k zdraidtest/notshrcompr-zstd
changed ownership of '/zdraidtest/notshrcompr-zstd' from root to user

Filesystem                  Type      Size  Used Avail Use% Mounted on
zdraidtest/notshrcompr-zstd zfs       256G  1.0M  256G   1% /zdraidtest/notshrcompr-zstd

+ zfs create -o atime=off -o compression=off -o sharesmb=off -o recordsize=1024k zdraidtest/notshrnotcompr
changed ownership of '/zdraidtest/notshrnotcompr' from root to user

Filesystem                  Type      Size  Used Avail Use% Mounted on
zdraidtest/notshrnotcompr   zfs       256G  1.0M  256G   1% /zdraidtest/notshrnotcompr

  pool: zdraidtest
 state: ONLINE
config:
        NAME                  STATE     READ WRITE CKSUM
        zdraidtest            ONLINE       0     0     0
          draid2:8d:96c:6s-0  ONLINE       0     0     0
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
            sdaa              ONLINE       0     0     0
            sdab              ONLINE       0     0     0
            sdac              ONLINE       0     0     0
            sdad              ONLINE       0     0     0
            sdae              ONLINE       0     0     0
            sdaf              ONLINE       0     0     0
            sdag              ONLINE       0     0     0
            sdah              ONLINE       0     0     0
            sdai              ONLINE       0     0     0
            sdaj              ONLINE       0     0     0
            sdak              ONLINE       0     0     0
            sdal              ONLINE       0     0     0
            sdam              ONLINE       0     0     0
            sdan              ONLINE       0     0     0
            sdao              ONLINE       0     0     0
            sdap              ONLINE       0     0     0
            sdaq              ONLINE       0     0     0
            sdar              ONLINE       0     0     0
            sdas              ONLINE       0     0     0
            sdat              ONLINE       0     0     0
            sdau              ONLINE       0     0     0
            sdav              ONLINE       0     0     0
            sdaw              ONLINE       0     0     0
            sdax              ONLINE       0     0     0
            sdba              ONLINE       0     0     0
            sdbb              ONLINE       0     0     0
            sdbc              ONLINE       0     0     0
            sdbd              ONLINE       0     0     0
            sdbe              ONLINE       0     0     0
            sdbf              ONLINE       0     0     0
            sdbg              ONLINE       0     0     0
            sdbh              ONLINE       0     0     0
            sdbi              ONLINE       0     0     0
            sdbj              ONLINE       0     0     0
            sdbk              ONLINE       0     0     0
            sdbl              ONLINE       0     0     0
            sdbm              ONLINE       0     0     0
            sdbn              ONLINE       0     0     0
            sdbo              ONLINE       0     0     0
            sdbp              ONLINE       0     0     0
            sdbq              ONLINE       0     0     0
            sdbr              ONLINE       0     0     0
            sdbs              ONLINE       0     0     0
            sdbt              ONLINE       0     0     0
            sdbu              ONLINE       0     0     0
            sdbv              ONLINE       0     0     0
            sdbw              ONLINE       0     0     0
            sdbx              ONLINE       0     0     0
            sdca              ONLINE       0     0     0
            sdcb              ONLINE       0     0     0
            sdcc              ONLINE       0     0     0
            sdcd              ONLINE       0     0     0
            sdce              ONLINE       0     0     0
            sdcf              ONLINE       0     0     0
            sdcg              ONLINE       0     0     0
            sdch              ONLINE       0     0     0
            sdci              ONLINE       0     0     0
            sdcj              ONLINE       0     0     0
            sdck              ONLINE       0     0     0
            sdcl              ONLINE       0     0     0
            sdcm              ONLINE       0     0     0
            sdcn              ONLINE       0     0     0
            sdco              ONLINE       0     0     0
            sdcp              ONLINE       0     0     0
            sdcq              ONLINE       0     0     0
            sdcr              ONLINE       0     0     0
            sdcs              ONLINE       0     0     0
            sdct              ONLINE       0     0     0
            sdcu              ONLINE       0     0     0
            sdcv              ONLINE       0     0     0
            sdcw              ONLINE       0     0     0
            sdcx              ONLINE       0     0     0
        spares
          draid2-0-0          AVAIL
          draid2-0-1          AVAIL
          draid2-0-2          AVAIL
          draid2-0-3          AVAIL
          draid2-0-4          AVAIL
          draid2-0-5          AVAIL
          sdz                 AVAIL
          sday                AVAIL
          sdaz                AVAIL
          sdby                AVAIL
          sdbz                AVAIL
          sdcy                AVAIL
          sdcz                AVAIL
errors: No known data errors

NAME         SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zdraidtest   330G  1.92M   330G        -         -     0%     0%  1.00x    ONLINE  -

NAME                          USED  AVAIL     REFER  MOUNTPOINT
zdraidtest                   1.10M   255G      104K  /zdraidtest
zdraidtest/notshrcompr       95.9K   255G     95.9K  /zdraidtest/notshrcompr
zdraidtest/notshrcompr-zstd  95.9K   255G     95.9K  /zdraidtest/notshrcompr-zstd
zdraidtest/notshrnotcompr    95.9K   255G     95.9K  /zdraidtest/notshrnotcompr
zdraidtest/shrcompr          95.9K   255G     95.9K  /zdraidtest/shrcompr

Filesystem                  Type      Size  Used Avail Use% Mounted on
zdraidtest                  zfs       256G  128K  256G   1% /zdraidtest
zdraidtest/shrcompr         zfs       256G  1.0M  256G   1% /zdraidtest/shrcompr
zdraidtest/notshrcompr      zfs       256G  1.0M  256G   1% /zdraidtest/notshrcompr
zdraidtest/notshrcompr-zstd zfs       256G  1.0M  256G   1% /zdraidtest/notshrcompr-zstd
zdraidtest/notshrnotcompr   zfs       256G  1.0M  256G   1% /zdraidtest/notshrnotcompr

NOTE - best practice is to export the pool and # zpool import -a -d /dev/disk/by-id

-----

Here the pool is severely degraded with (13) simultaneous drive failures; spares (virtual and physical)
have been swapped in but two of them are giving an error when we try to manually replace them:

  pool: zdraidtest
 state: DEGRADED
status: One or more devices could not be used because the label is missing or
        invalid.  Sufficient replicas exist for the pool to continue
        functioning in a degraded state.
action: Replace the device using 'zpool replace'.
   see: https://openzfs.github.io/openzfs-docs/msg/ZFS-8000-4J
  scan: scrub repaired 0B in 00:00:01 with 0 errors on Mon Jul  5 19:21:57 2021
config:

        NAME                  STATE     READ WRITE CKSUM
        zdraidtest            DEGRADED     0     0     0
          draid2:8d:96c:6s-0  DEGRADED     0     0     0
            spare-0           DEGRADED     0     0     0
              sdb             UNAVAIL      0     0     0
              draid2-0-0      ONLINE       0     0     0
            spare-1           DEGRADED     0     0     0
              sdc             UNAVAIL      0     0     0
              draid2-0-3      ONLINE       0     0     0
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
            sdaa              ONLINE       0     0     0
            sdab              ONLINE       0     0     0
            sdac              ONLINE       0     0     0
            sdad              ONLINE       0     0     0
            sdae              ONLINE       0     0     0
            sdaf              ONLINE       0     0     0
            sdag              ONLINE       0     0     0
            sdah              ONLINE       0     0     0
            sdai              ONLINE       0     0     0
            sdaj              ONLINE       0     0     0
            sdak              ONLINE       0     0     0
            sdal              ONLINE       0     0     0
            sdam              ONLINE       0     0     0
            sdan              ONLINE       0     0     0
            sdao              ONLINE       0     0     0
            sdap              ONLINE       0     0     0
            sdaq              ONLINE       0     0     0
            sdar              ONLINE       0     0     0
            sdas              ONLINE       0     0     0
            sdat              ONLINE       0     0     0
            sdau              ONLINE       0     0     0
            sdav              ONLINE       0     0     0
            sdaw              ONLINE       0     0     0
            sdax              ONLINE       0     0     0
            sdba              ONLINE       0     0     0
            spare-49          DEGRADED     0     0     0
              sdbb            UNAVAIL      0     0     0
              draid2-0-1      ONLINE       0     0     0
            spare-50          DEGRADED     0     0     0
              sdbc            UNAVAIL      0     0     0
              draid2-0-4      ONLINE       0     0     0
            sdbd              ONLINE       0     0     0
            sdbe              ONLINE       0     0     0
            sdbf              ONLINE       0     0     0
            sdbg              ONLINE       0     0     0
            sdbh              ONLINE       0     0     0
            sdbi              ONLINE       0     0     0
            sdbj              ONLINE       0     0     0
            sdbk              ONLINE       0     0     0
            sdbl              ONLINE       0     0     0
            sdbm              ONLINE       0     0     0
            sdbn              ONLINE       0     0     0
            sdbo              ONLINE       0     0     0
            sdbp              ONLINE       0     0     0
            sdbq              ONLINE       0     0     0
            sdbr              ONLINE       0     0     0
            sdbs              ONLINE       0     0     0
            sdbt              ONLINE       0     0     0
            sdbu              ONLINE       0     0     0
            sdbv              ONLINE       0     0     0
            sdbw              ONLINE       0     0     0
            sdbx              ONLINE       0     0     0
            sdca              ONLINE       0     0     0
            spare-73          DEGRADED     0     0     0
              sdcb            UNAVAIL      0     0     0
              draid2-0-2      ONLINE       0     0     0
            spare-74          DEGRADED     0     0     0
              sdcc            UNAVAIL      0     0     0
              draid2-0-5      ONLINE       0     0     0
            sdcd              ONLINE       0     0     0
            spare-76          DEGRADED     0     0     0
              sdce            UNAVAIL      0     0     0
              sdz             ONLINE       0     0     0
            sdcf              ONLINE       0     0     0
            spare-78          DEGRADED     0     0     0
              sdcg            UNAVAIL      0     0     0
              sday            ONLINE       0     0     0
            sdch              ONLINE       0     0     0
            spare-80          DEGRADED     0     0     0
              sdci            UNAVAIL      0     0     0
              sdaz            ONLINE       0     0     0
            sdcj              ONLINE       0     0     0
            spare-82          DEGRADED     0     0     0
              sdck            UNAVAIL      0     0     0
              sdby            ONLINE       0     0     0
            sdcl              ONLINE       0     0     0
            sdcm              UNAVAIL      0     0     0
            sdcn              ONLINE       0     0     0
            spare-86          DEGRADED     0     0     0
              sdco            UNAVAIL      0     0     0
              sdbz            ONLINE       0     0     0
            sdcp              UNAVAIL      0     0     0
            sdcq              ONLINE       0     0     0
            sdcr              ONLINE       0     0     0
            sdcs              ONLINE       0     0     0
            sdct              ONLINE       0     0     0
            sdcu              ONLINE       0     0     0
            sdcv              ONLINE       0     0     0
            sdcw              ONLINE       0     0     0
            sdcx              ONLINE       0     0     0
        spares
          draid2-0-0          INUSE     currently in use
          draid2-0-1          INUSE     currently in use
          draid2-0-2          INUSE     currently in use
          draid2-0-3          INUSE     currently in use
          draid2-0-4          INUSE     currently in use
          draid2-0-5          INUSE     currently in use
          sdz                 INUSE     currently in use
          sday                INUSE     currently in use
          sdaz                INUSE     currently in use
          sdby                INUSE     currently in use
          sdbz                INUSE     currently in use
          sdcy                AVAIL
          sdcz                AVAIL
errors: No known data errors

# zpool replace zdraidtest sdcm sdcy
# zpool replace zdraidtest sdcm sdcz
/dev/sdcy is in use and contains a unknown filesystem.
/dev/sdcz is in use and contains a unknown filesystem.

-----

Another iteration: 96 drive pool with x2 VDEVs (48/ea) and 4 vspares:

+ zpool create -o autoreplace=on -o autoexpand=on -O atime=off -O compression=lz4 zdraidtest \
  draid2:8d:48c:4s /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg /dev/sdh /dev/sdi \
  /dev/sdj /dev/sdk /dev/sdl \
/dev/sdm /dev/sdn /dev/sdo /dev/sdp /dev/sdq /dev/sdr /dev/sds /dev/sdt \
/dev/sdu /dev/sdv /dev/sdw /dev/sdx /dev/sdy /dev/sdaa /dev/sdab /dev/sdac \
/dev/sdad /dev/sdae /dev/sdaf /dev/sdag /dev/sdah /dev/sdai /dev/sdaj \
/dev/sdak /dev/sdal /dev/sdam /dev/sdan /dev/sdao /dev/sdap /dev/sdaq \
/dev/sdar /dev/sdas /dev/sdat /dev/sdau /dev/sdav /dev/sdaw /dev/sdax \
draid2:8d:48c:4s /dev/sdba /dev/sdbb /dev/sdbc /dev/sdbd /dev/sdbe /dev/sdbf \
/dev/sdbg /dev/sdbh /dev/sdbi /dev/sdbj /dev/sdbk /dev/sdbl /dev/sdbm \
/dev/sdbn /dev/sdbo /dev/sdbp /dev/sdbq /dev/sdbr /dev/sdbs /dev/sdbt \
/dev/sdbu /dev/sdbv /dev/sdbw /dev/sdbx /dev/sdca /dev/sdcb /dev/sdcc \
/dev/sdcd /dev/sdce /dev/sdcf /dev/sdcg /dev/sdch /dev/sdci /dev/sdcj \
/dev/sdck /dev/sdcl /dev/sdcm /dev/sdcn /dev/sdco /dev/sdcp /dev/sdcq \
/dev/sdcr /dev/sdcs /dev/sdct /dev/sdcu /dev/sdcv /dev/sdcw /dev/sdcx
real    0m13.202s

+ zfs create -o atime=off -o compression=lz4 -o sharesmb=on -o xattr=sa -o recordsize=1024k zdraidtest/shrcompr
cannot share 'zdraidtest/shrcompr: system error': SMB share creation failed
filesystem successfully created, but not shared
changed ownership of '/zdraidtest/shrcompr' from root to user
Filesystem          Type      Size  Used Avail Use% Mounted on
zdraidtest/shrcompr zfs       250G  1.0M  250G   1% /zdraidtest/shrcompr

+ zfs create -o atime=off -o compression=lz4 -o sharesmb=off -o recordsize=1024k zdraidtest/notshrcompr
changed ownership of '/zdraidtest/notshrcompr' from root to user
Filesystem             Type      Size  Used Avail Use% Mounted on
zdraidtest/notshrcompr zfs       250G  1.0M  250G   1% /zdraidtest/notshrcompr

+ zfs create -o atime=off -o compression=zstd-3 -o sharesmb=off -o recordsize=1024k zdraidtest/notshrcompr-zstd
changed ownership of '/zdraidtest/notshrcompr-zstd' from root to user
Filesystem                  Type      Size  Used Avail Use% Mounted on
zdraidtest/notshrcompr-zstd zfs       250G  1.0M  250G   1% /zdraidtest/notshrcompr-zstd

+ zfs create -o atime=off -o compression=off -o sharesmb=off -o recordsize=1024k zdraidtest/notshrnotcompr
changed ownership of '/zdraidtest/notshrnotcompr' from root to user
Filesystem                  Type      Size  Used Avail Use% Mounted on
zdraidtest/notshrnotcompr   zfs       250G  1.0M  250G   1% /zdraidtest/notshrnotcompr

  pool: zdraidtest
 state: ONLINE
config:
        NAME                  STATE     READ WRITE CKSUM
        zdraidtest            ONLINE       0     0     0
          draid2:8d:48c:4s-0  ONLINE       0     0     0
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
            sdaa              ONLINE       0     0     0
            sdab              ONLINE       0     0     0
            sdac              ONLINE       0     0     0
            sdad              ONLINE       0     0     0
            sdae              ONLINE       0     0     0
            sdaf              ONLINE       0     0     0
            sdag              ONLINE       0     0     0
            sdah              ONLINE       0     0     0
            sdai              ONLINE       0     0     0
            sdaj              ONLINE       0     0     0
            sdak              ONLINE       0     0     0
            sdal              ONLINE       0     0     0
            sdam              ONLINE       0     0     0
            sdan              ONLINE       0     0     0
            sdao              ONLINE       0     0     0
            sdap              ONLINE       0     0     0
            sdaq              ONLINE       0     0     0
            sdar              ONLINE       0     0     0
            sdas              ONLINE       0     0     0
            sdat              ONLINE       0     0     0
            sdau              ONLINE       0     0     0
            sdav              ONLINE       0     0     0
            sdaw              ONLINE       0     0     0
            sdax              ONLINE       0     0     0
          draid2:8d:48c:4s-1  ONLINE       0     0     0
            sdba              ONLINE       0     0     0
            sdbb              ONLINE       0     0     0
            sdbc              ONLINE       0     0     0
            sdbd              ONLINE       0     0     0
            sdbe              ONLINE       0     0     0
            sdbf              ONLINE       0     0     0
            sdbg              ONLINE       0     0     0
            sdbh              ONLINE       0     0     0
            sdbi              ONLINE       0     0     0
            sdbj              ONLINE       0     0     0
            sdbk              ONLINE       0     0     0
            sdbl              ONLINE       0     0     0
            sdbm              ONLINE       0     0     0
            sdbn              ONLINE       0     0     0
            sdbo              ONLINE       0     0     0
            sdbp              ONLINE       0     0     0
            sdbq              ONLINE       0     0     0
            sdbr              ONLINE       0     0     0
            sdbs              ONLINE       0     0     0
            sdbt              ONLINE       0     0     0
            sdbu              ONLINE       0     0     0
            sdbv              ONLINE       0     0     0
            sdbw              ONLINE       0     0     0
            sdbx              ONLINE       0     0     0
            sdca              ONLINE       0     0     0
            sdcb              ONLINE       0     0     0
            sdcc              ONLINE       0     0     0
            sdcd              ONLINE       0     0     0
            sdce              ONLINE       0     0     0
            sdcf              ONLINE       0     0     0
            sdcg              ONLINE       0     0     0
            sdch              ONLINE       0     0     0
            sdci              ONLINE       0     0     0
            sdcj              ONLINE       0     0     0
            sdck              ONLINE       0     0     0
            sdcl              ONLINE       0     0     0
            sdcm              ONLINE       0     0     0
            sdcn              ONLINE       0     0     0
            sdco              ONLINE       0     0     0
            sdcp              ONLINE       0     0     0
            sdcq              ONLINE       0     0     0
            sdcr              ONLINE       0     0     0
            sdcs              ONLINE       0     0     0
            sdct              ONLINE       0     0     0
            sdcu              ONLINE       0     0     0
            sdcv              ONLINE       0     0     0
            sdcw              ONLINE       0     0     0
            sdcx              ONLINE       0     0     0
        spares
          draid2-0-0          AVAIL
          draid2-0-1          AVAIL
          draid2-0-2          AVAIL
          draid2-0-3          AVAIL
          draid2-1-0          AVAIL
          draid2-1-1          AVAIL
          draid2-1-2          AVAIL
          draid2-1-3          AVAIL
errors: No known data errors

NAME         SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zdraidtest   322G  2.46M   322G        -         -     0%     0%  1.00x    ONLINE  -

NAME                          USED  AVAIL     REFER  MOUNTPOINT
zdraidtest                   1.57M   249G      112K  /zdraidtest
zdraidtest/notshrcompr       95.9K   249G     95.9K  /zdraidtest/notshrcompr
zdraidtest/notshrcompr-zstd  95.9K   249G     95.9K  /zdraidtest/notshrcompr-zstd
zdraidtest/notshrnotcompr    95.9K   249G     95.9K  /zdraidtest/notshrnotcompr
zdraidtest/shrcompr          95.9K   249G     95.9K  /zdraidtest/shrcompr

Filesystem                  Type      Size  Used Avail Use% Mounted on
zdraidtest                  zfs       250G  128K  250G   1% /zdraidtest
zdraidtest/shrcompr         zfs       250G  1.0M  250G   1% /zdraidtest/shrcompr
zdraidtest/notshrcompr      zfs       250G  1.0M  250G   1% /zdraidtest/notshrcompr
zdraidtest/notshrcompr-zstd zfs       250G  1.0M  250G   1% /zdraidtest/notshrcompr-zstd
zdraidtest/notshrnotcompr   zfs       250G  1.0M  250G   1% /zdraidtest/notshrnotcompr
NOTE - best practice is to export the pool and # zpool import -a -d /dev/disk/by-id

-----

As expected, a raidz2 pool with 4 vspares can sustain 6 drive failures per vdev without data loss:

  pool: zdraidtest
 state: DEGRADED
status: One or more devices could not be used because the label is missing or
        invalid.  Sufficient replicas exist for the pool to continue
        functioning in a degraded state.
action: Replace the device using 'zpool replace'.
   see: https://openzfs.github.io/openzfs-docs/msg/ZFS-8000-4J
  scan: scrub repaired 0B in 00:00:01 with 0 errors on Mon Jul  5 20:41:42 2021
  scan: resilvered (draid2:8d:48c:4s-0) 6.31M in 00:00:30 with 0 errors on Mon Jul  5 20:41:41 2021
config:
        NAME                  STATE     READ WRITE CKSUM
        zdraidtest            DEGRADED     0     0     0
          draid2:8d:48c:4s-0  DEGRADED     0     0     0
            spare-0           DEGRADED     0     0     0
              sdb             UNAVAIL      0     0     0
              draid2-0-0      ONLINE       0     0     0
            sdc               ONLINE       0     0     0
            spare-2           DEGRADED     0     0     0
              sdd             UNAVAIL      0     0     0
              draid2-0-1      ONLINE       0     0     0
            sde               ONLINE       0     0     0
            spare-4           DEGRADED     0     0     0
              sdf             UNAVAIL      0     0     0
              draid2-0-2      ONLINE       0     0     0
            sdg               ONLINE       0     0     0
            spare-6           DEGRADED     0     0     0
              sdh             UNAVAIL      0     0     0
              draid2-0-3      ONLINE       0     0     0
            sdi               ONLINE       0     0     0
            sdj               UNAVAIL      0     0     0
            sdk               ONLINE       0     0     0
            sdl               UNAVAIL      0     0     0
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
            sdaa              ONLINE       0     0     0
            sdab              ONLINE       0     0     0
            sdac              ONLINE       0     0     0
            sdad              ONLINE       0     0     0
            sdae              ONLINE       0     0     0
            sdaf              ONLINE       0     0     0
            sdag              ONLINE       0     0     0
            sdah              ONLINE       0     0     0
            sdai              ONLINE       0     0     0
            sdaj              ONLINE       0     0     0
            sdak              ONLINE       0     0     0
            sdal              ONLINE       0     0     0
            sdam              ONLINE       0     0     0
            sdan              ONLINE       0     0     0
            sdao              ONLINE       0     0     0
            sdap              ONLINE       0     0     0
            sdaq              ONLINE       0     0     0
            sdar              ONLINE       0     0     0
            sdas              ONLINE       0     0     0
            sdat              ONLINE       0     0     0
            sdau              ONLINE       0     0     0
            sdav              ONLINE       0     0     0
            sdaw              ONLINE       0     0     0
            sdax              ONLINE       0     0     0
          draid2:8d:48c:4s-1  ONLINE       0     0     0
            sdba              ONLINE       0     0     0
            sdbb              ONLINE       0     0     0
            sdbc              ONLINE       0     0     0
            sdbd              ONLINE       0     0     0
            sdbe              ONLINE       0     0     0
            sdbf              ONLINE       0     0     0
            sdbg              ONLINE       0     0     0
            sdbh              ONLINE       0     0     0
            sdbi              ONLINE       0     0     0
            sdbj              ONLINE       0     0     0
            sdbk              ONLINE       0     0     0
            sdbl              ONLINE       0     0     0
            sdbm              ONLINE       0     0     0
            sdbn              ONLINE       0     0     0
            sdbo              ONLINE       0     0     0
            sdbp              ONLINE       0     0     0
            sdbq              ONLINE       0     0     0
            sdbr              ONLINE       0     0     0
            sdbs              ONLINE       0     0     0
            sdbt              ONLINE       0     0     0
            sdbu              ONLINE       0     0     0
            sdbv              ONLINE       0     0     0
            sdbw              ONLINE       0     0     0
            sdbx              ONLINE       0     0     0
            sdca              ONLINE       0     0     0
            sdcb              ONLINE       0     0     0
            sdcc              ONLINE       0     0     0
            sdcd              ONLINE       0     0     0
            sdce              ONLINE       0     0     0
            sdcf              ONLINE       0     0     0
            sdcg              ONLINE       0     0     0
            sdch              ONLINE       0     0     0
            sdci              ONLINE       0     0     0
            sdcj              ONLINE       0     0     0
            sdck              ONLINE       0     0     0
            sdcl              ONLINE       0     0     0
            sdcm              ONLINE       0     0     0
            sdcn              ONLINE       0     0     0
            sdco              ONLINE       0     0     0
            sdcp              ONLINE       0     0     0
            sdcq              ONLINE       0     0     0
            sdcr              ONLINE       0     0     0
            sdcs              ONLINE       0     0     0
            sdct              ONLINE       0     0     0
            sdcu              ONLINE       0     0     0
            sdcv              ONLINE       0     0     0
            sdcw              ONLINE       0     0     0
            sdcx              ONLINE       0     0     0
        spares
          draid2-0-0          INUSE     currently in use
          draid2-0-1          INUSE     currently in use
          draid2-0-2          INUSE     currently in use
          draid2-0-3          INUSE     currently in use
          draid2-1-0          AVAIL
          draid2-1-1          AVAIL
          draid2-1-2          AVAIL
          draid2-1-3          AVAIL
errors: No known data errors

After failing sdba in vdev #2, zpool status is giving us pertinent information:

  pool: zdraidtest
 state: DEGRADED
status: One or more devices could not be used because the label is missing or
        invalid.  Sufficient replicas exist for the pool to continue
        functioning in a degraded state.
action: Replace the device using 'zpool replace'.
   see: https://openzfs.github.io/openzfs-docs/msg/ZFS-8000-4J
  scan: scrub repaired 0B in 00:00:00 with 0 errors on Mon Jul  5 20:48:21 2021
  scan: resilvered (draid2:8d:48c:4s-0) 6.31M in 00:00:30 with 0 errors on Mon Jul  5 20:41:41 2021
  scan: resilvered (draid2:8d:48c:4s-1) 44K in 00:00:30 with 0 errors on Mon Jul  5 20:48:21 2021

NOTE that if we add physical hotspares on the fly, ZED will not auto-allocate spares to the
already UNAVAIL drives in vdev #1 - they still need to be manually replaced.

  
# source draid-pooldisks-assoc.sh
# zp=zdraidtest;zpool add $zp spare ${hotspares[@]} # got error, maybe part of active pool 
# - reset did not LC hotspares

# echo ${hotspares[@]}
# zpool status -v |egrep 'sdz|sday|sdaz|sdby|sdbz|sdcy|sdcz'
  zpool labelclear -f /dev/sdz1
  zpool labelclear -f /dev/sday1
  zpool labelclear -f /dev/sdaz1
  zpool labelclear -f /dev/sdby1
  zpool labelclear -f /dev/sdbz1
  zpool labelclear -f /dev/sdcy1
  zpool labelclear -f /dev/sdcz1
  zp=zdraidtest;zpool add $zp spare ${hotspares[@]}
  zps

Note that the pool still shows DEGRADED if a drive under "spares" is in use - keeping a drive outside
  of "spares" (such as sdda) and replacing using that will be considered a permanent replacement
  and when the "spares" drive is replaced it will go back to the "AVAIL" spares list. 
  
            spare-8           DEGRADED     0     0     0
              sdj             UNAVAIL      0     0     0
              sdz             ONLINE       0     0     0
            sdk               ONLINE       0     0     0

# zpool replace zdraidtest sdz sdda
cannot replace sdz with sdda: can only be replaced by another hot spare
# zpool replace zdraidtest sdj sdda

            sdi               ONLINE       0     0     0
            sdda              ONLINE       0     0     0
            sdk               ONLINE       0     0     0
            sdl               UNAVAIL      0     0     0

-----

Yet another iteration: 96 drives, 4xVDEVs, 3 spares per vdev and 4xPspares:
NOTE we still have 3-4 pspares available outside of the allocated 'spares' JIC

+ zpool create -o autoreplace=on -o autoexpand=on -O atime=off -O compression=lz4 zdraidtest \
 draid2:8d:24c:3s /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg \
 /dev/sdh /dev/sdi /dev/sdj /dev/sdk /dev/sdl \
/dev/sdm /dev/sdn /dev/sdo /dev/sdp /dev/sdq /dev/sdr /dev/sds /dev/sdt \
/dev/sdu /dev/sdv /dev/sdw /dev/sdx /dev/sdy \
 draid2:8d:24c:3s /dev/sdaa /dev/sdab /dev/sdac /dev/sdad /dev/sdae /dev/sdaf /dev/sdag /dev/sdah \
/dev/sdai /dev/sdaj /dev/sdak /dev/sdal /dev/sdam /dev/sdan /dev/sdao \
/dev/sdap /dev/sdaq /dev/sdar /dev/sdas /dev/sdat /dev/sdau /dev/sdav \
/dev/sdaw /dev/sdax \
 draid2:8d:24c:3s /dev/sdba /dev/sdbb /dev/sdbc /dev/sdbd \
/dev/sdbe /dev/sdbf /dev/sdbg /dev/sdbh /dev/sdbi /dev/sdbj /dev/sdbk \
/dev/sdbl /dev/sdbm /dev/sdbn /dev/sdbo /dev/sdbp /dev/sdbq /dev/sdbr \
/dev/sdbs /dev/sdbt /dev/sdbu /dev/sdbv /dev/sdbw /dev/sdbx \
 draid2:8d:24c:3s \
/dev/sdca /dev/sdcb /dev/sdcc /dev/sdcd /dev/sdce /dev/sdcf /dev/sdcg \
/dev/sdch /dev/sdci /dev/sdcj /dev/sdck /dev/sdcl /dev/sdcm /dev/sdcn \
/dev/sdco /dev/sdcp /dev/sdcq /dev/sdcr /dev/sdcs /dev/sdct /dev/sdcu \
/dev/sdcv /dev/sdcw /dev/sdcx
real    0m15.215s

+ zfs create -o atime=off -o compression=lz4 -o sharesmb=on -o xattr=sa -o recordsize=1024k zdraidtest/shrcompr
cannot share 'zdraidtest/shrcompr: system error': SMB share creation failed
filesystem successfully created, but not shared
changed ownership of '/zdraidtest/shrcompr' from root to user
Filesystem          Type      Size  Used Avail Use% Mounted on
zdraidtest/shrcompr zfs       239G  1.0M  239G   1% /zdraidtest/shrcompr
/root/bin/boojum/zfs-newds.sh opt1=(1)compression opt1=(1)sharesmb, 0 == OFF zpool dirname

+ zfs create -o atime=off -o compression=lz4 -o sharesmb=off -o recordsize=1024k zdraidtest/notshrcompr
changed ownership of '/zdraidtest/notshrcompr' from root to user
Filesystem             Type      Size  Used Avail Use% Mounted on
zdraidtest/notshrcompr zfs       239G  1.0M  239G   1% /zdraidtest/notshrcompr

+ zfs create -o atime=off -o compression=zstd-3 -o sharesmb=off -o recordsize=1024k zdraidtest/notshrcompr-zstd
changed ownership of '/zdraidtest/notshrcompr-zstd' from root to user
Filesystem                  Type      Size  Used Avail Use% Mounted on
zdraidtest/notshrcompr-zstd zfs       239G  1.0M  239G   1% /zdraidtest/notshrcompr-zstd

+ zfs create -o atime=off -o compression=off -o sharesmb=off -o recordsize=1024k zdraidtest/notshrnotcompr
changed ownership of '/zdraidtest/notshrnotcompr' from root to user
Filesystem                  Type      Size  Used Avail Use% Mounted on

zdraidtest/notshrnotcompr   zfs       239G  1.0M  239G   1% /zdraidtest/notshrnotcompr
  pool: zdraidtest
 state: ONLINE
config:
        NAME                  STATE     READ WRITE CKSUM
        zdraidtest            ONLINE       0     0     0
          draid2:8d:24c:3s-0  ONLINE       0     0     0
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
          draid2:8d:24c:3s-1  ONLINE       0     0     0
            sdaa              ONLINE       0     0     0
            sdab              ONLINE       0     0     0
            sdac              ONLINE       0     0     0
            sdad              ONLINE       0     0     0
            sdae              ONLINE       0     0     0
            sdaf              ONLINE       0     0     0
            sdag              ONLINE       0     0     0
            sdah              ONLINE       0     0     0
            sdai              ONLINE       0     0     0
            sdaj              ONLINE       0     0     0
            sdak              ONLINE       0     0     0
            sdal              ONLINE       0     0     0
            sdam              ONLINE       0     0     0
            sdan              ONLINE       0     0     0
            sdao              ONLINE       0     0     0
            sdap              ONLINE       0     0     0
            sdaq              ONLINE       0     0     0
            sdar              ONLINE       0     0     0
            sdas              ONLINE       0     0     0
            sdat              ONLINE       0     0     0
            sdau              ONLINE       0     0     0
            sdav              ONLINE       0     0     0
            sdaw              ONLINE       0     0     0
            sdax              ONLINE       0     0     0
          draid2:8d:24c:3s-2  ONLINE       0     0     0
            sdba              ONLINE       0     0     0
            sdbb              ONLINE       0     0     0
            sdbc              ONLINE       0     0     0
            sdbd              ONLINE       0     0     0
            sdbe              ONLINE       0     0     0
            sdbf              ONLINE       0     0     0
            sdbg              ONLINE       0     0     0
            sdbh              ONLINE       0     0     0
            sdbi              ONLINE       0     0     0
            sdbj              ONLINE       0     0     0
            sdbk              ONLINE       0     0     0
            sdbl              ONLINE       0     0     0
            sdbm              ONLINE       0     0     0
            sdbn              ONLINE       0     0     0
            sdbo              ONLINE       0     0     0
            sdbp              ONLINE       0     0     0
            sdbq              ONLINE       0     0     0
            sdbr              ONLINE       0     0     0
            sdbs              ONLINE       0     0     0
            sdbt              ONLINE       0     0     0
            sdbu              ONLINE       0     0     0
            sdbv              ONLINE       0     0     0
            sdbw              ONLINE       0     0     0
            sdbx              ONLINE       0     0     0
          draid2:8d:24c:3s-3  ONLINE       0     0     0
            sdca              ONLINE       0     0     0
            sdcb              ONLINE       0     0     0
            sdcc              ONLINE       0     0     0
            sdcd              ONLINE       0     0     0
            sdce              ONLINE       0     0     0
            sdcf              ONLINE       0     0     0
            sdcg              ONLINE       0     0     0
            sdch              ONLINE       0     0     0
            sdci              ONLINE       0     0     0
            sdcj              ONLINE       0     0     0
            sdck              ONLINE       0     0     0
            sdcl              ONLINE       0     0     0
            sdcm              ONLINE       0     0     0
            sdcn              ONLINE       0     0     0
            sdco              ONLINE       0     0     0
            sdcp              ONLINE       0     0     0
            sdcq              ONLINE       0     0     0
            sdcr              ONLINE       0     0     0
            sdcs              ONLINE       0     0     0
            sdct              ONLINE       0     0     0
            sdcu              ONLINE       0     0     0
            sdcv              ONLINE       0     0     0
            sdcw              ONLINE       0     0     0
            sdcx              ONLINE       0     0     0
        spares
          draid2-0-0          AVAIL
          draid2-0-1          AVAIL
          draid2-0-2          AVAIL
          draid2-1-0          AVAIL
          draid2-1-1          AVAIL
          draid2-1-2          AVAIL
          draid2-2-0          AVAIL
          draid2-2-1          AVAIL
          draid2-2-2          AVAIL
          draid2-3-0          AVAIL
          draid2-3-1          AVAIL
          draid2-3-2          AVAIL
          sdz                 AVAIL
          sday                AVAIL
          sdaz                AVAIL
          sdby                AVAIL
errors: No known data errors

NAME         SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zdraidtest   308G  2.07M   308G        -         -     0%     0%  1.00x    ONLINE  -

NAME                          USED  AVAIL     REFER  MOUNTPOINT
zdraidtest                   1.21M   238G      104K  /zdraidtest
zdraidtest/notshrcompr       95.9K   238G     95.9K  /zdraidtest/notshrcompr
zdraidtest/notshrcompr-zstd  95.9K   238G     95.9K  /zdraidtest/notshrcompr-zstd
zdraidtest/notshrnotcompr    95.9K   238G     95.9K  /zdraidtest/notshrnotcompr
zdraidtest/shrcompr          95.9K   238G     95.9K  /zdraidtest/shrcompr
Filesystem                  Type      Size  Used Avail Use% Mounted on
zdraidtest                  zfs       239G  128K  239G   1% /zdraidtest
zdraidtest/shrcompr         zfs       239G  1.0M  239G   1% /zdraidtest/shrcompr
zdraidtest/notshrcompr      zfs       239G  1.0M  239G   1% /zdraidtest/notshrcompr
zdraidtest/notshrcompr-zstd zfs       239G  1.0M  239G   1% /zdraidtest/notshrcompr-zstd
zdraidtest/notshrnotcompr   zfs       239G  1.0M  239G   1% /zdraidtest/notshrnotcompr
NOTE - best practice is to export the pool and # zpool import -a -d /dev/disk/by-id

---

The 1st vdev on this pool below got hit by a bus but it is still going strong with all available spares in use
 --and still no data loss:

  pool: zdraidtest
 state: DEGRADED
status: One or more devices could not be used because the label is missing or
        invalid.  Sufficient replicas exist for the pool to continue
        functioning in a degraded state.
action: Replace the device using 'zpool replace'.
   see: https://openzfs.github.io/openzfs-docs/msg/ZFS-8000-4J
  scan: resilvered 39.9M in 00:00:01 with 0 errors on Tue Jul  6 16:15:03 2021
config:
        NAME                  STATE     READ WRITE CKSUM
        zdraidtest            DEGRADED     0     0     0
          draid2:8d:24c:3s-0  DEGRADED     0     0     0
            spare-0           DEGRADED     0     0     0
              sdb             UNAVAIL      0     0     0
              draid2-0-0      ONLINE       0     0     0
            sdc               ONLINE       0     0     0
            spare-2           DEGRADED     0     0     0
              sdd             UNAVAIL      0     0     0
              draid2-0-1      ONLINE       0     0     0
            sde               ONLINE       0     0     0
            spare-4           DEGRADED     0     0     0
              sdf             UNAVAIL      0     0     0
              draid2-0-2      ONLINE       0     0     0
            sdg               ONLINE       0     0     0
            spare-6           DEGRADED     0     0     0
              sdh             UNAVAIL      0     0     0
              sdz             ONLINE       0     0     0
            sdi               ONLINE       0     0     0
            spare-8           DEGRADED     0     0     0
              sdj             UNAVAIL      0     0     0
              sday            ONLINE       0     0     0
            sdk               ONLINE       0     0     0
            spare-10          DEGRADED     0     0     0
              sdl             UNAVAIL      0     0     0
              sdaz            ONLINE       0     0     0
            sdm               ONLINE       0     0     0
            spare-12          DEGRADED     0     0     0
              sdn             UNAVAIL      0     0     0
              sdby            ONLINE       0     0     0
            sdo               ONLINE       0     0     0
            sdp               UNAVAIL      0     0     0
            sdq               ONLINE       0     0     0
            sdr               UNAVAIL      0     0     0
            sds               ONLINE       0     0     0
            sdt               ONLINE       0     0     0
            sdu               ONLINE       0     0     0
            sdv               ONLINE       0     0     0
            sdw               ONLINE       0     0     0
            sdx               ONLINE       0     0     0
            sdy               ONLINE       0     0     0
          draid2:8d:24c:3s-1  ONLINE       0     0     0
            sdaa              ONLINE       0     0     0
            sdab              ONLINE       0     0     0
            sdac              ONLINE       0     0     0
            sdad              ONLINE       0     0     0
            sdae              ONLINE       0     0     0
            sdaf              ONLINE       0     0     0
            sdag              ONLINE       0     0     0
            sdah              ONLINE       0     0     0
            sdai              ONLINE       0     0     0
            sdaj              ONLINE       0     0     0
            sdak              ONLINE       0     0     0
            sdal              ONLINE       0     0     0
            sdam              ONLINE       0     0     0
            sdan              ONLINE       0     0     0
            sdao              ONLINE       0     0     0
            sdap              ONLINE       0     0     0
            sdaq              ONLINE       0     0     0
            sdar              ONLINE       0     0     0
            sdas              ONLINE       0     0     0
            sdat              ONLINE       0     0     0
            sdau              ONLINE       0     0     0
            sdav              ONLINE       0     0     0
            sdaw              ONLINE       0     0     0
            sdax              ONLINE       0     0     0
          draid2:8d:24c:3s-2  ONLINE       0     0     0
            sdba              ONLINE       0     0     0
            sdbb              ONLINE       0     0     0
            sdbc              ONLINE       0     0     0
            sdbd              ONLINE       0     0     0
            sdbe              ONLINE       0     0     0
            sdbf              ONLINE       0     0     0
            sdbg              ONLINE       0     0     0
            sdbh              ONLINE       0     0     0
            sdbi              ONLINE       0     0     0
            sdbj              ONLINE       0     0     0
            sdbk              ONLINE       0     0     0
            sdbl              ONLINE       0     0     0
            sdbm              ONLINE       0     0     0
            sdbn              ONLINE       0     0     0
            sdbo              ONLINE       0     0     0
            sdbp              ONLINE       0     0     0
            sdbq              ONLINE       0     0     0
            sdbr              ONLINE       0     0     0
            sdbs              ONLINE       0     0     0
            sdbt              ONLINE       0     0     0
            sdbu              ONLINE       0     0     0
            sdbv              ONLINE       0     0     0
            sdbw              ONLINE       0     0     0
            sdbx              ONLINE       0     0     0
          draid2:8d:24c:3s-3  ONLINE       0     0     0
            sdca              ONLINE       0     0     0
            sdcb              ONLINE       0     0     0
            sdcc              ONLINE       0     0     0
            sdcd              ONLINE       0     0     0
            sdce              ONLINE       0     0     0
            sdcf              ONLINE       0     0     0
            sdcg              ONLINE       0     0     0
            sdch              ONLINE       0     0     0
            sdci              ONLINE       0     0     0
            sdcj              ONLINE       0     0     0
            sdck              ONLINE       0     0     0
            sdcl              ONLINE       0     0     0
            sdcm              ONLINE       0     0     0
            sdcn              ONLINE       0     0     0
            sdco              ONLINE       0     0     0
            sdcp              ONLINE       0     0     0
            sdcq              ONLINE       0     0     0
            sdcr              ONLINE       0     0     0
            sdcs              ONLINE       0     0     0
            sdct              ONLINE       0     0     0
            sdcu              ONLINE       0     0     0
            sdcv              ONLINE       0     0     0
            sdcw              ONLINE       0     0     0
            sdcx              ONLINE       0     0     0
        spares
          draid2-0-0          INUSE     currently in use
          draid2-0-1          INUSE     currently in use
          draid2-0-2          INUSE     currently in use
          draid2-1-0          AVAIL
          draid2-1-1          AVAIL
          draid2-1-2          AVAIL
          draid2-2-0          AVAIL
          draid2-2-1          AVAIL
          draid2-2-2          AVAIL
          draid2-3-0          AVAIL
          draid2-3-1          AVAIL
          draid2-3-2          AVAIL
          sdz                 INUSE     currently in use
          sday                INUSE     currently in use
          sdaz                INUSE     currently in use
          sdby                INUSE     currently in use
errors: No known data errors

--Lets bring vdev#1 back from the edge:

echo ${hotspares[@]}
zpool replace zdraidtest sdp sdbz
zpool replace zdraidtest sdr sdcy
zpool replace zdraidtest sdn sdcz
zps

  pool: zdraidtest
 state: DEGRADED
status: One or more devices could not be used because the label is missing or
        invalid.  Sufficient replicas exist for the pool to continue
        functioning in a degraded state.
action: Replace the device using 'zpool replace'.
   see: https://openzfs.github.io/openzfs-docs/msg/ZFS-8000-4J
  scan: resilvered 282M in 00:00:01 with 0 errors on Tue Jul  6 16:30:32 2021

# unavl 
zdraidtest 6

        spares
          draid2-0-0          INUSE     currently in use
          draid2-0-1          INUSE     currently in use
          draid2-0-2          INUSE     currently in use
          draid2-1-0          AVAIL   
          draid2-1-1          AVAIL   
          draid2-1-2          AVAIL   
          draid2-2-0          AVAIL   
          draid2-2-1          AVAIL   
          draid2-2-2          AVAIL   
          draid2-3-0          AVAIL   
          draid2-3-1          AVAIL   
          draid2-3-2          AVAIL   
          sdz                 INUSE     currently in use
          sday                INUSE     currently in use
          sdaz                INUSE     currently in use
          sdby                AVAIL   
errors: No known data errors

We still have (3) vspares per vdev + 1 pspare + raidz2 going, so the pool can still take (5) more hits to each(!)
  of the other vdevs and *still* keep going with nothing lost.
  
-----

NOTE if you simulate/take a drive offline, you cant just "echo online" to it later, that wont bring it back up!
try  rescan-scsi-bus.sh  or  reboot

FIX: if a drive is offline, replace it temporarily with a builtin virtual spare:
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

# zpool detach draid2-0-0


( OLD INFO )
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
