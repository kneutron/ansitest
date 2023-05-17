#!/usr/bin/env bash

# 2023 Kingneutron
# Simulate a large zpool in GB vs TB to do free-space-available calc rough approximations

# REQUIRES: seq , truncate , sort , grep , sed , column , xargs

# NOTE cd to where you want the output files to be first BEFORE running this, and 
# NOTE some filesystems like OSX JHFS+ do NOT support sparse files!
# APFS filesystem should be fine

# PROTIP - Quick variable mods between runs - Example:
# cd /Volumes/sgtera2/zfs-tmpdisks && \
#   export numdisks=8 disksize=12 zptype=raidz3 vdevs=1; source zfs-space-calculator-simulator.sh

# zpool destroy zspacecalc   # when done with it

# NOTE subsequent consecutive runs will remove the backing-store files, so dont store anything important
# on the temporary zpool!


# failexit.mrg
# REF: https://sharats.me/posts/shell-script-best-practices/
function failexit () {
  echo '! Something failed! Code: '"$1 $2" >&2 # code (and optional description)
  exit $1
}

# Check for root priviliges
if [ "$(id -u)" -ne 0 ]; then
   echo "Please run $0 as root."
   exit 1
fi

# xxx TODO EDITME
#numdisks=6
#disksize=18 # GB

# Check for override values on commandline, if run with ' source ' the user can provide vars directly w/o editing

# 24-bay disk shelf should be achievable for homelab, even if all slots not used
# https://www.ebay.com/sch/i.html?_from=R40&_trksid=p2380057.m570.l1313&_nkw=24+disk+sas&_sacat=0
[ "$numdisks" = "" ] && numdisks=24
[ "$disksize" = "" ] && disksize=16 # GB, multiply by ~10 for TB

[ "$zptype" = "" ] && zptype=raidz2
#zptype=raidz2 
#zptype=raidz3
#zptype=raidz
#zptype=mirror

[ "$vdevs" = "" ] && vdevs=3

zp=zspacecalc

zpool export -f $zp

[ $(df |grep -c $zp) -gt 0 ] && failexit 101 "$zp still not exported"
[ $(zpool list |grep -c $zp) -gt 0 ] && failexit 101 "$zp still not exported"

# Sparse files
rm -vf zsizetest* 	# had to remove existing backing-store files in case numdisks went down from previous run
echo "Creating $numdisks zpool disks"
# pad nums
for i in $(seq -w 1 $numdisks); do
  echo -n "$i "
  truncate -s ${disksize}G zsizetest${i}
done
echo ''

ls -lh z*

# disks per vdev
let dperv=$numdisks/$vdevs

# array
declare -a arr
IFS=$'\n' arr=( $(ls -1 ./z* |sort --human-numeric-sort |xargs -n $dperv) )
# Separate at newline; we need the preceding './' to replace it later with PWD

