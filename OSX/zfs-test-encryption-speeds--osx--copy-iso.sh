#!/bin/bash5

# osx
# basic copy test after running zfs-test-encryption-speeds--osx

stime=$(date)

# TODO editme
zp=zint500 # This is where the Test-aes* datasets live

tmpfile=$HOME/zfstestencrspeeds.txt
outfile=$HOME/zfs-test-encryption-speeds-results.log

source ~/bin/failexit.mrg

useramdisk=1
[ $useramdisk -eq 0 ] && isopath=/Volumes/zsgtera4/shrcompr-zsgt2B/ISO # use if < 6GB RAM installed
# TODO EDITME ^^
[ "$isopath" = "" ] && isopath=/Volumes/ramdisk

[ -e "$isopath" ] || failexit 101 "! Ramdisk or ISO source not detected - run zfs-test-encryption-speeds--osx to create it"

cd "$isopath" && pwd

function ttime () {
  result=$(date -j -f "%a %b %d %T %Z %Y" "`date`" "+%s") 
  # see ' man date ' -- seconds
}

> $tmpfile
echo "Copying ISO file to each encrypted dataset"
for d in /Volumes/$zp/Test-aes*; do
  date; ttime; tstart=$result
  time cp -vf *.iso $d
  date; ttime; tend=$result
  ntime=$(date)
  
  let csecs=$tend-$tstart
  echo "$csecs Seconds to Copy ISO to $d" |tee -a $tmpfile
  countdown 10 # sleep 10
  purge
done

echo "o Start time: $stime -- End time: $ntime"
sort -n $tmpfile > $outfile && rm -f $tmpfile
ls -al $outfile

exit;
