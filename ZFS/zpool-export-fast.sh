#!/bin/bash

# REQUIRES zpool awk grep xargs

zpool list
echo "$(date) - Fast exporting zpools"

time zpool list |grep -v ALLOC \
 |awk '{print $1}' \
 |xargs -n 1 -P 4 zpool export

date

zpool list

exit;

real    0m25.620s

# Normal zpool export takes >1 min with this many pools/mounts

# zpool list
NAME           SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zhgstera6     5.09T  2.82T  2.28T        -         -     0%    55%  1.00x    ONLINE  -
zimactera4    3.44T   654G  2.80T        -         -     0%    18%  1.00x    ONLINE  -
zint1000pro    652G   213G   439G        -         -     1%    32%  1.00x    ONLINE  -
zsamt7macpro   424G   232G   192G        -         -     0%    54%  1.00x    ONLINE  -
zsgtera4      3.19T  2.34T   873G        -         -     6%    73%  1.00x    ONLINE  -
zsgtera4-old  3.19T  1.36T  1.83T        -         -     1%    42%  1.00x    ONLINE  -
zsgtera6bkp   5.44T  3.26T  2.18T        -         -     2%    59%  1.00x    ONLINE  -
ztoshtera10   9.09T  6.31T  2.79T        -         -     0%    69%  1.00x    ONLINE  -

