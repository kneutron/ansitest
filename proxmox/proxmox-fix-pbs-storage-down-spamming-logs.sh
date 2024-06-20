#!/bin/bash

# REF: https://forum.proxmox.com/threads/reduce-log-spamming-when-pbs-is-offline-error-fetching-datastores-500-cant-connect-to.147310/

echo "arg1 = 1/0, 1=enable"
echo "arg2 = storagename [optional]"

# running from cron, we need this
PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/games:/usr/games:/root/bin:/root/bin/boojum:/usr/X11R6/bin:/usr/NX/bin:

if [ "$2" = "" ]; then
 storname=pbs-p2300m-laptop
else 
 storname="$2"
fi

pvesm status

if [ "$1" = "1" ]; then
 echo "Enabling storage $storname"
 pvesm set $storname --disable 0
else
 echo "Disabling storage $storname"
 pvesm set $storname --disable 1
fi

pvesm status

exit;

$0 0 pbs-vm-on-macpro
