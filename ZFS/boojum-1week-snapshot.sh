#!/bin/bash

# MODIFIED FOR MAC OSX
# NOTE - THIS *ONLY* KEEPS SNAPSHOTS FOR (7) DAYS!!

# =LLC= © (C)opyright 2016 Boojum Consulting LLC / Dave Bechtel, All rights reserved.
## NOTICE: Only Boojum Consulting LLC personnel may use or redistribute this code,
## Unless given explicit permission by the author - see http://www.boojumconsultingsa.com
#
# this runs from cron root - scheduled mon,wed,fri @ 11:45pm
# and keeps 7 days of rotating snapshots
# DISABLED plus 28-31 days of rotating snapshots, depending on days in month

logfile=/var/root/boojum-1week-snapshot.log
snaplog=/var/root/boojum-snaplist-all.log

/bin/mv -vf $snaplog $snaplog-old

PATH=/sbin:/var/root/bin:/var/root/bin/boojum:/usr/local/bin:/usr/local/sbin:/usr/sbin:/bin:/usr/bin:/usr/X11R6/bin: #/usr/NX/bin:/usr/games:
echo "=== START RUN `date` - boojum 1-week +28-31 day snapshot" >> $logfile

# speed things up a bit
#/root/bin/boojum/spinup 2>&1 >> $logfile

myday=`date +%a` # ex. Sun  
mydnum=`date +%d` # ex. 04  

#echo "= BEGIN Stage DF before, snaps before" >> $logfile
echo "= BEGIN Stage 1: DF before" >> $logfile
gdf -hT |grep /Volumes/z >> $logfile
#zfs list -H -t snapshot |column -t >> $logfile

  
for i in `zpool list |grep -v ALLOC |awk '{ print $1 }'`;do
  echo "= INFO $i:$myday:$mydnum" >> $logfile

# kill ANY preexisting snapshot with this daylabel
  echo "= BEGIN Stage 2: Destroy existing snaps for pool $i" >> $logfile

  zfs destroy -R -v $i@$myday 2>&1 >>$logfile;rc=$?
  echo "= DESTROY $i@$myday RTN CODE:$rc" >> $logfile

  zfs destroy -R -v $i@boojumDOM$mydnum 2>&1 >>$logfile;rc=$?
  echo "= DESTROY $i@boojumDOM$mydnum RTN CODE:$rc" >> $logfile

#  zfs snapshot -r $i@boojumDOM$mydnum
  zfs snapshot -r $i@$myday
done

echo "= BEGIN Stage 3: Today Snaps after, DF after" >> $logfile        

#zfs list -H -t snapshot |grep $myday >> $logfile
#zfs list -H -t snapshot |grep $mydnum >> $logfile

# ALL snaps here
#zfs list -H -t snapshot |column -t > $snaplog
zfs-list-snaps--boojum.sh |column -t > $snaplog
# Only today+wkly here
zfs-list-snaps--boojum.sh |egrep "@$myday|DOM$mydnum|weekly" |column -t >> $logfile

#df -h -T |grep zfs >> $logfile
gdf -hT |grep /Volumes/z >> $logfile

echo "=== END RUN boojum 1wk snapshot: `date`" >> $logfile 
  
# DONE while we're here, keep 28-31 day number backups too

exit 0;

2021.0227 osx fixed gdf

2017.1228 switched make-snapshot order to have ex. "Wed" after DOM to avoid snapshot rollback "newer exists"
+ fixed df -h -T |grep zfs since others may not have zfs filesystems starting w/Z

TODO log rotation 1/mo

2017.1229 DONE zfs-list-snaps instead (shows creation date
DONE save space in log - when listing snapshots, only list relevent-day
DONE enumerated stages better (for searching
