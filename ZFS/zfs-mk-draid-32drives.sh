#!/bin/bash

# Use this for 32 disks
echo "$0 - 2021 Dave Bechtel - make a ZFS DRAID pool"
echo "- pass arg1='reset' to destroy test pool"
echo "- pass arg1='fail' and arg2=dev2fail to simulate failure"
echo "Reboot to clear simulated device failures before issuing reset"

# Requires at least zfs 2.1.0
DD=/dev/disk
DBI=/dev/disk/by-id

# total disks for pool / children
td=32

# raidz level - usually 2
rzl=1

# spares
spr=4

# TODO EDITME
zp=zdraidtest

function zps () {
  zpool status -v |awk 'NF>0'
}

pooldisks1=$(echo /dev/sd{b..i) # 8
pooldisks2=$(echo /dev/sd{j..q})
pooldisks3=$(echo /dev/sd{r..y}) 
pooldisks4=$(echo /dev/sda{a..h}) # 32

pooldisks=$(echo /dev/sd{b..y} /dev/sda{a..h}) # a=root, z=spare
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
#source ~/bin/boojum/draid-pooldisks-assoc.sh $td

declare -a hotspares # regular indexed array
hotspares=(sdz sdah sdai sdaj) # we have thru sdak genned


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
#  -o ashift=12

# TODO EDITME
#iteration=OBM
iteration=z24a
if [ "$iteration" = "1" ]; then 
# raidz level (usually 2)
  rzl=1
# Vspares - you DON'T want to skimp!
  spr=4
#   draid$rzl:6d:8'c':$spr's' $pooldisks1 $pooldisks2 $pooldisks3 $pooldisks4 \
#   draid$rzl:6d:8'c':$spr's' $pooldisks5 $pooldisks6 $pooldisks7 $pooldisks8 \
( set -x
time zpool create -o autoreplace=on -o autoexpand=on -O atime=off -O compression=lz4 \
  $zp \
   draid$rzl:27d:$td'c':$spr's' sd{b..y} sda{a..h} \
|| failexit 101 "Failed to create DRAID"
)
# [ $(zpool list |grep -c "no pools") -eq 0 ] && \
#   zpool add $zp spare ${hotspares[@]}
elif [ "$iteration" = "2" ]; then 
  td=32
# raidz level (usually 2)
  rzl=1
# Vspares - if youre using DRAID then you want at least 1!
  spr=2
# b c d e f g h i j  k  l m n o p q r s t u v w x y  z=spare
# a b c d e f g h i j  k  l m n o p q r s t u v w x  y  z=spare (sdaa..ax)
# 1 2 3 4 5 6 7 8 9 10 1112131415161718192021222324  25 26
( set -x
time zpool create -o autoreplace=on -o autoexpand=on -O atime=off -O compression=lz4 \
  $zp \
   draid$rzl:13d:16'c':$spr's' sd{b..q} \
   draid$rzl:13d:16'c':$spr's' sd{r..y} sda{a..h} \
|| failexit 101 "Failed to create DRAID"
)
elif [ "$iteration" = "4" ]; then 
  td=32
# raidz level (usually 2)
  rzl=1
# Vspares - if youre using DRAID then you want at least 1!
  spr=2
# b c d e f g h i j  k  l m n o p q r s t u v w x y  z=spare
# a b c d e f g h i j  k  l m n o p q r s t u v w x  y  z=spare (sdaa..ax)
# 1 2 3 4 5 6 7 8 9 10 1112131415161718192021222324  25 26
( set -x
time zpool create -o autoreplace=on -o autoexpand=on -O atime=off -O compression=lz4 \
  $zp \
   draid$rzl:5d:8'c':$spr's' sd{b..i} \
   draid$rzl:5d:8'c':$spr's' sd{j..q} \
   draid$rzl:5d:8'c':$spr's' sd{r..y} \
   draid$rzl:5d:8'c':$spr's' sda{a..h} \
|| failexit 101 "Failed to create DRAID"
)
elif [ "$iteration" = "z21" ]; then 
# raidz level (usually 2)
  rzl=2
# Vspares - you DON'T want to skimp!
  spr=4
#   draid$rzl:6d:8'c':$spr's' $pooldisks1 $pooldisks2 $pooldisks3 $pooldisks4 \
#   draid$rzl:6d:8'c':$spr's' $pooldisks5 $pooldisks6 $pooldisks7 $pooldisks8 \
( set -x
time zpool create -o autoreplace=on -o autoexpand=on -O atime=off -O compression=lz4 \
  $zp \
   draid$rzl:26d:$td'c':$spr's' sd{b..y} sda{a..h} \
|| failexit 101 "Failed to create DRAID"
)
# [ $(zpool list |grep -c "no pools") -eq 0 ] && \
#   zpool add $zp spare ${hotspares[@]}
elif [ "$iteration" = "z22" ]; then 
  td=32
# raidz level (usually 2)
  rzl=2
# Vspares - if youre using DRAID then you want at least 1!
  spr=2
# b c d e f g h i j  k  l m n o p q r s t u v w x y  z=spare
# a b c d e f g h i j  k  l m n o p q r s t u v w x  y  z=spare (sdaa..ax)
# 1 2 3 4 5 6 7 8 9 10 1112131415161718192021222324  25 26
( set -x
time zpool create -o autoreplace=on -o autoexpand=on -O atime=off -O compression=lz4 \
  $zp \
   draid$rzl:12d:16'c':$spr's' sd{b..q} \
   draid$rzl:12d:16'c':$spr's' sd{r..y} sda{a..h} \
|| failexit 101 "Failed to create DRAID"
)
elif [ "$iteration" = "z24" ]; then 
  td=32
# raidz level (usually 2)
  rzl=2
# Vspares - if youre using DRAID then you want at least 1!
  spr=2
# b c d e f g h i j  k  l m n o p q r s t u v w x y  z=spare
# a b c d e f g h i j  k  l m n o p q r s t u v w x  y  z=spare (sdaa..ax)
# 1 2 3 4 5 6 7 8 9 10 1112131415161718192021222324  25 26
( set -x
time zpool create -o autoreplace=on -o autoexpand=on -O atime=off -O compression=lz4 \
  $zp \
   draid$rzl:4d:8'c':$spr's' sd{b..i} \
   draid$rzl:4d:8'c':$spr's' sd{j..q} \
   draid$rzl:4d:8'c':$spr's' sd{r..y} \
   draid$rzl:4d:8'c':$spr's' sda{a..h} \
|| failexit 101 "Failed to create DRAID"
)
elif [ "$iteration" = "z24a" ]; then 
  td=32
# raidz level (usually 2)
  rzl=2
# Vspares - if youre using DRAID then you want at least 1!
  spr=1
# b c d e f g h i j  k  l m n o p q r s t u v w x y  z=spare
# a b c d e f g h i j  k  l m n o p q r s t u v w x  y  z=spare (sdaa..ax)
# 1 2 3 4 5 6 7 8 9 10 1112131415161718192021222324  25 26
( set -x
time zpool create -o autoreplace=on -o autoexpand=on -O atime=off -O compression=lz4 \
  $zp \
   draid$rzl:5d:8'c':$spr's' sd{b..i} \
   draid$rzl:5d:8'c':$spr's' sd{j..q} \
   draid$rzl:5d:8'c':$spr's' sd{r..y} \
   draid$rzl:5d:8'c':$spr's' sda{a..h} \
|| failexit 101 "Failed to create DRAID"
)
else
# One Big Mother
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
#   zpool add $zp spare sdz sday sdaz

# cre8 datasets
# requires external script in the same PATH
# going with lz4 so not limited by CPU for compression
zfs-newds.sh 11 $zp shrcompr
zfs-newds.sh 10 $zp notshrcompr
zfs-newds-zstd.sh 10 $zp notshrcompr-zstd
zfs-newds.sh 00 $zp notshrnotcompr

$zps # zpool status -v |awk 'NF>0'
zpool list
zfs list

df -hT |egrep 'ilesystem|zfs'
zpool status -v|grep draid

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
