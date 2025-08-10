#!/bin/bash

# useful to see if a VM's time is way off and needs sync
# 2025.Aug kneutron

for vmid in $(qm list |grep running |awk '{print $1}'); do 
  echo $vmid
  date
  qm guest exec $vmid date
done
