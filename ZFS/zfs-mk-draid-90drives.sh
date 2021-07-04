#!/bin/bash

echo "$0 - 2021 Dave Bechtel - make a ZFS DRAID pool"
echo "- pass arg1='reset' to destroy test pool"
echo "- pass arg1='fail' and arg2=dev2fail to simulate failure"

# Requires at least zfs 2.1.0
DBI=/dev/disk/by-id

# total disks for pool / children
td=82 # 90 - spares and rootdisk

# raidz level (usually 2)
rzl=2

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
#pooldisks=$pooldisks1' '$pooldisks2' '$pooldisks3' '$pooldisks4 # need entire set for reset
pooldisks=$pooldisks01' '$pooldisks02' '$pooldisks03' '$pooldisks04' '$pooldisks05' '$pooldisks06
  pooldisks=$pooldisks' '$pooldisks07' '$pooldisks08' '$pooldisks09' '$pooldisks10' '$pooldisks11
  pooldisks=$pooldisks' '$pooldisks12' '$pooldisks13' '$pooldisks14
 
# need entire set for reset
# sdb sdc sdd sde sdf sdg sdh sdi sdj sdk sdl sdm sdn sdo sdp sdq sdr sds sdt sdu sdv sdw sdx sdy
# 1   2   3   4   5   6    1   2   3   4   5   6   1   2   3   4   5   6   1   2   3   4   5   6
# D   D   D   Z2  Z2  S

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
    zpool labelclear -f "$d"1
  done
  echo ''
  zpool status -v

  exit; # early
fi

if [ "$1" = "fail" ]; then
  echo "$(date) - Simulating disk failure for $(ls -l $DBI |grep $2)"
  echo offline > /sys/block/$2/device/state
  cat /sys/block/$2/device/state

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

iteration=1
if [ "$iteration" = "1" ]; then 
# compression=zstd-3
# -o ashift=12
( set -x
time zpool create -o autoexpand=on -O atime=off -O compression=lz4 \
  $zp \
   draid$rzl:8d:12'c':$spr's' $pooldisks01 $pooldisks02 \
   draid$rzl:8d:12'c':$spr's' $pooldisks03 $pooldisks04 \
   draid$rzl:8d:12'c':$spr's' $pooldisks05 $pooldisks06 \
   draid$rzl:8d:12'c':$spr's' $pooldisks07 $pooldisks08 \
   draid$rzl:8d:12'c':$spr's' $pooldisks09 $pooldisks10 \
   draid$rzl:8d:12'c':$spr's' $pooldisks11 $pooldisks12 \
   draid$rzl:8d:12'c':$spr's' $pooldisks13 $pooldisks14 \
|| failexit 101 "Failed to create DRAID"
)
else
# One Big Mother
# -o ashift=12
# raidz level (usually 2)
  rzl=2
# spares
  spr=4
( set -x
  time zpool create -o autoexpand=on -O atime=off -O compression=lz4 \
    $zp \
     draid$rzl:6d:$td'c':$spr's' $pooldisks \
  || failexit 101 "Failed to create DRAID"
)
fi

rc=$?
[ $rc -gt 0 ] && exit $rc
# ^ Need this check because of subshell, will not exit early otherwise

# cre8 datasets
# requires external script in the same PATH
# going with lz4 so not limited by CPU for compression
zfs-newds.sh 11 $zp shrcompr
zfs-newds.sh 10 $zp notshrcompr
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

Iteration 1:
# make a draid with raidz1, x14 VDEVs, 4 data disks, 6 children, 1 spare
# since we are using fairly small (4GB) disks this should not be an issue

