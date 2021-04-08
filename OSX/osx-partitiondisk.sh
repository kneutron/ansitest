#!/bin/bash5

# REF: https://howchoo.com/g/mdc3mje5ngm/partition-hard-drive-macos

# Format names are of the form jhfs+, HFS+, MS-DOS, etc

diskutil list
echo "o About to partition disk2 - PK"
read 

#diskutil partitionDisk /dev/disk2 GPT JHFS+ Partition1 10g JHFS+ Partition2 10g

diskutil partitionDisk /dev/disk2 GPT \
 JHFS+  sgtera4-CCCRESTORE 320g \
 MS-DOS %noformat% 2m \
 HFS+   sgtera4-linux1 22g \
 HFS+   sgtera4-linux2 22g \
 HFS+   sgtera4-linux3 22g \
 HFS+   sgtera4-linuxswap 2g \
 HFS+   sgtera4-linuxhome 22g \
 JHFS+  sgtera4-enki  62g \
 HFS+   sgtera4-zfs R
 
# msdos is reserved for biosboot/grub
# click cccrestore in CCC to resize and create recovery hd - no need to leave free space
# lastpartn = zfs
# rt-click enki in Finder to encrypt - not in Disk Util

exit;

/dev/disk2 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *4.0 TB     disk2
   1:                        EFI EFI                     209.7 MB   disk2s1
   2:                  Apple_HFS sgtera4-CCCRESTORE      4.0 TB     disk2s2
   
Started partitioning on disk2
Unmounting disk
Creating the partition map
Waiting for partitions to activate
Formatting disk2s2 as Mac OS Extended (Journaled) with name sgtera4-CCCRESTORE
Initialized /dev/rdisk2s2 as a 298 GB case-insensitive HFS Plus volume with a 24576k journal
Mounting disk
Formatting disk2s4 as Mac OS Extended with name sgtera4-linux1
Initialized /dev/rdisk2s4 as a 20 GB case-insensitive HFS Plus volume
Mounting disk
Formatting disk2s5 as Mac OS Extended with name sgtera4-linux2
Initialized /dev/rdisk2s5 as a 20 GB case-insensitive HFS Plus volume
Mounting disk
Formatting disk2s6 as Mac OS Extended with name sgtera4-linux3
Initialized /dev/rdisk2s6 as a 20 GB case-insensitive HFS Plus volume
Mounting disk
Formatting disk2s7 as Mac OS Extended with name sgtera4-linuxswap
Initialized /dev/rdisk2s7 as a 2 GB case-insensitive HFS Plus volume
Mounting disk
Formatting disk2s8 as Mac OS Extended with name sgtera4-linux4
Initialized /dev/rdisk2s8 as a 20 GB case-insensitive HFS Plus volume
Mounting disk
Formatting disk2s9 as Mac OS Extended with name sgtera4-enki
Initialized /dev/rdisk2s9 as a 58 GB case-insensitive HFS Plus volume
Mounting disk
Formatting disk2s10 as Mac OS Extended with name sgtera4-recoveryhd
Initialized /dev/rdisk2s10 as a 649 MB case-insensitive HFS Plus volume
Mounting disk
Formatting disk2s11 as Mac OS Extended with name sgtera4-zfs
Initialized /dev/rdisk2s11 as a 3 TB case-insensitive HFS Plus volume
Mounting disk
Finished partitioning on disk2
/dev/disk2 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *4.0 TB     disk2
   1:                        EFI EFI                     209.7 MB   disk2s1
   2:                  Apple_HFS sgtera4-CCCRESTORE      319.9 GB   disk2s2
   3:       Microsoft Basic Data                         1.0 MB     disk2s3
   4:                  Apple_HFS sgtera4-linux1          21.9 GB    disk2s4
   5:                  Apple_HFS sgtera4-linux2          21.9 GB    disk2s5
   6:                  Apple_HFS sgtera4-linux3          21.9 GB    disk2s6
   7:                  Apple_HFS sgtera4-linuxswap       1.9 GB     disk2s7
   8:                  Apple_HFS sgtera4-linux4          21.9 GB    disk2s8
   9:                  Apple_HFS sgtera4-enki            61.9 GB    disk2s9
  10:                  Apple_HFS sgtera4-recoveryhd      680.0 MB   disk2s10
  11:                  Apple_HFS sgtera4-zfs             3.5 TB     disk2s11
 