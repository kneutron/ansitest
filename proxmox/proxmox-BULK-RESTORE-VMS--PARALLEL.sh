#!/bin/bash

# 2025.Feb kneutron
# Example script
# Parallel restore version; defaults to jobs=2

# Bulk restore latest-dated backup image of ALL LXC/VMs from a given Storage 
#   (e.g. proxmox backup server, already defined in PVE GUI)
# To new node / rebuilt server 

# NOTE - THIS SCRIPT REQUIRES INPUT TO PROCEED

# NOTE - after a run, you can pass argument "redofailed" to re-attempt failed restores
# --YOU NEED TO EDIT the $pjobrun file first!!

# NOTE - pvesh get /cluster/nextid # does NOT distinguish between LXC and VM numbers, they are mixed!
# And cluster nextid will fill-in any missing numbers!
# So be careful what you delete after a test run!


# xxx TODO EDITME
# set to 0 for actual restore, 1 if you want to run thru script WITHOUT restore step (dry run)
TESTONLY=1

restorelxc=1 # set to 0 to not restore LXC
restorevm=1

# (get name from PVE GUI or ' pvesm status ')
storage=pbsvm3-25g-vm-on-beelink
# PBS

dest="xfs-exos10"
# Destination storage


# ========================
# No more edits after this
outfile=/dev/shm/pvemstorage.list
restorethese=/dev/shm/bkps2restore.list
rm -fv "$restorethese" 2>/dev/null

logf=/dev/shm/BULK-RESTORE-VMS.log
/bin/mv -v "$logf" "$logf--old" 2>/dev/null

pjobrun=/dev/shm/parallel-input-bulk-restore.list
#rm -fv $pjobrun # moved down

# Install missing dependency
[ $(which parallel |wc -l) -eq 0 ] && apt install -y parallel

clear
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
echo "$(date) - Processing list of VMIDs to get latest backup date"
for i in ${vmlist[@]}; do
  echo -n "$i  "
  latestbkp=$(grep "/$i/" $outfile |tail -n 1)

if [ $restorelxc -gt 0 ] && [ $(echo "$latestbkp" |grep -c pbs-ct) -gt 0 ]; then
  echo "$latestbkp" |tee -a "$restorethese"
fi
if [ $restorevm -gt 0 ] && [ $(echo "$latestbkp" |grep -c pbs-vm) -gt 0 ]; then
  echo "$latestbkp" |tee -a "$restorethese"
fi
echo ''
done |awk 'NF>0'

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
echo "Number of LXC/VMs to restore: $(wc -l $restorethese)"
echo "$(basename $0) - $(date) - Space needed to restore (MiB): $(commanum $spaceneed1024) / $spaceneedgig GiB " |tee -a $logf
echo "NOTE this can vary with zfs compression on destination storage"
echo '========================='
echo "Enter to begin restore to $dest or ^C"
echo "PROTIP: You can edit the list in another window before proceeding"
ls -lh $restorethese
read


# Teh Main Thing
sdate=$(date)
oifs=$IFS
IFS="
"
if [ "$1" = "redofailed" ]; then
  : # NOP - do not modify the $pjobrun file, reuse edited version
else
# NOTE this will still proceed to the next one if restore fails

# bash arrays start at 0
quot='"'
declare -a delay #="30 45 60"
delay[0]=20
delay[1]=35
delay[2]=50
rm -fv $pjobrun

flipbit=0
while read -r line; do

#echo "delay $flipbit = ${delay[$flipbit]}"
  ((flipbit++))
  [ $flipbit -gt 2 ] && let flipbit=0
  
  bkp=$(echo "$line" |awk '{print $1}')
  vmtype=$(echo "$line" |awk '{print $2}')

  echo "$(date) - Restoring to $dest -- Image dated: $bkp"  |tee -a $logf

# By sleeping varying amount of seconds, we hope to avoid get nextid collisions
  RAND=${delay[$flipbit]}  

