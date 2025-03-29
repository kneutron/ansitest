#!/bin/bash

# REF: https://www.reddit.com/r/MacOS/comments/acxkkw/lots_of_mounts_for_time_machine_backups/
# clear up ' df ' 

#df -kh |grep com.apple.TimeMachine |awk '{print $9}' |xargs umount
df -kh |grep com.apple.TimeMachine |awk '{print $1}' |xargs umount
gdf -hT

# removes clutter:
# com.apple.TimeMachine.2024-12-20-060239.backup@/dev/disk20s2 apfs   600G  180G  421G  30% /Volumes/.timemachine/B9CED783-42ED-4388-BA8E-B6BEAE63126F/2024-12-20-060239.backup
