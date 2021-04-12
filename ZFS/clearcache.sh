#!/bin/bash

# free up cache RAM
# http://linux-mm.org/Drop_Caches

free
time sync

echo 1 > /proc/sys/vm/drop_caches # free pagecache
free

#To free dentries and inodes:
[ "$*" = "2" ] && echo 2 > /proc/sys/vm/drop_caches

#To free pagecache, dentries and inodes:
[ "$*" = "3" ] && echo 3 > /proc/sys/vm/drop_caches
#echo 3 > /proc/sys/vm/drop_caches
