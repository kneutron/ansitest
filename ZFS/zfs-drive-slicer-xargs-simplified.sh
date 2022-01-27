#!/bin/bash

#set -x
# PROTIP use bash5 from macports/brew on osx, much faster
# Get me a set of shortname disks for DRAID 
# DONE [b..y] a[a..x] get slices of X disks and be able to verify with wc -w
# REQUIRES: xargs, cut

# Trick to put header outside of col -t
>&2 echo "$0 - 2022 Dave Bechtel" 
>&2 echo "Pass arg1=total disks in pool -- arg2=how many disks per vdev" 
>&2 echo "+ NOTE arg2 ^^ should factor in the RAIDz level 1/2/3 desired to sustain X number" 
>&2 echo "+ of failed disks per vdev + vspares, dont go too narrow or will lose capacity" 
>&2 echo "NOTE output lines NEED to be the same number of devices to balance"
>&2 echo "DO NOT FORGET to prefix these lines with raidz2, mirror or whatever is applicable!"
>&2 echo "PROTIP: Pipe output to  column -t  to make it look nice" 
>&2 echo "=================================================================================="

# REF: https://tldp.org/LDP/abs/html/arrays.html
# regular array - STARTS AT 0
# NOTE vv keep this commented, slows waaay down on bash 3.x osx
#declare -a fullset=(sd{b..y} sda{a..x} sdb{a..x} sdc{a..x}) sdd{a..x}  # Total 120, sets of 24 
# NOTE ^^ intentionally has gaps -- sdz, sday sdaz, sdby sdbz, sdcy sdcz, sddy sddz == Reserved for spares (9)


function slice () {
# (echo sd{b..y} sda{a..x} sdb{a..x} sdc{a..x} sdd{a..x}) |wc -w # to print sum-total number of drives

# cut prints X range of fields (limit number of total drives), xargs breaks them up by 2nd arg
  (echo sd{b..y} sda{a..x} sdb{a..x} sdc{a..x} sdd{a..x}) \
  |cut -d' ' -f1-$1 \
  |xargs -n $2 
}

if [ "$1"  = "" ];  then
# Demo
echo "o Copypasta each line and verify with:  echo '[paste]' |wc -w "
  slice 72 72
  echo '===== ^^ 72 / 72 -- One Big Mother vdev'
  echo ''
  slice 72 36
  echo '===== ^^ 72 / 36 -- 2 VDEVs'
  echo ''
  slice 72 24
  echo '===== ^^ 72 / 24 -- 3 VDEVs'
  slice 96 12
  echo '===== ^^ 96 / 12 -- 8 VDEVs'
# = sd{b..y} sda{a..l} \
#sda{m..x} sdb{a..x}

exit; # early
fi

# Basic sanity
if [ "$1" -lt "$2" ]; then
  echo "$0 - Failed sanity check, \$2 must be greater than \$1"
  exit 999; # Somebody call Scotland Yard, we have a violation
fi

arg1=$1
arg2=$2

# REF: https://stackoverflow.com/questions/806906/how-do-i-test-if-a-variable-is-a-number-in-bash/806923
re='^[0-9]+$'
if ! [[ $arg1 =~ $re ]] ; then
   echo "error: arg1 Not a number" >&2; exit 666
fi
if ! [[ $arg2 =~ $re ]] ; then
   echo "error: arg1 Not a number" >&2; exit 666
fi

slice $arg1 $arg2 

# DO NOT put exit in case we get SOURCEd for the function(?)

# This is a decent method because we can give it arbitrary numbers of disks (up to total defined) 
#   and divide as needed; try 26 2, 24 2, 32 4, 32 8
# NOTE all output lines should have the same length - if you dont you wont have a balanced set of disks
# e.g. 32 6 = invalid config (32 4 = valid) but we just give you output -- real sanity checks are up 2U

# HOW THIS WORKS: 
# Imagine a set of disks sdb..sdcx , 96 in total, set along a slide rule
# "xargs" is our slider/window
# "cut" only prints up to the total number of drives we limit it to
# If $2 >= however many drives we need per vdev, it drops down a line - 
#   giving us the exact short drive names needed to create a zfs pool per-vdev


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

# (echo sd{b..y} sda{a..x} sdb{a..x} sdc{a..x} sdd{a..x}) |cut -d' ' -f1-15 |xargs -n 5
#sdb sdc sdd sde sdf
#sdg sdh sdi sdj sdk
#sdl sdm sdn sdo sdp


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

#===========================
# HOWTO get long-form disks:
# $0  arg1 arg2  >/tmp/zfsds.txt
# Then use  drive-slicer-get-longform.sh
# ^ Requires output from this script

# PROTIP to add in raidz2 prefix and trailing '\':
# ./zfs-drive-slicer-xargs-simplified.sh 80 8 |while read line; do printf "%s" "raidz2 $line \\";echo ''; done

# ./zfs-drive-slicer-xargs-simplified.sh 20 2 |while read line; do printf "%s" "mirror $line \\";echo ''; done
#mirror sdb sdc \
#mirror sdd sde \
#...
#mirror sdt sdu \

# Triple mirroring
# $ ./zfs-drive-slicer-xargs-simplified.sh 15 3 |while read line; do printf "%s" "mirror $line \\";echo ''; done
#mirror sdb sdc sdd \
#mirror sde sdf sdg \
#...
#mirror sdn sdo sdp \


# 2022.0127 substantially refactored to use xargs and cut for simplicity
# works with bash 3.2.57 osx
