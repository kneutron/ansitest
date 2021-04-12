#!/bin/bash

# create ZFS pool that should be cross-boot compatible and import OK

# EDITME!
# REF: https://www.reddit.com/r/zfs/comments/b092at/cant_import_pool_from_zol_to_bsd/
# REF: https://zgrep.org/zfs.html  # zfs by-OS compat. chart
# REF ' man zpool-features ' - large_blocks needed for recordsize=1024k

zp=zmac320
diskk=/dev/disk0s8 # Linux - use dev/disk/by-id

zpool create -f -d \
 -o feature@async_destroy=enabled \
 -o feature@bookmarks=enabled \
 -o feature@embedded_data=enabled \
 -o feature@empty_bpobj=enabled \
 -o feature@enabled_txg=enabled \
 -o feature@spacemap_histogram=enabled \
 -o feature@filesystem_limits=enabled \
 -o feature@lz4_compress=enabled \
 -o feature@large_blocks=enabled \
 -o ashift=12 -o autoexpand=off \
 -O atime=off -O compression=lz4 $zp "$diskk"
 