#!/bin/bash

# REF: https://forum.proxmox.com/threads/intel-x553-sfp-ixgbe-no-go-on-pve8.135129/#post-626516

echo "WARNING THIS DOES NOT CURRENTLY WORK"
exit;


apt update
apt-get install proxmox-default-headers build-essential dkms gcc make

modinfo ixgbe >/tmp/ixgbe-before.txt

ixver="5.19.9"

cd /usr/local/src
wget --no-clobber https://sourceforge.net/projects/e1000/files/ixgbe%20stable/$ixver/ixgbe-$ixver.tar.gz

tar -xzvf ixgbe-*tar.gz -C /usr/src

echo '
MAKE="BUILD_KERNEL=${kernelver} make -C src/ KERNELDIR=/lib/modules/${kernelver}/build"
CLEAN="make -C src/ clean"
PACKAGE_NAME="ixgbe-dkms"
PACKAGE_VERSION="5.19.9"
BUILT_MODULE_NAME="ixgbe"
BUILT_MODULE_LOCATION=src/
DEST_MODULE_LOCATION="/kernel/drivers/net/ethernet/intel/ixgbe/"
AUTOINSTALL="yes"
' > /usr/src/ixgbe-$ixver/dkms.conf

dkms add ixgbe/$ixver
dkms build ixgbe/$ixver
dkms install ixgbe/$ixver

rmmod ixgbe
cd /usr/src/ixgbe-$ixver/src
#insmod ./ixgbe.ko
modprobe ixgbe

modinfo ixgbe >/tmp/ixgbe-after.txt