# Do some string replacing, precede with topology and provide path to backing-store virt disk
let numelements=${#arr[@]}-1 # start at 0
for line in $(seq 0 $numelements); do
  arr[$line]="$zptype ${arr[$line]}"
  arr[$line]=$(echo ${arr[$line]} |sed "s%./%$PWD/%g")
done
#echo ${arr[*]} # debugg

#echo "Press any key to continue"
#read -n 1

echo "Creating $zp"
set -x
cmd="zpool create -f -o ashift=12 -o autoexpand=on -O atime=off -O compression=lz4 $zp \
  $(echo ${arr[*]})"
eval "$cmd"
#  ${arr[*]})" # NOTWORK
# Dont ask me why we have to do this insane shit, refused to create it otherwise due to quoting!
#  $PWD/zsizetest*

# DONE use driveslicer for vdevs

# no empty lines
zpool status -v $zp |awk 'NF>0'
zpool list -o name,size,alloc,free $zp
zfs list $zp
df -h |egrep "ilesystem|zspace" |column -t

echo "Created zpool $zp , $zptype with $numdisks disks / $vdevs vdevs // $dperv disks per vdev"

echo "Press any key to continue or ^C if you Sourced $0"
read -n 1

exit;


ls |xargs -n 6
zsizetest1 zsizetest10 zsizetest11 zsizetest12 zsizetest13 zsizetest14
zsizetest15 zsizetest16 zsizetest17 zsizetest18 zsizetest19 zsizetest2
.
zsizetest42 zsizetest43 zsizetest44 zsizetest45 zsizetest46 zsizetest47
zsizetest48 zsizetest5 zsizetest6 zsizetest7 zsizetest8 zsizetest9

After pad:
ls |sort --human-numeric-sort |xargs -n 6 
zsizetest01 zsizetest02 zsizetest03 zsizetest04 zsizetest05 zsizetest06
.
zsizetest43 zsizetest44 zsizetest45 zsizetest46 zsizetest47 zsizetest48

echo ${ar[0]}
zsizetest01 zsizetest02 zsizetest03 zsizetest04 zsizetest05 zsizetest06

ar[0]="raidz2 ${ar[0]}"
echo ${ar[0]}
raidz2 zsizetest01 zsizetest02 zsizetest03 zsizetest04 zsizetest05 zsizetest06

ar[1]="raidz2 ${ar[1]}"
echo ${ar[*]}
raidz2 zsizetest01 zsizetest02 zsizetest03 zsizetest04 zsizetest05 zsizetest06 raidz2 zsizetest07 zsizetest08 zsizetest09 zsizetest10 zsizetest11 zsizetest12 zsizetest13 zsizetest14 zsizetest15 zsizetest16 zsizetest17 zsizetest18 zsizetest19 zsizetest20 zsizetest21 zsizetest22 zsizetest23 zsizetest24 zsizetest25 zsizetest26 zsizetest27 zsizetest28 zsizetest29 zsizetest30 zsizetest31 zsizetest32 zsizetest33 zsizetest34 zsizetest35 zsizetest36 zsizetest37 zsizetest38 zsizetest39 zsizetest40 zsizetest41 zsizetest42 zsizetest43 zsizetest44 zsizetest45 zsizetest46 zsizetest47 zsizetest48

echo ${arr[0]} |sed 's%./%$PWD/%g'
raidz2 $PWD/zsizetest01 $PWD/zsizetest02 $PWD/zsizetest03 $PWD/zsizetest04 $PWD/zsizetest05 $PWD/zsizetest06


===== Various configs / output results

# NOTE zpool list is all addressable disks with parity,
# zfs list is "usable" space - always take the LOWER number for free space

# 48x16G raidz2, 6 vdevs
+ zpool list zspacecalc
NAME         SIZE  ALLOC   FREE  
zspacecalc   762G  1.20M   762G  
+ zfs list zspacecalc
NAME         USED  AVAIL  REFER  MOUNTPOINT
zspacecalc   717K   525G   205K  /Volumes/zspacecalc
+ df -h
Filesystem  Size   Used   Avail  Capacity  iused  ifree       %iused  Mounted              
zspacecalc  525Gi  205Ki  525Gi  1%        6      1100594534  0%      /Volumes/zspacecalc
Created zpool raidz2 zspacecalc with 48 disks / 6 vdevs 
# 8 disks per vdev, 2 can fail per vdev or 12 total


# 48x16G raidz1, 6 vdevs = more free space but more risk
+ zpool list zspacecalc
NAME         SIZE  ALLOC   FREE  
zspacecalc   764G   816K   764G  
+ zfs list zspacecalc
NAME         USED  AVAIL  REFER  MOUNTPOINT
zspacecalc   537K   591G   153K  /Volumes/zspacecalc
+ df -h |egrep 'ilesystem|zspace' |column -t
Filesystem     Size   Used   Avail  Capacity  iused  ifree       %iused  Mounted              
/dev/disk12s1  591Gi  154Ki  591Gi  1%        6      1239903502  0%      /Volumes/zspacecalc
Created zpool raidz zspacecalc with 48 disks / 6 vdevs 


# 48x16G raidz3, 4 vdevs, more available space than ^ raidz2 with 6 vdevs (538G vs 525G)
# I/O will likely be slower due to parity
+ zpool list zspacecalc
NAME         SIZE  ALLOC   FREE  
zspacecalc   764G  1.64M   764G  
+ zfs list zspacecalc
NAME         USED  AVAIL  REFER  MOUNTPOINT
zspacecalc   976K   538G   279K  /Volumes/zspacecalc
+ df -h
Filesystem  Size   Used   Avail  Capacity  iused  ifree       %iused  Mounted              
zspacecalc  538Gi  279Ki  538Gi  1%        6      1127734972  0%      /Volumes/zspacecalc
Created zpool raidz3 zspacecalc with 48 disks / 4 vdevs 
# 3/12 disks per vdev can fail (18 total for pool) with no dataloss


# 48x16G mirror, 24 vdevs - low amount of free space per # of disks used
+ zpool list -o name,size,alloc,free zspacecalc
NAME         SIZE  ALLOC   FREE
zspacecalc   372G   456K   372G
+ zfs list zspacecalc
NAME         USED  AVAIL  REFER  MOUNTPOINT
zspacecalc   372K   360G    96K  /Volumes/zspacecalc
+ df -h
Filesystem     Size   Used  Avail  Capacity  iused  ifree      %iused  Mounted              
/dev/disk12s1  360Gi  96Ki  360Gi  1%        6      755760264  0%      /Volumes/zspacecalc
Created zpool zspacecalc , mirror with 48 disks / 24 vdevs 


# 48x16G triple mirror, 3x16 vdevs with 16G/ea, waste of space but good survivability - 2/3 disks per vdev can fail
# Might be good for hospital / 99% uptime requirement
+ zpool list -o name,size,alloc,free zspacecalc
NAME         SIZE  ALLOC   FREE
zspacecalc   248G   420K   248G
+ zfs list zspacecalc
NAME         USED  AVAIL  REFER  MOUNTPOINT
zspacecalc   348K   240G    96K  /Volumes/zspacecalc
+ df -h
Filesystem  Size   Used  Avail  Capacity  iused  ifree      %iused  Mounted              
zspacecalc  240Gi  96Ki  240Gi  1%        6      503839952  0%      /Volumes/zspacecalc
Created zpool zspacecalc , mirror with 48 disks / 16 vdevs 
          mirror-15                                    ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest46  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest47  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest48  ONLINE       0     0     0


# Same config as triple mirror, 3x/vdev but raidz = LOTS more free space
+ zpool list -o name,size,alloc,free zspacecalc
NAME         SIZE  ALLOC   FREE
zspacecalc   760G   840K   760G
+ zfs list zspacecalc
NAME         USED  AVAIL  REFER  MOUNTPOINT
zspacecalc   464K   490G   128K  /Volumes/zspacecalc
+ df -h
Filesystem  Size   Used   Avail  Capacity  iused  ifree       %iused  Mounted              
zspacecalc  490Gi  128Ki  490Gi  1%        6      1028345793  0%      /Volumes/zspacecalc
Created zpool zspacecalc , raidz with 48 disks / 16 vdevs 
          raidz1-15                                    ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest46  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest47  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest48  ONLINE       0     0     0


# raidz2, 24x16G disks, 8 disks per vdev, achievable for homelab with proper budget
+ zpool list -o name,size,alloc,free zspacecalc
NAME         SIZE  ALLOC   FREE
zspacecalc   381G  1.18M   381G
+ zfs list zspacecalc
NAME         USED  AVAIL  REFER  MOUNTPOINT
zspacecalc   691K   262G   205K  /Volumes/zspacecalc
+ df -h
Filesystem  Size   Used   Avail  Capacity  iused  ifree      %iused  Mounted              
zspacecalc  262Gi  205Ki  262Gi  1%        6      550296474  0%      /Volumes/zspacecalc
Created zpool zspacecalc , raidz2 with 24 disks / 3 vdevs
          raidz2-2                                     ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest17  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest18  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest19  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest20  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest21  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest22  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest23  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest24  ONLINE       0     0     0


# For ~100TB of "usable space" pool and hopefully decent I/O with 2 vdevs:
# 14x12GB raidz2, 7/vdev, up to (4) disks in the pool can fail (2 per vdev) with no dataloss
+ zpool list -o name,size,alloc,free zspacecalc
NAME         SIZE  ALLOC   FREE
zspacecalc   167G  1.12M   167G
+ zfs list zspacecalc
NAME         USED  AVAIL  REFER  MOUNTPOINT
zspacecalc   623K   108G   192K  /Volumes/zspacecalc
+ df -h
Filesystem     Size   Used   Avail  Capacity  iused  ifree      %iused  Mounted              
/dev/disk12s1  108Gi  192Ki  108Gi  1%        6      225964209  0%      /Volumes/zspacecalc
Created zpool zspacecalc , raidz2 with 14 disks / 2 vdevs 
          raidz2-1                                     ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest08  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest09  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest10  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest11  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest12  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest13  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest14  ONLINE       0     0     0


# For ~100TB of "usable space" with larger disks - but slower i/o due to only 1 vdev
# 9x16GB raidz2 , 2/9 disks can fail
# Probably suitable for a "backup" pool
+ zpool list -o name,size,alloc,free zspacecalc
NAME         SIZE  ALLOC   FREE
zspacecalc   143G  1.12M   143G
+ zfs list zspacecalc
NAME         USED  AVAIL  REFER  MOUNTPOINT
zspacecalc   713K   106G   219K  /Volumes/zspacecalc
+ df -h
Filesystem     Size   Used   Avail  Capacity  iused  ifree      %iused  Mounted              
/dev/disk12s1  106Gi  220Ki  106Gi  1%        6      221293659  0%      /Volumes/zspacecalc
Created zpool zspacecalc , raidz2 with 9 disks / 1 vdevs 
          raidz2-0                                    ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest1  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest2  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest3  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest4  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest5  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest6  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest7  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest8  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest9  ONLINE       0     0     0


# If you really want to run a "Petabyte" pool
# numdisks=72; disksize=20; zptype=raidz2; vdevs=8
# 2/9 disks per vdev can fail, or up to (16) total
+ zpool list -o name,size,alloc,free zspacecalc
NAME         SIZE  ALLOC   FREE
zspacecalc  1.40T  1.27M  1.40T
+ zfs list zspacecalc
NAME         USED  AVAIL  REFER  MOUNTPOINT
zspacecalc   823K  1.03T   219K  /Volumes/zspacecalc
+ df -h
Filesystem     Size   Used   Avail  Capacity  iused  ifree      %iused  Mounted             
/dev/disk12s1  1.0Ti  216Ki  1.0Ti  1%        6      277005840  0%      /Volumes/zspacecalc
Created zpool zspacecalc , raidz2 with 72 disks / 8 vdevs 
          raidz2-7                                     ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest64  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest65  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest66  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest67  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest68  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest69  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest70  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest71  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest72  ONLINE       0     0     0


# same "petabyte" config but with RAIDZ3:
# numdisks=72; disksize=20; zptype=raidz3; vdevs=6
# Up to 3/12 disks per vdev can fail, or (18) total for the pool with no dataloss
+ zpool list -o name,size,alloc,free zspacecalc
NAME         SIZE  ALLOC   FREE
zspacecalc  1.39T  1.69M  1.39T
+ zfs list zspacecalc
NAME         USED  AVAIL  REFER  MOUNTPOINT
zspacecalc  1.02M  1005G   279K  /Volumes/zspacecalc
+ df -h
Filesystem  Size   Used   Avail  Capacity  iused  ifree       %iused  Mounted              
zspacecalc  1.0Ti  279Ki  1.0Ti  1%        6      2107862646  0%      /Volumes/zspacecalc
Created zpool zspacecalc , raidz3 with 72 disks / 6 vdevs
          raidz3-5                                     ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest61  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest62  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest63  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest64  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest65  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest66  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest67  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest68  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest69  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest70  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest71  ONLINE       0     0     0
            /Volumes/sgtera2/zfs-tmpdisks/zsizetest72  ONLINE       0     0     0
