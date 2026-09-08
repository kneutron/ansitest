#!/bin/bash

# REF: https://github.com/kneutron/ansitest/blob/master/proxmox/HOWTO-make-a-file-backed-backup-of-proxmox-rpool.docx

# 2026.Sep kneutron

# Objective: Bare-metal Restore a proxmox zfs boot/root disk from an iscsi mirror disk over network and reboot into it (Disaster Recovery)
# Useful for P2V or if both disks in the mirror failed

# NOTE - You should have attached an iscsi mirror disk to your rpool beforehand!!

# Tested with PVE 9

# NOTE - this is a PROOF OF CONCEPT script and is NOT meant to be run blindly!
# you need to EDIT IT before running!

# MAKE SURE you specify the correct destination disk and other info! Author takes NO RESPONSIBILITY for data loss!!

# This should hopefully get your full environment back online and running in a minimum amount of time :)

# IT IS HIGHLY RECOMMENDED to test this process in a VM first before you rely on it!
# NOTE if restoring to VM, you should turn off Secure Boot in the vm BIOS


# NOTE this **needs** to be the correct disk!
# Default is set to be a proxmox restore-VM with a SCSI disk; virtio destination disk would be vda

# xxx TODO EDITME - this needs to be the short-form device, no partition number
newzfsrootdisk=sdb
# Obtain from /dev/disk/by-id
# *** ALL DATA ON THIS DISK WILL BE OVERWRITTEN FOR THE RESTORE PROCESS - YOU HAVE BEEN WARNED! ***

zp=rpool
          
# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

set -u # abort if var undefined

# Takes only 1 arg, use in loop if multiple
function install-if-missing () {
  [ $(which $1 |wc -l) -gt 0 ] || apt-get install -y $1
}

# NOTE this will not work on systemrescuecd, as its not Debian
# You can make your own rescue environment simply by installing Debian+ZFS to usb drive, and add any necessary recovery packages
#install-if-missing sshfs
install-if-missing parted 
install-if-missing sgdisk
install-if-missing gdisk

echo ''
echo "$(date) - Attempting to import $zp"
zpool import -f -N -d /dev/disk/by-path $zp # without mounting any datasets
# cannot attach /dev/sdc3 to ip-172.16.25.76:3260-iscsi-iqn.2026-05.iscsi-macmini3-zfsboot.com.example:32761070b6724dbb7f21-lun-0-part3: pool is read-only

#Breakdown of options:
# -f # Force - likely necessary since we offlined this disk and it wasn't "exported properly"
# -N # Do not mount zfs datasets, just import this pool
# -d $PWD # Look in the current directory for the pool disk(s)

zpool status $zp -v |awk 'NF>0'

result=$(zpool list)
[ "$result" = "no pools available" ] && failexit 50 "Unable to find / import $zp! Cannot continue"

# Remember, "$zp" is basically mounted over the network at this point
# We still need to mirror it to local disk and restore EFI partition so it (hopefully) boots

#zpool status -v $zp
#  pool: $zp
# state: DEGRADED
#status: One or more devices could not be used because the label is missing or
#        invalid.  Sufficient replicas exist for the pool to continue
#        functioning in a degraded state.
#action: Replace the device using 'zpool replace'.
#   see: https://openzfs.github.io/openzfs-docs/msg/ZFS-8000-4J
#  scan: resilvered 17.7M in 00:00:01 with 0 errors on Sat Sep  5 19:48:31 2026
#config: 
#        NAME                                                                                                            STATE     READ WRITE CKSUM
#        $zp                                                                                                           DEGRADED     0     0     0
#          mirror-0                                                                                                      DEGRADED     0     0     0
#            12489994290334952755                                                                                        UNAVAIL      0     0     0  was /dev/sda3
#            ip-172.16.25.76:3260-iscsi-iqn.2026-05.iscsi-macmini3-zfsboot.com.example:32761070b6724dbb7f21-lun-0-part3  ONLINE       0     0     0
#errors: No known data errors

fdisk -l /dev/$newzfsrootdisk
lsblk -f |grep $newzfsrootdisk
echo "
o New $zp mirror disk is specified as: /dev/$newzfsrootdisk
o NOTE - it will be wiped!
"

guessdisk=$(zpool status $zp |grep ONLINE |head -n 1 |awk '{print $1}')
echo "o I am guessing the $zp disk to be mirrored is:

$guessdisk"
echo "Enter to accept, or input another disk in the $zp, or ^C"
read youguessedwrong

if [ "$youguessedwrong" = "" ]; then
  : # NOP
else
  guessdisk=$youguessedwrong
  [ $(zpool status -v $zp |grep -c $youguessedwrong) -gt 0 ] || failexit 55 "Disk entered not detected in pool $zp"
fi

# Proceed with Teh Main Thing
# NOTE nothing can be actively mounted on the destination disk - including swap
gdisk -l /dev/$newzfsrootdisk
echo ''
echo "$(date) - Creating new partition table on /dev/$newzfsrootdisk - ALL EXISTING DATA WILL BE ERASED"

zpool labelclear -f /dev/${newzfsrootdisk}3 # shouldnt be necessary, but why not - we could be doing this more than once
wipefs -a /dev/$newzfsrootdisk
time parted -s /dev/$newzfsrootdisk mklabel gpt || failexit 99 "Failed to create fresh GPT partition table on /dev/$newzfsrootdisk"