# This crazy shit we have to do for bash quoting... (buildstr)
  if [ $vmtype = "pbs-vm" ]; then
    outline="sleep $RAND; time qmrestore --storage $dest $bkp "
    outline+=' $(pvesh get /cluster/nextid) ||echo '
    outline+="${quot}ERROR: - Restore of VM $bkp failed! $quot"
    outline+=' |tee -a '
    outline+=$logf 
#    echo "= $outline ="
    echo "$outline" >>$pjobrun
    outline=''
  else
    outline="sleep $RAND; time pct restore "
    outline+=' $(pvesh get /cluster/nextid) --storage '
    outline+="$dest $bkp"
    outline+=' ||'
    outline+="echo ${quot}ERROR: - Restore of LXC $bkp failed! $quot"
    outline+=' |tee -a '
    outline+=$logf
#    echo "= $outline ="
    echo "$outline" >>$pjobrun
    outline=''
  fi # vmtype
# PROTIP: add "--unique 1" if you need a new MAC address for each VM (usually only necessary if VM is duplicated)
done < $restorethese
fi # redofailed check
IFS=$oifs

# Higher job limits may cause more fragmentation
joblimit=2 
# It is not recommended to change this, but you can experiment - odds of collision when getting the next free ID may be worse

# xxx TODO EDITME if youre feeling brave
#joblimit=3 
# It is not recommended to change this, but you can experiment - odds of collision when getting the next free ID may be worse
# I have tested with up to 3 on a Qotom 8-core firewall appliance - it "worked" but it MAY NOT WORK EVERY TIME

echo "$(date) - Starting parallel restore, jobs=$joblimit" |tee -a $logf
[ $TESTONLY -eq 0 ] && time cat $pjobrun |parallel -j $joblimit --progress

echo '=========================' |tee -a $logf
date |tee -a $logf

endate=$(date)

echo '=========================' |tee -a $logf
echo "Restore process started: $sdate" |tee -a $logf
echo "Restore process   ended: $endate" |tee -a $logf
echo "Edit the $pjobrun file and rerun with:  $(basename $0) redofailed   if needed" |tee -a $logf
echo '=========================' |tee -a $logf
ls -l $logf

exit;

# DONE $1 = redofailed, with modified infile

# DONE parallel (faster?)

# Example log:
#proxmox-BULK-RESTORE-VMS--PARALLEL.sh - Fri Feb  7 10:58:58 AM MST 2025 - Space needed to restore (MiB): 43,624,899 / 41 GiB
#Fri Feb  7 10:59:02 AM MST 2025 - Restoring to xfs-exos10 -- Image dated: pbsvm3-25g-vm-on-beelink:backup/ct/105/2025-02-07T10:00:06Z
#Fri Feb  7 10:59:02 AM MST 2025 - Restoring to xfs-exos10 -- Image dated: pbsvm3-25g-vm-on-beelink:backup/ct/108/2025-02-02T08:02:43Z
#Fri Feb  7 10:59:02 AM MST 2025 - Restoring to xfs-exos10 -- Image dated: pbsvm3-25g-vm-on-beelink:backup/ct/110/2025-02-02T08:03:16Z
#Fri Feb  7 10:59:02 AM MST 2025 - Restoring to xfs-exos10 -- Image dated: pbsvm3-25g-vm-on-beelink:backup/ct/113/2025-02-07T10:01:17Z
#Fri Feb  7 10:59:02 AM MST 2025 - Restoring to xfs-exos10 -- Image dated: pbsvm3-25g-vm-on-beelink:backup/ct/114/2025-02-02T08:04:28Z
#Fri Feb  7 10:59:03 AM MST 2025 - Restoring to xfs-exos10 -- Image dated: pbsvm3-25g-vm-on-beelink:backup/ct/118/2024-12-22T12:17:59Z
#Fri Feb  7 10:59:03 AM MST 2025 - Restoring to xfs-exos10 -- Image dated: pbsvm3-25g-vm-on-beelink:backup/ct/122/2025-02-02T08:13:49Z
#Fri Feb  7 10:59:03 AM MST 2025 - Restoring to xfs-exos10 -- Image dated: pbsvm3-25g-vm-on-beelink:backup/ct/124/2025-02-02T08:19:43Z
#Fri Feb  7 10:59:03 AM MST 2025 - Restoring to xfs-exos10 -- Image dated: pbsvm3-25g-vm-on-beelink:backup/ct/135/2025-02-02T08:29:53Z
#Fri Feb  7 10:59:03 AM MST 2025 - Restoring to xfs-exos10 -- Image dated: pbsvm3-25g-vm-on-beelink:backup/ct/136/2025-02-02T08:30:01Z
#Fri Feb  7 10:59:03 AM MST 2025 - Starting parallel restore, jobs=2
#=========================
#Fri Feb  7 11:07:14 AM MST 2025
#=========================
#Restore process started: Fri Feb  7 10:59:02 AM MST 2025
#Restore process   ended: Fri Feb  7 11:07:14 AM MST 2025
#=========================

