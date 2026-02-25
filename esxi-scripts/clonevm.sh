#!/bin/sh

# NOTE source vm should not have any snapshots!
# 2026.Feb bechteld.adm

# ./getallvms.sh |grep -i astrodef01
#210    astrodef01             [VMHOST02-LocalStorage] astrodef01/astrodef01.vmx   

datastore=/vmfs/volumes/VMHOST02-LocalStorage

# xxx TODO EDITME
vmid=210
origvm=astrodef01 # should match dirname in datastore
newvmname=astrodef02

./getallvms.sh |grep ^$vmid
echo "$(date) - Powering off vm $vmid"
vim-cmd vmsvc/power.off $vmid

mkdir -p $datastore/$newvmname

cp -v $datastore/$origvm/*.vmx $datastore/$newvmname/$newvmname.vmx
sed -i 's/'$origvm'/'$newvmname'/g' $datastore/$newvmname/$newvmname.vmx

# xxx TODO EDITME for all .vmdk
echo "$(date) - Cloning disks"
time vmkfstools -i $datastore/$origvm/astrodef01_2.vmdk \
 -d thin \
 $datastore/$newvmname/astrodef02.vmdk 
echo "$(date) - Done"

vim-cmd solo/registervm $datastore/$newvmname/*.vmx
#vim-cmd vmsvc/power.on $newvmid

