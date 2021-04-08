#!/bin/bash

# Mod for osx 2019.0317
# runs from cron monthly


# will run after smart stage2 and list only attributes that Backblaze keeps track of

PATH=/sbin:/var/root/bin:/var/root/bin/boojum:/usr/local/bin:/usr/local/sbin:/usr/sbin:/bin:/usr/bin:/usr/X11R6/bin

outfile=~/smartlog-attrib-shortreport.log
mv -v $outfile $outfile--prev
touch $outfile
chmod 750 $outfile # -rwxr-x---

myhn=$(hostname)
echo "o START SMART disk attribute short report for: $myhn" >> $outfile

# adapted from rc.local
# ls disk by id, no partitions, only certain fields, get rid of '../'
#ls -l /dev/disk/by-id |grep -v part |awk '{ print $11" "$10" "$9 }' |sed 's%../%%g' |sort
# orig line:
#lrwxrwxrwx 1 root root  9 Feb 20 11:15 ata-ST4000VN000-1H4168_Z3076XVL -> ../../sdk
# Fields:                               9                               10 11
#  sda -> ata-WDC_WD30EURX-73T0FY0_WD-WMC4N0F2DKJA
#  sda -> wwn-0x50014ee605149030
#  sdb -> ata-ST2000VN000-1HJ164_W523LE2H
#  sdb -> wwn-0x5000c5009c42d511

DBS=/var/run/disk/by-serial

echo "o Disk translation table:" >> $outfile  
ls -l $DBS \
  | egrep -v 'disk.s.|^total' \
  | awk '{ print $11" "$10" "$9 }' \
  | sort \
  >> $outfile

for d in $(ls -l $DBS |egrep -v 'disk.s.|^total' |awk '{print $NF}'); do
  echo "o BEGIN smart attrib report for $d " >> $outfile

  echo "========================" >> $outfile

  smartctl -a $d |head -n 16 >> $outfile
  smartctl -a $d |egrep 'ID#|Power_On|Reallocated|Uncorrect|Timeout|Pending_Sector|Uncorrectable' >> $outfile
  smartctl -a $d |grep -A 2 'log structure' >> $outfile

#SMART Self-test log structure revision number 1
#Num  Test_Description    Status                  Remaining  LifeTime(hours)  LBA_of_first_error
# 1  Extended offline    Completed without error       00%      1973         -

  echo "========================" >> $outfile
#  echo "o END OF smart attrib report for $d " >> $outfile
    
done

echo "o FINISHED short smart attrib report for: $myhn @ $(date) " >> $outfile

exit;

# grep sdd /tmp/fdisk-l.txt |egrep 'ata|wwn' 
# ^^ is a cheat, and will not work right if any disks have been changed since boot / rc.local ran last
# so better we do it OTF
ata-ST4000VN000-1H4168_Z3073Z7X -> sdd
wwn-0x5000c500917978f5 -> sdd
              
SMART reports on 5 fields: REF: https://www.backblaze.com/blog/what-smart-stats-indicate-hard-drive-failures/
[[
For the last few years we’ve used the following five SMART stats as a means of helping determine if a drive is going to fail.
Attribute               Description
SMART 5                 Reallocated Sectors Count
SMART 187               Reported Uncorrectable Errors
SMART 188               Command Timeout
SMART 197               Current Pending Sector Count
SMART 198               Uncorrectable Sector Count
]]


=== START OF INFORMATION SECTION ===
Model Family:     SandForce Driven SSDs
Device Model:     KINGSTON SH103S
Serial Number:    50026B723A
LU WWN Device Id: 5 0026b7 23a07
Firmware Version: 507KC4
User Capacity:    120,034,123,776 bytes [120 GB]
Sector Size:      512 bytes logical/physical
Rotation Rate:    Solid State Device
Device is:        In smartctl database [for details use: -P show]
ATA Version is:   ATA8-ACS, ACS-2 T13/2015-D revision 3
SATA Version is:  SATA 3.0, 6.0 Gb/s (current: 3.0 Gb/s)
Local Time is:    Thu Feb 23 14:49:17 2017 CST

