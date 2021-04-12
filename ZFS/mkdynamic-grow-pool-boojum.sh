#!/bin/bash

#====================================================
# 2016 Dave Bechtel
#====================================================

# Interactive demo: make a dynamic-growing zfs pool from 1 disk to 6
# zfs pools are on loop files (virtual disks)
# NOTE this demo waits for multiple press-a-key-to-proceed prompts

# trace on: set -x // off: set +x  # REF: http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_02_03.html
# PROTIP: Avoid having to turn off and avoid clutter by using subshell 
# REF: http://serverfault.com/questions/16204/how-to-make-bash-scripts-print-out-every-command-before-it-executes

# TODO setme or pass "new" as arg1
newdisks=1  # set 1 to zero-out new disk files

# DONE redirect to non-ZFS spinning disk if avail, otherwise use RAMdisk
zdpath="/run/shm/zdisks"

# if milterausb3 is mounted, use it
usemil=$(df |grep -c /mnt/milterausb3)
[ $usemil -gt 0 ] && zdpath="/mnt/milterausb3/zdisks"
# xxx TODO EDITME

mkdir -pv $zdpath
ln $zdpath /zdisks -sfn
cd /zdisks || exit 99

DS=400  # Disksize in MB
[ $usemil -gt 0 ] && DS=465 

let mkpop=$DS-100  # size of populate-data file in MB

# NOTE we need more loop devices; 1-time fix REF: http://askubuntu.com/questions/499131/how-to-use-more-than-255-loop-devices

logfile=~/mkdynamic-grow-pool.log
> $logfile # clearit

function nomorepool () {
 zfs umount -f $1 2>> $logfile

# zpool export $1 2>> $logfile

 zpool status $1
 zpool destroy -f $1 2>> $logfile
 zpool status -L -P -x
}

pool1="zdynpool1"

nomorepool $pool1

df -hT
zpool status $pool1
echo "POOL $pool1 SHOULD BE GONE -PK"

# if not exist, trip
[ -e zdyndisk1 ] || let newdisks=1
[ "$1" = "new" ] && let newdisks=1  # if arg passed

[ $newdisks -gt 0 ] && read -n 1
[ $newdisks -gt 0 ] && clearcache.sh

# getting rid of sync for each dd should speed things up
echo "Preparing virtual disks... (Size: $DS MB)"
for i in {1..8};do
  printf $i...

# NECESSARY if re-using disks that were previously in a pool!!
  zpool labelclear -f /zdisks/zdyndisk$i
  
[ $newdisks -gt 0 ] && time dd if=/dev/zero of=zdyndisk$i bs=1M count=$DS 2>&1 |egrep 'copied|real' >> $logfile

done

echo 'Syncing...'
time sync
# NOTE may not want to do this if you have a long-running I/O process (tar) because the sync will hang here

ls -alh |tee -a $logfile

#NOTE: ' zfs add ' = add a disk (expand, non-redundant); ' zfs attach ' = add mirror

# REF: http://zfsonlinux.org/faq.html#WhatDevNamesShouldIUseWhenCreatingMyPool
# REF: https://flux.org.uk/tech/2007/03/zfs_tutorial_1.html


############ create 1-disk NORAID
(set -x
 time zpool create -f -o ashift=12 -o autoexpand=on -O atime=off $pool1 \
   /zdisks/zdyndisk1) #; set +x

echo 'o Populating pool with random,uncompressible data...'
# if file not there, create
[ -e /root/tmpfile ] && [ $newdisks -eq 0 ] || time dd if=/dev/urandom of=/root/tmpfile bs=1M count=$mkpop
  time cp -v /root/tmpfile /$pool1

echo 'o Should now have a 1-disk, non-redundant pool with some data in it:'
zpool status $pool1; df -h /$pool1
echo '';printf 'PK to add mirror to single disk:';read -n 1


