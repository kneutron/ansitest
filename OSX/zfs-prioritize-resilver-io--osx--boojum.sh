#!/bin/bash

sysctl -w kstat.zfs.darwin.tunable.zfs_resilver_delay=0
sysctl -w kstat.zfs.darwin.tunable.zfs_top_maxinflight=512

exit;

echo 0 > /sys/module/zfs/parameters/zfs_resilver_delay
echo 512 > /sys/module/zfs/parameters/zfs_top_maxinflight
echo 8000 > /sys/module/zfs/parameters/zfs_resilver_min_time_ms

exit;

# Orig values:

echo 2 > /sys/module/zfs/parameters/zfs_resilver_delay
echo 32 > /sys/module/zfs/parameters/zfs_top_maxinflight
echo 3000 > /sys/module/zfs/parameters/zfs_resilver_min_time_ms

exit;

# REF: https://www.reddit.com/r/zfs/comments/4192js/resilvering_raidz_why_so_incredibly_slow/

# sysctl -a|grep zfs|egrep 'resilver_delay|top_maxinflight|resilver'
kstat.zfs.darwin.tunable.zfs_top_maxinflight: 32
kstat.zfs.darwin.tunable.zfs_resilver_delay: 2

REF: https://openzfsonosx.org/wiki/Performance

sysctl -w kstat.zfs.darwin.tunable.zfs_arc_max=<size of arc in bytes> 
