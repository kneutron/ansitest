#!/bin/bash

# Linux version
# basic copy ISO test timings after running zfs-test-encryption-speeds to create encrypted datasets of each type

stime=$(date)

# TODO editme
zp=zint500 # This is where the Test-aes* datasets live

tmpfile=$HOME/zfstestencrspeeds.txt
outfile=$HOME/zfs-test-encryption-speeds-results.log

#source ~/bin/failexit.mrg
# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

useramdisk=1
[ $useramdisk -eq 0 ] && isopath=/Volumes/zsgtera4/shrcompr-zsgt2B/ISO # use if < 6GB RAM installed
# xxx TODO EDITME ^^
[ "$isopath" = "" ] && isopath=/dev/shm

[ -e "$isopath" ] || failexit 101 "! Ramdisk or ISO source not detected - run zfs-test-encryption-speeds to create it"

cd "$isopath" && pwd

function ttime () {
  result=$(date +%s) 
  # see ' man date ' -- seconds
}

# clearit
> $tmpfile

# supported encryption at time of writing:
# encryption=aes-128-ccm,aes-192-ccm,aes-256-ccm,aes-128-gcm,aes-192-gcm,aes-256-gcm

echo "o $(date) + Copying ISO file(s) to each encrypted dataset"
for d in /$zp/Test-aes*; do
  date; ttime; tstart=$result
  time cp -vf *.iso $d
  time sync
  date; ttime; tend=$result
  
  let csecs=$tend-$tstart
  echo "$csecs Seconds to Copy ISO to $d" |tee -a $tmpfile
#  countdown 10 
  echo "Pausing 5 seconds"
  sleep 5
done

ntime=$(date)

echo "o Start time: $stime -- End time: $ntime"
sort -n $tmpfile > $outfile && rm -f $tmpfile
ls -al $outfile

exit;

# 2021.april mod osx version to linux