+ zpool create -o autoexpand=on -O atime=off -O compression=lz4 zdraidtest \
draid1:4d:6c:1s /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg \
draid1:4d:6c:1s /dev/sdh /dev/sdi /dev/sdj /dev/sdk /dev/sdl /dev/sdm \
draid1:4d:6c:1s /dev/sdn /dev/sdo /dev/sdp /dev/sdq /dev/sdr /dev/sds \
draid1:4d:6c:1s /dev/sdt /dev/sdu /dev/sdv /dev/sdw /dev/sdx /dev/sdy \
draid1:4d:6c:1s /dev/sdaa /dev/sdab /dev/sdac /dev/sdad /dev/sdae /dev/sdaf \
draid1:4d:6c:1s /dev/sdag /dev/sdah /dev/sdai /dev/sdaj /dev/sdak /dev/sdal \
draid1:4d:6c:1s /dev/sdam /dev/sdan /dev/sdao /dev/sdap /dev/sdaq /dev/sdar \
draid1:4d:6c:1s /dev/sdas /dev/sdat /dev/sdau /dev/sdav /dev/sdaw /dev/sdax \
draid1:4d:6c:1s /dev/sdba /dev/sdbb /dev/sdbc /dev/sdbd /dev/sdbe /dev/sdbf \ 
draid1:4d:6c:1s /dev/sdbg /dev/sdbh /dev/sdbi /dev/sdbj /dev/sdbk /dev/sdbl \
draid1:4d:6c:1s /dev/sdbm /dev/sdbn /dev/sdbo /dev/sdbp /dev/sdbq /dev/sdbr \
draid1:4d:6c:1s /dev/sdbs /dev/sdbt /dev/sdbu /dev/sdbv /dev/sdbw /dev/sdbx \
draid1:4d:6c:1s /dev/sdca /dev/sdcb /dev/sdcc /dev/sdcd /dev/sdce /dev/sdcf \
draid1:4d:6c:1s /dev/sdcg /dev/sdch /dev/sdci /dev/sdcj /dev/sdck /dev/sdcl
real    0m15.619s

+ zfs create -o atime=off -o compression=lz4 -o sharesmb=on -o xattr=sa -o recordsize=1024k zdraidtest/shrcompr
cannot share 'zdraidtest/shrcompr: system error': SMB share creation failed
filesystem successfully created, but not shared
changed ownership of '/zdraidtest/shrcompr' from root to user

Filesystem          Type      Size  Used Avail Use% Mounted on
zdraidtest/shrcompr zfs       196G  1.0M  196G   1% /zdraidtest/shrcompr

+ zfs create -o atime=off -o compression=lz4 -o sharesmb=off -o recordsize=1024k zdraidtest/notshrcompr
changed ownership of '/zdraidtest/notshrcompr' from root to user

Filesystem             Type      Size  Used Avail Use% Mounted on
zdraidtest/notshrcompr zfs       196G  1.0M  196G   1% /zdraidtest/notshrcompr

  pool: zdraidtest
 state: ONLINE
