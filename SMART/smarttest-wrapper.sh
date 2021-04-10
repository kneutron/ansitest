#!/bin/bash

# grab dates when smart tests will complete, convert to seconds, sort and display latest time

PATH=/sbin:/var/root/bin:/var/root/bin/boojum:/root/bin:/root/bin/boojum:/usr/local/bin:/usr/local/sbin:/usr/sbin:/bin:/usr/bin:/usr/X11R6/bin

# TODO comment if smart already running
monthly-smart.sh
sleep 2

sortf=/tmp/smartdates.txt
tmpf=/tmp/smartdates-tmp.txt
sorted=/tmp/smartdates-seconds.txt
# clearit
> $sortf
> $tmpf
> $sorted

grep 'will complete' ~/smartlog.log > $sortf

# convert dates to seconds and sort

OIFS=$IFS
IFS='
'
# REF: https://stackoverflow.com/questions/1092631/get-current-time-in-seconds-since-the-epoch-on-linux-bash
for dt in $(awk '{print $6" "$7" "$8" "$9}' $sortf); do
  dtos=$(date -d "$dt" +%s)
#  echo "$dtos,$dt" |tee -a $tmpf
  echo "$dtos,$dt" >> $tmpf
done

sort -n $tmpf -o $sorted
tail -n 1 $sorted |awk -F',' '{print "Check SMART logs after: "$2}' |tee -a ~/smartlog.log

# TODO schedule stage2 ~15 minutes after latest (convert to seconds)
nrsecs=$(tail -n 1 $sorted |awk -F',' '{print $1}')
let nrsecs=$nrsecs+900 # add 15 min (15*60)

ftrdt=$(date --date @"$nrsecs")
# Sun Jan 14 01:34:06 CST 2018
#at -M 

# cleanup
/bin/rm -f $tmpf

IFS=$OIFS

exit;

1    2    3        4     5   6   7  8        9 
Test will complete after Sun Jan 14 01:17:06 2018
Test will complete after Sat Jan 13 22:59:06 2018
Test will complete after Sat Jan 13 22:55:06 2018
Test will complete after Sat Jan 13 21:33:06 2018
Test will complete after Sun Jan 14 01:19:06 2018
Test will complete after Sat Jan 13 22:11:06 2018

Check SMART logs after: 01:19:06 

TODO @ xx:xx # monthly-smart.sh stage2; less ~/smartlog-attrib-shortreport.log
