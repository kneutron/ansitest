#!/bin/bash5

# OSX Show more detailed information about internal, external usb/firewire, iSCSI drives
# 2022.May Dave Bechtel
# REQUIRES: smartctl fmt
outf=drivemap.txt

cd /tmp

echo "Building list... Standby"
result=$(diskutil list |egrep 'internal, physical|external, physical|\(external\)' |awk '{print $1}')

# REF: https://www.shellscript.sh/tips/pattern-substitution/
for disk in $result; do 
  devonly=${disk/#dev/} # strip

  variants=$(ls -lR /var/run/disk |grep -w $devonly |awk '{print $9}') # -w = word, leave out subpartitions
  if [ "$variants" = "" ] \
  || [[ "$variants" = *FRWR* ]]; then
# special handling for Firewire drive due to OSX bug
    variants=$variants" "$(smartctl -i $devonly |egrep 'Device Model|Serial Number|WWN' |col 2>/dev/null)
  fi

  variants2=$(diskutil info $devonly |egrep 'Device / Media Name|Protocol')

#  echo -n "$devonly -> $variants $variants2" |sed "s/  / /g; s/$(printf '\t')/ /g"
  echo -n "$devonly -> $variants $variants2" |fmt -s # collapse whitespace
  echo ""
  
done >$outf

less $outf  
cp -v $outf $HOME
ls -alh $PWD/$outf $HOME/$outf

exit;
  
  
echo ${tmp#/dev/}
disk0

/dev/disk0 (internal, physical):
/dev/disk1 (external, physical):
/dev/disk2 (external, physical):
/dev/disk8 (external):
/dev/disk9 (external):
/dev/disk10 (external):
/dev/disk11 (external):
/dev/disk12 (external):
/dev/disk13 (external):
/dev/disk14 (external):
/dev/disk15 (external):
/dev/disk16 (external):
/dev/disk17 (external):
/dev/disk18 (external):
/dev/disk19 (external):
/dev/disk20 (external):
/dev/disk21 (external):
/dev/disk22 (external):
/dev/disk23 (external):
/dev/disk24 (external):
/dev/disk25 (external):
/dev/disk26 (external):
/dev/disk27 (external):
/dev/disk29 (external):
/dev/disk30 (external):
/dev/disk31 (external):
/dev/disk32 (external):
/dev/disk33 (external):
/dev/disk34 (external):


Sample output:

/dev/disk0 -> PCI0@0-SATA@1F,2-PRT0@0-PMP@0-@0:0 ST3500418AS-5VMST
Device / Media Name: ST3500418
   Protocol: SATA

/dev/disk1 -> PCI0@0-EHC1@1D,7-@3:0 Portable_SSD_T5-S49WNP0N1205
Device / Media Name: Samsung Portable SSD T5
   Protocol: USB

/dev/disk2 -> PCI0@0-RP03@1C,2-FRWR@0-node@30e102e00026af-sbp-2@c000-@0:0
Device Model: ST4000VN008-2DR16 Serial Number: ZGY9F4 LU WWN
Device Id: 5 000c50 0dba33a51 Device / Media Name: ST4000VN008-2DR16
   Protocol: FireWire

/dev/disk8 -> Device Model: [No Information Found] Serial Number:
[No Information Found] Device / Media Name:
   Protocol: iSCSI

/dev/disk9 -> VIRTUAL-DISK-0040_ Device / Media Name:
   Protocol: iSCSI

/dev/disk10 -> VIRTUAL-DISK-beaf32 Device / Media Name: VIRTUAL-DISK
   Protocol: iSCSI

/dev/disk11 -> Device Model: [No Information Found] Serial Number:
[No Information Found] Device / Media Name:
   Protocol: iSCSI
