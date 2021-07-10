#!/bin/bash

# 2021 Dave Bechtel
# SOURCE me to access array data and access several helper functions
# working with 96 pooldisks, put in associative array
# REMEMBER ARRAYS START AT 0

DRlogfile=/tmp/draid-pooldisks-assoc.log
> $DRlogfile # clearit
#source ~/bin/logecho.mrg

DD=/dev/disk

debugg=0


##################################################################
# TEH MAIN THING
declare -a pooldisks # regular indexed array
declare -a hotspares # regular indexed array

# We actually have 103 drives total with hotspares
# NOTE Technically we also have sdda (104) genned, but leaving it out for subtle emergency-use ZOMGWTF reasons

# b c d e f g h i j  k  l m n o p q r s t u v w x y  z=spare, a=root
# a b c d e f g h i j  k  l m n o p q r s t u v w x   y z=spare (sdaX sdbX sdcX)
# 1 2 3 4 5 6 7 8 9 10 1112131415161718192021222324  25 26

if [ "$1" = "96" ] || [ "$1" = "" ]; then # assume 96
  echo "Defining for 96 disks in pool b4 hotspares (7)"
  inpooldisks=(sd{b..y} sda{a..x} sdb{a..x} sdc{a..x}) # for 96 drives
# 24 in 1st set, skipping sda=root and sdz=hotspare
# 24 in 2nd + 3rd set + 4th set, (96) total
# NOTE changed the name to not conflict since we get SOURCEd in the 96 script
  hotspares=(sdz sday sdaz sdby sdbz sdcy sdcz) # 7, will be sitting idle for replaces

# IRL with 2x5 HDDRACKs would do 8 disks in pool + 2 pspares
elif [ "$1" = "8p2h" ]; then 
  echo "Defining for 8 disks in pool + hotspares (2)" 
  inpooldisks=(sd{b..i}) 
# 24 in 1st set, skipping sda=root and sdz=hotspare
  hotspares=(sdj sdk) # 1, will be sitting idle for replaces so prolly need 1 vspares

elif [ "$1" = "10" ]; then 
  echo "Defining for $1 disks in pool + hotspares (1)" 
  inpooldisks=(sd{b..k}) 
# 24 in 1st set, skipping sda=root and sdz=hotspare
  hotspares=(sdl) # 1, will be sitting idle for replaces so prolly need 1 vspares

elif [ "$1" = "12" ]; then 
  echo "Defining for $1 disks in pool + hotspares (1)" 
  inpooldisks=(sd{b..m}) 
# 24 in 1st set, skipping sda=root and sdz=hotspare
  hotspares=(sdn) # 1, will be sitting idle for replaces so prolly need 1 vspares

elif [ "$1" = "16" ]; then 
  echo "Defining for $1 disks in pool b4 hotspares (2)" 
  inpooldisks=(sd{b..q}) 
# 24 in 1st set, skipping sda=root and sdz=hotspare
  hotspares=(sdr sds) # 2, will be sitting idle for replaces so prolly need 1-2 vspares

elif [ "$1" = "24" ]; then 
  echo "Defining for $1 disks in pool b4 hotspares (2)" 
  inpooldisks=(sd{b..y}) 
# 24 in 1st set, skipping sda=root and sdz=hotspare
  hotspares=(sdz sdaa) # 2, will be sitting idle for replaces so prolly need 2-4 vspares

elif [ "$1" = "32" ]; then 
  echo "Defining for $1 disks in pool b4 hotspares (4)" 
  inpooldisks=(sd{b..y} sda{a..d}) # 24 + abcd efg
# 24 in 1st set, skipping sda=root and sdz=hotspare
# +4 in 2nd set, can have 1 vdev of 28 or, 2 of 14, or 4 of 7; we dont want to have vdevs of <6 disks
# 4 extra will used for hotspares
  hotspares=(sdz sda{e..g}) # 4, will be sitting idle for replaces

# groups of 7
 pooldisks01=$(echo /dev/sd{b..h}) # a is rootdisk bcdefgh ijklmno pqrstuv wxy 
 pooldisks02=$(echo /dev/sd{i..o})
 pooldisks03=$(echo /dev/sd{p..v})
 pooldisks04=$(echo /dev/sd{w..y}) # z is spare

 pooldisks05=$(echo /dev/sda{a..d}) #abcd # Total 28

 pooldisks=$pooldisks01' '$pooldisks02' '$pooldisks03' '$pooldisks04' '$pooldisks05
# need entire set for reset

elif [ "$1" = "48" ]; then 
  echo "Defining for $1 disks in pool b4 hotspares (3)" 
  inpooldisks=(sd{b..y} sda{a..x}) # abcdefghijklmnopqrstuvwx yz 
# 24 in 1st set, skipping sda=root and sdz=hotspare
# 24 in 2nd set  // 2 vdevs of 24, or 4v of 12d, or 6v of 8d, or possibly 8v of 6d minimum but that might be cutting it a bit fine
  hotspares=(sdz sday sdaz) # 3, will be sitting idle for replaces

