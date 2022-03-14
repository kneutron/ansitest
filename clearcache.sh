#!/bin/bash

# free up cache RAM
# http://linux-mm.org/Drop_Caches

# uname -a
#Darwin davesimac-2.local 15.6.0 Darwin

[ `uname -a |grep -ci darwin` -gt 0 ] && exit 1;

sync

free
echo 1 > /proc/sys/vm/drop_caches # free pagecache

#To free dentries and inodes:
[ "$*" = "2" ] && echo 2 > /proc/sys/vm/drop_caches

#To free pagecache, dentries and inodes:
[ "$*" = "3" ] && echo 3 > /proc/sys/vm/drop_caches
#echo 3 > /proc/sys/vm/drop_caches

free
