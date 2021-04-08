#!/bin/bash

# REF: https://howchoo.com/g/mdc3mje5ngm/partition-hard-drive-macos

# Format names are of the form jhfs+, HFS+, MS-DOS, etc

# this is for new Sam 860 Pro internal replacement xxx 2021.0104
diskk=$1

diskutil list |less
echo "o About to partition /dev/$diskk - PK to commit or ^C"
read 

#diskutil partitionDisk /dev/disk2 GPT JHFS+ Partition1 10g JHFS+ Partition2 10g

diskutil partitionDisk /dev/$diskk GPT \
 APFS  osx-hs1013int 204g \
 MS-DOS %noformat% 2m \
 HFS+   sam512i-linux1 22g \
 HFS+   sam512i-linux2 22g \
 HFS+   sam512i-linuxswap 2g \
 HFS+   sam512i-linuxhome 22g \
 HFS+   zsam860pro-zfs R

# HFS+   sam512i-linuxhome 22g \
# JHFS+  sgtera4-enki  62g \
# HFS+   sgtera4-zfs R
 
# msdos is reserved for biosboot/grub
# click cccrestore in CCC to resize and create recovery hd - no need to leave free space
# lastpartn = zfs
# rt-click enki in Finder to encrypt - not in Disk Util

exit;

Started partitioning on disk3
Unmounting disk
Creating the partition map
Waiting for partitions to activate
Formatting disk3s2 as Mac OS Extended (Journaled) with name osx-hs1013int
Initialized /dev/rdisk3s2 as a 190 GB case-insensitive HFS Plus volume with a 16384k journal
Mounting disk
Formatting disk3s4 as Mac OS Extended with name sam512i-linux1
Initialized /dev/rdisk3s4 as a 20 GB case-insensitive HFS Plus volume
Mounting disk
Formatting disk3s5 as Mac OS Extended with name sam512i-linux2
Initialized /dev/rdisk3s5 as a 20 GB case-insensitive HFS Plus volume
Mounting disk
Formatting disk3s6 as Mac OS Extended with name sam512i-linuxswap
Initialized /dev/rdisk3s6 as a 2 GB case-insensitive HFS Plus volume
Mounting disk
Formatting disk3s7 as Mac OS Extended with name sam512i-linuxhome
Initialized /dev/rdisk3s7 as a 20 GB case-insensitive HFS Plus volume
Mounting disk
Formatting disk3s8 as Mac OS Extended with name zsam860pro-zfs
Initialized /dev/rdisk3s8 as a 223 GB case-insensitive HFS Plus volume
Mounting disk
Finished partitioning on disk3

/dev/disk3 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *512.1 GB   disk3
   1:                        EFI EFI                     209.7 MB   disk3s1
   2:                  Apple_HFS osx-hs1013int           203.9 GB   disk3s2
   3:       Microsoft Basic Data                         1.0 MB     disk3s3
   4:                  Apple_HFS sam512i-linux1          21.9 GB    disk3s4
   5:                  Apple_HFS sam512i-linux2          21.9 GB    disk3s5
   6:                  Apple_HFS sam512i-linuxswap       1.9 GB     disk3s6
   7:                  Apple_HFS sam512i-linuxhome       21.9 GB    disk3s7
   8:                  Apple_HFS zsam860pro-zfs          239.8 GB   disk3s8
 
