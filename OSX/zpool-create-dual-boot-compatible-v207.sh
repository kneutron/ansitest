#!/bin/bash

# create ZFS pool that should be cross-boot compatible with v.207 and import OK
# REF: https://openzfs.github.io/openzfs-docs/Basic%20Concepts/Feature%20Flags.html

# EDITME!
# REF: https://www.reddit.com/r/zfs/comments/b092at/cant_import_pool_from_zol_to_bsd/
# REF: https://zgrep.org/zfs.html  # OLD zfs by-OS compat. chart
# REF ' man zpool-features ' - large_blocks needed for recordsize=1024k

zp=zsamt72mp2
diskk=/dev/disk2s6 # sdc # Linux - use dev/disk/by-id

zpool create -f -d \
 -o feature@allocation_classes=enabled	\
 -o feature@async_destroy=enabled  \
 -o feature@bookmark_v2=enabled  \
 -o feature@bookmark_written=enabled  \
 -o feature@bookmarks=enabled  \
 -o feature@device_rebuild=enabled  \
 -o feature@device_removal=enabled  \
 -o feature@edonr=enabled  \
 -o feature@embedded_data=enabled  \
 -o feature@empty_bpobj=enabled  \
 -o feature@enabled_txg=enabled  \
 -o feature@encryption=enabled  \
 -o feature@extensible_dataset=enabled  \
 -o feature@filesystem_limits=enabled  \
 -o feature@hole_birth=enabled  \
 -o feature@large_blocks=enabled  \
 -o feature@large_dnode=enabled  \
 -o feature@livelist=enabled  \
 -o feature@log_spacemap=enabled  \
 -o feature@lz4_compress=enabled  \
 -o feature@multi_vdev_crash_dump=enabled  \
 -o feature@obsolete_counts=enabled  \
 -o feature@project_quota=enabled  \
 -o feature@redacted_datasets=enabled  \
 -o feature@redaction_bookmarks=enabled  \
 -o feature@resilver_defer=enabled  \
 -o feature@sha512=enabled  \
 -o feature@skein=enabled  \
 -o feature@spacemap_histogram=enabled  \
 -o feature@spacemap_v2=enabled  \
 -o feature@userobj_accounting=enabled  \
 -o feature@zpool_checkpoint=enabled  \
 -o feature@zstd_compress=enabled  \
 -o ashift=12 -o autoexpand=on -o autoreplace=off \
 -O atime=off -O compression=zstd-3 $zp "$diskk"
 
 zfs-newds-zstd.sh 11 $zp shrcompr-$zp
 zfs-newds-zstd.sh 10 $zp notshrcompr-$zp

gdf -hT
 
 exit;
 

# Created by pasting into spreadsheet, grabbing 2.0.7=yes and deleting the NOs
# TODO alt.method https://vermaden.wordpress.com/2022/03/25/zfs-compatibility/
