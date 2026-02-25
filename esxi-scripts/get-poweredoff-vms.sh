#!/bin/sh

cd /root/bin
#pwd
ofile=/root/poweredoffcpus.txt
> $ofile # always new

echo "$(date) - Generating report file for powered-off vms..."
vmlist=$(./getallvms.sh |grep "vmx" |awk '{print $1,"\t",$2}')
oifs=$IFS
IFS=$'\r\n'

for vm in $(echo "$vmlist"); do
  vmname=$(echo "$vm" |awk '{print $2}')
  vmid=$(echo "$vm" |awk '{print $1}')
  powerstate=$(vim-cmd vmsvc/power.getstate $vmid |tail -n 1)
  vmx=$(echo "$vm" |awk '{print $4}')

  if [ "$powerstate" = "Powered off" ]; then
    echo -e "$vmid \t $vmname \t $powerstate"
    (cd /vmfs/volumes/VMHOST02-LocalStorage/$vmname; grep numvcpu *.vmx) |sed 's/"//g' |tee -a $ofile # delquot
  fi
done

echo '====='
echo "Number of allocated but powered-off cpus:"
awk -F= '{sum += $2} END {print sum}' $ofile

