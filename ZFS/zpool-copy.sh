#!/bin/bash

# copy 1 zpool/datasets to another destination pool (populates pool from zero content)

# REQUIRES: pv or buffer

# TODO editme if you have an @NOW snap
zsnap=zfs3nvme1T@Thu
dest=ztestpool # file-based, disposable


#(HOST)
set -x 
  time zfs send -L -R -e $zsnap \
  |pv -t -r -b -W -i 2 -B 250M \
  |zfs recv -Fdv $dest; date
#  |zfs recv -Fdvn $dest; date
#(VM/dest) 
# TODO Remove the "n" for live xmit! Otherwise test run - can ^C after ~10 sec!

#  |zfs recv -evn $dest; date
#  time nc -l -p 32100 |zfs recv -Fev zhome/home; date

exit;


 # truncate -s 500G /mnt/dir1-xfs/ztestpool; zpool create -o ashift=12 -o autoexpand=on -o autoreplace=off -O atime=off -O compression=lz4 ztestpool /mnt/dir1-xfs/ztestpool
# zpool list
NAME                  SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zfs3nvme1T            952G   283G   669G        -         -     4%    29%  1.00x    ONLINE  -
ztestpool             496G   396K   496G        -         -     0%     0%  1.00x    ONLINE  -

NOTE the above run results in:

zfs list -r zfs3nvme1T
NAME                           USED  AVAIL  REFER  MOUNTPOINT
zfs3nvme1T                     283G   639G    27K  /zfs3nvme1T
zfs3nvme1T/ISO                 197G   639G   197G  /zfs3nvme1T/ISO
zfs3nvme1T/shrcompr-fast        24K   639G    24K  /zfs3nvme1T/shrcompr-fast
zfs3nvme1T/subvol-118-disk-1  9.14G  14.9G  9.10G  /zfs3nvme1T/subvol-118-disk-1
zfs3nvme1T/vm-106-disk-0        12K   639G    12K  -
zfs3nvme1T/vm-111-disk-0      11.4G   639G  11.0G  -
zfs3nvme1T/vm-112-disk-0      1.62G   639G  1.62G  -
zfs3nvme1T/vm-115-disk-0      24.5K   639G  24.5K  -
zfs3nvme1T/vm-115-disk-1      8.70G   639G  8.70G  -
zfs3nvme1T/vm-117-disk-0      1.45G   639G  1.36G  -
zfs3nvme1T/vm-120-disk-0      7.75G   639G  4.80G  -
zfs3nvme1T/vm-121-disk-0      4.14G   639G  3.97G  -
zfs3nvme1T/vm-123-disk-0      41.7G   639G  41.3G  -

