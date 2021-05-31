#!/bin/bash

# 2014-2021 Dave Bechtel
# this runs in cron.daily
# and keeps 7 days of rotating snapshots
# example cron:
# run zfs snapshot @ 11:45pm mon,wed,fri
#45      23      *       *       1,3,5   /root/bin/boojum/zfs-1week-snapshot.sh

# + plus optional 28-31 days of rotating snapshots, depending on days in month (will need to be uncommented)

logfile=/root/zfs-1week-snapshot.log
snaplog=/root/zfs-snaplist-all.log

/bin/mv -vf $snaplog $snaplog-old

PATH=/sbin:/root/bin:/root/bin/boojum:/usr/local/bin:/usr/local/sbin:/usr/sbin:/bin:/usr/bin:/usr/X11R6/bin: #/usr/NX/bin:/usr/games:
echo "=== START RUN $(date) - zfs 1-week +28-31 day snapshot" >> $logfile

myday=$(date +%a) # ex. Sun  
mydnum=$(date +%d) # ex. 04  

echo "= BEGIN Stage 1: DF before" >> $logfile
df -h -T |grep zfs >> $logfile
#zfs list -H -t snapshot |column -t >> $logfile

  
for i in $(zpool list |grep -v ALLOC |awk '{ print $1 }');do
  echo "= INFO $i:$myday:$mydnum" >> $logfile

# kill ANY preexisting snapshot with this daylabel
  echo "= BEGIN Stage 2: Destroy existing snaps for pool $i" >> $logfile

  zfs destroy -R -v $i@$myday 2>&1 >>$logfile;rc=$?
  echo "= DESTROY $i@$myday RTN CODE:$rc" >> $logfile

# 28-31 days
  zfs destroy -R -v $i@zfsDOM$mydnum 2>&1 >>$logfile;rc=$?
  echo "= DESTROY $i@zfsDOM$mydnum RTN CODE:$rc" >> $logfile

# this is for 28-31 days, uncomment if needed beyond 1 week
#  zfs snapshot -r $i@zfsDOM$mydnum

  zfs snapshot -r $i@$myday
done

echo "= BEGIN Stage 3: Today Snaps after, DF after" >> $logfile        

#zfs list -H -t snapshot |grep $myday >> $logfile
#zfs list -H -t snapshot |grep $mydnum >> $logfile

# ALL snaps here
#zfs list -H -t snapshot |column -t > $snaplog
# Requires another script in the same PATH
zfs-list-snaps--boojum.sh |column -t > $snaplog

# Only today+wkly here
#zfs-list-snaps--boojum.sh |egrep "@$myday|DOM$mydnum|weekly" |column -t >> $logfile

df -h -T |grep zfs >> $logfile
echo "=== END RUN zfs 1wk/28-31 day snapshot: $(date)" >> $logfile 
  
# DONE while we're here, keep 28-31 day number backups too

exit 0;


2017.1228 switched make-snapshot order to have ex. "Wed" after DOM to avoid snapshot rollback "newer exists"
+ fixed df -h -T |grep zfs since others may not have zfs filesystems starting w/Z

TODO log rotation 1/mo

2017.1229 DONE zfs-list-snaps instead (shows creation date
DONE save space in log - when listing snapshots, only list relevent-day
DONE enumerated stages better (for searching