echo ''
echo "Recreating boot/root partitions on /dev/$newzfsrootdisk"

# TODO change from 512 to 1G for "standard" proxmox efi partition
# The -n options are sizes, and the -t sets the filesystem type.
#-n 2:0:+1G \
sgdisk -g \
-n 1:0:+1M \
-n 2:0:+512M \
-n 3:0:0 \
-t 1:8300 \
-t 2:EF00 \
-t 3:BF01 \
-p /dev/$newzfsrootdisk

time sync; sleep 1
gdisk -l /dev/$newzfsrootdisk

echo ''
#echo "$(date) - Restoring EFI to /dev/${newzfsrootdisk}2"
#time gzip -cd $efifile |dd of=/dev/${newzfsrootdisk}2 bs=1M status=progress || failexit 101 "Failed to restore EFI partition"

# NOTE I have not bothered to re-size the ZFS partition on the replacement disk
# to take advantage of any increased disk space

# Tips for resizing here:
# REF: https://sirlagz.net/2023/07/03/updated-live-resize-lvm-on-linux/

#zpool attach $zp /mnt/macpro-sgtera2/$zp-mirror-64gig-thumbdrive-zfs-efi.disk \
#  ata-Samsung_Portable_SSD_T5_S49WNV0MC04217F-part3

echo ''
echo "$(date) - Beginning restore process"

time zpool attach $zp $guessdisk \
  /dev/${newzfsrootdisk}3 || failexit 102 "Failed to attach physical disk /dev/${newzfsrootdisk}3 to $zp"
  
# get shorty  
newdiskefi=/dev/${newzfsrootdisk}2

function watchresilver () {
sdate=$(date)

# do forever
while :; do
  clear
  echo "Pool: $zp - NOW: $(date) -- Watchresilver started: $sdate"

  zpool status $zp |grep -A 2 'in progress' || break 2
  zpool iostat -v $zp #2 3 &
#  zpool iostat -T d -v $1 2 3 & # with timestamp
  sleep 5
  date
done

ndate=$(date)

zpool status -v $zp |awk 'NF>0' # skip blank lines
echo "o Resilver watch $zp start: $sdate // Completed: $ndate"
} # function

watchresilver;

# dup EFI
echo "$(date) - o Duplicating EFI boot partition and making disk bootable"

proxmox-boot-tool status # Note if grub is being used or not here
addgrub=""
[ $(proxmox-boot-tool status |grep -c grub) -gt 0 ] && addgrub="grub"

echo "$(date) - Fixing boot on new drive"
set -x
proxmox-boot-tool format ${newdiskefi} --force # <new disk's ESP partn>
time sync; sleep 2

proxmox-boot-tool init ${newdiskefi} $addgrub # <new disk's ESP partn>

set +e # grub error is ok here
proxmox-boot-tool refresh
set +x

#zpool status $zp -v

echo '====='
echo "You should be able to boot with the new disk now! After shutdown + remove old disks, run:"
echo " proxmox-boot-tool clean"
echo "and:"
echo " zpool clear $zp"
echo "
NOTE you do NOT want to issue a detach or a zpool split at this
point because this is an $zp, and a detach will not guarantee usable data
on the detached disk.  We just offline it, and reboot to get out from under it
(so to speak.)"

(set -x
zpool offline $zp $guessdisk
)

# reboot

echo "
PLEASE MAKE A NOTE OF THIS:

After rebooting, you will get dumped into the initramfs because ZFS has
temporarily lost its mind and can't import from the cache file properly.

Easy fix:

(initramfs) zpool import -f 
Then hit Control+D, boot process resumes and should survive further reboots.

If the boot process does NOT continue, hard reboot and issue:

(initramfs) rm -fv /etc/zfs/zpool.cache
(initramfs) zpool import -a -f -d /dev/disk/by-id

Then hit ^D to continue the boot process. Further reboots should now work OK.

Finally, without the original disk being mounted, you should detach the missing disk
from the $zp to get it out of DEGRADED state:

# zpool detach $zp missing-disk-id

And you should be back to a bootable single-disk Proxmox $zp.
(Its probably a good idea to write these instructions down. Or take a picture)

o Alt.Easy.Fix: Install zfs-bootmenu on the EFI partition.

Refer to the online reference if you want to attach a mirror to a single-disk $zp:

https://pve.proxmox.com/pve-docs/pve-admin-guide.html#sysadmin_zfs_change_failed_dev

https://www.reddit.com/r/Proxmox/comments/spbdlw/how_to_add_to_proxmox_ve_bootmirrored_zfs_disks/

"

#zpool status -v $zp
date;
echo $0 DONE

exit;


#placeholder1
guessdisk=$(zpool status -v |grep UNAVAIL |head -n 1 |awk '{print $1}')
# if no disk needs detaching, we skip this 
# bash if not
if [ ! "$guessdisk" = "" ]; then

	echo "Guessing disk to detach from $zp:
$guessdisk"

	echo "Hit Enter to proceed with this, or input another disk identifier here to use:"
	echo "PROTIP - run $0 from GNU screen or tmux so you can use the keyboard to copypasta"
	read indisk

	[ "$indisk" = "" ] || guessdisk=$indisk
	[ $(zpool status $zp -v |grep -c $guessdisk) -eq 0 ] && failexit 60 "$guessdisk does not appear to be in the $zp" 

	echo "Detaching $guessdisk from $zp"
	zpool detach $zp $guessdisk
fi
