#!/bin/bash

# 2026.Aug kneutron

# Will go thru list of vms on thisnode and enroll new efi keys if missing, skip running vms

debugg=0 # 1 = test run, no changes

cd /etc/pve/qemu-server ||exit 44;

vmrc=/dev/shm/vmsrunning.in

echo "$(date) - Check running vms" 
qm list |grep running >$vmrc

column -t <$vmrc
echo ''

IFS="
"

for efiline in $(grep ^efidisk *.conf); do
#  [[ "$efiline" == *"ms-cert=2023k"* ]] && continue # already done, skippit
  [ $(echo "$efiline" |grep -c "ms-cert=2023k") -gt 0 ] && continue # already done, skippit

  vmid=$(echo "$efiline" |tr '.' ' ' |awk '{print $1}')
  echo "o Processing $vmid"

  if [ $(awk '$1 == "'$vmid'"' /dev/shm/vmsrunning.in) ]; then
    echo "o Skipping vmid $vmid - still running - to fix, STOP vm (not hibernate!) and rerun"
    continue
  fi
  
  if [ $debugg -gt 0 ]; then
    echo "qm enroll-efi-keys $vmid"
  else
    qm enroll-efi-keys $vmid
  fi

  echo '-----'  
done

touch ~/$(basename $0).ran

date;

#/etc/pve/qemu-server # grep ^efidisk *.conf
#102.conf:efidisk0: local-lvm:vm-102-disk-0,efitype=4m,ms-cert=2023k,pre-enrolled-keys=1,size=4M
#115.conf:efidisk0: zfs3nvme1T:vm-115-disk-0,efitype=4m,pre-enrolled-keys=1,size=1M
#121.conf:efidisk0: local-lvm:vm-121-disk-0,efitype=4m,ms-cert=2023k,pre-enrolled-keys=1,size=4M
#125.conf:efidisk0: ztosh10:vm-125-disk-1,efitype=4m,pre-enrolled-keys=1,size=1M
#126.conf:efidisk0: local-lvm:vm-126-disk-0,efitype=4m,pre-enrolled-keys=1,size=4M
#128.conf:efidisk0: local-lvm:vm-128-disk-0,efitype=4m,ms-cert=2023k,pre-enrolled-keys=1,size=4M
#132.conf:efidisk0: local-lvm:vm-132-disk-0,efitype=4m,ms-cert=2023k,pre-enrolled-keys=1,size=4M
