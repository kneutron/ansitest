#!/bin/bash


# 2014 Dave Bechtel
# arg1 is poolname

sdate=$(date)

#mv ~/scrublog.log ~/scrublog-prev.log
#> ~/scrublog.log

# do forever
while :; do
  clear
  
  echo "Pool: $1 - NOW: $(date) -- Watchresilver started: $sdate"

  zpool status $1 |grep -A 2 'resilver in progress' || break 2
  zpool iostat -v $1 2 3 &
#  zpool iostat -T d -v $1 2 3 & # with timestamp

  sleep 9
  date
  
done

ndate=$(date)

zpool status -v $1 |awk 'NF>0' # skip blank lines
echo "o Resilver watch $1 start: $sdate // Completed: $ndate"

#hd-power-status

exit;

pool: tank1
 state: ONLINE
 scan: scrub in progress since Tue May  1 23:28:07 2012
    146G scanned out of 1.24T at 177M/s, 1h47m to go
    0 repaired, 11.56% done
config:
        NAME              STATE     READ WRITE CKSUM
        tank1             ONLINE       0     0     0
          raidz1-0        ONLINE       0     0     0
            label/zdisk1  ONLINE       0     0     0
            label/zdisk2  ONLINE       0     0     0
            label/zdisk3  ONLINE       0     0     0
            label/zdisk4  ONLINE       0     0     0
errors: No known data errors
