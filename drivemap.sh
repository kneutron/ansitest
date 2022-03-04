#!/bin/bash

# for linux; tested with a 104-disk VM (SATA + SAS)
# Author: dave.bechtel kingneutron@gmail.com
# Builds a searchable disk "translation table"
# Useful for finding the short name of your disk (or serial number) in a ZFS pool
# NOTE should be re-run if a disk is physically replaced because the descriptive name may change

outf=/tmp/drivemap.txt

# Replace ../.. with /dev and reverse columns so shortdev is 1st
# Use 'sort -k 3' if $9 $10 $11
ls -lR /dev/disk |grep -w /sd[a-z] |sed 's^../..^/dev^' |awk 'NF>0 {print $11" "$10" "$9}' |column -t |sort \
 >$outf
 
echo '========' >> $outf

ls -lR /dev/disk |grep -w /sd[a-z][a-z] |sed 's^../..^/dev^' |awk 'NF>0 {print $11" "$10" "$9}' |column -t |sort \
 >>$outf

#less $outf

# To search outfile:
# grep ata-VBOX_HARDDISK_VB0fffe26a-25e5ad55 /tmp/drivemap.txt

exit;

#1         2 3    4       5 6   7  8     $9                                    $10 $11
$ ls -al /dev/disk/by-id /dev/disk/by-path |grep -w sda
lrwxrwxrwx 1 root root    9 Jan 26 20:04 ata-VBOX_HARDDISK_VB0fffe26a-25e5ad55 -> ../../sda
lrwxrwxrwx 1 root root    9 Jan 26 20:04 scsi-0ATA_VBOX_HARDDISK_VB0fffe26a-25e5ad55 -> ../../sda
lrwxrwxrwx 1 root root    9 Jan 26 20:04 scsi-1ATA_VBOX_HARDDISK_VB0fffe26a-25e5ad55 -> ../../sda
lrwxrwxrwx 1 root root    9 Jan 26 20:04 scsi-SATA_VBOX_HARDDISK_VB0fffe26a-25e5ad55 -> ../../sda

$ ls -al /dev/disk/by-id /dev/disk/by-path |grep -w sdab
lrwxrwxrwx 1 root root   10 Jan 26 20:04 pci-0000:00:16.0-sas-phy26-lun-0 -> ../../sdab


Example output: (sda is not a typo, it can be addressed 4 different ways)

