#!/bin/bash

# 4Linux
# HD power status and match long drive ID (drivemap)
# know EXACTLY which drives are powered down

# Requires: hdparm awk paste grep tr

function hdps1 () {
# getdrive-byids |awk 'NF>0'
# /root/bin/hd-power-status |awk 'NF>0'
  hdparm -C /dev/sd? 2>/dev/null |awk 'NF>0' |paste - - 
  hdparm -C /dev/sd{a..z}{a..z} 2>/dev/null |awk 'NF>0' |paste - - 
# If you have a LOT of drives
}

hdps1 >/tmp/hdps1.txt

IFS=$'\n' # newline
for line in $(grep 'drive state' /tmp/hdps1.txt); do 
  drive=$(echo $line |awk -F: '{print $1}') # /dev/sda
  drive=$(echo ${drive#/dev/}) # bash inline sed, delete from begin, get e.g. sda
  mdrive=$(ls -lR /dev/disk/by-id /dev/disk/by-path |grep -v part |grep "$drive" |awk '{print $9}')
  mdrive=$(echo "$mdrive" |tr '\n' ' ') # newlines to spaces
  echo "$line"
  echo "$drive -- $mdrive"
done 


exit;

hdps1
/dev/sda:        drive state is:  active/idle
/dev/sdb:        drive state is:  active/idle
/dev/sdc:        drive state is:  standby
/dev/sdd:        drive state is:  standby
/dev/sde:        drive state is:  active/idle
/dev/sdf:        drive state is:  standby
/dev/sdg:        drive state is:  active/idle

Example output:

/dev/sda:        drive state is:  active/idle
sda -- ata-Samsung_SSD_860_PRO_512GB_S5GBNS0NB0106 wwn-0x5002538e30b04a pci-0000:02:00.0-sas-phy4-lun-0 
/dev/sdb:        drive state is:  active/idle
sdb -- ata-ST4000VN000-1H4168_Z3073Z wwn-0x5000c500917978 pci-0000:02:00.0-sas-phy2-lun-0 
/dev/sdc:        drive state is:  standby
sdc -- ata-HGST_HTS721010A9E630_JR10004M1TJY wwn-0x5000cca8a8d940 pci-0000:02:00.0-sas-phy5-lun-0 
/dev/sdd:        drive state is:  standby
sdd -- ata-HGST_HTS721010A9E630_JR1003D4G2XD wwn-0x5000cca8e8c153 pci-0000:02:00.0-sas-phy6-lun-0 
/dev/sde:        drive state is:  active/idle
sde -- ata-ST4000VN008-2DR166_ZGY005 wwn-0x5000c500a29833 pci-0000:02:00.0-sas-phy3-lun-0 
/dev/sdf:        drive state is:  standby
sdf -- ata-ST1000LM024_HN-M101MBB_S2RQJ9CC9033 wwn-0x50004cf2084c33 pci-0000:02:00.0-sas-phy7-lun-0 
/dev/sdg:        drive state is:  active/idle
sdg -- ata-Samsung_Portable_SSD_T5_S3UJNP0K70201 wwn-0x5002538d000000 pci-0000:03:00.0-usb-0:1:1.0-scsi-0:0:0:0 