config:
        NAME                  STATE     READ WRITE CKSUM
        zdraidtest            ONLINE       0     0     0
          draid1:4d:6c:1s-0   ONLINE       0     0     0
            sdb               ONLINE       0     0     0
            sdc               ONLINE       0     0     0
            sdd               ONLINE       0     0     0
            sde               ONLINE       0     0     0
            sdf               ONLINE       0     0     0
            sdg               ONLINE       0     0     0
          draid1:4d:6c:1s-1   ONLINE       0     0     0
            sdh               ONLINE       0     0     0
            sdi               ONLINE       0     0     0
            sdj               ONLINE       0     0     0
            sdk               ONLINE       0     0     0
            sdl               ONLINE       0     0     0
            sdm               ONLINE       0     0     0
          draid1:4d:6c:1s-2   ONLINE       0     0     0
            sdn               ONLINE       0     0     0
            sdo               ONLINE       0     0     0
            sdp               ONLINE       0     0     0
            sdq               ONLINE       0     0     0
            sdr               ONLINE       0     0     0
            sds               ONLINE       0     0     0
          draid1:4d:6c:1s-3   ONLINE       0     0     0
            sdt               ONLINE       0     0     0
            sdu               ONLINE       0     0     0
            sdv               ONLINE       0     0     0
            sdw               ONLINE       0     0     0
            sdx               ONLINE       0     0     0
            sdy               ONLINE       0     0     0
          draid1:4d:6c:1s-4   ONLINE       0     0     0
            sdaa              ONLINE       0     0     0
            sdab              ONLINE       0     0     0
            sdac              ONLINE       0     0     0
            sdad              ONLINE       0     0     0
            sdae              ONLINE       0     0     0
            sdaf              ONLINE       0     0     0
          draid1:4d:6c:1s-5   ONLINE       0     0     0
            sdag              ONLINE       0     0     0
            sdah              ONLINE       0     0     0
            sdai              ONLINE       0     0     0
            sdaj              ONLINE       0     0     0
            sdak              ONLINE       0     0     0
            sdal              ONLINE       0     0     0
          draid1:4d:6c:1s-6   ONLINE       0     0     0
            sdam              ONLINE       0     0     0
            sdan              ONLINE       0     0     0
            sdao              ONLINE       0     0     0
            sdap              ONLINE       0     0     0
            sdaq              ONLINE       0     0     0
            sdar              ONLINE       0     0     0
          draid1:4d:6c:1s-7   ONLINE       0     0     0
            sdas              ONLINE       0     0     0
            sdat              ONLINE       0     0     0
            sdau              ONLINE       0     0     0
            sdav              ONLINE       0     0     0
            sdaw              ONLINE       0     0     0
            sdax              ONLINE       0     0     0
          draid1:4d:6c:1s-8   ONLINE       0     0     0
            sdba              ONLINE       0     0     0
            sdbb              ONLINE       0     0     0
            sdbc              ONLINE       0     0     0
            sdbd              ONLINE       0     0     0
            sdbe              ONLINE       0     0     0
            sdbf              ONLINE       0     0     0
          draid1:4d:6c:1s-9   ONLINE       0     0     0
            sdbg              ONLINE       0     0     0
            sdbh              ONLINE       0     0     0
            sdbi              ONLINE       0     0     0
            sdbj              ONLINE       0     0     0
            sdbk              ONLINE       0     0     0
            sdbl              ONLINE       0     0     0
          draid1:4d:6c:1s-10  ONLINE       0     0     0
            sdbm              ONLINE       0     0     0
            sdbn              ONLINE       0     0     0
            sdbo              ONLINE       0     0     0
            sdbp              ONLINE       0     0     0
            sdbq              ONLINE       0     0     0
            sdbr              ONLINE       0     0     0
          draid1:4d:6c:1s-11  ONLINE       0     0     0
            sdbs              ONLINE       0     0     0
            sdbt              ONLINE       0     0     0
            sdbu              ONLINE       0     0     0
            sdbv              ONLINE       0     0     0
            sdbw              ONLINE       0     0     0
            sdbx              ONLINE       0     0     0
          draid1:4d:6c:1s-12  ONLINE       0     0     0
            sdca              ONLINE       0     0     0
            sdcb              ONLINE       0     0     0
            sdcc              ONLINE       0     0     0
            sdcd              ONLINE       0     0     0
            sdce              ONLINE       0     0     0
            sdcf              ONLINE       0     0     0
          draid1:4d:6c:1s-13  ONLINE       0     0     0
            sdcg              ONLINE       0     0     0
            sdch              ONLINE       0     0     0
            sdci              ONLINE       0     0     0
            sdcj              ONLINE       0     0     0
            sdck              ONLINE       0     0     0
            sdcl              ONLINE       0     0     0
        spares
          draid1-0-0          AVAIL
          draid1-1-0          AVAIL
          draid1-2-0          AVAIL
          draid1-3-0          AVAIL
          draid1-4-0          AVAIL
          draid1-5-0          AVAIL
          draid1-6-0          AVAIL
          draid1-7-0          AVAIL
          draid1-8-0          AVAIL
          draid1-9-0          AVAIL
          draid1-10-0         AVAIL
          draid1-11-0         AVAIL
          draid1-12-0         AVAIL
          draid1-13-0         AVAIL
errors: No known data errors

NAME         SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zdraidtest   252G   895K   252G        -         -     0%     0%  1.00x    ONLINE  -

NAME                     USED  AVAIL     REFER  MOUNTPOINT
zdraidtest               497K   195G     51.9K  /zdraidtest
zdraidtest/notshrcompr  51.9K   195G     51.9K  /zdraidtest/notshrcompr
zdraidtest/shrcompr     51.9K   195G     51.9K  /zdraidtest/shrcompr

