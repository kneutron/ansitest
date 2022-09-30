#!/bin/bash

# OSX ZFS 1.9.4 / compatible with Linux 0.8.6 and up
# create ZFS pool that should be cross-boot compatible and import OK
# Original: Feb 2020
# Updated: Sep 2022
# REF: https://www.reddit.com/r/zfs/comments/b092at/cant_import_pool_from_zol_to_bsd/
# REF: https://openzfs.github.io/openzfs-docs/Basic%20Concepts/Feature%20Flags.html  # zfs by-OS compat. chart
# REF ' man zpool-features ' - large_blocks needed for recordsize=1024k

# TODO EDITME!
zp=zsam53
diskk=disk30s2 # Linux - use dev/disk/by-id

source ~/bin/failexit.mrg

zpool create -f -d \
-o feature@allocation_classes=enabled \
-o feature@async_destroy=enabled \
-o feature@bookmark_v2=enabled \
-o feature@bookmarks=enabled \
-o feature@device_removal=enabled \
-o feature@edonr=enabled \
-o feature@embedded_data=enabled \
-o feature@empty_bpobj=enabled \
-o feature@enabled_txg=enabled \
-o feature@encryption=enabled \
-o feature@extensible_dataset=enabled \
-o feature@filesystem_limits=enabled \
-o feature@hole_birth=enabled \
-o feature@large_blocks=enabled \
-o feature@large_dnode=enabled \
-o feature@lz4_compress=enabled \
-o feature@multi_vdev_crash_dump=enabled \
-o feature@obsolete_counts=enabled \
-o feature@resilver_defer=enabled \
-o feature@sha512=enabled \
-o feature@skein=enabled \
-o feature@spacemap_histogram=enabled \
-o feature@spacemap_v2=enabled \
-o feature@zpool_checkpoint=enabled \
 -o ashift=12 -o autoexpand=off \
 -O atime=off -O compression=lz4 \
  $zp \
  "$diskk" || failexit 101 "! Cant create zpool!"
 
zfs-newds.sh 11 $zp sharecompr-$zp
zfs-newds.sh 10 $zp notshrcompr-$zp

gdf -hT

exit;

# PROTIP
$ zpool get all zint500 |grep feature |awk '{print "-o " $2"=enabled \\" }' |sort

Original list:
 -o feature@async_destroy=enabled \
 -o feature@bookmarks=enabled \
 -o feature@embedded_data=enabled \
 -o feature@empty_bpobj=enabled \
 -o feature@enabled_txg=enabled \
 -o feature@spacemap_histogram=enabled \
 -o feature@filesystem_limits=enabled \
 -o feature@lz4_compress=enabled \
 -o feature@large_blocks=enabled \
