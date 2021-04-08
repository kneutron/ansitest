#!/bin/bash

# Mod for OSX 2019.0317
# runs monthly from crontab

PATH=/sbin:/var/root/bin:/var/root/bin/boojum:/usr/local/bin:/usr/local/sbin:/usr/sbin:/bin:/usr/bin:/usr/X11R6/bin

debugg=0

log=$HOME/smartlog-boojum.log
mv -v -f $log $log--old

DBS=/var/run/disk/by-serial

#source ~/bin/failexit.mrg
# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}


if [ "$1" = "stage2" ]; then
  myd=$(date)
  echo "=========================================" |tee -a $log
  echo "o BEGIN STAGE2 SMART OSX report: $myd" |tee -a $log
  

# only lv out total if @begin
# i = longform NewerTch__Voyage-WDH0SB5N

  for i in $(ls $DBS |egrep -v 'disk.s.|^total|:'); do
#    drvonly=`echo $i |awk -F/ '{ print $3 }'` # disk0
    devdisk=$(ls -l $DBS/$i |awk '{print $(NF)}') # /dev/disk9s9
#    bid=`ls -l /dev/disk/by-id |grep $drvonly |grep -v part`

    echo "$i = $devdisk" |tee -a $log
#    echo "$bid" |tee -a $log
#    fdisk -l $i |tee -a $log

    diskutil list $devdisk |tee -a $log
    smartctl -a $devdisk |tee -a $log
  done
  echo "=========================================" |tee -a $log
  echo "o END STAGE2 SMART OSX report: $myd" |tee -a $log

# run in BG
  smart-osx-shortreport.sh &
    
  exit 0; # skip test
fi

# (to syslog)
logger "FYI -- SMARTCTL testing of all drives are in progress - see $log"

echo "=========================================" |tee -a $log  
echo "o BEGIN STAGE1 SMART OSX testing: $myd" |tee -a $log 


# SMART testing

ls -l $DBS |egrep -v 'disk.s.|^total' > /tmp/boojum-smart-in.txt
awk '{ print $9" "$11 }' /tmp/boojum-smart-in.txt  > /tmp/boojum-smart-in-edit.txt

while read -r inline; do 
[ $debugg -gt 0 ] && set -x
#OIFS=$IFS
#IFS=
#`echo -e \n`

  drvonly=$(echo "$inline" |awk -F\/ '{ print $3 }') # disk0
  bid=$(echo "$inline" |awk '{ print $(NF-2) }') || failexit 101 "Invalid bid"
   # Numfields -2 = Portable...

  echo "$inline = $bid" |tee -a $log
#  /sbin/fdisk -l $i |tee -a $log
  diskutil list $drvonly |tee -a $log

#read -n 1
  smartctl -t long $drvonly |tee -a $log

#IFS=$OIFS
done < /tmp/boojum-smart-in-edit.txt

echo "=========================================" |tee -a $log
  
