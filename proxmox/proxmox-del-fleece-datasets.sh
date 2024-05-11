#!/bin/bash

set -e
set -u

zfs list |grep fleece

echo "$(date) - About to destroy the above fleece datasets - ^C to backout or Enter to proceed"
read

zfs-killsnaps.sh fleece

for fd in $(zfs list |grep fleece |awk '{print $1}'); do 
  echo "$fd"
  zfs destroy "$fd"
done

zfs list |grep fleece
exit;
