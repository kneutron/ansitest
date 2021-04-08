#!/bin/bash

# =LLC= © (C)opyright 2016 Boojum Consulting LLC / Dave Bechtel, All rights reserved.
## NOTICE: Only Boojum Consulting LLC personnel may use or redistribute this code,
## Unless given explicit permission by the author - see http://www.boojumconsultingsa.com
#

source ~/bin/failexit.mrg

firstrun=1
[ $firstrun -gt 0 ] && apt update

# REF: https://github.com/zfsonlinux/zfs/wiki/Building-ZFS

[ $firstrun -gt 0 ] && time apt -y install build-essential autoconf libtool gawk alien fakeroot \
  zlib1g-dev uuid-dev libattr1-dev libblkid-dev libselinux-dev libudev-dev \
  parted lsscsi ksh libssl-dev libelf-dev linux-headers-$(uname -r)

# NOTE - TO AVOID COMPILE ERRORS, RUN AT LEAST ONCE:

# xxx as of 2017.0903 REF: https://github.com/zfsonlinux/zfs/wiki/Building-ZFS
#apt-get -y install git build-essential autoconf automake libtool gawk alien fakeroot linux-headers-$(uname -r) \
# zlib1g-dev uuid-dev libattr1-dev libblkid-dev libselinux-dev libudev-dev libdevmapper-dev \
# parted lsscsi ksh
#mkdir -pv /root/dnld/zfs/zfs #/root/dnld/zfs/spl
#cd /root/dnld/zfs

service zed stop
service smbd stop

zfs umount -a -f
zpool export -a -f


modprobe -r zfs zunicode zavl icp zcommon znvpair spl
df -h -T |grep zfs

[ `lsmod |grep -c zfs` -gt 0 ] && failexit 101 "! ZFS module still loaded!"

echo "`date` - Removing existing ZFS packages"
time apt-get remove --purge -y libzfs2linux zfs-dkms zfsutils-linux spl spl-dkms  libnvpair* libuutil* libzpool*
[ `dpkg -l |egrep -c 'libzfs2linux|zfs-dkms|zfsutils-linux|spl-dkms|libnvpair|libuutil|libzpool'` -gt 0 ] && failexit 199 "! ZFS packages are still installed!"

# call downloaded script
~/dnld/ubuntu_zfs_build_install.sh


exit;


zver="0.8.0"
cd /usr/local/src/zfs-"$zver" || failexit 105 " Failed to change dir to src"

#(set -x
#time git clone https://github.com/zfsonlinux/spl.git
#time git clone https://github.com/zfsonlinux/zfs.git
#)

# TODO - only need to do once??
#(set -x
# cd /root/dnld/zfs/spl
# time ./autogen.sh
# time ./configure --prefix=/usr
# time make -s -j 12 && make -s install
#) 2>/root/zfs-compile.log.txt

echo "`date` - Starting compile"
(set -x
# cd /root/dnld/zfs/zfs
# time ./autogen.sh
# time ./configure --with-spl=/root/dnld/zfs/spl --prefix=/usr
# time make -s -j 12 && make -s install
#git checkout master
time sh autogen.sh
time ./configure
time make -s -j$(nproc)
) 2>>/root/zfs-compile.log.txt

date
modprobe zfs
zpool status -v

echo "PK to make deb pkg (optional)"
time make deb
date

exit;

2019.0525 Testing on atomicpi 2GB RAM

DONE 2017.0903 on p2700dual-antix
real    17m30.609s


OLD 2017.0903
#apt-get install git autoconf libtool zlib1g-dev uuid-dev linux-headers-$(uname -r) \
#  automake libblkid-dev libattr1-dev
