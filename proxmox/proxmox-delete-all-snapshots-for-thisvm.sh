#!/bin/bash

# arg1 = vmid number

# Delete all snapshots for a vm without having to use the GUI
# 2024.0521 kneutron

# USE AT YOUR OWN RISK - I TAKE NO REPSONSIBILITY FOR DATA LOSS!

logf=~/proxmox-vm-snapshots-deleted.log
 
qm list |egrep "VMID|$1" |column -t
echo '=========='
qm listsnapshot $1
echo '=========='
echo "$(date) - About to delete all snapshots for VMID $1 - ^C to backout or Enter to proceed"
read

for snap in $(qm listsnapshot $1 |grep -v "You are here" |awk '{print $2}'); do
  echo "$(date) - $(id -un) - Deleting snap $snap for VMID $1" |tee -a $logf
  time qm delsnapshot $1 "$snap"
done

qm listsnapshot $1
date;

ls -lh $logf

exit;

# REF: https://phoenixnap.com/kb/proxmox-delete-vm#ftoc-heading-9
# REF: https://forum.proxmox.com/threads/feature-request-button-to-delete-all-snapshots-at-once.147460/


Example output:

  proxmox-delete-all-snapshots-for-thisvm.sh 126
VMID  NAME                         STATUS   MEM(MB)  BOOTDISK(GB)  PID
126   pve-test-unattended-install  stopped  4096     256.00        0
==========
`-> snaptree1                   2024-05-21 13:57:25     no-description
 `-> snaptree2                  2024-05-21 13:57:39     no-description
  `-> snapree3                  2024-05-21 13:57:48     no-description
   `-> snaptree5                2024-05-21 13:58:00     no-description
    `-> snaptree4               2024-05-21 13:58:14     no-description
     `-> current                                        You are here!
==========
Tue May 21 01:58:32 PM MDT 2024 - About to delete all snapshots for VMID 126 - ^C to backout or Enter to proceed

Tue May 21 01:58:37 PM MDT 2024 - root - Deleting snap snaptree1 for VMID 126
  Logical volume "snap_vm-126-disk-0_snaptree1" successfully removed.

real    0m6.649s
user    0m4.979s
sys     0m0.380s
Tue May 21 01:58:44 PM MDT 2024 - root - Deleting snap snaptree2 for VMID 126
  Logical volume "snap_vm-126-disk-0_snaptree2" successfully removed.

real    0m6.328s
user    0m4.921s
sys     0m0.359s
Tue May 21 01:58:50 PM MDT 2024 - root - Deleting snap snapree3 for VMID 126
  Logical volume "snap_vm-126-disk-0_snapree3" successfully removed.

real    0m6.385s
user    0m4.860s
sys     0m0.384s
Tue May 21 01:58:56 PM MDT 2024 - root - Deleting snap snaptree5 for VMID 126
  Logical volume "snap_vm-126-disk-0_snaptree5" successfully removed.

real    0m6.196s
user    0m4.905s
sys     0m0.320s
Tue May 21 01:59:03 PM MDT 2024 - root - Deleting snap snaptree4 for VMID 126
  Logical volume "snap_vm-126-disk-0_snaptree4" successfully removed.

real    0m8.459s
user    0m4.821s
sys     0m0.479s
`-> current                                             You are here!
Tue May 21 01:59:13 PM MDT 2024
-rw-r--r-- 1 root root 389 May 21 13:59 /root/proxmox-vm-snapshots-deleted.log
