#!/bin/bash

# REF: https://blog.bianxi.com/2022/06/02/convert-proxmox-cluster-node-to-standalone-local-mode/

echo "WARNING - THIS WILL REMOVE THIS NODE FROM CLUSTER AND PUT IT BACK IN STANDALONE MODE!"
echo "Press Enter if youre REALLY SURE or ^C"
read

systemctl stop pve-cluster
systemctl stop corosync

pmxcfs -l

rm /etc/pve/corosync.conf
rm -r /etc/corosync/*

killall pmxcfs
systemctl start pve-cluster

#pvecm delnode oldnode

pvecm expected 1

rm /var/lib/corosync/*

echo '====='
echo "TODO Remove /etc/pve/nodes/<node_name> from other nodes."

echo "TODO Remove ssh key from /etc/pve/priv/authorized_keys file."