# old and weird, if we only actually had to work with 48 total and still alloc HS - train of thought derailed by x32
# ...ok so I'm tired and mai brain is terrible at math
#  inpooldisks=(sd{b..y} sda{a..t}) # abcdefghijklmnopqrst uvw 
# 24 in 1st set, skipping sda=root and sdz=hotspare
# 20 in 2nd set = total of 44 // 2 vdevs of 22, or 4 of 11 # IGNOREME
#  hotspares=(sdz sdau sdav sdaw) # 4, will be sitting idle for replaces

elif [ "$1" = "72" ]; then 
  echo "Defining for $1 disks in pool b4 hotspares (5)" 
  inpooldisks=(sd{b..y} sda{a..x} sdb{a..x}) 
# 24 in 1st set, skipping sda=root and sdz=hotspare
# 24 in 2nd set
# 24 in 3rd set  // 2 vdevs of 36d, or 4v of 18d, or 6v of 12d, or 8v of 9d, or 9v of 8d, or 12v of 6d
  hotspares=(sdz sday sdaz sdby sdbz) # 5, will be sitting idle for replaces

# old and busted
#  inpooldisks=(sd{b..y} sda{a..x} sdb{a..t}) 
# 24 in 1st set, skipping sda=root and sdz=hotspare
# 24 in 2nd set
# 20 in 3rd set = total of 68 // 2 vdevs of 34, or 4 of 17 # IGNOREME
#  hotspares=(sdz sday sdaz sdbu) # 4, will be sitting idle for replaces

else
  echo "$0 - $1 not found in common configurations. Please define in code"
  echo "Please hit ^C"
  read
  #exit 404; # will kill bash if we were sourced from terminal
fi


# echo ${pd[0]} = sdb; echo ${pd[24]} = sdy

# NOTE CAPITAL A for assoc array!
declare -A ASinpooldisks 
declare -A AShotspares 

# populate
idx=0
for disk in ${inpooldisks[@]}; do
  key=${inpooldisks[$idx]} # sdb
#echo "$key" # DEBUG
  ASinpooldisks[$key]=$(ls -lR $DD |grep -w /$key |head -n 1 |awk '{print $9}')
#echo "${ASinpooldisks[$key]}" # DEBUG
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
for hdisk in ${hotspares[@]}; do
  key=${hotspares[$idx]} # sdb
  AShotspares[$key]=$(ls -lR $DD |grep -w /$key |head -n 1 |awk '{print $9}')
  let idx=idx+1
done

echo "Dumping shortdisk == longdisk assoc array to $DRlogfile"
#for K in "${!ASinpooldisks[@]}"; do 
# ^ This was wrong, was getting too many disks instead of just the subset!

for INP in "${inpooldisks[@]}"; do 
#  echo "$INP == ${ASinpooldisks[$K]}" # DEBUG
  echo "$INP == ${ASinpooldisks[$INP]}" >> $DRlogfile
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
function sparesused () {
  for zp in $(zpool list |grep -v CKPOINT |awk '{print $1}'); do
    echo "$zp $(zpool status -v $zp |grep -c spare-)"
  done
}

#exit; # we can't have an early EXIT in a sourced file! (unless err

# DONE can we swapout a spare (after reboot, it came back)
function swapspareback () {
#echo ${hotspares[@]} # dump the whole thing
#sdz sday sdaz sdby sdbz

# NOTE UNAVAIL is only in effect before reboot! after drive comes back all we have is spare-*

# NOTE /var/log/syslog - zed is not particularly helpful with replace events info, also not in ZP history

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
#  zpool status -v |grep -A 1 UNAVAIL |grep -v -- -- |paste - - |column -t >$fyl
  zpool status -v |grep -A2 spare- |egrep -v -- '--|spare-' |paste - - |column -t |tee >$fyl
   
#  for d in ${hotspares[@]}; do
  for d in $(awk '{print $1}' $fyl); do
#    chkdsk=$(grep -w $d $fyl |awk '{ print $1 }') # $d=sdz = $chkdsk=sdd
#    [ "$chkdsk" = "" ] && break;
#    fdisk -l $chkdsk || echo "$chkdsk still not responding"; continue # next iteration

# try the obvious, then try everything else
    fdisk -l /dev/$d |grep /dev || \
    for octry in /dev/disk/*; do
      fdisk -l $octry/$d |grep /dev && break
    done \
    || continue # next iteration
# give it the ol' college try using short and longform and fail out if we get nada    
    
#    echo "# zpool replace \$zp [longnumber] $d - should work now but you should zpool export and labelclear ${d}1 1st"
# ^ not necessary

    # get matching disk
    mdsk=$(grep $d $fyl |awk '{print $6}')
#sdb  ONLINE  0  0  0  draid2-0-0  ONLINE  0  0  0    
#1    2       3  4  5  6

#    zpool detach zdraidtest draid2-0-1
    echo ":) $d is responding - swapping spare $mdsk back"
    zpool detach zdraidtest $mdsk
    zpool status -v |head
  done
}


# la $DBI |grep -w /sda |head -n 1
#lrwxrwxrwx 1 root root    9 Jul  3 14:45 ata-VBOX_HARDDISK_VB7d75d4dd-69ea47dd -> ../../sda
#1          2 3    4       5 6    7 8     9                                     10 11 
# la $DBI |grep -w /sda |head -n 1 |awk '{print $9}'
#ata-VBOX_HARDDISK_VB7d75d4dd-69ea47dd
