#!/bin/bash

# 2024.feb kneutron
# REF: https://youtu.be/wp4kCUM6dik?t=233

time qm list 

for vmid in $(qm list |grep running |awk '{print $1}'); do
  echo "$(date) - Checking $vmid"
  qm agent $vmid ping || echo "$vmid guest agent not responding!"
done

exit;

qm list
      VMID NAME                 STATUS     MEM(MB)    BOOTDISK(GB) PID       
       100 lmde                 stopped    4096              21.00 0         
       104 pfsense-272-dhcp-for-HO running    1500              20.00 222982    
