#!/bin/bash

# REF: https://openzfsonosx.org/wiki/FAQ#Q.29_How_can_I_access_the_.zfs_snapshot_directories.3F

# Auto-set visible on all (mounted/imported) pools
for zds in $(zpool list |grep -v ALLOC |awk '{print $1}'); do
  zfs set snapdir=visible $zds
done

# xxx TODO EDITME - mount all virtbox* snapshots
for zds in $(zfs-list-snaps--boojum.sh |grep virtbox |awk '{print $1}'); do
#for zds in `zfs-list-snaps--boojum.sh |grep DOM16 |awk '{print $1}'`; do
  zfs mount $zds  
done

df -hT

exit;

--As of 2019.0316, zfs for osx v1.8.2:

How can I access the .zfs snapshot directories?
A) You need to set snapdir visible and manually mount a snapshot.
( ed. note: ZFS on Linux automounts zfs snapshots for you. )

$ sudo zfs set snapdir=visible tank/bob
$ sudo zfs mount tank/bob@yesterday
$ ls -l /tank/bob/.zfs/snapshot/yesterday/
You can see existing snapshots via:

$ zfs list -t snapshot
Q) Is .zfs snapdir auto-mounting supported?
A) No, not at this time. You must manually "zfs mount" snapshots manually to see them in the snapdir.

Q) OK, I manually mounted my snapshot but still cannot see it in Finder. What gives?
A) Currently mounted snapshots are only visible from Terminal, not from Finder.

EX:

# zfs-list-snaps--boojum.sh |grep virtbox
zmac1t/virtbox-virtmachines@boojumDOM10     684M  97.5G  /Volumes/zmac1t/virtbox-virtmachines/.zfs/snapshot/boojumDOM10    Wed Oct 10 20:19 2018
zmac1t/virtbox-virtmachines@boojumDOM24     691M  97.6G  /Volumes/zmac1t/virtbox-virtmachines/.zfs/snapshot/boojumDOM24    Wed Oct 24 19:53 2018
zmac1t/virtbox-virtmachines@boojumDOM06        0   118G  /Volumes/zmac1t/virtbox-virtmachines/.zfs/snapshot/boojumDOM06    Wed Mar  6 15:18 2019
zmac1t/virtbox-virtmachines@Wed                0   118G  /Volumes/zmac1t/virtbox-virtmachines/.zfs/snapshot/Wed            Wed Mar  6 15:18 2019
zmac1t/virtbox-virtmachines@boojumDOM16        0   118G  /Volumes/zmac1t/virtbox-virtmachines/.zfs/snapshot/boojumDOM16    Sat Mar 16 18:15 2019
zmac1t/virtbox-virtmachines@Sat                0   118G  /Volumes/zmac1t/virtbox-virtmachines/.zfs/snapshot/Sat            Sat Mar 16 18:15 2019
zmac320/virtbox-virtmachines@boojumDOM16       0  24.1G  /Volumes/zmac320/virtbox-virtmachines/.zfs/snapshot/boojumDOM16   Sat Mar 16 18:15 2019
zmac320/virtbox-virtmachines@Sat               0  24.1G  /Volumes/zmac320/virtbox-virtmachines/.zfs/snapshot/Sat           Sat Mar 16 18:15 2019
zmacsg2t/virtbox-virtmachines@boojumDOM06      0  56.7G  /Volumes/zmacsg2t/virtbox-virtmachines/.zfs/snapshot/boojumDOM06  Wed Mar  6 15:18 2019
zmacsg2t/virtbox-virtmachines@Wed              0  56.7G  /Volumes/zmacsg2t/virtbox-virtmachines/.zfs/snapshot/Wed          Wed Mar  6 15:18 2019
zmacsg2t/virtbox-virtmachines@boojumDOM10      0  85.8G  /Volumes/zmacsg2t/virtbox-virtmachines/.zfs/snapshot/boojumDOM10  Sun Mar 10 16:45 2019
zmacsg2t/virtbox-virtmachines@Sun              0  85.8G  /Volumes/zmacsg2t/virtbox-virtmachines/.zfs/snapshot/Sun          Sun Mar 10 16:45 2019
zmacsg2t/virtbox-virtmachines@boojumDOM16      0   124G  /Volumes/zmacsg2t/virtbox-virtmachines/.zfs/snapshot/boojumDOM16  Sat Mar 16 18:15 2019
zmacsg2t/virtbox-virtmachines@Sat              0   124G  /Volumes/zmacsg2t/virtbox-virtmachines/.zfs/snapshot/Sat          Sat Mar 16 18:15 2019
zmacsg2t/virtbox-virtmachines@test          664K   124G  /Volumes/zmacsg2t/virtbox-virtmachines/.zfs/snapshot/test         Sat Mar 16 18:19 2019
