#!/bin/bash

# 2020.0620
# ADAPTED FROM # zpool-resizeup-mirror--no-degradation--raid10.sh

# NOTE - SCRUB 1st!!

source ~/bin/boojum/wait4resilver.mrg
source ~/bin/failexit.mrg

zp=zseatera4

disk1=ata-ST4000VN000-2AH166_WDH0SB5N
disk2=ata-ST4000VN000-1H4168_Z3076XVL

disk3=ata-HGST_HUS726060ALE614_K8HU3M7N # sdh
disk4=ata-HGST_HUS726060ALE614_K8HUH6YN # sdf

zpool set autoexpand=on $zp

# speed up resilver I/O for zfs 0.8.x
#echo 0 > /sys/module/zfs/parameters/zfs_resilver_delay
echo 8000 > /sys/module/zfs/parameters/zfs_resilver_min_time_ms
# original value: 3000

echo "o Attach disk1=disk3 - $(date)"
time zpool attach $zp $disk1 $disk3 || failexit 103 "zpool attach disk1=disk3 $disk1 = $disk3 failed `date`"
waitforresilver $zp

echo "o Attach disk2=disk4 - $(date)"
time zpool attach $zp $disk2 $disk4 || failexit 104 "zpool attach disk2=disk4 $disk2 = $disk4 failed `date`"
waitforresilver $zp

zpool status -v
df -hT

echo "`date` - PK to detach smaller mirror disks and increase pool size"
read -n 1

time zpool detach $zp $disk1
time zpool detach $zp $disk2

zpool status -v
df -hT

exit;

GIVEN @ START:
( zfs list )
NAME        USED  AVAIL     REFER  MOUNTPOINT
zseatera4  5.60T  1.43T      340K  /zseatera4

( zpool list )
NAME        SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zseatera4  7.25T  5.60T  1.65T        -         -    22%    77%  1.00x    ONLINE  -
                                       capacity    
pool                                 alloc   free  
-----------------------------------  -----  -----  
zseatera4                            5.60T  1.65T  
  mirror                             2.79T   850G  
    ata-ST4000VN000-2AH166_WDH0SB5N      -      -  
    ata-ST4000VN000-1H4168_Z3076XVL      -      -  
  mirror                             2.80T   844G  
    ata-ST4000VN000-1H4168_Z3073Z7X      -      -  
    ata-ST4000VN008-2DR166_ZGY005C6      -      -  

+ replace 1st 2 Mirror disks with HGST 6TB to increase pool size

-----

Afterward:

Sun 21 Jun 2020 09:07:43 AM CDT - PK to detach smaller mirror disks and increase pool size

real    0m0.559s
real    0m0.367s

  pool: zseatera4
 state: ONLINE
status: Some supported features are not enabled on the pool. The pool can
        still be used, but some features are unavailable.
action: Enable all features using 'zpool upgrade'. Once this is done,
        the pool may no longer be accessible by software that does not support
        the features. See zpool-features(5) for details.
  scan: resilvered 2.80T in 0 days 04:49:39 with 0 errors on Sun Jun 21 09:07:36 2020
config:
        NAME                                   STATE     READ WRITE CKSUM
        zseatera4                              ONLINE       0     0     0
          mirror-0                             ONLINE       0     0     0
            ata-HGST_HUS726060ALE614_K8HU3M7N  ONLINE       0     0     0
            ata-HGST_HUS726060ALE614_K8HUH6YN  ONLINE       0     0     0
          mirror-1                             ONLINE       0     0     0
            ata-ST4000VN000-1H4168_Z3073Z7X    ONLINE       0     0     0
            ata-ST4000VN008-2DR166_ZGY005C6    ONLINE       0     0     0
errors: No known data errors

Filesystem                                             Type      Size  Used Avail Use% Mounted on
zseatera4                                              zfs       3.2T  384K  3.2T   1% /zseatera4
zseatera4/from-imacdual-zredtera1                      zfs       3.2T  384K  3.2T   1% /zseatera4/from-imacdual-zredtera1
zseatera4/dvdshare                                     zfs       6.3T  3.1T  3.2T  49% /zseatera4/dvdshare
zseatera4/dvshr                                        zfs       3.8T  541G  3.2T  15% /zseatera4/dvshr
zseatera4/notshrcompr                                  zfs       3.7T  474G  3.2T  13% /zseatera4/notshrcompr
zseatera4/virtbox-virtmachines                         zfs       3.2T  9.2G  3.2T   1% /zseatera4/virtbox-virtmachines
zseatera4/from-imacdual-zredtera1/notshrcompr-zrt1     zfs       3.3T   40G  3.2T   2% /zseatera4/from-imacdual-zredtera1/notshrcompr-zrt1
zseatera4/dvdshare/0MKV                                zfs       3.4T  217G  3.2T   7% /zseatera4/dvdshare/0MKV
zseatera4/dvdshare/0BLURAY                             zfs       4.3T  1.1T  3.2T  26% /zseatera4/dvdshare/0BLURAY
zseatera4/from-imacdual-zredtera1/virtbox-virtmachines zfs       3.3T   72G  3.2T   3% /zseatera4/from-imacdual-zredtera1/virtbox-virtmachines
zseatera4/from-imacdual-zredtera1/shrcompr-zrt1        zfs       3.3T   41G  3.2T   2% /zseatera4/from-imacdual-zredtera1/shrcompr-zrt1
zseatera4/dvdshare/DMZ-W                               zfs       3.3T   96G  3.2T   3% /zseatera4/dvdshare/DMZ-W
zseatera4/virtbox-virtmachines/OSXELCAPTEST            zfs       3.3T   40G  3.2T   2% /zseatera4/virtbox-virtmachines/OSXELCAPTEST
 
# zpool list zseatera4
NAME        SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zseatera4  9.06T  5.60T  3.47T        -         -    17%    61%  1.00x    ONLINE  -
 