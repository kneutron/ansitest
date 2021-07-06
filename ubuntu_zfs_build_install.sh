#!/bin/bash

# Download ZFS on Linux from git, build and install.

# This script is part 2 of 2 - run 'debian-compile-zfs--boojum.sh' first to completely uninstall existing ZFS and unmount everything 1st
# FYI look for EDITME and change the point release

# Original script / Author attribution; mods by Dave Bechtel:
# REF: https://gitlab.com/snippets/1861014
##Tested on Ubuntu 18.04LTS with ZFS on Linux 0.8.0
# Tested on Ubuntu 20.04LTS with ZOL 0.8.6 and 2.0.4

# ZFS on Linux release page: https://github.com/zfsonlinux/zfs/releases

#set -e
set -x

##define variables
# xxx TODO EDITME
firstrun=1
pointrel="2.1.0"
# pointrel="2.0.5"
# pointrel="0.8.6" # for older installs

# xxx TODO EDITME - this is for chown later if creating encrypted pool
user=dave

poolname=ztestpoolencr
poolmount=/mnt/"$poolname"/

# file-based encrypted pool, change location if needed
DISKID=/mnt/imacdual/zdisk1

zfskeyloc=/home/"$user"/zfskey


##Check for root priviliges
if [ "$(id -u)" -ne 0 ]; then
   echo "Please run as root."
   exit 1
fi


# otherwise it downloads in CURDIR!
cd /usr/local/src

##declare functions
compile_zfs(){
	##https://github.com/zfsonlinux/zfs/wiki/Custom-Packages#debian-and-ubuntu
	installcompilepackages(){
		apt-get install -y build-essential autoconf libtool gawk alien fakeroot gdebi wget
		apt-get install -y zlib1g-dev uuid-dev libattr1-dev libblkid-dev libselinux-dev libudev-dev libaio-dev
		apt-get install -y parted lsscsi ksh libssl-dev libelf-dev
		apt-get install -y linux-headers-$(uname -r)
		apt-get install -y python3 python3-dev python3-setuptools python3-cffi python3-distutils
	}
	
	compile(){
	
		pointrelease(){
#			wget https://github.com/zfsonlinux/zfs/releases/download/zfs-0.8.0-rc3/zfs-0.8.0-rc3.tar.gz
			wget -nc https://github.com/zfsonlinux/zfs/releases/download/zfs-$pointrel/zfs-$pointrel.tar.gz
			tar -xzf zfs-$pointrel.tar.gz
#			mv zfs-0.8.0{,-rc3}
			cd zfs-$pointrel #0.8.0-rc3
			./configure --prefix=/usr || exit $?
			make -s -j $(nproc) && make deb-utils deb-dkms && echo "ZFS packages are ready" || echo "ZFS compilation error"
		}
		
		master(){
			wget https://github.com/zfsonlinux/zfs/releases/download/zfs-0.8.0/zfs-0.8.0.tar.gz
			tar -xzf zfs-0.8.0.tar.gz
			cd zfs-0.8.0
			./configure --prefix=/usr
			make -s -j$(nproc) && make deb-utils deb-dkms && echo "ZFS packages are ready" || echo "ZFS compilation error"
		}

# run this:
		pointrelease
#		master
	}

installcompilepackages
compile	

}
	
install_zfs(){
	##need dkms package to install zfs-dkms
	apt-get -y install dkms
	for DEB in *.deb; do gdebi --non-interactive $DEB; done

	services(){
		modprobe zfs
		systemctl enable zfs-import-cache
		systemctl enable zfs-import-scan
		systemctl enable zfs-import.target
		systemctl enable zfs-mount
		systemctl enable zfs-share
		systemctl enable zfs-zed
		systemctl enable zfs.target
		
		cp ./etc/init.d/zfs-functions /etc/zfs
		update-initramfs -k all -u
	}
	services
	
	##check zfs installed
	dmesg |grep ZFS
#	lsinitramfs /initrd.img | grep zfs

}

createdatapool(){
	##create pool mount point
	if [ -d "$poolmount" ]; then
		echo "Pool mount point exists."
	else
		mkdir "$poolmount"
		chown $user:$user "$poolmount"
		echo "Pool mount point created."
	fi
	echo Pool mount location is "$poolmount"
	
	#generate 32 byte passkey
	dd if=/dev/urandom of="$zfskeyloc" bs=1 count=32
	
	##Get Disk UUID
#	ls -la /dev/disk/by-id
#	echo "Enter Disk ID (must match exactly):"
#	read DISKID
	#DISKID=<enter override here>
	echo "Disk ID set to $DISKID"

	##create pool
	##for description of options see section 2.4b:
	##https://github.com/zfsonlinux/zfs/wiki/Debian-Buster-Encrypted-Root-on-ZFS
	##Note options with -O are file-system-properties. options with -o aren't. need to use upper and lowercase correctly.
	##use create -n for dry-run
	zpool create -O mountpoint="$poolmount"\
		-O encryption=aes-256-gcm \
		-O keyformat=raw \
		-O keylocation=file://"$zfskeyloc" \
		-O compression=lz4 \
		-O acltype=posixacl \
		-O normalization=formD \
		-O relatime=on \
		-O xattr=sa \
		-o ashift=12 \
		$poolname $DISKID
#		$poolname /dev/disk/by-id/"$DISKID"
		
	##set mountpoint permissions
	chown -R $user:$user "$poolmount"
	
	##bug in 0.8.0. zfs-mount.service mount command should have -l to load keyfile and automount pool at boot.
	##ExecStart line in /usr/lib/systemd/system/zfs-mount.service should be: "ExecStart=/sbin/zfs mount -l -a" 
	##https://github.com/zfsonlinux/zfs/issues/8750
	
	zpool status -v
	zfs list
	
}

##call functions
##--------		
if [ "$firstrun" -gt 0 ]; then
  apt update
  compile_zfs
  install_zfs
fi

#createdatapool
