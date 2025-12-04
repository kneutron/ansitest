#!/bin/bash

source ~/bin/failexit.mrg

# xxx TODO EDITME
# original disks - no partitions
mdra=sdb
mdrb=sdc

# xxx TODO EDITME
# replacement disks
mdrepla=sda
mdreplb=sdd

echo "$(date) - Init replacement drives: $mdrepla $mdreplb"
for diskk in $mdrepla $mdreplb; do
  sgdisk -g \
-n 1:0:0 \
-t 1:8e00 \
-p /dev/$diskk

  sleep 1
  sync
done

fdisk -l /dev/$mdrepla /dev/$mdreplb

echo '====='
echo "$(date) - PK to add replacement drives - $mdrepla $mdreplb - to md0"
read -n 1

time mdadm /dev/md0 --add /dev/"$mdrepla" /dev/"$mdreplb"

echo '====='
echo "Note that you can set the raid rebuild speed ( /proc/sys/dev/raid/speed_limit_min / max ), by default its limited for background rebuilds."
echo "PK to start moving data to $mdrepla"
read -n 1

time mdadm /dev/md0 --replace /dev/$mdra --with /dev/"$mdrepla" || \
 failexit 102 "Failed to replace $mdra with $mdrepla"
  
time mdadm /dev/md0 --remove /dev/$mdra 

echo '====='
echo "$(date) - Moving data to $mdreplb"
time mdadm /dev/md0 --replace /dev/$mdrb --with /dev/$"mdreplb" || \
 failexit 103 "Failed to replace $mdrb with $mdreplb"
  
time mdadm /dev/md0 --remove /dev/$mdrb
sleep 5

cat /proc/mdstat
# TODO watch here

# NOTE growing involves init / resilvering!
time mdadm --grow /dev/md0 --size=max
cat /proc/mdstat

echo "$(date) - Dont forget to resize lvm!"

exit;


echo "$(date) - PK to fail $mdra or ^C"
read -n 1

time mdadm --manage /dev/md0 --fail /dev/$mdra # sdX1
time mdadm --manage /dev/md0 --remove /dev/$mrda # sdX1

echo "$(date) - PK to replace $mdra"

time mdadm --manage /dev/md0 --add /dev/${mdrepla}1 

o Normal state:
# cat /proc/mdstat
Personalities : [raid1] 
md0 : active raid1 sdc[1] sdb[0]
      1953382464 blocks super 1.2 [2/2] [UU]
      
unused devices: <none>
------

Note that you can set the raid rebuild speed ( /proc/sys/dev/raid/speed_limit_min / max ), by default its limited for background rebuilds.

https://serverfault.com/questions/182048/mdadm-swapping-out-small-hard-drives-for-bigger-ones-in-a-raid5-how-to-partiti
[[
First you need to add a disk as a spare to the array (assuming 4 drives in RAID):

# mdadm /dev/md0 --add /dev/sde1

Then, you tell Linux to start moving the data to the new drive:

# mdadm /dev/md0 --replace /dev/sda1 --with /dev/sde1

After replacement is finished, the device is marked as faulty, so you need to remove it from array:

# mdadm /dev/md0 --remove /dev/sda1

Repeat for other drives in the array.

If you have ability to connect multiple additional drives, you can do that
even for all drives at the same time, all while keeping the array online and
with full redundancy.  So following is a valid set of commands:

# mdadm /dev/md0 --add /dev/sde1 /dev/sdf1 /dev/sdg1 /dev/sdh1
# mdadm /dev/md0 --replace /dev/sda1 /dev/sdb1 /dev/sdc1 /dev/sdd1 --with /dev/sde1

Wait until finish, remove old drives:

# mdadm /dev/md0 --remove /dev/sda1 /dev/sdb1 /dev/sdc1 /dev/sdd1

]]

Step 1: Replace each disk individually

    Mark a disk as failed: Using mdadm --manage /dev/mdX --fail /dev/sdX1 (replace mdX and sdX1 with your array and partition names).

    Remove the failed disk: mdadm --manage /dev/mdX --remove /dev/sdX1.

    Physically replace the disk: Shut down the system, remove the old disk, and install the new, larger one.

    Add the new disk: Boot the system, and add the new disk to the array. 
    The system may automatically detect it, or you may need to use 
    
    mdadm --manage /dev/mdX --add /dev/sdY1 
    (use the new device name, sdY1).

    Wait for the rebuild: Monitor /proc/mdstat to ensure the array rebuilds correctly before proceeding to the next disk.

    Partition the new disk (if necessary): If you are using MBR, you may
    need to switch to GPT partitioning for larger drives.  For example, use
    cfdisk or fdisk to create a new partition table and a new partition that
    spans the entire new disk.

    Repeat for each disk: Repeat the above steps for every disk in the array. 

-----

Step 2: Grow the array and filesystem

    Grow the mdadm array: Once all disks are replaced, tell mdadm to use the full size of the new disks. Use 
mdadm --grow /dev/mdX --size=max

    Grow LVM (if applicable): If you are using LVM on top of the RAID, use pvresize /dev/mdX to make the new space available to the volume group.

    Grow the filesystem: Finally, grow the filesystem to fill the new space. 
    For example, use resize2fs /dev/mapper/my-volume for an ext4 filesystem
    or xfs_growfs /mount/point for XFS.  



    Once all disks are changed, tell md to get the good size:  mdadm --grow /dev/md0 --size=max

    Then you can extend your PV:  pvresize /dev/md0

    Extend your VG only if needed. 
