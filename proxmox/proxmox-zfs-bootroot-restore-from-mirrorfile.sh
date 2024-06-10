#!/bin/bash

# REF: https://github.com/kneutron/ansitest/blob/master/proxmox/HOWTO-make-a-file-backed-backup-of-proxmox-rpool.docx

# 2024.Jun kneutron

# Objective: Restore a proxmox zfs boot/root disk from a mirror file over sshfs and reboot into it (Disaster Recovery)
# NOTE - proxmox-backup-zfs-bootroot.sh should have been run beforehand!!

# Tested with "systemrescuecd + zfs" ISO
# https://github.com/nchevsky/systemrescue-zfs/releases

# NOTE - this is a PROOF OF CONCEPT script and is NOT meant to be run blindly!
# you need to EDIT IT before running!

# MAKE SURE you specify the correct destination disk and other info! Author takes NO RESPONSIBILITY for data loss!!

# This should hopefully get your full environment back online and running in a minimum amount of time

# IT IS HIGHLY RECOMMENDED to test this process in a VM first before you rely on it!


# TODO EDITME before running!
destdir=/mnt/macpro-sgtera2
# Will be mounted on this server / local dir

sshfsmountthis=/Volumes/sgtera2
# destination directory on the remote side
# TODO add a subdir here for different systems

loginid=dave 
# for sshfs

destserver=172.16.25.12 # macpro-static
# hostname or IP; IP is better for systemrescue environment

# NOTE this **needs** to be the correct disk!
# Default is set to proxmox restore VM with SCSI disk
# TODO EDITME
zfsroot=sda
# Obtain from /dev/disk/by-id

          
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
install-if-missing sshfs

mkdir -pv $destdir
# if not already mounted
if [ $(df -T |grep sshfs |grep -c $destdir) -eq 0 ]; then
  echo "Mounting $destdir on $destserver"
# TODO change this to samba, nfs, whatever works for you
# TODO ssh-copy-id for passwordless access
  sshfs -o Ciphers=chacha20-poly1305@openssh.com \
    $loginid@$destserver:$sshfsmountthis $destdir
fi

if [ $(df -T |grep -c $destdir) -eq 0 ]; then
  failexit 40 "$destdir is not mounted, cannot proceed"
fi
  
cd $destdir 

echo "
Currently available restore mirror disks:"
ls -lh *disk

# TODO EDITME - this is the restore/mirror file
mirfile="proxmox-rpool-mirror-41.5G-zfs-efi.disk"

echo "
Selected restore disk:
$mirfile"
echo ''
echo "Hit Enter to proceed with this default, ^C to abort, or input another filename here to use:"
read infile

[ "$infile" = "" ] || mirfile=$infile
[ -e $mirfile ] || failexit 44 "Cannot find $PWD/$mirfile"


efifile="dd-efi-part2-rpool-mirror-41.5G-zfs.dd.gz"
ls -lh dd*gz
echo ''
echo "Selected EFI restore disk:
$efifile"
echo "Hit Enter to proceed with this, or input another filename here to use:"
read infile

[ "$infile" = "" ] || efifile=$infile
[ -e $efifile ] || failexit 45 "Cannot find $PWD/$efifile"

zpool export -f rpool # if $0 run >1

echo ''
echo "$(date) - Attempting to import rpool from $PWD - NOTE THIS MAY NOT WORK if there are multiple restore disks in the same dir"
zpool import -f -N -d $PWD rpool # without mounting any datasets

#Breakdown of options:
# -f # Force - likely necessary since we offlined this disk and it wasn't "exported properly"
# -N # Do not mount zfs datasets, just import this pool
# -d $PWD # Look in the current directory for the pool disk(s)

zpool status rpool -v |awk 'NF>0'

result=$(zpool list)
[ "$result" = "no pools available" ] && failexit 50 "Unable to find / import rpool! Cannot continue"

guessdisk=$(zpool status -v |grep UNAVAIL |head -n 1 |awk '{print $1}')
# if no disk needs detaching, we skip this 
# bash if not
if [ ! "$guessdisk" = "" ]; then

	echo "Guessing disk to detach from rpool:
$guessdisk"

	echo "Hit Enter to proceed with this, or input another disk identifier here to use:"
	echo "PROTIP - run $0 from GNU screen or tmux so you can use the keyboard to copypasta"
	read indisk

	[ "$indisk" = "" ] || guessdisk=$indisk
	[ $(zpool status rpool -v |grep -c $guessdisk) -eq 0 ] && failexit 60 "$guessdisk does not appear to be in the rpool" 

	echo "Detaching $guessdisk from rpool"
	zpool detach rpool $guessdisk
fi

# Remember, "rpool" is basically mounted over the network at this point
# We still need to mirror it to local disk and restore EFI partition so it (hopefully) boots

# NOTE nothing can be actively mounted on the destination disk - including swap
echo ''
echo "$(date) - Creating new partition table on /dev/$zfsroot - ALL EXISTING DATA WILL BE ERASED"

time parted -s /dev/$zfsroot mklabel gpt || failexit 99 "Failed to create fresh GPT partition table on /dev/$zfsroot"

echo ''
echo "Recreating boot/root partitions on /dev/$zfsroot"

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
-p /dev/$zfsroot

time sync; sleep 1
gdisk -l /dev/$zfsroot

echo ''
echo "$(date) - Restoring EFI to /dev/${zfsroot}2"
time gzip -cd $efifile |dd of=/dev/${zfsroot}2 bs=1M status=progress || failexit 101 "Failed to restore EFI partition"

# NOTE I have not bothered to re-size the ZFS partition on the replacement
# disk to take advantage of any increased disk space

# Tips for resizing here:
# REF: https://sirlagz.net/2023/07/03/updated-live-resize-lvm-on-linux/

#zpool attach rpool /mnt/macpro-sgtera2/rpool-mirror-64gig-thumbdrive-zfs-efi.disk \
#  ata-Samsung_Portable_SSD_T5_S49WNV0MC04217F-part3

echo ''
echo "$(date) - Beginning restore process"
zpool labelclear /dev/${zfsroot}3 # shouldnt be necessary, but why not 

time zpool attach rpool $destdir/$mirfile \
  /dev/${zfsroot}3 || failexit 102 "Failed to attach physical disk ${zfsroot}3 to rpool $mirfile"
  
function watchresilver () {
sdate=$(date)

# do forever
while :; do
  clear
  echo "Pool: rpool - NOW: $(date) -- Watchresilver started: $sdate"

  zpool status rpool |grep -A 2 'in progress' || break 2
  zpool iostat -v rpool #2 3 &
#  zpool iostat -T d -v $1 2 3 & # with timestamp
  sleep 5
  date
done

ndate=$(date)

zpool status -v rpool |awk 'NF>0' # skip blank lines
echo "o Resilver watch rpool start: $sdate // Completed: $ndate"
}

watchresilver;

echo "Now we need to take the file-backed copy offline, leaving it intact for later use if
needed - NOTE you do NOT want to issue a detach or a zpool split at this
point because this is an rpool, and a detach will not guarantee usable data
on the detached disk.  We just offline it, and reboot to get out from under it
(so to speak.)"

(set -x
zpool offline rpool $destdir/$mirfile
)

# reboot

echo ''
echo "
After rebooting, you will get dumped into the initramfs because ZFS has
temporarily lost its mind and can't import from the cache file properly.

Easy fix:

(initramfs) zpool import -f 
Then hit Control+D, boot process resumes and should survive further reboots.

If the boot process does not continue, hard reboot and issue:

(initramfs) rm -fv /etc/zfs/zpool.cache
(initramfs) zpool import -a -f -d /dev/disk/by-id

Then hit ^D to continue the boot process. Further reboots should work OK.

Finally, without the target/backup $destdir being mounted, you should detach the file-backed copy
from the rpool to get it out of DEGRADED state:

# zpool detach rpool $destdir/$mirfile

And you should be back to a bootable single-disk Proxmox rpool.
(Its probably a good idea to write these instructions down.)

Refer to the online reference if you want to attach a mirror to a single-disk rpool:

https://pve.proxmox.com/pve-docs/pve-admin-guide.html#sysadmin_zfs_change_failed_dev

https://www.reddit.com/r/Proxmox/comments/spbdlw/how_to_add_to_proxmox_ve_bootmirrored_zfs_disks/

"

date;
echo $0 DONE

exit;
