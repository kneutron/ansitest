#!/bin/bash

# Get me a set of disks for DRAID 
# DONE [b..y] a[a..x] get slices of X disks and be able to verify with wc -w

echo "$0 - 2021 Dave Bechtel"
echo "Pass arg1=total disks in pool -- arg2=how many per vdev"

# REF: https://tldp.org/LDP/abs/html/arrays.html
# regular array - STARTS AT 0
declare -a fullset=(sd{b..y} sda{a..x} sdb{a..x} sdc{a..x}) # Total 96, excluding spares
# sdz, sday sdaz, sdby sdbz, sdcy sdcz == Reserved for spares (7)

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
# copypasta not-including the '\' and verify with:  echo '[paste]' |wc -w
  slice 72 72
  echo '===== ^^ 72 / 72'

  slice 72 36
  echo '===== ^^ 72 / 36'

  slice 72 24
  echo '===== ^^ 72 / 24'
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
# e.g. 32 6 = invalid config (32 4 = valid) but we just give you output - sanity checks are up 2U
