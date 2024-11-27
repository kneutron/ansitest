#!/bin/bash

# copy 1 zpool/datasets to another destination pool+dataset

# TODO editme if you have an @NOW snap
zsnap=zintmacpro2@Sat
dest=zsgtera6bkp
destip=10.9.12.12

#(HOST) 
  time zfs send -L -R -e $zsnap \
  |pv -t -r -b -W -i 2 -B 250M \
  |nc -w 10 $destip 32100
  
date  
#  |zfs recv -Fev $dest; date
#  |zfs recv -Fevn $dest; date
#(VM/dest) 
# TODO Remove the "n" for live xmit! Otherwise test run - can ^C after ~10 sec!

#  |zfs recv -evn $dest; date
#  time nc -l -p 32100 |zfs recv -Fev zhome/home; date

exit;

NOTE the below results in:

zhgstsas4                                                   zfs       2.9T  128K  2.9T   1% /zhgstsas4
zhgstsas4/shrcompr                                          zfs       3.0T  101G  2.9T   4% /zhgstsas4/shrcompr
zhgstsas4/notshrnotcompr                                    zfs       2.9T  128K  2.9T   1% /zhgstsas4/notshrnotcompr
zhgstsas4/notshrcompr                                       zfs       2.9T  128K  2.9T   1% /zhgstsas4/notshrcompr
zhgstsas4/NEVERLOSE-notshrcompr                             zfs       2.9T  291M  2.9T   1% /zhgstsas4/NEVERLOSE-notshrcompr
zhgstsas4/BURNME-shrcompr                                   zfs       3.5T  622G  2.9T  18% /zhgstsas4/BURNME-shrcompr
zwd6t/zhgstsas4                                             zfs       4.4T  128K  4.4T   1% /zwd6t/zhgstsas4
zwd6t/zhgstsas4/BURNME-shrcompr                             zfs       5.0T  622G  4.4T  13% /zwd6t/zhgstsas4/BURNME-shrcompr
zwd6t/zhgstsas4/NEVERLOSE-notshrcompr                       zfs       4.4T  291M  4.4T   1% /zwd6t/zhgstsas4/NEVERLOSE-notshrcompr
zwd6t/zhgstsas4/notshrcompr                                 zfs       4.4T  128K  4.4T   1% /zwd6t/zhgstsas4/notshrcompr
zwd6t/zhgstsas4/notshrnotcompr                              zfs       4.4T  128K  4.4T   1% /zwd6t/zhgstsas4/notshrnotcompr
zwd6t/zhgstsas4/shrcompr                                    zfs       4.5T  101G  4.4T   3% /zwd6t/zhgstsas4/shrcompr

zsnap=zhgstsas4@Sat
dest=zwd6t

#(HOST) 
  time zfs send -L -R -e $zsnap \
  |zfs recv -Fev $dest; date
 