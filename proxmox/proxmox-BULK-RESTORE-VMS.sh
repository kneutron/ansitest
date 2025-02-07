#!/bin/bash

# 2025.Feb kneutron
# Example script
# Bulk restore latest-dated backup image of ALL LXC/VMs from a given Storage 
#   (e.g. proxmox backup server, already defined in PVE GUI)
# To new node / rebuilt server 
# NOTE - THIS SCRIPT REQUIRES INPUT TO PROCEED

# xxx TODO EDITME
TESTONLY=1
# set to 0 for actual restore, 1 if you want to run thru script WITHOUT restore step (dry run)

# (get name from PVE GUI or ' pvesm status ')
storage=pbsvm3-25g-vm-on-beelink
# PBS

dest="xfs-exos10"
# destination storage


# No more edits after this
outfile=/dev/shm/pvemstorage.list
restorethese=/dev/shm/bkps2restore.list
rm -fv "$restorethese" 2>/dev/null

logf=/dev/shm/BULK-RESTORE-VMS.log
/bin/mv -v "$logf" "$logf--old" 2>/dev/null

echo ''
echo "-- YOU NEED TO EDIT THIS SCRIPT BEFORE RUNNING IT --"
echo "SCRIPT AUTHOR TAKES NO RESPONSIBILITY FOR DATA LOSS"
echo "RUN AT YOUR OWN RISK"
echo "Enter to proceed or ^C"
[ $TESTONLY -eq 0 ] && read

echo ''
echo "$(date) - Getting list of VMIDs on this backup storage: $storage"
declare -a vmlist=$(pvesm list "$storage" |grep -v 'VMID' |awk '{print $5}' |sort -u)

pvesm list "$storage" >$outfile # faster search, only pull it once

# Get latest backup - NOTE backups are listed oldest-first
#echo "$(date) - Processing list of ${#vmlist[@]} VMIDs"
echo "$(date) - Processing list of VMIDs to get latest backup date"
for i in ${vmlist[@]}; do
  echo $i
#  latestbkp=$(pvesm list "$storage" |grep "/$i/" |tail -n 1)
  latestbkp=$(grep "/$i/" $outfile |tail -n 1)
  echo "$latestbkp" |tee -a "$restorethese"
done

#using-my-own-vm-as-storage-lol:backup/ct/105/2025-02-04T10:00:05Z  pbs-ct  backup       640117954 105
#using-my-own-vm-as-storage-lol:backup/ct/105/2025-02-05T10:00:13Z  pbs-ct  backup       640122782 105
#using-my-own-vm-as-storage-lol:backup/ct/105/2025-02-06T10:00:02Z  pbs-ct  backup       640125449 105

#using-my-own-vm-as-storage-lol:backup/vm/100/2025-01-26T08:00:09Z  pbs-vm  backup     33285998322 100
#using-my-own-vm-as-storage-lol:backup/vm/100/2025-02-02T08:00:08Z  pbs-vm  backup     33285998313 100

spaceneed=$(awk '{sum+=$4;} END{print sum;}' $restorethese)
let spaceneed1024=$spaceneed/1024
let spaceneedgig=$spaceneed1024/1024/1024

function commanum () { 
  LC_NUMERIC=en_US printf "%'.f" $1 
} 2>/dev/null

echo '========================='
echo "Number of VMs to restore: $(wc -l $restorethese)"
echo "$(basename $0) - $(date) - Space needed to restore (MiB): $(commanum $spaceneed1024)" |tee -a $logf
echo "Or $spaceneedgig GiB"
echo '========================='
echo "Enter to begin restore to $dest or ^C"
echo "PROTIP: You can edit the list in another window before proceeding"
ls -lh $restorethese
read

# Teh Main Thing
for bkp in $(awk '{print $1}' $restorethese); do
  let newid=$(pvesh get /cluster/nextid) # get next free VMID number
  echo "$(date) - Restoring to $dest -- Image dated: $bkp -- as VMID $newid"  |tee -a $logf
if [ $TESTONLY -eq 0 ]; then
  time qmrestore --storage $dest "$bkp" $newid \
  ||echo "ERROR: $(date) - Restore of $bkp / new VMID $newid failed!" |tee -a $logf
fi
# PROTIP: add "--unique 1" if you need a new MAC address for each VM (usually only necessary if VM is duplicated)
  date |tee -a $logf
done
echo '=========================' |tee -a $logf
ls -l $logf

# TODO parallel / xargs (faster?)

# Example log:
#BULK-RESTORE-VMS.sh - Fri Feb  7 12:13:42 AM MST 2025 - Space needed to restore (MiB): 1,571,406,038
#Fri Feb  7 12:13:55 AM MST 2025 - Restoring to xfs-exos10 -- Image dated: pbsvm3-25g-vm-on-beelink:backup/vm/100/2025-02-02T08:00:08Z -- as VMID 130
#Fri Feb  7 12:17:41 AM MST 2025
#Fri Feb  7 12:17:43 AM MST 2025 - Restoring to xfs-exos10 -- Image dated: pbsvm3-25g-vm-on-beelink:backup/vm/101/2025-02-02T08:01:21Z -- as VMID 131
#Fri Feb  7 12:17:47 AM MST 2025
#Fri Feb  7 12:17:49 AM MST 2025 - Restoring to xfs-exos10 -- Image dated: pbsvm3-25g-vm-on-beelink:backup/vm/102/2025-02-07T04:42:14Z -- as VMID 132
#Fri Feb  7 12:17:55 AM MST 2025
#Fri Feb  7 12:17:58 AM MST 2025 - Restoring to xfs-exos10 -- Image dated: pbsvm3-25g-vm-on-beelink:backup/vm/103/2025-02-02T08:02:36Z -- as VMID 138
#Fri Feb  7 12:18:02 AM MST 2025
