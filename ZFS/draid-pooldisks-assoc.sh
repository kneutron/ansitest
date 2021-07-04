#!/bin/bash

# SOURCE me to access array data, otherwise grep the log file
# working with 90 pooldisks, put in associative array
# REMEMBER ARRAYS START AT 0

DRlogfile=/tmp/draid-pooldisks-assoc.log
> $DRlogfile # clearit
#source ~/bin/logecho.mrg

DD=/dev/disk

debugg=0

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


# TEH MAIN THING
declare -a pooldisks # regular indexed array
pooldisks=(sd{b..y} sda{a..x} sdb{a..x} sdc{a..l}) # abcdefghijkl
# 24 in 1st set, skipping sda=root and sdz=hotspare
# 24 in 2nd + 3rd set, 12 in 4th set, (84) total
declare -a hotspares # regular indexed array
hotspares=(sdz sday sdaz sdby sdbz) # 5, will be sitting idle for replaces
# echo ${pd[0]} = sdb; echo ${pd[24]} = sdy

# NOTE CAPITAL A for assoc array!
declare -A ASpooldisks 
declare -A AShotspares 

# populate
idx=0
for disk in ${pooldisks[@]}; do
  key=${pooldisks[$idx]} # sdb
  ASpooldisks[$key]=$(ls -lR $DD |grep -w /$key |head -n 1 |awk '{print $9}')
  let idx=idx+1
done
  # ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J1NL656R -make this whatever this disk is in dev/disk/by-id 
  # for SAS this will be  pci-0000:00:16.0-sas-phy0-lun-0  so we cant limit search to disk/by-id

# ^^ HOW THIS WORKS:
# key=${pooldisks[0]}                      # returns: LET key="sdb"
# ASpooldisks[$key]=ata-VBOX_HARDDISK_blah # ASpooldisks["sdb"]="ata-*"  # LOOKUP and set!
# key=${pooldisks[1]}                      # returns: LET key="sdc" 
# ASpooldisks[$key]=pci-*                  # ASpooldisks["sdc"]="pci-*" or whatever 

#echo "key:$key: ASpooldisks $key == ${ASpooldisks[$key]}"
idx=0
for disk in ${hotspares[@]}; do
  key=${hotspares[$idx]} # sdb
  AShotspares[$key]=$(ls -lR $DD |grep -w /$key |head -n 1 |awk '{print $9}')
  let idx=idx+1
done

echo "Dumping shortdisk == longdisk assoc array to $DRlogfile"
for K in "${!ASpooldisks[@]}"; do 
  echo "$K == ${ASpooldisks[$K]}" >> $DRlogfile
#    echo "INTENT: ZPOOL DISK: $K == ${ASpooldisks[$K]}" >> $DRlogfile
done

for H in ${hotspares[@]}; do
  echo "Hotspare: $H == ${AShotspares[$H]}" >> $DRlogfile
done

# if SOURCEd
function getdrpdshort () {
  key=$1 # short devname
  echo "${ASpooldisks[$key]}"
}
function gethotspareshort () {
  key=$1 # short devname
  echo "${AShotspares[$key]}"
}

# if you need to search the long form and get the short, just grep the logfile and awk $1

#exit;

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


# la $DBI |grep -w /sda |head -n 1
#lrwxrwxrwx 1 root root    9 Jul  3 14:45 ata-VBOX_HARDDISK_VB7d75d4dd-69ea47dd -> ../../sda
#1          2 3    4       5 6    7 8     9                                     10 11 
# la $DBI |grep -w /sda |head -n 1 |awk '{print $9}'
#ata-VBOX_HARDDISK_VB7d75d4dd-69ea47dd
