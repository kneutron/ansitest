#!/bin/bash

# 2026.Jan kneutron
# commonly used for PBS VMs
# Doitall - create zfs share as virtiofs with proper attributes, define in pve gui and add to a vm (optional)

# REF: https://forum.proxmox.com/threads/proxmox-8-4-virtiofs-virtiofs-shared-host-folder-for-linux-and-or-windows-guest-vms.167435/
# FIX on host: zfs set xattr=sa zmixed3/pbs-datastore; zfs set acltype=posixacl zmixed3/pbs-datastore

# cre8 a new ZFS dataset with virtiofs options and define it in pve gui
echo "$0 Usage: opt1=(1)compression+(1)sharesmb, (0 == OFF) opt2=zpoolname opt3=datasetname opt4={vmid / Optional}"
echo "Example: $0 10 zpoolname mydatasetname 101	# 1=compression enabled, 0=not samba shared, add virtiofs  zpoolname-mydatasetname  to VMID 101"

source ~/bin/failexit.mrg
logfile=/root/boojum-zfs-newds.log

# TODO editme
#zp=zredpool2; myds=home/vmtmpdir/vmware-virtmachines
zp="$2"; myds="$3"; vmid="$4"
user=dave # will use this for chown later


# defaults
compr=lz4
shrwin=off

# opt1=compression, opt2=sharesmb
case "$1" in
	"10" )
# use defaults
		compr=lz4; shrwin=off
    ;;
	"11" )
		compr=lz4; shrwin=on    
    ;;
	"01" )
		compr=off; shrwin=on
    ;;
	"00" )
		compr=off; shrwin=off
    ;;
	"" )
# no arg passed; print help and exit
	failexit 101 "No arg passed!"
		;;
  * )
    failexit 201 "Invalid arg passed, +$1+ not recognized"
    
    ;;
esac      

# trace on
(set -x
zfs create -o \
  atime=off -o compression=$compr -o xattr=sa -o acltype=posixacl -o sharesmb=$shrwin -o recordsize=1024k \
  $zp/$myds || failexit 99 "! Failed to create ZFS $zp/$myds"
) 

echo "`date` + $zp/$myds + compr=$compr:shr=$shrwin + owner:$user" >> $logfile

# NOTE does not take into account alt.mountpoints like /home!
chown -v $user /$zp/$myds; ls -al /$zp/$myds

echo "o Defining virtiofs in pve gui with API call"
pvesh create /cluster/mapping/dir --id $zp-$myds --map node=$(hostname -s),path=/$zp/$myds

# if vmid was passed, also define it in vm
[ "$vmid" = "" ] || qm set $vmid --virtiofs0 dirid=$zp-$myds,cache=always,direct-io=1,expose-acl=1,expose-xattr=1
# pct set 100 --mp0 /mnt/host-data,/mnt/container-data,rw   	# UNTESTED

echo '====='
df -hT |head -n 1
df -hT |grep $myds
echo '====='
echo "+ NOTE: Add the following line to fstab in VMID $vmid /etc/fstab:"
echo "$zp-$myds  /mnt/$zp-$myds  virtiofs  rw,nofail,noatime  0 0 "

exit;
