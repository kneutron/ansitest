#!/bin/bash

# Part 1 of 2 scripts - this part *uninstalls* and unmounts all current zfs for code upgrade!
# stops the Samba and Zed daemons, exports all zpools, and uninstalls existing ZFS packages so you start building with a clean slate

#source ~/bin/failexit.mrg
# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

firstrun=1
[ $firstrun -gt 0 ] && apt update

# REF: https://github.com/zfsonlinux/zfs/wiki/Building-ZFS

[ $firstrun -gt 0 ] && time apt install -y build-essential autoconf libtool gawk alien fakeroot \
  zlib1g-dev uuid-dev libattr1-dev libblkid-dev libselinux-dev libudev-dev \
  parted lsscsi ksh libssl-dev libelf-dev linux-headers-$(uname -r)

# NOTE - TO AVOID COMPILE ERRORS, RUN AT LEAST ONCE:

service zed stop
service smbd stop

# NOTE zfs pools go away temporarily here!
zfs umount -a -f
zpool export -a -f


modprobe -r zfs zunicode zavl icp zcommon znvpair spl
df -hT |grep zfs

[ $(lsmod |grep -c zfs) -gt 0 ] && failexit 101 "! ZFS module still loaded!"

echo "$(date) - Removing existing ZFS packages"
time apt-get remove --purge -y libzfs2linux zfs-dkms zfsutils-linux spl spl-dkms  libnvpair* libuutil* libzpool*
time apt-get remove --purge libnvpair3linux libuutil3linux

[ "$1" = "nuke" ] && apt-get remove $(dpkg -l |egrep 'zfs|libnvpair|libuutil|libzpool' |awk '{printf $2" "}')

[ $(dpkg -l |egrep -c 'libzfs.linux|zfs-dkms|zfsutils-linux|spl-dkms|libnvpair|libuutil|libzpool') -gt 0 ] && failexit 199 "! ZFS packages are still installed!"

# call downloaded script, should be in /root/bin or /usr/local/bin // accessible by PATH
~/dnld/ubuntu_zfs_build_install.sh


exit;
