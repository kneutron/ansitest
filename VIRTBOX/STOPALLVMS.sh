#!/bin/bash5

vbm=VBoxManage

$vbm list runningvms

for vm in $($vbm list runningvms |awk '{print $2}' |tr -d '{}'); do
  echo "$(date) - Stopping $vm"
  $vbm controlvm $vm savestate
  sleep 2 # allow disk to catch up a bit
done

date