/dev/sda  ->  ata-VBOX_HARDDISK_VB0fffe26a-25e5ad55
/dev/sda  ->  scsi-0ATA_VBOX_HARDDISK_VB0fffe26a-25e5ad55
/dev/sda  ->  scsi-1ATA_VBOX_HARDDISK_VB0fffe26a-25e5ad55
/dev/sda  ->  scsi-SATA_VBOX_HARDDISK_VB0fffe26a-25e5ad55
/dev/sdb  ->  pci-0000:00:16.0-sas-phy0-lun-0
/dev/sdc  ->  pci-0000:00:16.0-sas-phy1-lun-0
/dev/sdd  ->  pci-0000:00:16.0-sas-phy2-lun-0
/dev/sde  ->  pci-0000:00:16.0-sas-phy3-lun-0
/dev/sdf  ->  pci-0000:00:16.0-sas-phy4-lun-0
/dev/sdg  ->  pci-0000:00:16.0-sas-phy5-lun-0
/dev/sdh  ->  pci-0000:00:16.0-sas-phy6-lun-0
/dev/sdi  ->  pci-0000:00:16.0-sas-phy7-lun-0
/dev/sdj  ->  pci-0000:00:16.0-sas-phy8-lun-0
/dev/sdk  ->  pci-0000:00:16.0-sas-phy9-lun-0
/dev/sdl  ->  pci-0000:00:16.0-sas-phy10-lun-0
/dev/sdm  ->  pci-0000:00:16.0-sas-phy11-lun-0
/dev/sdn  ->  pci-0000:00:16.0-sas-phy12-lun-0
/dev/sdo  ->  pci-0000:00:16.0-sas-phy13-lun-0
/dev/sdp  ->  pci-0000:00:16.0-sas-phy14-lun-0
/dev/sdq  ->  pci-0000:00:16.0-sas-phy15-lun-0
/dev/sdr  ->  pci-0000:00:16.0-sas-phy16-lun-0
/dev/sds  ->  pci-0000:00:16.0-sas-phy17-lun-0
/dev/sdt  ->  pci-0000:00:16.0-sas-phy18-lun-0
/dev/sdu  ->  pci-0000:00:16.0-sas-phy19-lun-0
/dev/sdv  ->  pci-0000:00:16.0-sas-phy20-lun-0
/dev/sdw  ->  pci-0000:00:16.0-sas-phy21-lun-0
/dev/sdx  ->  pci-0000:00:16.0-sas-phy22-lun-0
/dev/sdy  ->  pci-0000:00:16.0-sas-phy23-lun-0
/dev/sdz  ->  pci-0000:00:16.0-sas-phy24-lun-0
========
/dev/sdaa  ->  pci-0000:00:16.0-sas-phy25-lun-0
/dev/sdab  ->  pci-0000:00:16.0-sas-phy26-lun-0
/dev/sdac  ->  pci-0000:00:16.0-sas-phy27-lun-0
/dev/sdad  ->  pci-0000:00:16.0-sas-phy28-lun-0
/dev/sdae  ->  pci-0000:00:16.0-sas-phy29-lun-0
/dev/sdaf  ->  pci-0000:00:16.0-sas-phy30-lun-0
/dev/sdag  ->  pci-0000:00:16.0-sas-phy31-lun-0
/dev/sdah  ->  pci-0000:00:16.0-sas-phy32-lun-0
/dev/sdai  ->  pci-0000:00:16.0-sas-phy33-lun-0
/dev/sdaj  ->  pci-0000:00:16.0-sas-phy34-lun-0
/dev/sdak  ->  pci-0000:00:16.0-sas-phy35-lun-0
/dev/sdal  ->  pci-0000:00:16.0-sas-phy36-lun-0
/dev/sdam  ->  pci-0000:00:16.0-sas-phy37-lun-0
/dev/sdan  ->  pci-0000:00:16.0-sas-phy38-lun-0
/dev/sdao  ->  pci-0000:00:16.0-sas-phy39-lun-0
/dev/sdap  ->  pci-0000:00:16.0-sas-phy40-lun-0
/dev/sdaq  ->  pci-0000:00:16.0-sas-phy41-lun-0
/dev/sdar  ->  pci-0000:00:16.0-sas-phy42-lun-0
/dev/sdas  ->  pci-0000:00:16.0-sas-phy43-lun-0
/dev/sdat  ->  pci-0000:00:16.0-sas-phy44-lun-0
/dev/sdau  ->  pci-0000:00:16.0-sas-phy45-lun-0
/dev/sdav  ->  pci-0000:00:16.0-sas-phy46-lun-0
/dev/sdaw  ->  pci-0000:00:16.0-sas-phy47-lun-0
/dev/sdax  ->  pci-0000:00:16.0-sas-phy48-lun-0
/dev/sday  ->  pci-0000:00:16.0-sas-phy49-lun-0
/dev/sdaz  ->  pci-0000:00:16.0-sas-phy50-lun-0
/dev/sdba  ->  pci-0000:00:16.0-sas-phy51-lun-0
/dev/sdbb  ->  pci-0000:00:16.0-sas-phy52-lun-0
/dev/sdbc  ->  pci-0000:00:16.0-sas-phy53-lun-0
/dev/sdbd  ->  pci-0000:00:16.0-sas-phy54-lun-0
/dev/sdbe  ->  pci-0000:00:16.0-sas-phy55-lun-0
/dev/sdbf  ->  pci-0000:00:16.0-sas-phy56-lun-0
/dev/sdbg  ->  pci-0000:00:16.0-sas-phy57-lun-0
/dev/sdbh  ->  pci-0000:00:16.0-sas-phy58-lun-0
/dev/sdbi  ->  pci-0000:00:16.0-sas-phy59-lun-0
/dev/sdbj  ->  pci-0000:00:16.0-sas-phy60-lun-0
/dev/sdbk  ->  pci-0000:00:16.0-sas-phy61-lun-0
/dev/sdbl  ->  pci-0000:00:16.0-sas-phy62-lun-0
/dev/sdbm  ->  pci-0000:00:16.0-sas-phy63-lun-0
/dev/sdbn  ->  pci-0000:00:16.0-sas-phy64-lun-0
/dev/sdbo  ->  pci-0000:00:16.0-sas-phy65-lun-0
/dev/sdbp  ->  pci-0000:00:16.0-sas-phy66-lun-0
/dev/sdbq  ->  pci-0000:00:16.0-sas-phy67-lun-0
/dev/sdbr  ->  pci-0000:00:16.0-sas-phy68-lun-0
/dev/sdbs  ->  pci-0000:00:16.0-sas-phy69-lun-0
/dev/sdbt  ->  pci-0000:00:16.0-sas-phy70-lun-0
/dev/sdbu  ->  pci-0000:00:16.0-sas-phy71-lun-0
/dev/sdbv  ->  pci-0000:00:16.0-sas-phy72-lun-0
/dev/sdbw  ->  pci-0000:00:16.0-sas-phy73-lun-0
/dev/sdbx  ->  pci-0000:00:16.0-sas-phy74-lun-0
/dev/sdby  ->  pci-0000:00:16.0-sas-phy75-lun-0
/dev/sdbz  ->  pci-0000:00:16.0-sas-phy76-lun-0
/dev/sdca  ->  pci-0000:00:16.0-sas-phy77-lun-0
/dev/sdcb  ->  pci-0000:00:16.0-sas-phy78-lun-0
/dev/sdcc  ->  pci-0000:00:16.0-sas-phy79-lun-0
/dev/sdcd  ->  ata-VBOX_HARDDISK_VB7c106e2c-6f1ebfbf
/dev/sdcd  ->  scsi-0ATA_VBOX_HARDDISK_VB7c106e2c-6f1ebfbf
/dev/sdcd  ->  scsi-1ATA_VBOX_HARDDISK_VB7c106e2c-6f1ebfbf
/dev/sdcd  ->  scsi-SATA_VBOX_HARDDISK_VB7c106e2c-6f1ebfbf
/dev/sdce  ->  ata-VBOX_HARDDISK_VBd7f1bb8e-d22e8c8c
/dev/sdce  ->  scsi-0ATA_VBOX_HARDDISK_VBd7f1bb8e-d22e8c8c
/dev/sdce  ->  scsi-1ATA_VBOX_HARDDISK_VBd7f1bb8e-d22e8c8c
/dev/sdce  ->  scsi-SATA_VBOX_HARDDISK_VBd7f1bb8e-d22e8c8c
/dev/sdcf  ->  ata-VBOX_HARDDISK_VB882c653e-c5bcc371
/dev/sdcf  ->  scsi-0ATA_VBOX_HARDDISK_VB882c653e-c5bcc371
/dev/sdcf  ->  scsi-1ATA_VBOX_HARDDISK_VB882c653e-c5bcc371
/dev/sdcf  ->  scsi-SATA_VBOX_HARDDISK_VB882c653e-c5bcc371
/dev/sdcg  ->  ata-VBOX_HARDDISK_VB1592b5f3-53ad43a7
/dev/sdcg  ->  scsi-0ATA_VBOX_HARDDISK_VB1592b5f3-53ad43a7
/dev/sdcg  ->  scsi-1ATA_VBOX_HARDDISK_VB1592b5f3-53ad43a7
/dev/sdcg  ->  scsi-SATA_VBOX_HARDDISK_VB1592b5f3-53ad43a7
/dev/sdch  ->  ata-VBOX_HARDDISK_VB2bf3ef90-ecf2977e
/dev/sdch  ->  scsi-0ATA_VBOX_HARDDISK_VB2bf3ef90-ecf2977e
/dev/sdch  ->  scsi-1ATA_VBOX_HARDDISK_VB2bf3ef90-ecf2977e
/dev/sdch  ->  scsi-SATA_VBOX_HARDDISK_VB2bf3ef90-ecf2977e
/dev/sdci  ->  ata-VBOX_HARDDISK_VBbec4f4ac-0132a385
/dev/sdci  ->  scsi-0ATA_VBOX_HARDDISK_VBbec4f4ac-0132a385
/dev/sdci  ->  scsi-1ATA_VBOX_HARDDISK_VBbec4f4ac-0132a385
/dev/sdci  ->  scsi-SATA_VBOX_HARDDISK_VBbec4f4ac-0132a385
/dev/sdcj  ->  ata-VBOX_HARDDISK_VBb5646a7b-0954ef57
/dev/sdcj  ->  scsi-0ATA_VBOX_HARDDISK_VBb5646a7b-0954ef57
/dev/sdcj  ->  scsi-1ATA_VBOX_HARDDISK_VBb5646a7b-0954ef57
/dev/sdcj  ->  scsi-SATA_VBOX_HARDDISK_VBb5646a7b-0954ef57
/dev/sdck  ->  ata-VBOX_HARDDISK_VB441b5ccb-d12ee119
/dev/sdck  ->  scsi-0ATA_VBOX_HARDDISK_VB441b5ccb-d12ee119
/dev/sdck  ->  scsi-1ATA_VBOX_HARDDISK_VB441b5ccb-d12ee119
/dev/sdck  ->  scsi-SATA_VBOX_HARDDISK_VB441b5ccb-d12ee119
/dev/sdcl  ->  ata-VBOX_HARDDISK_VBeeb81791-8fedcbbb
/dev/sdcl  ->  scsi-0ATA_VBOX_HARDDISK_VBeeb81791-8fedcbbb
/dev/sdcl  ->  scsi-1ATA_VBOX_HARDDISK_VBeeb81791-8fedcbbb
/dev/sdcl  ->  scsi-SATA_VBOX_HARDDISK_VBeeb81791-8fedcbbb
/dev/sdcm  ->  ata-VBOX_HARDDISK_VBb1985871-b6a5fb94
/dev/sdcm  ->  scsi-0ATA_VBOX_HARDDISK_VBb1985871-b6a5fb94
/dev/sdcm  ->  scsi-1ATA_VBOX_HARDDISK_VBb1985871-b6a5fb94
/dev/sdcm  ->  scsi-SATA_VBOX_HARDDISK_VBb1985871-b6a5fb94
/dev/sdcn  ->  ata-VBOX_HARDDISK_VB22ebe1ec-5369661c
/dev/sdcn  ->  scsi-0ATA_VBOX_HARDDISK_VB22ebe1ec-5369661c
/dev/sdcn  ->  scsi-1ATA_VBOX_HARDDISK_VB22ebe1ec-5369661c
/dev/sdcn  ->  scsi-SATA_VBOX_HARDDISK_VB22ebe1ec-5369661c
/dev/sdco  ->  ata-VBOX_HARDDISK_VBdc670002-8ec73b3d
/dev/sdco  ->  scsi-0ATA_VBOX_HARDDISK_VBdc670002-8ec73b3d
/dev/sdco  ->  scsi-1ATA_VBOX_HARDDISK_VBdc670002-8ec73b3d
/dev/sdco  ->  scsi-SATA_VBOX_HARDDISK_VBdc670002-8ec73b3d
/dev/sdcp  ->  ata-VBOX_HARDDISK_VB49422d74-cd74822b
/dev/sdcp  ->  scsi-0ATA_VBOX_HARDDISK_VB49422d74-cd74822b
/dev/sdcp  ->  scsi-1ATA_VBOX_HARDDISK_VB49422d74-cd74822b
/dev/sdcp  ->  scsi-SATA_VBOX_HARDDISK_VB49422d74-cd74822b
/dev/sdcq  ->  ata-VBOX_HARDDISK_VBd062a8b6-4c545fc6
/dev/sdcq  ->  scsi-0ATA_VBOX_HARDDISK_VBd062a8b6-4c545fc6
/dev/sdcq  ->  scsi-1ATA_VBOX_HARDDISK_VBd062a8b6-4c545fc6
/dev/sdcq  ->  scsi-SATA_VBOX_HARDDISK_VBd062a8b6-4c545fc6
/dev/sdcr  ->  ata-VBOX_HARDDISK_VB99f8848c-fef7709a
/dev/sdcr  ->  scsi-0ATA_VBOX_HARDDISK_VB99f8848c-fef7709a
/dev/sdcr  ->  scsi-1ATA_VBOX_HARDDISK_VB99f8848c-fef7709a
/dev/sdcr  ->  scsi-SATA_VBOX_HARDDISK_VB99f8848c-fef7709a
/dev/sdcs  ->  ata-VBOX_HARDDISK_VBeb60609c-1eda5172
/dev/sdcs  ->  scsi-0ATA_VBOX_HARDDISK_VBeb60609c-1eda5172
/dev/sdcs  ->  scsi-1ATA_VBOX_HARDDISK_VBeb60609c-1eda5172
/dev/sdcs  ->  scsi-SATA_VBOX_HARDDISK_VBeb60609c-1eda5172
/dev/sdct  ->  ata-VBOX_HARDDISK_VBca083d5c-c7b498eb
/dev/sdct  ->  scsi-0ATA_VBOX_HARDDISK_VBca083d5c-c7b498eb
/dev/sdct  ->  scsi-1ATA_VBOX_HARDDISK_VBca083d5c-c7b498eb
/dev/sdct  ->  scsi-SATA_VBOX_HARDDISK_VBca083d5c-c7b498eb
/dev/sdcu  ->  ata-VBOX_HARDDISK_VB96afaef5-9bdf8920
/dev/sdcu  ->  scsi-0ATA_VBOX_HARDDISK_VB96afaef5-9bdf8920
/dev/sdcu  ->  scsi-1ATA_VBOX_HARDDISK_VB96afaef5-9bdf8920
/dev/sdcu  ->  scsi-SATA_VBOX_HARDDISK_VB96afaef5-9bdf8920
/dev/sdcv  ->  ata-VBOX_HARDDISK_VB72fbebcd-30bf5803
/dev/sdcv  ->  scsi-0ATA_VBOX_HARDDISK_VB72fbebcd-30bf5803
/dev/sdcv  ->  scsi-1ATA_VBOX_HARDDISK_VB72fbebcd-30bf5803
/dev/sdcv  ->  scsi-SATA_VBOX_HARDDISK_VB72fbebcd-30bf5803
/dev/sdcw  ->  ata-VBOX_HARDDISK_VB57124aad-08886b93
/dev/sdcw  ->  scsi-0ATA_VBOX_HARDDISK_VB57124aad-08886b93
/dev/sdcw  ->  scsi-1ATA_VBOX_HARDDISK_VB57124aad-08886b93
/dev/sdcw  ->  scsi-SATA_VBOX_HARDDISK_VB57124aad-08886b93
/dev/sdcx  ->  ata-VBOX_HARDDISK_VBa2ce3c9e-3e92f93a
/dev/sdcx  ->  scsi-0ATA_VBOX_HARDDISK_VBa2ce3c9e-3e92f93a
/dev/sdcx  ->  scsi-1ATA_VBOX_HARDDISK_VBa2ce3c9e-3e92f93a
/dev/sdcx  ->  scsi-SATA_VBOX_HARDDISK_VBa2ce3c9e-3e92f93a
/dev/sdcy  ->  ata-VBOX_HARDDISK_VBb9f369c6-999a56d3
/dev/sdcy  ->  scsi-0ATA_VBOX_HARDDISK_VBb9f369c6-999a56d3
/dev/sdcy  ->  scsi-1ATA_VBOX_HARDDISK_VBb9f369c6-999a56d3
/dev/sdcy  ->  scsi-SATA_VBOX_HARDDISK_VBb9f369c6-999a56d3
/dev/sdcz  ->  ata-VBOX_HARDDISK_VB144d530e-70b6d420
/dev/sdcz  ->  scsi-0ATA_VBOX_HARDDISK_VB144d530e-70b6d420
/dev/sdcz  ->  scsi-1ATA_VBOX_HARDDISK_VB144d530e-70b6d420
/dev/sdcz  ->  scsi-SATA_VBOX_HARDDISK_VB144d530e-70b6d420
/dev/sdda  ->  ata-VBOX_HARDDISK_VB105427d5-303f04a5
/dev/sdda  ->  scsi-0ATA_VBOX_HARDDISK_VB105427d5-303f04a5
/dev/sdda  ->  scsi-1ATA_VBOX_HARDDISK_VB105427d5-303f04a5
/dev/sdda  ->  scsi-SATA_VBOX_HARDDISK_VB105427d5-303f04a5
