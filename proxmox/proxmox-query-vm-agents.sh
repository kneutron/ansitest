#!/bin/bash

# 2024.feb kneutron
# REF: https://youtu.be/wp4kCUM6dik?t=233

time qm list |column -t

for vmid in $(qm list |grep running |awk '{print $1}'); do
  echo "$(date) - Checking $vmid"
  qm agent $vmid ping; rc=$?
  if [ $rc -gt 0 ]; then
    echo "$vmid guest agent not responding!"
    continue;
  fi
  qm guest cmd $vmid get-host-name |tr -d '{}' |awk 'NF>0'
  qm guest cmd 104 network-get-interfaces |grep 'ip-address" :'
# pvesh get /nodes/proxmox/qemu/104/agent/network-get-interfaces -o json-pretty |grep 'ip-address" :'
#  qm guest cmd $vmid get-osinfo
done

exit;

qm list
      VMID NAME                 STATUS     MEM(MB)    BOOTDISK(GB) PID       
       100 lmde                 stopped    4096              21.00 0         
       104 pfsense-272-dhcp-for-HO running    1500              20.00 222982    

NOTE for lxc containers:

# lxc-info -i -n 105
IP:             172.16.25.64
IP:             192.168.1.253
IP:             2600:100e:a001:1a9c:be24:11ff:fe96:3df9
IP:             2600:100e:a011:4e4b:be24:11ff:fe96:3df9
