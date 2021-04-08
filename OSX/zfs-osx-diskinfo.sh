#!/bin/bash

# REF: https://openzfsonosx.org/forum/viewtopic.php?f=26&t=3115

# NOTE Pass media- arg from 'zpool list -v' 
diskutil info  `ls -l  /var/run/disk/by-id | grep "$1" | awk -F" " '{print $11}' \
 | sed 's/s1//' \
 | sed 's|\/dev\/||'` \
 | egrep '(Device Identifier:)|(Whole:)|(Device / Media Name)|(Disk Size:)|(Device Block Size:)'

exit;

# ls -al /var/run/disk/by-id|grep -w /dev/disk.
lrwxr-xr-x   1 root  daemon    10 Mar 19 23:48 media-ACDA6BAE-722B-42B8-9B55-EC47162D959C -> /dev/disk3

# zfs-osx-diskinfo.sh media-ACDA6BAE-722B-42B8-9B55-EC47162D959C
   Device Identifier:        disk3
   Whole:                    Yes
   Part of Whole:            disk3
   Device / Media Name:      ST4000VN000-2AH166
   Disk Size:                61.9 GB (61865783296 Bytes) (exactly 120831608 512-Byte-Units)
   Device Block Size:        4096 Bytes
