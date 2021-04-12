#!/bin/bash

zfs list -r -o name,used,usedsnap |sort -h -k 3

zfs list -t snapshot -o name,refer,used,written,creation
# REF: https://www.reddit.com/r/zfs/comments/i0lx98/why_isnt_snapshot_used_value_0/

exit;

Note - use -p flag for parsable (exact) numbers (for spreadsheet) - date will be in seconds from epoch

Fields:

Used is the amount of space reclaimed by deleting only this snapshot.

Refer is the size of the tarball that would be created from this snapshots contents (give/take compression). 

Written is the amount of data added or modified in the snapshot between the previous snapshot and this one
  in particular written == refer for the first snapshot in the timeline

NAME                                                 USED  USEDSNAP
zsgtera4/tmpdel-xattrsa                             16.7G      120K
zsam52/notshrcompr-zsam52                            680K      200K
zsam52                                               176G      268K
zsgtera4                                            1.66T      272K
zsam52/imac513-installed-old                         869M      396K
zsam52/shrcompr-zsam52                              94.7G     1.31M
zsgtera4/virtbox-virtmachines-linux                 47.1G     1.64M
zsgtera4/dvdrips-shr                                38.4G     4.35G
zsam52/dvdrips-shr-zsam52                           25.6G     6.35G
zsgtera4/virtbox-virtmachines/zfsubuntu2FIXEDClone  33.4G     9.31G
zsam52/tmpdel-zsam52                                55.0G     16.2G
zsgtera4/virtbox-virtmachines                        429G     23.9G
zsgtera4/notshrcompr-zsgt2B                          375G     32.2G
zsgtera4/notshrcompr-zsgt2B/bkp-bookmarks           68.9G     36.3G
zsgtera4/shrcompr-zsgt2B                             795G     47.4G
