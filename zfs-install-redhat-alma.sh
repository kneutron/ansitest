#!/bin/bash

# tested on alma linux 8.3 // centos replacement

# xxx EDITME
zver="2.0.4"

if [ "$1" = "fixit" ]; then
  echo "$(date) recompiling ZFS module for new/current kernel"
  cd /usr/local/src/zfs-$zver
  time rpm --reinstall zfs-dkms*.rpm && modprobe zfs
  dmesg |grep ZFS
  zpool version
  exit;
fi

# failexit.mrg
function failexit () {
  echo '! Something failed! Code: '"$1 $2" # code # (and optional description)
  exit $1
}

if [ "$1" = "upgrade" ]; then
  systemctl stop zed
  systemctl stop smb
# TODO also do nfs if you use that with zfs

  echo "! Unmounting all ZFS datasets and exporting pools..."
  zfs umount -a -f
  zpool export -a -f
  [ $(df -hT |grep -c zfs) -gt 0 ] && failexit 111 "ZFS pool/dataset found still mounted, lsof may come in handy"  
# handy REF if you need fuser: https://vander.host/knowledgebase/operating-systems/how-to-deal-with-fuser-command-not-found-on-centos/
# yum install -y psmisc

  echo "o Unloading ZFS modules..."
  modprobe -rv zfs zunicode zzstd zlua zcommon znvpair zavl icp spl
  if [ $(lsmod |grep -c zfs) -gt 0 ]; then
    echo "NOTE if you get error here, ' lsof |grep zfs ' and kill the process holding it, then retry"
    failexit 302 "ZFS module(s) are still loaded!"
  fi
  
  yum remove -y zfs zfs-dkms* libnvpair* libuutil* libzfs* libzpool* python3-pyzfs zfs-debug* zfs-dracut zfs-test* \
    --setopt=clean_requirements_on_remove=false \
  || failexit 999 "Failed to uninstall ZFS RPMs"
# REF: https://access.redhat.com/solutions/5577491
# otherwise it removes ~128 packages and is a big PITA :b
fi

echo "o Installing prereq pkgs..."
yum install -y epel-release
#yum install -y https://zfsonlinux.org/epel/zfs-release.el8_3.noarch.rpm
#gpg --import --import-options show-only /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux

# REF: https://openzfs.github.io/openzfs-docs/Developer%20Resources/Custom%20Packages.html

yum install -y kernel-devel kernel-headers wget curl lsof
yum groupinstall -y "Development Tools"

dnf install -y gcc make autoconf automake libtool rpm-build kernel-rpm-macros dkms libtirpc-devel \
 libblkid-devel libuuid-devel libudev-devel openssl-devel zlib-devel libaio-devel libattr-devel \
 elfutils-libelf-devel kernel-devel-$(uname -r) python3 python3-devel python3-setuptools python3-cffi libffi-devel
 
cd /usr/local/src
echo "o Downloading ZFS source code"
wget --no-clobber https://github.com/openzfs/zfs/releases/download/zfs-$zver/zfs-$zver.tar.gz
tar xzf zfs-$zver.tar.gz 

cd zfs-$zver

# REF: https://openzfs.github.io/openzfs-docs/Developer%20Resources/Custom%20Packages.html
time ./configure
time make -s -j4 rpm-utils rpm-dkms && \
  mv -v *.src.rpm ..
  
echo "$(date) + Installing ZFS RPMs" 
time yum localinstall -y *.$(uname -p).rpm *.noarch.rpm \
  || failexit 666 "Failed to install ZFS packages"

modprobe zfs
dmesg |grep ZFS

zpool version && \
 echo "o Now you should be able to issue ' zpool import '"

date

exit;

# Download and install zfs from source code, load module
# 2021 Dave Bechtel

REF:
https://zfsonlinux.topicbox.com/groups/zfs-discuss/T5e4d6ecb1044b00e
