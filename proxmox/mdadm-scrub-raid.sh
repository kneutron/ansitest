#!/bin/bash

PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/games:/usr/games:/root/bin:/root/bin/boojum:/usr/X11R6/bin:/usr/NX/bin:

msg="$(date) - boojum - Initiating scrub on mdadm raid"

echo "$msg"
logger "$msg"

# Only valid for parity raids - this will also check the integrity of the
# data as it reads it, and rewrite a corrupt stripe.  It will terminate
# immediately without doing anything if the array is degraded, as it cannot
# recalculate the faulty data. 
# echo repair

echo check > /sys/block/md0/md/sync_action

sleep 2
mdadm-raid-status.sh

exit;

If the system is rebooted or otherwise interrupted while a scan is in
progress, the scan will resume from the beginning when the array comes back up. 

With a raid-5 array the only thing that can be done when there is an error
is to correct the parity.  This is also the most likely error - the scenario
where the data has been flushed and the parity not updated is the expected
cause of problems like this.

With raid-6, it is possible to detect which block is corrupt - certainly on
a single-bit error.  However, "repair" will not correct this sort of error. 
Be very careful using it - it may just rewrite both parities and leave any
corruption in place.  The reason for this behaviour is that there is no
easily detectable cause for data error and the correct repair strategy needs
user intervention.  There is a utility "raid6check" that you should use if
"check" flags data errors on a raid-6.

#echo idle > /sys/block/md0/md/sync_action
This will stop any check or repair that is
currently in progress.  It is okay to do so, as both of them normally only
ever read the data, so interrupting them wont leave the system in an
inconsistent state.
