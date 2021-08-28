#!/bin/bash

# might as well do the whole thing, not just watch :)
# NOTE pass arg1="s" to Select pool (will prompt)
sdate=$(date)

# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

if [ "$1" = "s" ] || [ "$1" = "" ]; then
# select ; REF: https://www.baeldung.com/linux/reading-output-into-array
  tmptest=$(zpool list |head -n 1)
  [ $"tmptest" = "no pools available" ] && failexit 404 "No zfs pools"

  OIFS=$IFS
  IFS=$'\n'
  declare -a zplist=( $(zpool list |grep -v ALLOC |awk '{print $1}') )
  IFS=$OIFS
  
  # dump array - REF: https://opensource.com/article/18/5/you-dont-know-bash-intro-bash-arrays
  for i in ${!zplist[@]}; do
     echo "$i ${zplist[$i]}"
  done

  echo -n "Enter number of zpool: "
  read zpn
  zp=${zplist[$zpn]}
else
  zp=$1
fi

[ "$zp" = "" ] && failexit 101 "Invalid zpool"

zpool scrub $zp

mv ~/scrublog.log ~/scrublog-prev.log
> ~/scrublog.log # Clearit

# do forever
while :; do
  clear
  
  echo "Pool: $zp - scrub started: $sdate"
# E WORKY! - note, egrep 4 canceled not breakloop
  zpool status -v $zp |awk 'NF>0' |tee -a ~/scrublog.log |grep -A 2 'scrub in progress' || break 2
#  zpool iostat -y -T d -v $1 2 3 &
  zpool iostat -y -v $zp 2 3 &

  sleep 9
  date |tee -a ~/scrublog.log
  
done

ndate=$(date)

zpool status -v $zp
echo "o Scrub $zp start: $sdate // Completed: $ndate"

hd-power-status

exit;

# zpool status |egrep -B 2 -A 2 "scrub in progress|bigvaiterazfs" # $1

zpool status
  pool: tank0
 state: ONLINE
 scan: none requested
config:
        NAME                                          STATE     READ WRITE CKSUM
        tank0                                         ONLINE       0     0 0
          gptid/8194f816-80cd-11e1-8a71-00221516e8b8  ONLINE       0     0 0
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
