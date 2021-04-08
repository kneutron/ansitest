#!/bin/bash

# mod for osx - NOTE no wwn's here

# NOTE - other scripts rely on this output!
# put dev-disk-by-id into assoc array > comma-sep file

outf=/tmp/dbi-commasep--boojum.csv

DBI=/var/run/disk/by-id
DBP=/var/run/disk/by-path
DBS=/var/run/disk/by-serial

# |sed -e 's^../../^/dev/^g' \
# s[0-9] = leave out slices/partns
/bin/ls -l $DBI $DBP $DBS \
 |egrep -v 'var/|s[0-9]|total ' \
 |awk 'NF>0' \
 |awk '{ print $11","$9 }' \
 |sort \
 > $outf

exit;

OSX:

 /var/run/disk $ ls -l $DBI $DBP |egrep -v 'var/|part|wwn|total'
lrwxr-xr-x  1 root  daemon  10 Apr 18 19:31 PCI0-RP04@1C,3-FRWR@0-node@30e0c430385436-sbp-2@4008-@0:0 -> /dev/disk7
1	          2 3     4       5  6   7  8     9							                                                  10 11

# NOTE FIELD 9 HAS COMMAS!!!!
/var/run/disk $ ls -l $DBI $DBP |egrep -v 'var/|s[0-9]|wwn|total' |column -t
lrwxr-xr-x  1  root  daemon  10  Apr  14  22:26  PCI0-EHC1@1D,7-@3:0                                        ->  /dev/disk1
lrwxr-xr-x  1  root  daemon  10  Apr  18  19:31  PCI0-RP04@1C,3-FRWR@0-node@30e0c430385436-sbp-2@4008-@0:0  ->  /dev/disk7
lrwxr-xr-x  1  root  daemon  10  Apr  18  19:31  PCI0-RP04@1C,3-FRWR@0-node@30e0c430385436-sbp-2@4008-@1:0  ->  /dev/disk3
lrwxr-xr-x  1  root  daemon  10  Apr  18  19:25  PCI0-RP04@1C,3-FRWR@0-node@5500000065-sbp-2@4008-@0:0      ->  /dev/disk2
lrwxr-xr-x  1  root  daemon  10  Apr  14  22:26  PCI0-SATA@1F,2-PRT0@0-PMP@0-@0:0                           ->  /dev/disk0
lrwxr-xr-x  1  root  daemon  10  Apr  14  22:26  PCI0-EHC1@1D,7-@3:0                                        ->  /dev/disk1
lrwxr-xr-x  1  root  daemon  10  Apr  18  19:31  PCI0-RP04@1C,3-FRWR@0-node@30e0c430385436-sbp-2@4008-@0:0  ->  /dev/disk7
lrwxr-xr-x  1  root  daemon  10  Apr  18  19:31  PCI0-RP04@1C,3-FRWR@0-node@30e0c430385436-sbp-2@4008-@1:0  ->  /dev/disk3
lrwxr-xr-x  1  root  daemon  10  Apr  18  19:25  PCI0-RP04@1C,3-FRWR@0-node@5500000065-sbp-2@4008-@0:0      ->  /dev/disk2
lrwxr-xr-x  1  root  daemon  10  Apr  14  22:26  PCI0-SATA@1F,2-PRT0@0-PMP@0-@0:0                           ->  /dev/disk0

$ ls -l $DBI $DBP $DBS |egrep -v 'var/|s[0-9]|wwn|total' |column -t |sort -k 11
lrwxr-xr-x  1  root  daemon  10  Apr  14  22:26  Hitachi_HDT721032SLA380-STA208MT3JA1EW                     ->  /dev/disk0
lrwxr-xr-x  1  root  daemon  10  Apr  14  22:26  PCI0-SATA@1F,2-PRT0@0-PMP@0-@0:0                           ->  /dev/disk0
lrwxr-xr-x  1  root  daemon  10  Apr  14  22:26  PCI0-EHC1@1D,7-@3:0                                        ->  /dev/disk1
lrwxr-xr-x  1  root  daemon  10  Apr  14  22:26  Portable_SSD_T5-S3UJNP0K70.                                ->  /dev/disk1
lrwxr-xr-x  1  root  daemon  10  Apr  18  19:25  000-1HJ164-W523LE2H                                        ->  /dev/disk2
lrwxr-xr-x  1  root  daemon  10  Apr  18  19:25  PCI0-RP04@1C,3-FRWR@0-node@5500000065-sbp-2@4008-@0:0      ->  /dev/disk2
lrwxr-xr-x  1  root  daemon  10  Apr  18  19:31  EFRX-68FYTN0-WD-WCC4J2HE.                                  ->  /dev/disk3
lrwxr-xr-x  1  root  daemon  10  Apr  18  19:31  PCI0-RP04@1C,3-FRWR@0-node@30e0c430385436-sbp-2@4008-@1:0  ->  /dev/disk3
lrwxr-xr-x  1  root  daemon  10  Apr  15  13:25  media-280E431F-DC1B-4AC2-81BF-2207DEF2CB8B                 ->  /dev/disk5
lrwxr-xr-x  1  root  daemon  10  Apr  15  13:25  volume-3F432B2A-FBF0-3AB9-BE71-1D51409D467A                ->  /dev/disk5
lrwxr-xr-x  1  root  daemon  10  Apr  18  19:31  EFRX-68FYTN0-WD-WCC4J4KD                                   ->  /dev/disk7
lrwxr-xr-x  1  root  daemon  10  Apr  18  19:31  PCI0-RP04@1C,3-FRWR@0-node@30e0c430385436-sbp-2@4008-@0:0  ->  /dev/disk7


