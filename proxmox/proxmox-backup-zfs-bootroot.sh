#!/bin/bash

# 2024.Jun kneutron
# REF: https://github.com/kneutron/ansitest/blob/master/proxmox/HOWTO-make-a-file-backed-backup-of-proxmox-rpool.docx

# Objective: bare-metal backup of proxmox boot/root ZFS partition and EFI

# NOTE - this is a PROOF OF CONCEPT script and is NOT meant to be run blindly!
# you need to EDIT IT before running! And make sure the destination disk has sufficient free space!


# TODO EDITME before running!
destdir=/mnt/macpro-sgtera2
# Will be mounted on this server / local dir

sshfsmountthis=/Volumes/sgtera2
# destination directory on the remote side
# TODO add a subdir here for different systems

loginid=dave 
# for sshfs

destserver=macpro-static
# hostname or IP

# NOTE this **needs** to be the correct disk!
zfsroot=sdb
# Obtain from /dev/disk/by-id

disktomir="ata-Samsung_Portable_SSD_T5_S49WNV0MC04217F-part3" 
# Obtain from zpool status -v

#  pool: rpool
# state: ONLINE
#  scan: resilvered 3.48G in 00:04:03 with 0 errors on Fri Jun  7 22:16:20 2024
#config:
#        NAME                                                 STATE     READ WRITE CKSUM
#        rpool                                                ONLINE       0     0     0
#          ata-Samsung_Portable_SSD_T5_S49WNV0MC04217F-part3  ONLINE       0     0     0	*** this one
   
# Disk size in GB will be determined auto by script
          
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

install-if-missing sshfs
install-if-missing bc


mkdir -pv $destdir
# if not already mounted
if [ $(df -T |grep sshfs |grep -c $destdir) -eq 0 ]; then
  echo "Mounting $destdir on $destserver"
# TODO change this to samba, nfs, whatever works for you
# TODO ssh-copy-id for passwordless access
  sshfs -o Ciphers=chacha20-poly1305@openssh.com \
    -o ServerAliveInterval=30 \
    -o ServerAliveCountMax=1 \
    $loginid@$destserver:$sshfsmountthis $destdir
fi
# hopefully by adding the serveralives, sshfs will drop the connection if it doesnt hear back (network issues)

if [ $(df -T |grep -c $destdir) -eq 0 ]; then
  failexit 40 "$destdir is not mounted, cannot proceed"
fi
  
cd $destdir 
fdisk -l /dev/$zfsroot >fdisk-l-pve-zfs-bootroot.txt

# (OLD)
# # fdisk -l /dev/nvme0n1 2>/dev/null|head -n 1
#Disk /dev/nvme0n1: 238.47 GiB, 256060514304 bytes, 500118192 sectors
# 1   2             3      4    5
# (OLD)
#bytes=$(fdisk -l /dev/$zfsroot |head -n 1 |awk '{print $5}')
# pi=$(echo "scale=10; 4*a(1)" | bc -l)
#gigs=$(echo "scale=0; ${bytes}/1024/1024/1024" |bc -l)


# fdisk -l /dev/sdb|grep '^/dev/sdb3'
#/dev/sdb3  1050624 88080384 87029761 41.5G Solaris /usr & Apple ZFS
# 1         2       3        4        5

# We dont actually need to allocate the whole disk size, just the partition 3 size
gigs=$(fdisk -l /dev/$zfsroot |grep "^/dev/${zfsroot}3" |awk '{print $5}') # 41.5G

# truncate needs an INTEGER
# echo "41.5G" |numfmt --round=up  --from=iec 
#44560285696
gigactual=$(echo ${gigs} |numfmt --round=up  --from=iec)


# NOTE always starting over with a new one, back it up or move it somewhere if you want to keep previous versions!
mirfile="proxmox-rpool-mirror-${gigs}-zfs-efi.disk"

if [ $(zpool status rpool -v |grep -c $mirfile) -gt 0 ]; then
  failexit 202 "rpool still has $mirfile attached - you need to detach it first before running another backup!!"
fi
  
[ -e $mirfile ] && rm -fv "$destdir/$mirfile"
#truncate -s ${gigs}G $mirfile
truncate -s ${gigactual} $mirfile || failexit 99 "Failed to create sparsefile $mirfile $gigs"
ls -lh $mirfile

echo "$(date) - Backing up the EFI partition" # to a lightly gzipped file (for speed):
time dd if=/dev/${zfsroot}2 bs=1M status=progress |gzip -1 >dd-efi-part2-rpool-mirror-${gigs}-zfs.dd.gz

echo "$(date) - Beginning mirror process"
time zpool attach rpool $disktomir \
 $PWD/$mirfile


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

#echo "At this point, you may want to run a ' zpool scrub ' and a ' zpool clear rpool ' afterward"
sleep 3

echo "$(date) - commencing automatic scrub to verify backup"

zpool scrub rpool

watchresilver;


echo ''
echo "$(date) - Check results of scrub and ^C to abort, or Enter to offline the file-backed mirror"
echo "(Waiting for input)"
read

zpool offline rpool $destdir/$mirfile
sleep 1
zpool status -v rpool |awk 'NF>0'

echo ''
echo "$(date) - At this point you can reboot (or if possible, unmount the backup / sshfs destination)"
echo " and (as long as the target containing the rpool*efi.disk isn't mounted)"
echo " you can detach the efi.disk mirror copy from the pool without issues, the data on the backup file will stay intact."

echo "TODO: # zpool detach rpool $destdir/$mirfile"

exit;


EXPERIMENTAL: In order to update the mirror file occasionally, you might leave the sshfs mounted and simply:

# zpool online rpool /mnt/macpro-sgtera2/proxmox-rpool-mirror-41.5G-zfs-efi.disk

And allow it to resilver. Then bring it offline again. 

# zpool offline rpool /mnt/macpro-sgtera2/proxmox-rpool-mirror-41.5G-zfs-efi.disk

I have NO IDEA how "stable" this would be, but would definitely NOT recommend allowing
the 2nd disk in a zfs rpool mirror to run over an sshfs network mount for
any length of time - beyond what it takes to update the file-based backup.

Unstable behavior could result if you have a network outage / need to bounce a switch.

You can test this in a VM restore - start a GNU ' screen ' session, then disconnect the primary network interface
while the sshfs is mounted and the file-backed mirror is still attached to the rpool.

Now try to dd /dev/random to a file, bs=1M, count=100 and issue a ' sync '
You will start seeing "task blocked for more than X seconds" RIP messages.

ZFS will still think everything is fine, ' zpool status ' still responds, but comms to the mirror disk are hanging.
' df ' will hang. Bash tab-completion may hang. Load average on a single-cpu instance shot up to (15).

Even trying to take the mirror disk offline while comms were down hung up for almost 3 minutes,
but finally completed. Once the dead mirror disk finally went offline from the command, the several
hung commands also finally completed.

Reconnecting the vNIC after 10-15 minutes finally dropped the sshfs mount. (The Samba mounts recovered.)



