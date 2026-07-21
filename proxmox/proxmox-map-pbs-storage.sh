#!/bin/bash

# xxx TODO EDITME for your environment! Will not run as-is

# 2026.Jul kneutron

# pvesm add pbs <STORAGE_ID> --server <PBS_IP_OR_HOSTNAME> --datastore <DATASTORE_NAME_ON_PBS>
# macmini2 pbsvm

# Nodes, can be unclustered
# Server needs to be pingable / resolve in DNS
addqotom=1
addmacmini2=0
addbeelink=1
addmac3=1

# Use information from pbs GUI for fingerprint, and you need to know the root password or have another user with proper access
if [ $addqotom -gt 0 ]; then
 pvesm add pbs pbsvm-on-qotom-4-beelink-datastore-ztosh10 --server qotom-pbs-bkp-for-beelink-vms-25g --datastore virtiofs-ztoshtera10 \
  --username root@pam --password PASSWDHERE \
  --fingerprint 21:3e:df:27:31:3d:42:e8:8c:c7:c4:cc:ce:6d:8a:d2:08:d8:53:db:9e:91:f2:bd:fa:a5:9a:32:7f

 pvesm add pbs pbsvm-on-qotom-DS-ztosh10-NS-beelink --server qotom-pbs-bkp-for-beelink-vms-25g --datastore virtiofs-ztoshtera10 --namespace beelink \
  --username root@pam --password PASSWDHERE \
  --fingerprint 21:3e:df:27:31:3d:42:e8:8c:c7:c4:cc:ce:6d:8a:d2:08:d8:53:db:9e:91:f2:bd:fa:a5:9a:32:7f
 pvesm add pbs pbsvm-on-qotom-DS-ztosh10-NS-fryserver --server qotom-pbs-bkp-for-beelink-vms-25g --datastore virtiofs-ztoshtera10 --namespace fryserver \
  --username root@pam --password PASSWDHERE \
  --fingerprint 21:3e:df:27:31:3d:42:e8:8c:c7:c4:cc:ce:6d:8a:d2:08:d8:53:db:9e:91:f2:bd:fa:a5:9a:32:7f
 pvesm add pbs pbsvm-on-qotom-DS-ztosh10-NS-macmini3 --server qotom-pbs-bkp-for-beelink-vms-25g --datastore virtiofs-ztoshtera10 --namespace macmini3 \
  --username root@pam --password PASSWDHERE \
  --fingerprint 21:3e:df:27:31:3d:42:e8:8c:c7:c4:cc:ce:6d:8a:d2:08:d8:53:db:9e:91:f2:bd:fa:a5:9a:32:7f

# these are just for dellap e6540s
# pvesm add pbs pbsvm-on-qotom-4-beelink-datastore-ds-sgIWpro --server qotom-pbs-bkp-for-beelink-vms-25g --datastore ds-sgIWpro \
#  --username root@pam --password 12345 \
#  --fingerprint 21:3e:df:27:31:3d:42:e8:8c:c7:c4:cc:ce:6d:8a:d2:08:d8:53:db:9e:91:f2:bd:fa:a5:9a:32:7f
fi

if [ $addmacmini2 -gt 0 ]; then
# pvesm add pbs pbs-macmini2-datastore-ext4 --server pbsvm-macmini2.lan --datastore pbs-datastore-ext4 \
#  --username root@pam --password PASSWDHERE \
#  --fingerprint 3a:95:b4:1e:c3:e7:f5:e1:a7:6d:4a:78:7f:c3:70:4f:68:86:7e:e9:f5:e8:27:cd:19:6b:ca:47:bb

 pvesm add dir macmini2-sgtera2-proxmox-multi --path /mnt/macmini2-sgtera2

 pvesm add dir macmini2-cifs-sgnas3tb --path /mnt/macmini2-sgnas3tb-shared
fi

if [ $addbeelink -gt 0 ]; then
# pvesm add pbs pbsvm-beelink-datastore-virtiofs-zseatera4  --server pbsvm-beelink.lan --datastore virtiofs-zseatera4  \
 pvesm add pbs pbsvm-beelink-datastore-virtiofs-zseatera4  --server pbs-qotom.local --datastore virtiofs-zseatera4  \
  --username root@pam --password PASSWDHERE \
  --fingerprint db:ff:0b:e2:a9:c4:bf:f2:f9:a2:ee:0c:2b:5f:cc:ec:38:a1:62:4e:8a:05:93:96:61:b3:f8:9a:c3
 
# pvesm add dir macmini2-sgtera2-proxmox-multi --path /mnt/macmini2-sgtera2
fi

if [ $addmac3 -gt 0 ]; then
 pvesm add pbs pbs-mac3-virtiofs-zmixed3 --server pbsvm-on-macmini3.local --datastore virtiofs-zmixed3 \
  --username root@pam --password PASSWDHERE \
  --fingerprint 38:28:e5:e5:ac:a5:aa:16:74:72:df:dc:82:98:e0:82:2b:c0:99:ac:15:50:24:01:c0:91:50:76:12

 pvesm add pbs pbs-mac3-virtiofs-zmixed3-NS-beelink --server pbsvm-on-macmini3.local --datastore virtiofs-zmixed3 --namespace=beelink \
  --username root@pam --password PASSWDHERE \
  --fingerprint 38:28:e5:e5:ac:a5:aa:16:74:72:df:dc:82:98:e0:82:2b:c0:99:ac:15:50:24:01:c0:91:50:76:12

 pvesm add pbs pbs-mac3-virtiofs-ztosh16-NS-qotom --server pbsvm-on-macmini3.local --datastore virtiofs-ztosh16 --namespace=qotom \
  --username root@pam --password PASSWDHERE \
  --fingerprint 38:28:e5:e5:ac:a5:aa:16:74:72:df:dc:82:98:e0:82:2b:c0:99:ac:15:50:24:01:c0:91:50:76:12
 
# pvesm add dir macmini2-sgtera2-proxmox-multi --path /mnt/macmini2-sgtera2
fi


pvesm status

exit;

# REF: https://pve.proxmox.com/wiki/Storage#_using_the_command_line_interface
# pvesm set storid --disable 1 / 0

# sep, not work -- use all1cmd
#pvesm set pbs-macmini2-datastore-ext4 --username root@pam --password PASSWDHERE
#pvesm set pbs-macmini2-datastore-ext4 --fingerprint 3a:95:b4:1e:c3:e7:f5:e1:a7:6d:4a:78:7f:c3:70:4f:68:86:7e:e9:f5:e8:27:cd:19:6b:ca:47:bb

#pvesm add pbs pbs-backups --server 192.168.1.100 --datastore my_datastore
#pvesm set pbs-backups --username admin@pbs --password mysecretpassword
#pvesm set pbs-backups --fingerprint 64:d3:ff:3a:50:38:53:5a:9b:f7:50:ab:fe:cd:ef:12:34:56:78:90:ab:cd:ef:12:34:56:78:90
