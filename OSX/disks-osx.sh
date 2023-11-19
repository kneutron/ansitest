#!/bin/bash

# NOTE osx does not seem to have a concept of wwn anywhere that I can find (smartctl, diskutil, dev/*)

DBI=/var/run/disk/by-id
DBP=/var/run/disk/by-path
DBS=/var/run/disk/by-serial

ls -l $DBI $DBP $DBS |egrep -v 'var/|s[0-9]|total' |column -t |sort -k 11 |awk '{ print $11" "$10" "$9 }'

diskutil list |grep -A 2 physical

exit;

# Sample output
/dev/disk0 -> PCI0@0-SATA@1F,2-PRT0@0-PMP@0-@0:0
/dev/disk0 -> ST3500418AS-5VMSTS
/dev/disk1 -> 004-2E4164-Z521TR
/dev/disk1 -> PCI0@0-RP03@1C,2-FRWR@0-node@30e0c84631304a-sbp-2@4008-@1:0
/dev/disk1 -> device-030ffffffe0ffffffc84631304a
/dev/disk2 -> PCI0@0-EHC1@1D,7-@4:0
/dev/disk2 -> Portable_SSD_T5-S49WNP0N12051
/dev/disk3 -> HDWR460UZSVB-13T0A01HF1
/dev/disk3 -> PCI0@0-RP03@1C,2-FRWR@0-node@30e0c84631304a-sbp-2@4008-@0:0
/dev/disk4 -> media-03EC333F-F868-4677-9B79-F1AC28924999
/dev/disk5 -> media-A30E1D81-CBD1-4228-B896-E5084F8A2D74
/dev/disk0 (internal, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *500.1 GB   disk0
--
/dev/disk1 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *2.0 TB     disk1
--
/dev/disk2 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *500.1 GB   disk2
--
/dev/disk3 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *6.0 TB     disk3