Filesystem             Type      Size  Used Avail Use% Mounted on
zdraidtest             zfs       196G  128K  196G   1% /zdraidtest
zdraidtest/shrcompr    zfs       196G  1.0M  196G   1% /zdraidtest/shrcompr
zdraidtest/notshrcompr zfs       196G  1.0M  196G   1% /zdraidtest/notshrcompr

NOTE - best practice is to export the pool and # zpool import -a -d /dev/disk/by-id


-----

     draid$rzl:6d:$td'c':$spr's' $pooldisks \

Iteration 2 - make a DRAID raidz2 with  6 data disks, (84) children, 4 spares = more space available
Note that we are allocating more virtual spares than the raidz2 level, as well as having
idle hotspare disks available - we can sustain 2 failures with no data loss, replace them
with virtual spares, and once the resilver finishes we should be able to sustain ANOTHER 2 fails
HOWEVER - if we get 4x simultaneous fails, the pool I/O gets suspended and we HAVE TO reboot
because the zfs commands will hang

+ zpool create -o autoexpand=on -O atime=off -O compression=lz4 zdraidtest \
 draid2:6d:84c:4s \
 /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg \
/dev/sdh /dev/sdi /dev/sdj /dev/sdk /dev/sdl /dev/sdm /dev/sdn /dev/sdo \
/dev/sdp /dev/sdq /dev/sdr /dev/sds /dev/sdt /dev/sdu /dev/sdv /dev/sdw \
/dev/sdx /dev/sdy /dev/sdaa /dev/sdab /dev/sdac /dev/sdad /dev/sdae \
/dev/sdaf /dev/sdag /dev/sdah /dev/sdai /dev/sdaj /dev/sdak /dev/sdal \
/dev/sdam /dev/sdan /dev/sdao /dev/sdap /dev/sdaq /dev/sdar /dev/sdas \
/dev/sdat /dev/sdau /dev/sdav /dev/sdaw /dev/sdax /dev/sdba /dev/sdbb \
/dev/sdbc /dev/sdbd /dev/sdbe /dev/sdbf /dev/sdbg /dev/sdbh /dev/sdbi \
/dev/sdbj /dev/sdbk /dev/sdbl /dev/sdbm /dev/sdbn /dev/sdbo /dev/sdbp \
/dev/sdbq /dev/sdbr /dev/sdbs /dev/sdbt /dev/sdbu /dev/sdbv /dev/sdbw \
/dev/sdbx /dev/sdca /dev/sdcb /dev/sdcc /dev/sdcd /dev/sdce /dev/sdcf \
/dev/sdcg /dev/sdch /dev/sdci /dev/sdcj /dev/sdck /dev/sdcl
real    0m11.846s

+ zfs create -o atime=off -o compression=lz4 -o sharesmb=on -o xattr=sa -o recordsize=1024k zdraidtest/shrcompr
cannot share 'zdraidtest/shrcompr: system error': SMB share creation failed
filesystem successfully created, but not shared
changed ownership of '/zdraidtest/shrcompr' from root to user

Filesystem          Type      Size  Used Avail Use% Mounted on
zdraidtest/shrcompr zfs       211G  1.0M  211G   1% /zdraidtest/shrcompr

+ zfs create -o atime=off -o compression=lz4 -o sharesmb=off -o recordsize=1024k zdraidtest/notshrcompr
changed ownership of '/zdraidtest/notshrcompr' from root to user

Filesystem             Type      Size  Used Avail Use% Mounted on
zdraidtest/notshrcompr zfs       211G  1.0M  211G   1% /zdraidtest/notshrcompr

  pool: zdraidtest
 state: ONLINE
config:
        NAME                  STATE     READ WRITE CKSUM
        zdraidtest            ONLINE       0     0     0
          draid2:6d:84c:4s-0  ONLINE       0     0     0
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
        spares
          draid2-0-0          AVAIL
          draid2-0-1          AVAIL
          draid2-0-2          AVAIL
          draid2-0-3          AVAIL
errors: No known data errors

NAME         SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zdraidtest   292G  1.21M   292G        -         -     0%     0%  1.00x    ONLINE  -

