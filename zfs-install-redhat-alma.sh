#!/bin/bash

# tested on alma linux 8.3 // centos replacement

# xxx EDITME
zver="2.0.4"

yum install -y epel-release
#yum install -y https://zfsonlinux.org/epel/zfs-release.el8_3.noarch.rpm
#gpg --import --import-options show-only /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux

# REF: https://openzfs.github.io/openzfs-docs/Developer%20Resources/Custom%20Packages.html

yum install -y kernel-devel kernel-headers wget curl
yum groupinstall -y "Development Tools"

dnf install -y gcc make autoconf automake libtool rpm-build kernel-rpm-macros dkms libtirpc-devel \
 libblkid-devel libuuid-devel libudev-devel openssl-devel zlib-devel libaio-devel libattr-devel \
 elfutils-libelf-devel kernel-devel-$(uname -r) python3 python3-devel python3-setuptools python3-cffi libffi-devel
 
cd /usr/local/src
wget --no-clobber https://github.com/openzfs/zfs/releases/download/zfs-$zver/zfs-$zver.tar.gz
tar xzf zfs-$zver.tar.gz 

cd zfs-$zver

# REF: https://openzfs.github.io/openzfs-docs/Developer%20Resources/Custom%20Packages.html
time ./configure
time make -s -j4 rpm-utils rpm-dkms && \
  mv -v *.src.rpm ..
  
echo "$(date) + Installing ZFS RPMs" 
time yum localinstall -y *.$(uname -p).rpm *.noarch.rpm

modprobe zfs
dmesg |grep ZFS

zpool version && \
 echo "o Now you should be able to issue ' zpool import '"

date

exit;


REF:
https://zfsonlinux.topicbox.com/groups/zfs-discuss/T5e4d6ecb1044b00e
