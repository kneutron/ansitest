#!/bin/bash

if [ "$1" = "" ]; then
  echo "Config for jumbo frames 9000"
  ifconfig en0 mtu 9000
else
  echo "Config for std frames 1500"
  ifconfig en0 mtu 1500
fi

echo "$(date) - Waiting for interface to come back online"
result=1
while [ $result -gt 0 ]; do
 result=$(ifconfig en0 |grep -c inactive)
 sleep .5
done

date
ifconfig en0