NAME                     USED  AVAIL     REFER  MOUNTPOINT
zdraidtest               634K   211G     77.4K  /zdraidtest
zdraidtest/notshrcompr  77.4K   211G     77.4K  /zdraidtest/notshrcompr
zdraidtest/shrcompr     77.4K   211G     77.4K  /zdraidtest/shrcompr

Filesystem             Type      Size  Used Avail Use% Mounted on
zdraidtest             zfs       211G  128K  211G   1% /zdraidtest
zdraidtest/shrcompr    zfs       211G  1.0M  211G   1% /zdraidtest/shrcompr
zdraidtest/notshrcompr zfs       211G  1.0M  211G   1% /zdraidtest/notshrcompr

NOTE - best practice is to export the pool and # zpool import -a -d /dev/disk/by-id


-----

Here is a simulated severely degraded draidZ2 pool with multiple drive failures and spares in use:

zpool replace zdraidtest sdbf draid2-0-0
zpool replace zdraidtest sdbg draid2-0-1


  pool: zdraidtest
 state: DEGRADED
status: One or more devices could not be used because the label is missing or
        invalid.  Sufficient replicas exist for the pool to continue
        functioning in a degraded state.
action: Replace the device using 'zpool replace'.
   see: https://openzfs.github.io/openzfs-docs/msg/ZFS-8000-4J
  scan: resilvered 192K in 00:00:00 with 0 errors on Sat Jul  3 17:13:50 2021
config:
        NAME                                             STATE     READ WRITE CKSUM
        zdraidtest                                       DEGRADED     0     0     0
          draid2:6d:84c:4s-0                             DEGRADED     0     0     0
            sdb                                          ONLINE       0     0     0
            sdc                                          ONLINE       0     0     0
            sdd                                          ONLINE       0     0     0
            sde                                          ONLINE       0     0     0
            sdf                                          ONLINE       0     0     0
            sdg                                          ONLINE       0     0     0
            sdh                                          ONLINE       0     0     0
            sdi                                          ONLINE       0     0     0
            sdj                                          ONLINE       0     0     0
            sdk                                          ONLINE       0     0     0
            sdl                                          ONLINE       0     0     0
            sdm                                          ONLINE       0     0     0
            sdn                                          ONLINE       0     0     0
            sdo                                          ONLINE       0     0     0
            sdp                                          ONLINE       0     0     0
            sdq                                          ONLINE       0     0     0
            sdr                                          ONLINE       0     0     0
            sds                                          ONLINE       0     0     0
            sdt                                          ONLINE       0     0     0
            sdu                                          ONLINE       0     0     0
            sdv                                          ONLINE       0     0     0
            sdw                                          ONLINE       0     0     0
            sdx                                          ONLINE       0     0     0
            sdy                                          ONLINE       0     0     0
            sdaa                                         ONLINE       0     0     0
            sdab                                         ONLINE       0     0     0
            sdac                                         ONLINE       0     0     0
            sdad                                         ONLINE       0     0     0
            sdae                                         ONLINE       0     0     0
            sdaf                                         ONLINE       0     0     0
            sdag                                         ONLINE       0     0     0
            sdah                                         ONLINE       0     0     0
            sdai                                         ONLINE       0     0     0
            sdaj                                         ONLINE       0     0     0
            sdak                                         ONLINE       0     0     0
            sdal                                         ONLINE       0     0     0
            sdam                                         ONLINE       0     0     0
            sdan                                         ONLINE       0     0     0
            sdao                                         ONLINE       0     0     0
            sdap                                         ONLINE       0     0     0
            sdaq                                         ONLINE       0     0     0
            sdar                                         ONLINE       0     0     0
            sdas                                         ONLINE       0     0     0
            sdat                                         ONLINE       0     0     0
            sdau                                         ONLINE       0     0     0
            sdav                                         ONLINE       0     0     0
            sdaw                                         ONLINE       0     0     0
            sdax                                         ONLINE       0     0     0
            sdba                                         ONLINE       0     0     0
            sdbb                                         ONLINE       0     0     0
            sdbc                                         ONLINE       0     0     0
            sdbd                                         ONLINE       0     0     0
            sdbe                                         ONLINE       0     0     0
            spare-53                                     DEGRADED     0     0     0
              sdbf                                       UNAVAIL      0     0     0
              draid2-0-0                                 ONLINE       0     0     0
            spare-54                                     DEGRADED     0     0     0
              sdbg                                       UNAVAIL      0     0     0
              draid2-0-1                                 ONLINE       0     0     0
            sdbh                                         ONLINE       0     0     0
            sdbi                                         ONLINE       0     0     0
            sdbj                                         ONLINE       0     0     0
            sdbk                                         ONLINE       0     0     0
            sdbl                                         ONLINE       0     0     0
            sdbm                                         ONLINE       0     0     0
            sdbn                                         ONLINE       0     0     0
            sdbo                                         ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBa5ac7f8f-8a80f392  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB3e6c2216-e4a84097  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBdf46700d-57ffca34  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB93e2157f-ddab1d56  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBa832bbfb-72039324  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBfaec32a1-3e70d636  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBf341e4d8-2d3ef1c1  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB6e562a6b-0a70e7a7  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB2b5edd5d-4a72ce8e  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB7ba0f6fc-682efc82  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB159ac173-a10e8776  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBd640cdea-57f6bda0  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB17592c2d-adb9e154  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB6fd46fec-854516be  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB5eb81d86-30bd0f13  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB104bd37f-4cfbff43  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB0482fe5a-9533bcec  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBf406b98e-63085d50  ONLINE       0     0     0
            scsi-1ATA_VBOX_HARDDISK_VB2bb3428a-78b4c7f1  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB3ccc0544-8e178e88  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBb0b1ed03-fa8cfd99  ONLINE       0     0     0
        spares
          draid2-0-0                                     INUSE     currently in use
          draid2-0-1                                     INUSE     currently in use
          draid2-0-2                                     AVAIL
          draid2-0-3                                     AVAIL
