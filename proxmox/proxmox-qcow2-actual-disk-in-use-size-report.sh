#!/bin/bash

# updatedb
for disk in $(locate *.qcow2); do 
  qemu-img info "$disk" \
  |egrep 'image|format| size|compression'
  echo '====='
done
