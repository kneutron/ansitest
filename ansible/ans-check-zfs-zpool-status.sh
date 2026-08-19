#!/bin/bash

# 2026.Aug kneutron

# display timestamp w date, skip blank lines

cmd="zpool status -Tdv |awk 'NF>0'; echo ''; zpool status -x; echo '-------------------------------'"

ansible has_zfs -m shell -a "$cmd"
echo '========'
date;

#Wed Aug 19 03:14:02 PM MDT 2026
#-------------------------------