########### add mirror to 1-disk
# REF: http://docs.oracle.com/cd/E19253-01/819-5461/6n7ht6qvl/index.html
(set -x
 time zpool attach $pool1 \
  /zdisks/zdyndisk1 /zdisks/zdyndisk2) 
  
echo 'o Should now have a 2-disk, MIRRORED pool with RAID1:'
zpool status $pool1; df -hT /$pool1
echo '';echo 'o NOTE that available pool space has not changed yet - we have only added Redundancy'
echo '! NORMALLY we would wait for the resilver to complete before proceeding! # zpool status  # until resilvered'
printf 'PK to add another set of mirrored disks to the existing pool:';read -n 1
  
  
########### add 2-disk mirror to 2-disk
# REF: http://docs.oracle.com/cd/E19253-01/819-5461/6n7ht6qvk/index.html
(set -x
 time zpool add -o ashift=12 $pool1 \
   mirror /zdisks/zdyndisk3 /zdisks/zdyndisk4)

echo 'o Populating pool with more data...'
time cp -v /$pool1/tmpfile /$pool1/tmpfile2    
    
echo 'o Should now have a 4-disk, redundant pool with RAID10:'
zpool status $pool1; df -hT /$pool1
ls -lh /$pool1/*

echo '';echo 'o NOTE that the available pool space should be approximately 2x what we had before, minus a bit of overhead'
echo '! Again - NORMALLY we would wait for the resilver to complete before proceeding! # zpool status  # until resilvered'
# DONE adapt scrubwatch to wait4resilver
printf 'PK to add final 2-disk mirror with 1 hotspare:';read -n 1


########### add 2-disk mirror to 4-disk, with 1 spare
# REF: http://docs.oracle.com/cd/E19253-01/819-5461/6n7ht6qvk/index.html
(set -x
 time zpool add -o ashift=12 $pool1 \
   mirror /zdisks/zdyndisk5 /zdisks/zdyndisk6 \
   spare /zdisks/zdyndisk7)


echo 'o Should now have a 6-disk, highly failure-resistant pool with RAID10:'
zpool status $pool1; df -hT /$pool1; zpool list $pool1
echo ''
echo 'o NOTE that the available pool space should be approximately 1.5x what we had with the 4-disk mirror set,'
echo ' minus a bit of overhead'
echo '! Again - NORMALLY we would wait for the resilver to complete before proceeding! # zpool status  # until resilvered'
printf 'PK to proceed with next phase (POOL WILL BE DESTROYED and rebuilt):';read -n 1



####################### start over and build redundant RAID10 pool from 2-disk RAID0

nomorepool $pool1

df -h
zpool status $pool1
echo "POOL $pool1 SHOULD BE GONE -PK";read -n 1


############ create 2-disk NORAID with max available space
(set -x
 zpool create -f -o ashift=12 -o autoexpand=on -O atime=off $pool1 \
   /zdisks/zdyndisk1 /zdisks/zdyndisk2)
  
echo 'o Populating pool with data...'
time cp -v /root/tmpfile /$pool1    
time cp -v /$pool1/tmpfile /$pool1/tmpfile2  
  
echo 'o OK, say our client has a limited budget and wants to start with 2 disks with maximum writable space, NO redundancy... (RAID0)'
zpool status $pool1; df -hT /$pool1
echo '';echo 'o NOTE that the available pool space should be about the capacity of disk1+disk2 minus a bit of overhead;'
echo '+ it will be fast, but vulnerable to failure. NOTE that we will have done a *full burn-in test* on the drives 1st!'
echo 'o After a couple of weeks, client is able to buy 2 more drives -- we can add redundancy!'
printf 'PK to add a mirror to 1st disk:';read -n 1


########### add a mirror OTF to 1st disk of RAID0, 1st half
# REF: http://docs.oracle.com/cd/E19253-01/819-5461/6n7ht6qvl/index.html
(set -x
 time zpool attach $pool1 \
   /zdisks/zdyndisk1 /zdisks/zdyndisk3)

echo 'o Should now have a 3-disk, UNBALANCED MIRRORED pool with half-RAID1:'
zpool status $pool1; df -hT /$pool1
echo '';echo 'o NOTE that available pool space has **not changed** - we have only added Redundancy to HALF of the pool!'
echo '! NORMALLY we would NEED to wait for the resilver to complete before proceeding! # zpool status  # until resilvered'
printf 'PK to add a mirror to the 2nd half (will end up being RAID10):';read -n 1

  
########### add mirror OTF to 2nd disk of original RAID0
# REF: http://docs.oracle.com/cd/E19253-01/819-5461/6n7ht6qvl/index.html
(set -x
 time zpool attach $pool1 \
   /zdisks/zdyndisk2 /zdisks/zdyndisk4)

echo 'o Populating pool with more data...'
time cp -v /$pool1/tmpfile /$pool1/tmpfile2    
  
echo 'o Should now have a 4-disk, redundant pool with RAID10 - but we built it differently since it started out as a RAID0:'
zpool status $pool1; df -hT /$pool1

echo '';echo 'o NOTE that the available pool space is still the same as what we started with,'
echo '+ only now the pool has been upgraded in-place to be failure-resistant - with no downtime!'
echo '! Again - NORMALLY we would wait for the resilver to complete before proceeding! # zpool status  # until resilvered'
printf 'PK to expand this now-RAID10 pool with the final 2-disk mirror, plus 1 hotspare:';read -n 1


########### Expand free space = add final 2-disk mirror to 4-disk RAID10, with 1 spare
# REF: http://docs.oracle.com/cd/E19253-01/819-5461/6n7ht6qvk/index.html
(set -x
 time zpool add -o ashift=12 $pool1 \
   mirror /zdisks/zdyndisk5 /zdisks/zdyndisk6 \
   spare /zdisks/zdyndisk7)

echo ''
echo 'o We should now have ended up with a 6-disk, mirrored, failure-resistant pool with RAID10,'
echo ' with some acceptable risks but built on a budget:'
      
    
###########
# ENDIT
zpool status -L $pool1
#df -h |head -n 1 # unnec; fortuitously, grep also grabs "size"
df -hT |grep z 	# /$pool1 /$pool2 /$pool3a /$pool3b /$pool3c
(set -x; zfs list $pool1; zpool list $pool1)
echo ''
echo "Log: $logfile"

/bin/rm -v /zdisks/tmpfile

echo "! CLEANUP: PK to Destroy example pool $pool1 or ^C to keep it"; read -n 1
nomorepool $pool1
zpool status

exit;

====================================================
# 2016 Dave Bechtel
====================================================

# df -h /zdynpool1
Filesystem      Size  Used Avail Use% Mounted on
zdynpool1       832M     0  832M   0% /zdynpool1

# zpool status
  pool: zdynpool1
 state: ONLINE
  scan: resilvered 276K in 0h0m with 0 errors on Mon May  9 16:49:45 2016
config:
        NAME                   STATE     READ WRITE CKSUM
        zdynpool1              ONLINE       0     0     0
          mirror-0             ONLINE       0     0     0
            /zdisks/zdyndisk1  ONLINE       0     0     0
            /zdisks/zdyndisk2  ONLINE       0     0     0
          mirror-1             ONLINE       0     0     0
            /zdisks/zdyndisk3  ONLINE       0     0     0
            /zdisks/zdyndisk4  ONLINE       0     0     0
          mirror-2             ONLINE       0     0     0
            /zdisks/zdyndisk5  ONLINE       0     0     0
            /zdisks/zdyndisk6  ONLINE       0     0     0
        spares
          /zdisks/zdyndisk7    AVAIL
errors: No known data errors

========================================================

2016.0525 moving /zdisks to /run/shm due to usb3 thumbdrive heat / slowdowns
+ added "use milterausb3" capability, with bigger disk sizes

2016.0610 added "ashift=12" to zpool ADD commands (zfs quirk, ashift is not a global pool inherited property)
