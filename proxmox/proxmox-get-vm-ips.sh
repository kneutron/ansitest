#!/bin/bash

qm list
echo '====='

for vm in $(qm list |grep running |awk '{print $1}'); do
  echo "VMID $vm"
  qm agent $vm network-get-interfaces |grep -w 'ip-address'
  echo '====='
done

exit;
