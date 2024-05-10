#!/bin/bash

for d in $(ls -1 /dev/nvme?n1); do
  echo $d
  nvme id-ns -H $d |grep -i relative
done
