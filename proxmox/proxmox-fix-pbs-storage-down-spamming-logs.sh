#!/bin/bash

# REF: https://forum.proxmox.com/threads/reduce-log-spamming-when-pbs-is-offline-error-fetching-datastores-500-cant-connect-to.147310/

# 2026.0818 be more thorough, do all inactive
 
echo "arg1 = 1/0, 1=enable"
echo "arg2 = storagename [optional]"

# running from cron, we need this
PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/games:/usr/games:/root/bin:/root/bin/boojum:/usr/X11R6/bin:/usr/NX/bin:

pvess=/dev/shm/pve-storage-state.in

if [ "$2" = "" ]; then
# storname=pbs-p2300m-laptop
# storname=pbs-vm-on-macmini2-25g
 storname=inactive # pbs-mac3-virtiofs-zmixed3
else 
 storname="$2"
fi

pvesm status |tee $pvess

if [ "$1" = "1" ]; then
 echo "Enabling storage $storname"
 pvesm set $storname --disable 0
fi 

if [ "$storname" = "inactive" ]; then
  echo "Disabling all Inactive storage"
  for storname in $(grep inactive $pvess |awk '{print $1}'); do
    echo "- Disabling $storname"
    pvesm set $storname --disable 1
  done 
else
 echo "Disabling storage $storname"
 pvesm set $storname --disable 1
fi

pvesm status

exit;


Ex:
$0 0 pbs-vm-on-macpro

Name                                              Type     Status     Total (KiB)      Used (KiB) Available (KiB)        %
dir1-xfs                                           dir     active      5366622188      2111555944      3255066244   39.35%
local                                              dir     active        32073536        24387776         6030976   76.04%
local-lvm                                      lvmthin     active       106913792        15780475        91133316   14.76%
lvmthin2data                                   lvmthin     active       483258368       127531883       355726484   26.39%
macmini2-toshmg10                                  dir   disabled               0               0               0      N/A
macmini3-ztosh16-proxmox-multi-10gbit             cifs   inactive               0               0               0    0.00%
pbs-mac3-virtiofs-zmixed3                          pbs   disabled               0               0               0      N/A
pbs-mac3-virtiofs-zmixed3-NS-beelink               pbs   inactive               0               0               0    0.00%
pbs-mac3-virtiofs-ztosh16-NS-qotom                 pbs   inactive               0               0               0    0.00%
pbs-vm-on-macmini2-25g                             pbs   disabled               0               0               0      N/A
pbs-vm-on-macmini2-25g-NS-qotom-here               pbs   disabled               0               0               0      N/A
pbsvm-beelink-datastore-virtiofs-zseatera4         pbs     active      2730430464       309810944      2420619520   11.35%
pbsvm-lenovo-520-DS-virtio-NS-qotom-10g            pbs   disabled               0               0               0      N/A
pbsvm-on-qotom-4-beelink-datastore-ztosh10         pbs     active      4169546496       990976000      3178570496   23.77%
pbsvm-on-qotom-DS-ztosh10-NS-beelink               pbs     active      4169546496       990976000      3178570496   23.77%
pbsvm-on-qotom-DS-ztosh10-NS-fryserver             pbs     active      4169546496       990976000      3178570496   23.77%
pbsvm-on-qotom-DS-ztosh10-NS-macmini3              pbs     active      4169546496       990976000      3178570496   23.77%
xfs-tosh10-multi                                   dir     active      2146435072      1339457128       806977944   62.40%
zfs3nvme1T                                     zfspool     active       967311360       312977051       654334309   32.36%
ztosh10                                        zfspool     active      7482638336      4304067640      3178570696   57.52%
ztoshtera10-proxmox-multi                          dir     active      3178696704          126976      3178569728    0.00%
ztoshtera12                                    zfspool     active      6207570664      2438122296      3769448368   39.28%
ztoshtera12-multi                                  dir     active      3808521216        39073792      3769447424    1.03%

