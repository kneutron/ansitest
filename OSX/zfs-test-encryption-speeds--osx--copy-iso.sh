#!/bin/bash

# osx
# basic copy ISO to test each ZFS cipher's encryption speed after running zfs-test-encryption-speeds--osx (which creates the datasets)

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
[ "$isopath" = "" ] && isopath=/Volumes/ramdisk

[ -e "$isopath" ] || failexit 101 "! Ramdisk or ISO source not detected - run zfs-test-encryption-speeds--osx to create it"

cd "$isopath" && pwd

function ttime () {
  result=$(date -j -f "%a %b %d %T %Z %Y" "$(date)" "+%s") 
  # see ' man date ' -- seconds
}

# blankit
> $tmpfile
echo "$(date) - Copying ISO file to each encrypted dataset"
for d in /Volumes/$zp/Test-aes*; do
  date; ttime; tstart=$result
  time cp -vf *.iso $d
  date; ttime; tend=$result
  ntime=$(date)
  
  let csecs=$tend-$tstart
  echo "$csecs Seconds to Copy ISO to $d" |tee -a $tmpfile
  sleep 10
  purge # OSX doesnt really have a sync, this is close
done

echo "o Start time: $stime -- End time: $ntime"
sort -n $tmpfile > $outfile && rm -f $tmpfile
ls -al $outfile

exit;
