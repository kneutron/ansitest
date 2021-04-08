#!/bin/bash

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

zfs umount -a -f
zpool export -a -f


modprobe -r zfs zunicode zavl icp zcommon znvpair spl
df -h -T |grep zfs

[ $(lsmod |grep -c zfs) -gt 0 ] && failexit 101 "! ZFS module still loaded!"

echo "$(date) - Removing existing ZFS packages"
time apt-get remove --purge -y libzfs2linux zfs-dkms zfsutils-linux spl spl-dkms  libnvpair* libuutil* libzpool*
[ $(dpkg -l |egrep -c 'libzfs2linux|zfs-dkms|zfsutils-linux|spl-dkms|libnvpair|libuutil|libzpool') -gt 0 ] && failexit 199 "! ZFS packages are still installed!"

# call downloaded script, should be in /root/bin or /usr/local/bin // accessible by PATH
ubuntu_zfs_build_install.sh


exit;
