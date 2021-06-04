#!/bin/bash

# 2020.1005 mod for auto-month

# test for interactive shell / OK to ask for input
intera=1
[ `echo $- |grep i |wc -l` -gt 0 ] && intera=0

# TODO comment if you want auto
#mymonth=Mar
outfile=/tmp/zfs-killmonth-tmp.txt

source ~/bin/failexit.mrg

#zfs-list-snaps--boojum.sh |grep virtb |grep Jan |awk '{print $1}' |xargs -n1 -t zfs-killsnaps.sh

# REF: https://stackoverflow.com/questions/13168463/using-date-command-to-get-previous-current-and-next-month

# The fuzz in units can cause problems with relative items. 
# To determine the previous month more reliably, you can ask for the month before the 15th of current month
pmonth=$(date --date="$(date +%Y-%m-15) -2 month" |awk '{print $2}')

# arg NOT blank
[ "$1" = "" ] || mymonth=$1
# arg IS blank
[ "$1" = "" ] && [ "$mymonth" = "" ] && mymonth=$pmonth

# sanity check for valid month
validmo="Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec"
sanity=`echo $validmo |grep -c $mymonth` # will NOT allow "July", only 3-letter

if [ $sanity -eq 0 ]; then
  failexit 12 "! Invalid month specified: $mymonth"
fi

echo "`date` - DF before:" > $outfile
df -h -T |head -n 1 >> $outfile
df -h -T |grep zfs >> $outfile

# could use more error checking if $mymonth = 0 lines...
numlines=`zfs-list-snaps--boojum.sh |grep $mymonth |wc -l`
if [ $numlines -gt 0 ]; then
  echo "o KILLING THESE SNAPSHOTS:" >> $outfile
  zfs-list-snaps--boojum.sh |grep $mymonth >> $outfile # full dump of snapshots to delete

  echo "Killing $numlines snapshots for $mymonth ... PK to proceed!"
[ $intera -gt 0 ] && read
else
  failexit 101 "No $mymonth snapshots found to kill!"
fi

# killzem
zfs-list-snaps--boojum.sh |grep $mymonth |awk '{print $1}' |xargs -n1 -t zfs-killsnaps.sh

# review
[ $intera -gt 0 ] && zfs-list-snaps--boojum.sh |less

echo "`date` - DF after:" >> $outfile
#df -h >> $outfile
df -h -T |head -n 1 >> $outfile
df -h -T |grep zfs >> $outfile

[ $intera -gt 0 ] && less $outfile
