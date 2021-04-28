#!/bin/bash

# Burn-in test spinning disk before putting it into use
# W,R scan of big HD -- DESTRUCTIVE
# REQUIRES: hdparm, smartmontools, tee

# NOTE pass only sdX as arg, no /dev needed
# Requires key-input / Enter to continue

# Recommended to run this from GNU ' screen ' as root

argg=/dev/$1
logfile=~/scandisk-bigdrive.log

# This is for old IDE drives
hdparm -c1 -d1 -u1 $argg

hdparm -S 120 $argg # fastsleep after test, save power

blockdev --setra 16384 $argg
blockdev --getra $argg

ls -lk /dev/disk/by-id |grep $1
longform=$(ls -lk /dev/disk/by-id |grep $1 |head -n 1 |awk '{print $9}')
fdisk -l /dev/$1

smartctl -a $argg |head -n 15
echo "!! ARE YOU SURE!! PK - THIS WILL OVERWRITE ALL DATA ON $argg"
read

#time badblocks -f -c 20480 -n -s -v $argg
#time badblocks -f -c 16384 -n -s -v $argg
#time badblocks -f -c 10240 -n -s -v $argg

function scanbig () {
  echo "$(date) -> WRITING ZEROS TO $1 $longform" |tee -a $logfile
  time (dd if=/dev/zero of=$argg bs=1M; sync) 2>>$logfile

#  echo `date`'-> READING '$1'! '$argg |tee -a $logfile
#  time dd if=$argg bs=1M of=/dev/null 2>>$logfile

# bash redirect stdout and stderr 2>&1
# NOTE just trying to redirect stderr to tee is ridiculously hard

echo "$(date) - END WRITE ZEROS" |tee -a $logfile
  
}

echo "$(date) - START WRITE ZEROS" |tee -a $logfile
scanbig &

sleep 5
# skip this if we already have a dd running; echoes DD stats to logfile every 30 sec
[ `pidof dd |wc -l` -ge 2 ] || while [ `pidof dd |wc -l` -gt 0 ]; do kill -USR1 `pidof dd`;sleep 60;done;date
wait; # for BG job to finish

sleep 10
echo "$(date) - SMARTCTL TEST BEGIN" |tee -a $logfile
smartctl -t long $argg

echo "o Issue ' smartctl -a $argg |less' after the ETA time above to see test results"
date

exit;

#######################

# 2021 Dave Bechtel

# https://www.youtube.com/watch?v=2zjW-Rut51o
# :B

# $ smartctl -a /dev/sda |grep -A1 'Extended self' |tail -n 1
#recommended polling time:        (  83) minutes.

2017.1022 - removed 'dd READING' step and subst with 'smartctl long' to save time

# NOTE - results of 'kill -usr1 dd' go into the LOGFILE, not stdout!
