#!/bin/bash


# =LLC= © (C)opyright 2016 Boojum Consulting LLC / Dave Bechtel, All rights reserved.
## NOTICE: Only Boojum Consulting LLC personnel may use or redistribute this code,
## Unless given explicit permission by the author - see http://www.boojumconsultingsa.com
#
# arg1 is poolname

sdate=`date`

#mv ~/scrublog.log ~/scrublog-prev.log
#> ~/scrublog.log

# do forever
while :; do
  clear
  
  echo "Pool: $1 - NOW: `date` -- Watchresilver started: $sdate"
# E WORKY! - note, egrep 4 canceled not breakloop
#  zpool status $1 |tee -a ~/scrublog.log |grep -A 2 'resilver in progress' || break 2
  zpool status $1 |grep -A 2 'resilver in progress' || break 2
  zpool iostat -v $1 2 3 &
#  zpool iostat -T d -v $1 2 3 & # with timestamp

  sleep 9
  date
  
done

ndate=`date`

zpool status $1
echo "o Resilver watch $1 start: $sdate // Completed: $ndate"

hd-power-status

exit;

# zpool status |egrep -B 2 -A 2 "scrub in progress|bigvaiterazfs" # $1

zpool status
  pool: tank0
 state: ONLINE
 scan: none requested
config:

        NAME                                          STATE     READ WRITE
CKSUM
        tank0                                         ONLINE       0     0
0
          gptid/8194f816-80cd-11e1-8a71-00221516e8b8  ONLINE       0     0
0

errors: No known data errors

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