errors: No known data errors
  

NOTE that we still have 2x extra virtual spares available, and idle hotspare disks allocated;
We should be able to sustain 2 more disk failures but not 3.

At this point we will also simfail sdo and sdaq.

  pool: zdraidtest
 state: DEGRADED
status: One or more devices could not be used because the label is missing or
        invalid.  Sufficient replicas exist for the pool to continue
        functioning in a degraded state.
action: Replace the device using 'zpool replace'.
   see: https://openzfs.github.io/openzfs-docs/msg/ZFS-8000-4J
  scan: resilvered 192K in 00:00:00 with 0 errors on Sat Jul  3 17:13:50 2021
config:
        NAME                                             STATE     READ WRITE CKSUM
        zdraidtest                                       DEGRADED     0     0     0
          draid2:6d:84c:4s-0                             DEGRADED     0     0     0
            sdb                                          ONLINE       0     0     0
            sdc                                          ONLINE       0     0     0
            sdd                                          ONLINE       0     0     0
            sde                                          ONLINE       0     0     0
            sdf                                          ONLINE       0     0     0
            sdg                                          ONLINE       0     0     0
            sdh                                          ONLINE       0     0     0
            sdi                                          ONLINE       0     0     0
            sdj                                          ONLINE       0     0     0
            sdk                                          ONLINE       0     0     0
            sdl                                          ONLINE       0     0     0
            sdm                                          ONLINE       0     0     0
            sdn                                          ONLINE       0     0     0
            sdo                                          UNAVAIL      0     0     0
            sdp                                          ONLINE       0     0     0
            sdq                                          ONLINE       0     0     0
            sdr                                          ONLINE       0     0     0
            sds                                          ONLINE       0     0     0
            sdt                                          ONLINE       0     0     0
            sdu                                          ONLINE       0     0     0
            sdv                                          ONLINE       0     0     0
            sdw                                          ONLINE       0     0     0
            sdx                                          ONLINE       0     0     0
            sdy                                          ONLINE       0     0     0
            sdaa                                         ONLINE       0     0     0
            sdab                                         ONLINE       0     0     0
            sdac                                         ONLINE       0     0     0
            sdad                                         ONLINE       0     0     0
            sdae                                         ONLINE       0     0     0
            sdaf                                         ONLINE       0     0     0
            sdag                                         ONLINE       0     0     0
            sdah                                         ONLINE       0     0     0
            sdai                                         ONLINE       0     0     0
            sdaj                                         ONLINE       0     0     0
            sdak                                         ONLINE       0     0     0
            sdal                                         ONLINE       0     0     0
            sdam                                         ONLINE       0     0     0
            sdan                                         ONLINE       0     0     0
            sdao                                         ONLINE       0     0     0
            sdap                                         ONLINE       0     0     0
            sdaq                                         UNAVAIL      0     0     0
            sdar                                         ONLINE       0     0     0
            sdas                                         ONLINE       0     0     0
            sdat                                         ONLINE       0     0     0
            sdau                                         ONLINE       0     0     0
            sdav                                         ONLINE       0     0     0
            sdaw                                         ONLINE       0     0     0
            sdax                                         ONLINE       0     0     0
            sdba                                         ONLINE       0     0     0
            sdbb                                         ONLINE       0     0     0
            sdbc                                         ONLINE       0     0     0
            sdbd                                         ONLINE       0     0     0
            sdbe                                         ONLINE       0     0     0
            spare-53                                     DEGRADED     0     0     0
              sdbf                                       UNAVAIL      0     0     0
              draid2-0-0                                 ONLINE       0     0     0
            spare-54                                     DEGRADED     0     0     0
              sdbg                                       UNAVAIL      0     0     0
              draid2-0-1                                 ONLINE       0     0     0
            sdbh                                         ONLINE       0     0     0
            sdbi                                         ONLINE       0     0     0
            sdbj                                         ONLINE       0     0     0
            sdbk                                         ONLINE       0     0     0
            sdbl                                         ONLINE       0     0     0
            sdbm                                         ONLINE       0     0     0
            sdbn                                         ONLINE       0     0     0
            sdbo                                         ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBa5ac7f8f-8a80f392  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB3e6c2216-e4a84097  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBdf46700d-57ffca34  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB93e2157f-ddab1d56  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBa832bbfb-72039324  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBfaec32a1-3e70d636  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBf341e4d8-2d3ef1c1  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB6e562a6b-0a70e7a7  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB2b5edd5d-4a72ce8e  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB7ba0f6fc-682efc82  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB159ac173-a10e8776  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBd640cdea-57f6bda0  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB17592c2d-adb9e154  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB6fd46fec-854516be  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB5eb81d86-30bd0f13  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB104bd37f-4cfbff43  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB0482fe5a-9533bcec  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBf406b98e-63085d50  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB2bb3428a-78b4c7f1  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB3ccc0544-8e178e88  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBb0b1ed03-fa8cfd99  ONLINE       0     0     0
        spares
          draid2-0-0                                     INUSE     currently in use
          draid2-0-1                                     INUSE     currently in use
          draid2-0-2                                     AVAIL
          draid2-0-3                                     AVAIL
