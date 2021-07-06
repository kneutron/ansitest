#!/bin/bash

# 2021 Dave Bechtel
# SOURCE me to access array data, otherwise grep the log file
# working with 96 pooldisks, put in associative array
# REMEMBER ARRAYS START AT 0

DRlogfile=/tmp/draid-pooldisks-assoc.log
> $DRlogfile # clearit
#source ~/bin/logecho.mrg

DD=/dev/disk

debugg=0

# IGNORE ME - the real code is below
if [ $debugg -gt 0 ]; then
declare -a pooldisks # regular indexed array
pooldisks=(sd{b..y}) # 24, skipping sda=root and sdz=hotspare
#pooldisks=(/dev/sd{b..y}) # 24, skipping sda=root and sdz=hotspare
# echo ${pd[0]} = sdb; echo ${pd[24]} = sdy

# associative arrays REF: http://mywiki.wooledge.org/BashGuide/Arrays
# REF: http://www.artificialworlds.net/blog/2012/10/17/bash-associative-array-examples/

# NOTE CAPITAL A for assoc array!
declare -A ASpooldisks 

key=${pooldisks[0]} # sdb
ASpooldisks[$key]=$(ls -lR $DD |grep -w /$key |head -n 1 |awk '{print $9}')
  # ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J1NL656R -make this whatever this disk is in dev/disk/by-id 
  # for SAS this will be  pci-0000:00:16.0-sas-phy0-lun-0  so we cant limit search to disk/by-id

# ^^ HOW THIS WORKS:
# key=${pooldisks[0]}                      # returns: LET key="sdb"
# ASpooldisks[$key]=ata-VBOX_HARDDISK_blah # ASpooldisks["sdb"]="ata-*"  # LOOKUP and set!
# key=${pooldisks[1]}                      # returns: LET key="sdc" 
# ASpooldisks[$key]=pci-*                  # ASpooldisks["sdc"]="pci-*" or whatever 

echo "key:$key: ASpooldisks $key == ${ASpooldisks[$key]}"
# expected:
# key:sdb: ASpooldisks sdb == pci-0000:00:16.0-sas-phy0-lun-0
exit; # early
fi


##################################################################
# TEH MAIN THING
declare -a pooldisks # regular indexed array
inpooldisks=(sd{b..y} sda{a..x} sdb{a..x} sdc{a..x}) # for 96 drives
# 24 in 1st set, skipping sda=root and sdz=hotspare
# 24 in 2nd + 3rd set + 4th set, (96) total
# NOTE changed the name to not conflict since we get SOURCEd in the 96 script

#pooldisks=(sd{b..y} sda{a..x} sdb{a..x} sdc{a..l}) # abcdefghijkl
# 24 in 1st set, skipping sda=root and sdz=hotspare
# 24 in 2nd + 3rd set, 12 in 4th set, (84) total

declare -a hotspares # regular indexed array
hotspares=(sdz sday sdaz sdby sdbz sdcy sdcz) # 7, will be sitting idle for replaces
# NOTE Technically we also have sdda genned, but leaving it out for subtle emergency-use ZOMGWTF reasons

# echo ${pd[0]} = sdb; echo ${pd[24]} = sdy

# NOTE CAPITAL A for assoc array!
declare -A ASinpooldisks 
declare -A AShotspares 

# populate
idx=0
for disk in ${inpooldisks[@]}; do
  key=${inpooldisks[$idx]} # sdb
  ASinpooldisks[$key]=$(ls -lR $DD |grep -w /$key |head -n 1 |awk '{print $9}')
  let idx=idx+1
done
  # ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J1NL656R -make this whatever this disk is in dev/disk/by-id 
  # for SAS this will be  pci-0000:00:16.0-sas-phy0-lun-0  so we cant limit search to disk/by-id

# ^^ HOW THIS WORKS:
# key=${pooldisks[0]}                      # returns: LET key="sdb"
# ASinpooldisks[$key]=ata-VBOX_HARDDISK_blah # ASinpooldisks["sdb"]="ata-*"  # LOOKUP and set!
# key=${pooldisks[1]}                      # returns: LET key="sdc" 
# ASinpooldisks[$key]=pci-*                  # ASinpooldisks["sdc"]="pci-*" or whatever 

#echo "key:$key: ASinpooldisks $key == ${ASinpooldisks[$key]}"
idx=0
for disk in ${hotspares[@]}; do
  key=${hotspares[$idx]} # sdb
  AShotspares[$key]=$(ls -lR $DD |grep -w /$key |head -n 1 |awk '{print $9}')
  let idx=idx+1
done

echo "Dumping shortdisk == longdisk assoc array to $DRlogfile"
for K in "${!ASinpooldisks[@]}"; do 
  echo "$K == ${ASinpooldisks[$K]}" >> $DRlogfile
#    echo "INTENT: ZPOOL DISK: $K == ${ASinpooldisks[$K]}" >> $DRlogfile
done

