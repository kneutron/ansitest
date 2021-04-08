#!/bin/bash

# to be run every month 17th and 27th ~9:35pm to not conflict with snapshots

PATH=/sbin:/var/root/bin:/var/root/bin/boojum:/usr/local/bin:/usr/local/sbin:/usr/sbin:/bin:/usr/bin:/usr/X11R6/bin

log=/root/smartlog.log
mv -v -f $log $log--old

if [ "$1" = "stage2" ]; then
  myd=$(date)
  
  echo "=========================================" |tee -a $log
  echo "o BEGIN STAGE2 SMART report: $myd" |tee -a $log
  
  for i in /dev/sd?;do
    drvonly=$(echo $i |awk -F/ '{ print $3 }') # sda
    bid=$(ls -l /dev/disk/by-id |grep $drvonly |grep -v part)

    echo $i |tee -a $log
    echo "$bid" |tee -a $log
    fdisk -l $i |tee -a $log
    smartctl -a $i |tee -a $log
  done

  echo "=========================================" |tee -a $log
  echo "o END STAGE2 SMART report: $myd" |tee -a $log

# run in BG
  smart-shortreport.sh &
    
  exit 0; # skip test
fi

# (to syslog)
logger "FYI -- SMART testing of all drives are in progress - see $log"

echo "=========================================" |tee -a $log  
echo "o BEGIN STAGE1 SMART testing: $myd" |tee -a $log 

# SMART testing
for i in /dev/sd?;do
  drvonly=$(echo $i |awk -F/ '{ print $3 }') # sda
  bid=$(ls -l /dev/disk/by-id |grep $drvonly |grep -v part)

  echo $i |tee -a $log
  echo "$bid" |tee -a $log
  fdisk -l $i |tee -a $log
  smartctl -t long $i |tee -a $log
done

echo "=========================================" |tee -a $log
  