ubuntu14 seagate 4TB NAS:
ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
  1 Raw_Read_Error_Rate     0x000f   117   100   006    Pre-fail  Always       -       154799880
  3 Spin_Up_Time            0x0003   093   092   000    Pre-fail  Always       -       0
  4 Start_Stop_Count        0x0032   100   100   020    Old_age   Always       -       287
  5 Reallocated_Sector_Ct   0x0033   100   100   010    Pre-fail  Always       -       0
  7 Seek_Error_Rate         0x000f   066   060   030    Pre-fail  Always       -       4105125
  9 Power_On_Hours          0x0032   096   096   000    Old_age   Always       -       3560
 10 Spin_Retry_Count        0x0013   100   100   097    Pre-fail  Always       -       0
 12 Power_Cycle_Count       0x0032   100   100   020    Old_age   Always       -       14
184 End-to-End_Error        0x0032   100   100   099    Old_age   Always       -       0
187 Reported_Uncorrect      0x0032   100   100   000    Old_age   Always       -       0
188 Command_Timeout         0x0032   100   100   000    Old_age   Always       -       2
189 High_Fly_Writes         0x003a   100   100   000    Old_age   Always       -       0
190 Airflow_Temperature_Cel 0x0022   076   062   045    Old_age   Always       -       24 (Min/Max 22/34)
191 G-Sense_Error_Rate      0x0032   100   100   000    Old_age   Always       -       0
192 Power-Off_Retract_Count 0x0032   100   100   000    Old_age   Always       -       9
193 Load_Cycle_Count        0x0032   100   100   000    Old_age   Always       -       287
194 Temperature_Celsius     0x0022   024   040   000    Old_age   Always       -       24 (0 21 0 0 0)
197 Current_Pending_Sector  0x0012   100   100   000    Old_age   Always       -       0
198 Offline_Uncorrectable   0x0010   100   100   000    Old_age   Offline      -       0
199 UDMA_CRC_Error_Count    0x003e   200   197   000    Old_age   Always       -       423

antix (SSD):
ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
  1 Raw_Read_Error_Rate     0x000f   120   120   050    Pre-fail  Always       -       0/0
  5 Retired_Block_Count     0x0033   100   100   003    Pre-fail  Always       -       0
  9 Power_On_Hours_and_Msec 0x0032   098   098   000    Old_age   Always       -       2411h+06m+30.610s
 12 Power_Cycle_Count       0x0032   099   099   000    Old_age   Always       -       1052
171 Program_Fail_Count      0x0032   000   000   000    Old_age   Always       -       0
172 Erase_Fail_Count        0x0032   000   000   000    Old_age   Always       -       0
174 Unexpect_Power_Loss_Ct  0x0030   000   000   000    Old_age   Offline      -       56
177 Wear_Range_Delta        0x0000   000   000   000    Old_age   Offline      -       2
181 Program_Fail_Count      0x0032   000   000   000    Old_age   Always       -       0
182 Erase_Fail_Count        0x0032   000   000   000    Old_age   Always       -       0
187 Reported_Uncorrect      0x0032   100   100   000    Old_age   Always       -       0
189 Airflow_Temperature_Cel 0x0000   024   042   000    Old_age   Offline      -       24 (Min/Max 18/42)
194 Temperature_Celsius     0x0022   024   042   000    Old_age   Always       -       24 (Min/Max 18/42)
195 ECC_Uncorr_Error_Count  0x001c   100   100   000    Old_age   Offline      -       0/0
196 Reallocated_Event_Count 0x0033   100   100   003    Pre-fail  Always       -       0
201 Unc_Soft_Read_Err_Rate  0x001c   100   100   000    Old_age   Offline      -       0/0
204 Soft_ECC_Correct_Rate   0x001c   100   100   000    Old_age   Offline      -       0/0
230 Life_Curve_Status       0x0013   100   100   000    Pre-fail  Always       -       100
231 SSD_Life_Left           0x0013   100   100   010    Pre-fail  Always       -       0
233 SandForce_Internal      0x0000   000   000   000    Old_age   Offline      -       2087
234 SandForce_Internal      0x0032   000   000   000    Old_age   Always       -       1934
241 Lifetime_Writes_GiB     0x0032   000   000   000    Old_age   Always       -       1934
242 Lifetime_Reads_GiB      0x0032   000   000   000    Old_age   Always       -       2876
