#!/bin/bash
# REF: https://sysadminman.net/blog/2008/remove-all-zfs-snapshots-50

# destroy all snapshots on blue pool (to free space) and track what got killed
#zp=zblue500compr0
#zp=zredtera1
#crit=daily
crit=weekly
#crit=$zp

[ "$1" = "" ] || crit="$1"

logfile=/root/zfs-killsnaps.log

#for snapshot in `zfs list -H -t snapshot |grep hourly | cut -f 1`
#for snapshot in `zfs list -H -t snapshot |grep $zp | cut -f 1`
function dokill () {
  crit=$1
  for snapshot in `zfs list -H -t snapshot |grep $crit | cut -f 1`
  do
    echo "`date` - Killing $snapshot" |tee -a $logfile
    time zfs destroy $snapshot
  done
}

dokill $crit
dokill hourly
#dokill weekly
