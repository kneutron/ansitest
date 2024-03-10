#!/bin/bash

# 2024.Feb kneutron
# REF: https://www.reddit.com/r/Proxmox/comments/1auxnpd/io_error_zfs_pool_full_do_i_need_to_buy_new_disks/

# When your zpool has filled up and you need emergency temporary free space to start deleting things (like snapshots)

zfspath=/sys/module/zfs/parameters/spa_slop_shift

if [ "$1" = "putitback" ]; then
  echo 5 > $zfspath
  cat $zfspath
  zpool list
  exit 0;
fi

# only if it doesnt already exist - REF
[ -e /tmp/zfs-slop-shift-orig.txt ] || cat $zfspath >/tmp/zfs-slop-shift-orig.txt

zpool list
echo "$0 - Adjusting for temporary free space"
echo 8 > $zfspath
echo "====="
echo "After adjustment:"
zpool list

echo "This should have freed up a bunch of bonus free space on your pool
BUT you need to put it back when you're done or reboot!"

# This should allow you to delete files/snapshots.

# Be sure to switch spa_slop_shift back to its default of 5 afterwards (this
# tunable prevents you from filling up the zpool completely, which can cause
# it to be come permanently readonly).