for H in ${hotspares[@]}; do
  echo "$H == ${AShotspares[$H]} - Hotspare" >> $DRlogfile
done

# if SOURCEd
# supply shortdisk and return longdisk
function getpdshort () {
  key=$1 # short devname
  echo "${ASinpooldisks[$key]}"
}
function gethotspareshort () {
  key=$1 # short devname
  echo "${AShotspares[$key]}"
}
# ex:
## Given:
#sds == pci-0000:00:16.0-sas-phy17-lun-0
#Hotspare: sdz == pci-0000:00:16.0-sas-phy24-lun-0
#
# source $0
# getdrpdshort sds
#pci-0000:00:16.0-sas-phy17-lun-0
# gethotspareshort sdz
#pci-0000:00:16.0-sas-phy24-lun-0

# if you need to search the long form and get the short, just grep the logfile and awk $1(?)
# the only problem is that 'zpool status' may be displaying a different longform:
#/tmp# grep 65509 draid-pooldisks-assoc.log
#sdcd == ata-VBOX_HARDDISK_VB326b74ef-11e65509
# but from zps: scsi-SATA_VBOX_HARDDISK_VB326b74ef-11e65509

# return short diskname from longform
function getshorty () {
  ls -lR /dev/disk |grep $1 |awk -F/ '{print $3}' 
}
# ls -lR /dev/disk |grep scsi-SATA_VBOX_HARDDISK_VB326b74ef-11e65509 
#lrwxrwxrwx 1 root root 10 Jul  5 19:47 scsi-SATA_VBOX_HARDDISK_VB326b74ef-11e65509 -> ../../sdcd
#lrwxrwxrwx 1 root root 11 Jul  5 19:47 scsi-SATA_VBOX_HARDDISK_VB326b74ef-11e65509-part1 -> ../../sdcd1
#lrwxrwxrwx 1 root root 11 Jul  5 19:47 scsi-SATA_VBOX_HARDDISK_VB326b74ef-11e65509-part9 -> ../../sdcd9
# ls -lR /dev/disk |grep scsi-SATA_VBOX_HARDDISK_VB326b74ef-11e65509 |awk -F/ '{print $3}'
#sdcd
#sdcd1
#sdcd9

function unavl () {
  for zp in $(zpool list |grep -v CKPOINT |awk '{print $1}'); do
    echo "$zp $(zpool status -v $zp |grep -c UNAVAIL)"
  done
}

#exit;
# TODO can we swapout a spare
# this may not be useful, if rebooted all the UNAVAILs went awai!
function swapspareback () {
#echo ${hotspares[@]} # dump the whole thing
#sdz sday sdaz sdby sdbz

# NOTE /var/log/syslog - zed is not particularly helpful with replace events info, also not in ZP history
# zpool status -v |grep -B2 sdz
#spare-2           DEGRADED     0     0     0
#sdd             UNAVAIL      0     0     0
#sdz             ONLINE       0     0     0

# zpool status -v |grep -A 1 UNAVAIL
#sdb             UNAVAIL      0     0     0
#draid2-0-0      ONLINE       0     0     0
#sdd             UNAVAIL      0     0     0
#sdz             ONLINE       0     0     0

# zpool status -v |grep -A 1 UNAVAIL |grep -v -- -- |paste - - |column -t
#sdb   UNAVAIL  0  0  0  draid2-0-0  ONLINE  0  0  0
#sdd   UNAVAIL  0  0  0  sdz         ONLINE  0  0  0
#sdaa  UNAVAIL  0  0  0  draid2-0-1  ONLINE  0  0  0
#sdba  UNAVAIL  0  0  0  draid2-0-2  ONLINE  0  0  0
#sdca  UNAVAIL  0  0  0  draid2-0-3  ONLINE  0  0  0
#1     2        3  4  5  6
  fyl=/tmp/draid-swap-trans.tbl
  zpool status -v |grep -A 1 UNAVAIL |grep -v -- -- |paste - - |column -t >$fyl
  
  for d in ${hotspares[@]}; do
    chkdsk=$(grep -w $d $fyl |awk '{ print $1 }') # $d=sdz = $chkdsk=sdd
    [ "$chkdsk" = "" ] && break;
    fdisk -l $chkdsk || echo "$chkdsk still not responding"; continue # next iteration
    
    echo "# zpool replace $d $chkdsk ## should work now but you may need to labelclear it 1st"
  done
}


# la $DBI |grep -w /sda |head -n 1
#lrwxrwxrwx 1 root root    9 Jul  3 14:45 ata-VBOX_HARDDISK_VB7d75d4dd-69ea47dd -> ../../sda
#1          2 3    4       5 6    7 8     9                                     10 11 
# la $DBI |grep -w /sda |head -n 1 |awk '{print $9}'
#ata-VBOX_HARDDISK_VB7d75d4dd-69ea47dd