(LINUX)

ls -l $DBI|egrep -v 'part|wwn'
total 0
lrwxrwxrwx 1 root root  9 Aug  5 07:32 ata-HL-DT-ST_BD-RE_BH16NS40_K9JD27D5727 -> ../../sr1
lrwxrwxrwx 1 root root  9 Aug  5 07:32 ata-Optiarc_DVD_RW_AD-7240S -> ../../sr0
lrwxrwxrwx 1 root root  9 Aug  5 12:32 ata-ST3000VN007-2E4166_Z6A0GXZW -> ../../sde
lrwxrwxrwx 1 root root  9 Aug  5 12:32 ata-WDC_WD1002FAEX-00Y9A0_WD-WCAW3580 -> ../../sdb
lrwxrwxrwx 1 root root  9 Aug  5 12:32 ata-WDC_WD2003FZEX-00SRLA0_WD-WMC6N0D2 -> ../../sdd
lrwxrwxrwx 1 root root  9 Aug  5 12:32 ata-WDC_WD20EFRX-68EUZN0_WD-WCC4M1JD -> ../../sdf
lrwxrwxrwx 1 root root  9 Aug  5 12:32 ata-WDC_WD20EFRX-68EUZN0_WD-WCC4MCYP -> ../../sda
lrwxrwxrwx 1 root root  9 Aug  5 12:32 ata-WDC_WD30EURX-73T0FY0_WD-WMC4N0F2 -> ../../sdc

ata-HL-DT-ST_BD-RE_BH16NS40_K9JD27D,/dev/sr1
ata-Optiarc_DVD_RW_AD-7240S,/dev/sr0
ata-ST3000VN007-2E4166_Z6A0GXZW,/dev/sde
ata-WDC_WD1002FAEX-00Y9A0_WD-WCAW3580,/dev/sdb
ata-WDC_WD2003FZEX-00SRLA0_WD-WMC6N0D2,/dev/sdd
ata-WDC_WD20EFRX-68EUZN0_WD-WCC4M1JD,/dev/sdf
ata-WDC_WD20EFRX-68EUZN0_WD-WCC4MCYP,/dev/sda
ata-WDC_WD30EURX-73T0FY0_WD-WMC4N0F2,/dev/sdc

fry - expected output:
 ls -l /dev/disk/by-id /dev/disk/by-path \
  |egrep -v 'dev/|part|wwn|total ' \
  |awk 'NF>0' \
  |awk '{ print $11","$9 }' \
  |sed -e 's^../../^/dev/^g'

/dev/sda,ata-ST4000VN008-2DR166_ZGY005C6
/dev/sda,pci-0000:01:00.0-sas-0x4433221100000000-lun-0
/dev/sdb,ata-ST4000VN000-2AH166_WDH0SB5N
/dev/sdb,pci-0000:01:00.0-sas-0x4433221103000000-lun-0
/dev/sdc,ata-ST4000VN000-1H4168_Z3076XVL
/dev/sdc,pci-0000:01:00.0-sas-0x4433221101000000-lun-0
/dev/sdd,ata-ST4000VN000-1H4168_Z3073Z7X
/dev/sdd,pci-0000:01:00.0-sas-0x4433221102000000-lun-0
/dev/sde,ata-ST9500420AS_5VJ5FDYE
/dev/sde,pci-0000:02:00.0-sas-0x4433221101000000-lun-0
/dev/sdf,ata-ST1000LM024_HN-M101MBB_S2RQJ9CCQ
/dev/sdf,pci-0000:02:00.0-sas-0x4433221103000000-lun-0
/dev/sdg,pci-0000:00:14.0-usb-0:1:1.0-scsi-0:0:0:0
/dev/sdg,usb-SanDisk_Ultra_Fit_4C530001171117106334-0:0
/dev/sdh,ata-ST2000VN000-1HJ164_W523GA5J
/dev/sdi,ata-ST2000VN000-1HJ164_W5238TSL
/dev/sdj,ata-ST2000VN004-2E4164_Z521TRH4
/dev/sdk,ata-ST2000VN000-1HJ164_W7212LTE
/dev/sdl,ata-ST2000VN000-1HJ164_W72127JB
/dev/sdm,ata-ST2000VN000-1HJ164_Z520DLXJ
/dev/sr0,ata-HL-DT-ST_DVDRAM_GH24NSB0_K2EG1QE3246
