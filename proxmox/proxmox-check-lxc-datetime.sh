#!/bin/bash

# useful to see if LXC's time/zone is way off and needs sync
# 2025.Aug kneutron

# fk it, instead of relying on locale lets just specify a std format for output: Sat Aug  9 10:41:41 PM MDT 2025

#export LC_TIME="en_US.UTF-8"

for vmid in $(pct list |grep running |awk '{print $1}'); do 
  echo $vmid
  date
  pct exec $vmid -- date "+%a %b %d %r %Z %Y" 
done
#  pct exec $vmid -- env LC_TIME="en_US.UTF-8"  bash -c 'echo $LC_TIME; date'