# zfs list
NAME                                                     USED  AVAIL  REFER  MOUNTPOINT
zhgstera6                                               2.82T  2.15T  17.3M  /Volumes/zhgstera6
zhgstera6/bkp-from-macpro                               2.82T  2.15T  2.82T  /Volumes/zhgstera6/bkp-from-macpro
zimactera4                                               654G  2.69T   380K  /Volumes/zimactera4
zimactera4/notshrcompr-zimactera4                        440K  2.69T   360K  /Volumes/zimactera4/notshrcompr-zimactera4
zimactera4/shrcompr-zimactera4                           448K  2.69T   368K  /Volumes/zimactera4/shrcompr-zimactera4
zimactera4/virtbox-macpro-backup                         237G  2.69T   237G  /Volumes/zimactera4/virtbox-macpro-backup
zint1000pro                                              213G   419G  2.01M  /Volumes/zint1000pro
zint1000pro/notshrcompr-zint1000pro                     2.29M   419G  2.11M  /Volumes/zint1000pro/notshrcompr-zint1000pro
zint1000pro/shrNOTcompr-zint1000pro                     2.64M   419G  2.32M  /Volumes/zint1000pro/shrNOTcompr-zint1000pro
zint1000pro/shrcompr-zint1000pro                        31.4G   419G  5.25M  /Volumes/zint1000pro/shrcompr-zint1000pro
zint1000pro/shrcompr-zint1000pro/ISO                    31.4G   419G  29.8G  /Volumes/zint1000pro/shrcompr-zint1000pro/ISO
zint1000pro/virtbox-virtmachines                         181G   419G   157G  /Volumes/zint1000pro/virtbox-virtmachines
zsamt7macpro                                             232G   179G  1.96M  /Volumes/zsamt7macpro
zsamt7macpro/notshrcompr-samt7                          23.2G   179G  23.2G  /Volumes/zsamt7macpro/notshrcompr-samt7
zsamt7macpro/shrcompr-zsamt7macpro                       101G   179G   101G  /Volumes/zsamt7macpro/shrcompr-zsamt7macpro
zsamt7macpro/virtbox-virtmachines-samt7                 99.0G   179G  99.0G  /Volumes/zsamt7macpro/virtbox-virtmachines-samt7
zsamt7macpro/zvol01                                     1.38G   179G  1.38G  -
zsamt7macpro/zvol02                                     1.38G   179G  1.38G  -
zsamt7macpro/zvol03                                     1.38G   179G  1.38G  -
zsamt7macpro/zvol04                                     1.38G   179G  1.38G  -
zsamt7macpro/zvol05                                     1.38G   179G  1.38G  -
zsamt7macpro/zvol06                                     1.38G   179G  1.38G  -
zsamt7macpro/zvol07                                       56K   179G    56K  -
zsamt7macpro/zvol08                                       56K   179G    56K  -
zsamt7macpro/zvol09                                       56K   179G    56K  -
zsamt7macpro/zvol10                                       56K   179G    56K  -
zsamt7macpro/zvol11                                       56K   179G    56K  -
zsamt7macpro/zvol12                                       56K   179G    56K  -
zsamt7macpro/zvol13                                       56K   179G    56K  -
zsgtera4                                                2.34T   772G   752K  /Volumes/zsgtera4
zsgtera4-old                                            1.36T  1.73T  22.2G  /Volumes/zsgtera4-old
zsgtera4-old/from-imac5-old-zwdblack2                    345G  1.73T   345G  /Volumes/zsgtera4-old/from-imac5-old-zwdblack2
zsgtera4-old/from-imac5-sgtera2                         25.4G  1.73T  24.4G  /Volumes/zsgtera4-old/from-imac5-sgtera2
zsgtera4-old/from-imac5-time-machine                    3.58G  1.73T  3.58G  /Volumes/zsgtera4-old/from-imac5-time-machine
zsgtera4-old/from-imac5-zint500                          146G  1.73T   142G  /Volumes/zsgtera4-old/from-imac5-zint500
zsgtera4-old/from-imac5-zsam53                           141G  1.73T   141G  /Volumes/zsgtera4-old/from-imac5-zsam53
zsgtera4-old/notshrcompr-zsgt4B                         97.0G  1.73T  54.9G  /Volumes/zsgtera4-old/notshrcompr-zsgt4B
zsgtera4-old/notshrcompr-zsgt4B/bkp-bookmarks           42.1G  1.73T  42.1G  /Volumes/zsgtera4-old/notshrcompr-zsgt4B/bkp-bookmarks
zsgtera4-old/notshrcompr-zsgt4B/bkp-bookmarks-imac2008  3.80M  1.73T  3.51M  /Volumes/zsgtera4-old/notshrcompr-zsgt4B/bkp-bookmarks-imac2008
zsgtera4-old/shrcompr-zsgt4B                            44.9G  1.73T  44.9G  /Volumes/zsgtera4-old/shrcompr-zsgt4B
zsgtera4-old/virtbox-virtmachines-linux                  566G  1.73T   566G  /Volumes/zsgtera4-old/virtbox-virtmachines-linux
zsgtera4-old/zvol01                                       56K  1.73T    56K  -
zsgtera4/dvdrips-shr                                     135G   772G   135G  /Volumes/zsgtera4/dvdrips-shr
zsgtera4/notshrcompr-zsgt2B                              372G   772G   331G  /Volumes/zsgtera4/notshrcompr-zsgt2B
zsgtera4/notshrcompr-zsgt2B/bkp-bookmarks               31.9G   772G  31.9G  /Volumes/zsgtera4/notshrcompr-zsgt2B/bkp-bookmarks
zsgtera4/notshrcompr-zsgt2B/bkp-bookmarks-imac2008      8.45G   772G  3.50M  /Volumes/zsgtera4/notshrcompr-zsgt2B/bkp-bookmarks-imac2008
zsgtera4/shrcompr-gz3                                    536K   772G   352K  /Volumes/zsgtera4/shrcompr-gz3
zsgtera4/shrcompr-zsgt2B                                1.09T   772G  1.05T  /Volumes/zsgtera4/shrcompr-zsgt2B
zsgtera4/virtbox-virtmachines                            564G   772G   555G  /Volumes/zsgtera4/virtbox-virtmachines
zsgtera4/virtbox-virtmachines-linux                      151G   772G   151G  /Volumes/zsgtera4/virtbox-virtmachines-linux
zsgtera4/virtbox-virtmachines/nocompr-freebsd           9.09G   772G  9.09G  /Volumes/zsgtera4/virtbox-virtmachines/nocompr-freebsd
zsgtera4/zvol01                                          168K   772G    84K  -
zsgtera6bkp                                             3.26T  2.05T   368K  /Volumes/zsgtera6bkp
zsgtera6bkp/bkp-p2300m-win7-p2v--zstd                    215G  2.05T   215G  /Volumes/zsgtera6bkp/bkp-p2300m-win7-p2v--zstd
zsgtera6bkp/from-imac5                                  3.05T  2.05T  3.04T  /Volumes/zsgtera6bkp/from-imac5
zsgtera6bkp/from-imac5--bkp-osx-zsam53                  1.90M  2.05T  1.77M  /Volumes/zsgtera6bkp/from-imac5--bkp-osx-zsam53
zsgtera6bkp/notshrcompr                                  616K  2.05T   360K  /Volumes/zsgtera6bkp/notshrcompr
ztoshtera10                                             6.31T  2.66T  1.83M  /Volumes/ztoshtera10
ztoshtera10/fryserver-dvdbackup-shrnocompr-ztoshtera10  6.27T  2.66T  6.27T  /Volumes/ztoshtera10/fryserver-dvdbackup-shrnocompr-ztoshtera10
ztoshtera10/notshrcompr-ztoshtera10                     2.25G  2.66T  2.25G  /Volumes/ztoshtera10/notshrcompr-ztoshtera10
ztoshtera10/shrcompr-ztoshtera10                        1.94M  2.66T  1.79M  /Volumes/ztoshtera10/shrcompr-ztoshtera10
