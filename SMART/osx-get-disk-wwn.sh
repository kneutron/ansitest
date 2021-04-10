#!/bin/bash

# OSX /dev and /var/run/disk/by-* does not have a concept of WWN IDs so we get it from SMART
#egrep ' /dev|WWN' ~/smartlog-boojum.log
# ^ is a cheat and we can't depend on it existing or being up to date

# DEPENDS: smartctl being installed from brew or macports

# NOTE: Pass "1" as arg to print extended disk translation table

# we want physical disks only or Weird S--t Happens
for d in $(diskutil list |grep phys |awk '{print $1}'); do
  wwnid=$(smartctl -i $d |grep WWN |awk '{print "wwn-0x"$5$6$7}')

  [ "$1" = "1" ] && xtd=$(ls -l /var/run/disk/by-serial |grep -w $d |awk '{print $9}') # print extended trans tbl

  if [ "$1" = "1" ]; then
   tmp1=$(smartctl -i $d |egrep 'Device Model|Serial Number' |paste - -)
#Device Model:     ST4000VN000-2AH166
#Serial Number:    WDH0SB
# paste = combine lines
#Device Model:     ST4000VN000-2AH166 Serial Number:    WDH0SB
# 1     2          3                  4      5          6               

#  xstd2=${xstd2/Device Model:/} # bash inline sed, replace string with blank
#  xstd2=${xstd2/Serial Number:/} # bash inline sed, replace string with blank
   xstd2=$(echo "$tmp1" |awk '{print $3"-"$6}') # strip out devmod/ser # dont need replace, just fields + dash
  fi

  echo "$d = $wwnid $xtd $xstd2"
done

exit;


linux format /dev/disk/by-id:
wwn-0x50004cf2084c33d0 -> ../../sdi

osx:
NewerTch__Voyage-WDH0SB = /dev/disk3
LU WWN Device Id: 5 000c50 09d1a789b
^ raw from SMART

result of this script:
/dev/disk0 = wwn-0x5000c500380c8768
/dev/disk1 = wwn-0x5002538e00000000
/dev/disk2 = wwn-0x5000c5009d1a789b

extended table (pass 1 as arg)
/dev/disk0 = wwn-0x5000c500380c8768 ST3500418AS-5VMSTS ST3500418AS-5VMSTS
/dev/disk1 = wwn-0x5002538e00000000 Portable_SSD_T5-S49WNP0N12051 Samsung-T5
/dev/disk2 = wwn-0x5000c5009d1a789b  ST4000VN000-2AH166-WDH0SB

# BUG in high sierra 10.13, disk2 physical only has partitions in DBS and will not -w word match, 
#   disk3 does match but does not line up with ' diskutil list '
