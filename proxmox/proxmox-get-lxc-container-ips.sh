#!/bin/bash

pct list
echo '====='

for ctr in $(pct list |grep running |awk '{print $1}'); do
  echo "VMID $ctr"
  lxc-info -i -n $ctr
  echo '====='
done

exit;
