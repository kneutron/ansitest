#!/bin/bash

# Get me a set of disks for DRAID 
# DONE [b..y] a[a..x] get slices of X disks and be able to verify with wc -w
# REQUIRES: seq

# Trick to put header outside of col -t
>&2 echo "$0 - 2021 Dave Bechtel" 
>&2 echo "Pass arg1=total disks in pool -- arg2=how many disks per vdev" 
>&2 echo "+ NOTE arg2 ^^ should factor in the RAIDz level 1/2/3 desired to sustain X number" 
>&2 echo "+ of failed disks per vdev + vspares, dont go too narrow or will lose capacity" 
>&2 echo "NOTE it is Highly Recommended to export the pool after creation with shortnames"
>&2 echo "+ and re-import with -d /dev/disk/by-id or other long form names" 
>&2 echo "NOTE output lines should be the same number of devices to balance"
>&2 echo "PROTIP: Pipe output to  column -t  to make it look nice" 
>&2 echo "================================================================================="

# REF: https://tldp.org/LDP/abs/html/arrays.html
# regular array - STARTS AT 0
declare -a fullset=(sd{b..y} sda{a..x} sdb{a..x} sdc{a..x}) # Total 96, sets of 24 
# NOTE ^^ intentionally has gaps -- sdz, sday sdaz, sdby sdbz, sdcy sdcz == Reserved for spares (7)

# integer
declare -i howmany sliceby idx x

function slice () {
 howmany=$1
 sliceby=$2
 idx=0
 for x in $(seq 0 1 $howmany); do
   [ $x -ge $howmany ] && break

   let idx=$idx+1

#   echo -n "${fullset[$idx]} "
   printf "${fullset[$x]} " # no newline

   if [ $idx -ge $sliceby ]; then
     echo ' \'
     idx=0
   fi
 done
echo ''
}

if [ "$1"  = "" ];  then
# Demo
echo "o Copypasta each line not-including the '\' and verify with:  echo '[paste]' |wc -w "
  slice 72 72
  echo '===== ^^ 72 / 72 -- One Big Mother vdev'

  slice 72 36
  echo '===== ^^ 72 / 36 -- 2 VDEVs'

  slice 72 24
  echo '===== ^^ 72 / 24 -- 3 VDEVs'
# = sd{b..y} sda{a..l} \
#sda{m..x} sdb{a..x}

exit; # early
fi

# Basic sanity
if [ "$1" -lt "$2" ]; then
  echo "$0 - Failed sanity check, \$2 must be greater than \$1"
  exit 999; # Somebody call Scotland Yard, we have a violation
fi

slice $1 $2

# This is a decent method because we can give it arbitrary numbers of disks (up to total defined) 
#   and divide as needed; try 26 2, 24 2, 32 4, 32 8
# NOTE all output lines should have the same length - if you dont you wont have a balanced set of disks
# e.g. 32 6 = invalid config (32 4 = valid) but we just give you output -- real sanity checks are up 2U

# HOW THIS WORKS: 
# Imagine a set of disks sdb..sdcx , 96 in total, set along a slide rule
# "idx" is our slider/window
# If idx >= however many drives we need per vdev, it prints a "line continue" char and drops down a line - 
#   giving us the exact short drive names needed to create per-vdev


# Example for 60-bay Storinator from 45drives - gives us 56 usable disks in pool + 3 spares (sdz sday sdaz), and 4 vdevs
# $0  56 14 |column -t
#sdb   sdc   sdd   sde   sdf   sdg   sdh   sdi   sdj   sdk   sdl   sdm   sdn   sdo   \
#sdp   sdq   sdr   sds   sdt   sdu   sdv   sdw   sdx   sdy   sdaa  sdab  sdac  sdad  \
#sdae  sdaf  sdag  sdah  sdai  sdaj  sdak  sdal  sdam  sdan  sdao  sdap  sdaq  sdar  \
#sdas  sdat  sdau  sdav  sdaw  sdax  sdba  sdbb  sdbc  sdbd  sdbe  sdbf  sdbg  sdbh  \

# Example for 45drives with 1 spare (sdz), 4 vdevs of 11:
# $0  44 11 |column -t
#sdb   sdc   sdd   sde   sdf   sdg   sdh   sdi   sdj   sdk   sdl   \
#sdm   sdn   sdo   sdp   sdq   sdr   sds   sdt   sdu   sdv   sdw   \
#sdx   sdy   sdaa  sdab  sdac  sdad  sdae  sdaf  sdag  sdah  sdai  \
#sdaj  sdak  sdal  sdam  sdan  sdao  sdap  sdaq  sdar  sdas  sdat  \
#
# If you want more spares (5): (reserved sdz sdaq sdar sdas sdat) == 1 spare for every 8 drives
# $0  40 10 |column -t
#sdb   sdc   sdd   sde   sdf   sdg   sdh   sdi   sdj   sdk   \
#sdl   sdm   sdn   sdo   sdp   sdq   sdr   sds   sdt   sdu   \
#sdv   sdw   sdx   sdy   sdaa  sdab  sdac  sdad  sdae  sdaf  \
#sdag  sdah  sdai  sdaj  sdak  sdal  sdam  sdan  sdao  sdap  \


# HOWTO Verify output from this script
# $0  42 14 |column -t >/tmp/zfsds.txt

# sed -i 's/\\//g' /tmp/zfsds.txt   # remove line-continuation chars

# cat /tmp/zfsds.txt 
#sdb   sdc   sdd   sde   sdf   sdg   sdh   sdi   sdj   sdk   sdl   sdm   sdn   sdo   
#sdp   sdq   sdr   sds   sdt   sdu   sdv   sdw   sdx   sdy   sdaa  sdab  sdac  sdad  
#sdae  sdaf  sdag  sdah  sdai  sdaj  sdak  sdal  sdam  sdan  sdao  sdap  sdaq  sdar  

# while read line; do echo "$line" |wc -w; done < /tmp/zfsds.txt 
#      14
#      14
#      14


# HOWTO get long-form disks:
# $0  arg1 arg2  >/tmp/zfsds.txt
# Then use  drive-slicer-get-longform.sh
# ^ Requires output from this script
