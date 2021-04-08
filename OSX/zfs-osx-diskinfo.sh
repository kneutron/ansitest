#!/bin/bash

# REF: https://openzfsonosx.org/forum/viewtopic.php?f=26&t=3115

# Pass media- arg from 'zpool list -v' 
diskutil info  `ls -l  /var/run/disk/by-id | grep "$1" | awk -F" " '{print $11}' \
 | sed 's/s1//' \
 | sed 's|\/dev\/||'` \
 | egrep '(Device Identifier:)|(Whole:)|(Device / Media Name)|(Disk Size:)|(Device Block Size:)'
