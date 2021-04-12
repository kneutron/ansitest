#!/bin/bash
# REF: https://sysadminman.net/blog/2008/remove-all-zfs-snapshots-50

# destroy arg snapshots on pool (to free space) and track what got killed
# NOTE does NOT do Recursive and can grep on whatever criteria matches!
# NOTE no logfile rotation
# 2014 Dave Bechtel

#crit=daily
crit=weekly
#crit=$zp

[ "$1" = "" ] || crit="$1"

logfile=/root/zfs-killsnaps.log

function dokill () {
  crit=$1
  for snapshot in $(zfs list -H -t snapshot |grep $crit | cut -f 1)
  do
    echo "$(date) - Killing $snapshot" |tee -a $logfile
    time zfs destroy $snapshot
  done
}

dokill $crit
#dokill hourly
#dokill weekly
