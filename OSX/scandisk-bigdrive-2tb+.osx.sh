#!/bin/bash

# Mod for osx 2019.0424

# W,R scan of big HD -- DESTRUCTIVE
# REQUIRES: gdd, smartmontools (brew
# NOTE - results of 'kill -usr1 dd' go into the LOGFILE, not stdout!

# Use raw disk
argg=/dev/r$1
#argg=/dev/$1
logfile=~/scandisk-bigdrive-$(date +%Y%m%d)-$1.log

#hdparm -c1 -d1 -u1 $argg
#hdparm -S 120 $argg # fastsleep after test
#blockdev --setra 16384 $argg
#blockdev --getra $argg

DBI=/var/run/disk/by-id
DBP=/var/run/disk/by-path
DBS=/var/run/disk/by-serial

ls -lk $DBI $DBP $DBS |grep $1
#fdisk -l /dev/$1
diskutil list $1
diskutil info $1 |awk 'NF>0'

#smartctl -a $argg |head -n 15
# FIX - need to do this in BG cuz of smartctl output hang/delay for external drives
# skip smartctl hdrs (start at 3rd line, which is blank
smartctl -i $1 |gtail -n +3
smartctl -A $1 |gtail -n +3


echo "!! ARE YOU SURE!! PK - THIS WILL OVERWRITE ALL DATA ON $argg"
read

#time badblocks -f -c 20480 -n -s -v $argg
#time badblocks -f -c 16384 -n -s -v $argg
#time badblocks -f -c 10240 -n -s -v $argg

function scanbig () {
  echo `date`'-> WRITING '$1'! '$argg |tee -a $logfile
  time (gdd if=/dev/zero of=$argg bs=1M;sleep 10) 2>>$logfile

#  echo `date`'-> READING '$1'! '$argg |tee -a $logfile
#  time dd if=$argg bs=1M of=/dev/null 2>>$logfile

# bash redirect stdout and stderr 2>&1
# NOTE just trying to redirect stderr to tee is ridiculously hard

echo 'ENDSCAN: '`date` |tee -a $logfile
  
}

echo 'STARTSCAN: '`date` |tee -a $logfile
scanbig &

sleep 5
# skip this if we already have a dd running; echoes DD stats to logfile every 30 sec
# ' gdd --help' Sending a INFO signal to a running 'dd' process makes it
# print I/O statistics to standard error and then resume copying.
[ `pidof gdd |wc -l` -ge 2 ] || while [ `pidof gdd |wc -l` -gt 0 ]; do kill -SIGINFO `pidof gdd`;sleep 60;done;date
wait;

# omitted smart test for external drives 2019.0425 - may hang system

sleep 10
echo 'SMARTCTL TEST BEGIN: '`date` |tee -a $logfile
smartctl -t long $1
echo "o Issue ' smartctl -a $1 |less' after the ETA time above to see test results"
date

exit

#######################

2019.0424 mod for osx
2017.1022 - removed 'dd READING' step and subst with 'smartctl long' to save time