# HOWTO cleanup a test restore of LXC:
# ls -lrt /etc/pve/lxc/
# for VMID in 130 131; do pct set --protection 0 $VMID; echo $VMID; time pct destroy $VMID; done; date

# HOWTO cleanup test-restored VM:
# ls -lrt /etc/pve/qemu-server/
# for VMID in 130 131; do echo $VMID; qm unlock $VMID; time qm destroy $VMID; done; date

# After restore, to correlate new VMIDs, look between the start/end timeframe:
# ls -lrRt /var/log/pve/tasks |grep 'Feb..7' |grep restore |awk '{print $6" "$7" "$8" "$9'} |sort
#Feb 7 10:13 UPID:proxmox:002F0023:04727767:67A63F3B:qmrestore:130:root@pam:
#Feb 7 10:13 UPID:proxmox:002F008F:04727943:67A63F3F:qmrestore:131:root@pam:
#Feb 7 10:20 UPID:proxmox:002F1365:04731D0B:67A640E3:qmrestore:132:root@pam:
#Feb 7 10:20 UPID:proxmox:002F13D3:04731F94:67A640E9:qmrestore:138:root@pam:
#Feb 7 10:21 UPID:proxmox:002F14A6:047323D8:67A640F4:qmrestore:139:root@pam:
#Feb 7 10:21 UPID:proxmox:002F153E:047326C4:67A640FC:qmrestore:140:root@pam:
#Feb 7 10:21 UPID:proxmox:002F15F8:04732B39:67A64107:qmrestore:141:root@pam:

#Feb 7 10:59 UPID:proxmox:002F8541:0476A65B:67A649F0:vzrestore:130:root@pam:
#Feb 7 10:59 UPID:proxmox:002F85AF:0476A787:67A649F3:vzrestore:131:root@pam:
#Feb 7 11:00 UPID:proxmox:002F878C:0476B3BD:67A64A13:vzrestore:132:root@pam:
#Feb 7 11:00 UPID:proxmox:002F88CC:0476BB70:67A64A26:vzrestore:138:root@pam:
#Feb 7 11:04 UPID:proxmox:002F8BEE:0476D067:67A64A5C:vzrestore:140:root@pam:
#Feb 7 11:04 UPID:proxmox:002F9664:047724F6:67A64B34:vzrestore:141:root@pam:
#Feb 7 11:05 UPID:proxmox:002F8AB3:0476C8E8:67A64A49:vzrestore:139:root@pam:
#Feb 7 11:05 UPID:proxmox:002F991D:047735E0:67A64B60:vzrestore:143:root@pam:
#Feb 7 11:06 UPID:proxmox:002F9AAE:04774269:67A64B80:vzrestore:144:root@pam:
#Feb 7 11:07 UPID:proxmox:002F9845:04772FC1:67A64B50:vzrestore:142:root@pam:
