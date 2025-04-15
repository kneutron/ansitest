#!/bin/bash

# 2025.Apr kneutron
# REF: https://www.reddit.com/r/Proxmox/comments/1jzpttz/script_to_monitor_and_give_better_insight_with/

cd /etc/pve/qemu-server

echo "$(date) - CPU cores on this node $(hostname) = $(cat /proc/cpuinfo |grep -c ^processor)"
dmesg |egrep 'CPU topo: Allowing|smp: Brought up'
echo '====='
echo "$(date) - CPU Cores allocated by running VMs:"
grep ^cores $(qm list |grep running |awk '{print $1".conf"}') |awk -F' ' '{sum+=$2;} END{print sum;}'
echo '====='
cd /etc/pve/lxc/
echo "$(date) - CPU Cores allocated by running LXCs:"
grep ^cores $(pct list |grep running |awk '{print $1".conf"}') |awk -F' ' '{sum+=$2;} END{print sum;}'
echo '====='
uptime
free -h
echo '====='
pvesm status

exit;

qm list |grep running
      100 pbs3-beelink         running    6144              16.00 3629
      108 win10-boinc-from-beelink-vmwr running    6144              50.00 4297
      123 suse-iscsi-bkp-4-macmini2 running    4096  40.00 5648
      126 truenas-scale-test   running    8192       16.00 6074

grep ^cores /etc/pve/qemu-server/100.conf
cores: 4
      
grep ^cores 100.conf 108.conf 123.conf 126.conf |awk -F' ' '{sum+=$2;} END{print sum;}'
12
