#!/bin/bash

# 2025.Aug kneutron
# Also lists running LXC, but output format is different between pct/qm

ofs=$IFS
# dont ask why we need this, just works
IFS='
'

echo "$(date) - Calling report"
proxmox-show-backup-jobs.sh >/tmp/backupjobreport.txt

for line in $(pct list |grep running |awk '{print $1" "$3}'; qm list |grep running); do 
  vmid=$(echo "$line" |head -n 1 |awk '{print $1}')
  vmname=$(echo "$line" |head -n 1 |awk '{print $2}')
  echo "VMID: $vmid $vmname"
  echo "+ Found in ( $(grep -c $vmid /tmp/backupjobreport.txt) ) Backup jobs"
done

IFS=$ofs
exit;

pct list |grep running
105        running                 gotify              
113        running                 hostonly-dhcp-ctr-server-no-internet
118        running                 proxmox-fileserver-ctr

qm list |grep running
       109 opnsense-dhcp-for-2p5Gbit running    1288              22.00 6275
       111 ipfire-dhcp-for-10gig running    512               16.00 6457
       116 squidvm-new-2p5-10-HO running    4096              16.00 5331
       120 qotom-pbs-bkp-4-beelink-vms running    6144              20.00 13433
       121 suse-iscsi-qotom-macmini running    4096              32.00 411941
       130 suse-iscsi-bkp-4-macmini2 running    4096              40.00 9995