errors: No known data errors

As long as we replace the failed drives with either the available virtual spares or idling hotspare disks,
the pool will continue in a degraded state with no data loss.

Two virtual spares for  draid2:6d:84c:4s-0  are still good to go.
  If ANY other drive also fails at this point without a virtual or real spare put into use,
  we will have a dead pool. 

FIX: zpool replace zdraidtest sdbg sdbz
^ This puts the inuse spare back into an AVAIL state since the virtual spare was replaced with an actual drive

 zpool replace zdraidtest sdaq sdaz
 zpool replace zdraidtest sdo sday
 zpool replace zdraidtest sdbf sdby

  pool: zdraidtest
 state: ONLINE
  scan: resilvered 470K in 00:00:01 with 0 errors on Sat Jul  3 17:32:43 2021
config:
        NAME                                             STATE     READ WRITE CKSUM
        zdraidtest                                       ONLINE       0     0     0
          draid2:6d:84c:4s-0                             ONLINE       0     0     0
            sdb                                          ONLINE       0     0     0
            sdc                                          ONLINE       0     0     0
            sdd                                          ONLINE       0     0     0
            sde                                          ONLINE       0     0     0
            sdf                                          ONLINE       0     0     0
            sdg                                          ONLINE       0     0     0
            sdh                                          ONLINE       0     0     0
            sdi                                          ONLINE       0     0     0
            sdj                                          ONLINE       0     0     0
            sdk                                          ONLINE       0     0     0
            sdl                                          ONLINE       0     0     0
            sdm                                          ONLINE       0     0     0
            sdn                                          ONLINE       0     0     0
            sday                                         ONLINE       0     0     0
            sdp                                          ONLINE       0     0     0
            sdq                                          ONLINE       0     0     0
            sdr                                          ONLINE       0     0     0
            sds                                          ONLINE       0     0     0
            sdt                                          ONLINE       0     0     0
            sdu                                          ONLINE       0     0     0
            sdv                                          ONLINE       0     0     0
            sdw                                          ONLINE       0     0     0
            sdx                                          ONLINE       0     0     0
            sdy                                          ONLINE       0     0     0
            sdaa                                         ONLINE       0     0     0
            sdab                                         ONLINE       0     0     0
            sdac                                         ONLINE       0     0     0
            sdad                                         ONLINE       0     0     0
            sdae                                         ONLINE       0     0     0
            sdaf                                         ONLINE       0     0     0
            sdag                                         ONLINE       0     0     0
            sdah                                         ONLINE       0     0     0
            sdai                                         ONLINE       0     0     0
            sdaj                                         ONLINE       0     0     0
            sdak                                         ONLINE       0     0     0
            sdal                                         ONLINE       0     0     0
            sdam                                         ONLINE       0     0     0
            sdan                                         ONLINE       0     0     0
            sdao                                         ONLINE       0     0     0
            sdap                                         ONLINE       0     0     0
            sdaz                                         ONLINE       0     0     0
            sdar                                         ONLINE       0     0     0
            sdas                                         ONLINE       0     0     0
            sdat                                         ONLINE       0     0     0
            sdau                                         ONLINE       0     0     0
            sdav                                         ONLINE       0     0     0
            sdaw                                         ONLINE       0     0     0
            sdax                                         ONLINE       0     0     0
            sdba                                         ONLINE       0     0     0
            sdbb                                         ONLINE       0     0     0
            sdbc                                         ONLINE       0     0     0
            sdbd                                         ONLINE       0     0     0
            sdbe                                         ONLINE       0     0     0
            sdby                                         ONLINE       0     0     0
            sdbz                                         ONLINE       0     0     0
            sdbh                                         ONLINE       0     0     0
            sdbi                                         ONLINE       0     0     0
            sdbj                                         ONLINE       0     0     0
            sdbk                                         ONLINE       0     0     0
            sdbl                                         ONLINE       0     0     0
            sdbm                                         ONLINE       0     0     0
            sdbn                                         ONLINE       0     0     0
            sdbo                                         ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBa5ac7f8f-8a80f392  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB3e6c2216-e4a84097  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBdf46700d-57ffca34  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB93e2157f-ddab1d56  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBa832bbfb-72039324  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBfaec32a1-3e70d636  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBf341e4d8-2d3ef1c1  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB6e562a6b-0a70e7a7  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB2b5edd5d-4a72ce8e  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB7ba0f6fc-682efc82  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB159ac173-a10e8776  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBd640cdea-57f6bda0  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB17592c2d-adb9e154  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB6fd46fec-854516be  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB5eb81d86-30bd0f13  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB104bd37f-4cfbff43  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB0482fe5a-9533bcec  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBf406b98e-63085d50  ONLINE       0     0     0
            scsi-1ATA_VBOX_HARDDISK_VB2bb3428a-78b4c7f1  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VB3ccc0544-8e178e88  ONLINE       0     0     0
            scsi-SATA_VBOX_HARDDISK_VBb0b1ed03-fa8cfd99  ONLINE       0     0     0
        spares
          draid2-0-0                                     AVAIL
          draid2-0-1                                     AVAIL
          draid2-0-2                                     AVAIL
          draid2-0-3                                     AVAIL
errors: No known data errors

...and now the pool is whole again, all the virtual spares are back in place - things might be a little 
disordered as far as tracking what drives are in use now but we had multiple drive failures even after 
virtual spares were put in use and the pool is still going. ' zpool history ' can help.

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
